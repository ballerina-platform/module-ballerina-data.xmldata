package io.ballerina.lib.data.xmldata.utils;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import org.ballerinalang.langlib.map.ToArray;
import org.ballerinalang.langlib.xml.Concat;
import org.ballerinalang.langlib.xml.CreateElement;
import org.ballerinalang.langlib.xml.CreateText;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class ToXmlUtils {
    private static final BString XMLNS_NAMESPACE_URI = StringUtils.fromString("http://www.w3.org/2000/xmlns/");
    private static final BString ATTRIBUTE_PREFIX = StringUtils.fromString("attribute_");
    private static final BString XMLNS = StringUtils.fromString("xmlns");

    public static BXml fromModifiedRecordToXml(Object jsonValue, BMap<BString, Object> options, BTypedesc typed) {
        Type type = typed.getDescribingType();
        Type referredType = TypeUtils.getReferredType(type);
        Object rootTag = options.get(StringUtils.fromString("rootTag"));
        BMap<BString, BString> allNamespaces = getEmptyStringMap();

        if (!isSingleNode(jsonValue)) {
            addNamespaces(allNamespaces, getNamespacesMap(jsonValue, options, getEmptyStringMap()));
            return getElement(rootTag == null ? StringUtils.fromString("root")
                            : StringUtils.fromString(rootTag.toString()),
                    traverseNode(jsonValue, allNamespaces, getEmptyStringMap(), options,
                            null, TypeUtils.getReferredType(type)),
                    allNamespaces, options, getAttributesMap(jsonValue, options, allNamespaces, getEmptyStringMap()));
        }

        try {
            BMap<BString, Object> jMap = (BMap<BString, Object>) ValueUtils.convert(jsonValue,
                    TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));
            if (jMap.isEmpty()) {
                return ValueCreator.createXmlValue("");
            }

            BString key = jMap.getKeys()[0];
            HashMap<String, String> elementNamesMap = DataUtils.getElementNameMap(referredType);
            ArrayList<String> modelGroupRelatedFieldNames =
                    getModelGroupRelatedFieldNames(referredType, elementNamesMap);
            String localJsonKeyPart = key.getValue().contains(":")
                    ? key.getValue().substring(key.getValue().indexOf(":") + 1) : key.getValue();

            String recordKey = elementNamesMap.getOrDefault(localJsonKeyPart, localJsonKeyPart);
            boolean isNotContainXsdModelGroup = !modelGroupRelatedFieldNames.contains(recordKey);

            Object value = ToArray.toArray(jMap).getValues()[0];
            addNamespaces(allNamespaces, getNamespacesMap(value, options,
                    getEmptyStringMap()));

            if (value instanceof BArray) {
                return getElement(rootTag == null ? StringUtils.fromString("root")
                                : StringUtils.fromString(rootTag.toString()),
                        traverseNode(value, allNamespaces, getEmptyStringMap(), options, jMap.getKeys()[0],
                                getChildElementType(TypeUtils.getReferredType(type), key.getValue())),
                            allNamespaces, options, getAttributesMap(value, options, allNamespaces,
                                getEmptyStringMap()));
            }

            if (key.equals(options.get(StringUtils.fromString("textFieldName")))) {
                return CreateText.createText(StringUtils.fromString(value.toString()));
            }
            BXml output = getElement(jMap.getKeys()[0],
                    traverseNode(value, allNamespaces, getEmptyStringMap(),
                            options, null, getChildElementType(TypeUtils.getReferredType(type), recordKey)),
                    allNamespaces, options, getAttributesMap(value, options, allNamespaces, getEmptyStringMap()));
            if (!isNotContainXsdModelGroup) {
                output = output.children();
            }
            if (rootTag != null) {
                return CreateElement.createElement(StringUtils.fromString(rootTag.toString()),
                        getEmptyStringMap(), output);
            }
            return output;
        } catch (BError e) {
            return jsonValue == null ? ValueCreator.createXmlValue("")
                    : CreateText.createText(StringUtils.fromString(jsonValue.toString()));
        }
    }

    private static BMap<BString, BString> getEmptyStringMap() {
        return (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue());
    }

    public static BXml convertMapXml(BMap<BString, Object> mapValue) {
        BXml xNode = ValueCreator.createXmlValue("");
        for (Map.Entry<BString, Object> entry : mapValue.entrySet()) {
            BString key = entry.getKey();
            Object value = entry.getValue();
            if (value instanceof BArray arrayNode) {
                for (Object i : arrayNode.getValues()) {
                    if (i == null) {
                        continue;
                    }
                    xNode = Concat.concat(xNode, CreateElement.createElement(key, getEmptyStringMap(), (BXml) i));
                }
            } else {
                xNode = Concat.concat(xNode, CreateElement.createElement(key, getEmptyStringMap(), (BXml) value));
            }
        }
        return CreateElement.createElement(StringUtils.fromString("root"), getEmptyStringMap(), xNode);
    }

    public static BXml traverseNode(Object jNode, BMap<BString, BString> allNamespaces,
                    BMap<BString, BString> parentNamespaces, BMap<BString, Object> options, Object keyObj, Type type) {
        return traverseNode(jNode, allNamespaces, parentNamespaces, options, keyObj, type, false);
    }

    public static BXml traverseNode(Object jNode, BMap<BString, BString> allNamespaces,
                    BMap<BString, BString> parentNamespaces, BMap<BString, Object> options,
                    Object keyObj, Type type, boolean isParentSequence) {
        BMap<BString, BString> namespacesOfElem;
        BXml xNode = ValueCreator.createXmlValue("");
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        Type referredType = TypeUtils.getReferredType(type);
        HashMap<String, String> elementNamesMap = DataUtils.getElementNameMap(referredType);
        ArrayList<String> modelGroupRelatedFieldNames = getModelGroupRelatedFieldNames(referredType, elementNamesMap);
        ArrayList<String> sequenceFieldNames = getSequenceFieldNames(referredType, elementNamesMap);

        BXml childElement;

        if (jNode instanceof BMap jMap) {
            BMap<BString, Object> mapNode = (BMap<BString, Object>) jMap;

            BString[] orderedRecordKeysIfXsdSequencePresent = DataUtils
                    .getOrderedRecordKeysIfXsdSequencePresent(mapNode,
                            DataUtils.getXsdSequencePriorityOrder(referredType, isParentSequence));
            for (Map.Entry<BString, Object> entry : mapNode.entrySet()) {
                BString k = entry.getKey();
                Object value = entry.getValue();
                String jsonKey = k.getValue().trim();
                String localJsonKeyPart = jsonKey.contains(":")
                        ? jsonKey.substring(jsonKey.indexOf(":") + 1) : jsonKey;
                String recordKey = elementNamesMap.getOrDefault(localJsonKeyPart, localJsonKeyPart);
                boolean isNotContainXsdModelGroup = !modelGroupRelatedFieldNames.contains(recordKey);

                if (jsonKey.startsWith(attributePrefix)) {
                    continue;
                }

                if (jsonKey.equals(options.get(Constants.TEXT_FIELD_NAME).toString())) {
                    xNode = Concat.concat(xNode, CreateText.createText(StringUtils.fromString(value.toString())));
                } else {
                    namespacesOfElem = getNamespacesMap(value, options, parentNamespaces);
                    addNamespaces(allNamespaces, namespacesOfElem);

                    if (value instanceof BArray) {
                        childElement = traverseNode(value,
                                allNamespaces, namespacesOfElem, options, k,
                                getChildElementType(referredType, recordKey));
                        xNode = Concat.concat(xNode, childElement);
//                        xNode = Concat.concat(xNode, isNotContainXsdModelGroup
//                                ? childElement : childElement.children());
                    } else {
                        childElement = getElement(k,
                                traverseNode(value, allNamespaces, namespacesOfElem, options, null,
                                getChildElementType(referredType, recordKey)), allNamespaces, options,
                                getAttributesMap(value, options, allNamespaces, parentNamespaces));
                        xNode = Concat.concat(xNode, isNotContainXsdModelGroup
                                ? childElement : childElement.children());
                    }
                }
            }
        } else if (jNode instanceof BArray arrayNode) {
            for (Object i : arrayNode.getValues()) {
                if (i == null) {
                    continue;
                }
                String arrayEntryTagKey = "";
                if (keyObj instanceof BString key) {
                    arrayEntryTagKey = key.getValue();
                } else if (!options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    arrayEntryTagKey = options.get(Constants.ARRAY_ENTRY_TAG).toString();
                }

                boolean isNotContainXsdModelGroup = !modelGroupRelatedFieldNames.contains(
                        arrayEntryTagKey.contains(":") ?
                                arrayEntryTagKey.substring(arrayEntryTagKey.indexOf(":") + 1)
                                : arrayEntryTagKey);

                namespacesOfElem = getNamespacesMap(i, options, parentNamespaces);
                addNamespaces(allNamespaces, namespacesOfElem);
                if (options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    childElement = getElement(StringUtils.fromString(arrayEntryTagKey),
                            traverseNode(i, allNamespaces, namespacesOfElem, options, keyObj, referredType),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces));
                    xNode = Concat.concat(xNode, isNotContainXsdModelGroup ? childElement : childElement.children());
                } else {
                    childElement = getElement(StringUtils.fromString(arrayEntryTagKey),
                            traverseNode(i, allNamespaces, namespacesOfElem, options, null, referredType),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces));
                    xNode = Concat.concat(xNode, isNotContainXsdModelGroup ? childElement : childElement.children());
                }
            }
        } else {
            xNode = CreateText.createText(StringUtils.fromString(StringUtils.getStringValue(jNode)));
        }
        return xNode;
    }

    private static ArrayList<String> getModelGroupRelatedFieldNames(Type expType,
                                                                    HashMap<String, String> elementNamesMap) {
        Type referedType = TypeUtils.getReferredType(expType);
        if (referedType instanceof RecordType recordType) {
            return DataUtils.getFieldNamesWithModelGroupAnnotations(recordType, elementNamesMap);
        }
        return new ArrayList<>();
    }

    private static ArrayList<String> getSequenceFieldNames(Type expType,
                                                                    HashMap<String, String> elementNamesMap) {
        Type referedType = TypeUtils.getReferredType(expType);
        if (referedType instanceof RecordType recordType) {
            return DataUtils.getFieldNamesWithSequenceAnnotations(recordType, elementNamesMap);
        }
        return new ArrayList<>();
    }


    private static Type getChildElementType(Type type, String recordKey) {

        try {
            if (type instanceof ArrayType arrayType) {
                return TypeUtils.getReferredType(arrayType.getElementType());
            }

            if (type instanceof RecordType recordType) {
                Map<String, Field> fields = recordType.getFields();
                if (fields.containsKey(recordKey)) {
                    return fields.get(recordKey).getFieldType();
                }
                Optional<String> fieldName = getFieldFromRecordNameAnnotation(fields, recordKey);

                if (!(fieldName.isEmpty()) && fields.containsKey(fieldName.get())) {
                    return fields.get(fieldName.get()).getFieldType();
                } else {
                    assert false;
                    throw DiagnosticLog.createXmlError("Invalid xml provided");
                }
            }

            return type;
        } catch (Exception e) {
            int a = 1;
            throw e;
        }
    }

    private static Optional<String> getFieldFromRecordNameAnnotation(Map<String, Field> fields, String recordKey) {
        for (Field field: fields.values()) {
            Type fieldType = TypeUtils.getReferredType(field.getFieldType());
            if (fieldType instanceof RecordType recordType) {
                for (Map.Entry<BString, Object> annotation: recordType.getAnnotations().entrySet()) {
                    if (DataUtils.isNameAnnotationKey(annotation.getKey().getValue())) {
                        String name = ((BMap<BString, Object>) annotation.getValue()).get(Constants.VALUE).toString();
                        if (name.equals(recordKey)) {
                            return Optional.of(field.getFieldName());
                        }
                    }
                }
            }
        }
        return Optional.empty();
    }

    public static boolean isSingleNode(Object node) {
        if (node instanceof BArray arrayNode) {
            // TODO: Convert this into a anydata
            if (arrayNode.getElementType().getTag() == TypeTags.JSON_TAG) {
                return false;
            }
        }

        try {
            Object convertedValue = ValueUtils
                    .convert(node, TypeCreator.createMapType(PredefinedTypes.TYPE_ANYDATA));
            if (convertedValue instanceof BMap mapNode) {
                return mapNode.size() <= 1;
            }
        } catch (BError e) {
            return true;
        }
        return true;
    }

    public static BXml getElement(BString name, BXml children, BMap<BString, BString> namespaces,
                                  BMap<BString, Object> options, BMap<BString, BString> attributes) {
        return getElement(name, children, namespaces, options, attributes, PredefinedTypes.TYPE_ANYDATA);
    }

    public static BXml getElement(BString name, BXml children, BMap<BString, BString> namespaces,
                                  BMap<BString, Object> options, BMap<BString, BString> attributes, Type type) {
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        String userAttributePrefix = options.get(Constants.USER_ATTRIBUTE_PREFIX).toString();
        BXml element;

        String nameStr = name.getValue();

        int index = nameStr.indexOf(":");

        if (index != -1) {
            String prefix = nameStr.substring(0, index);

            String elementName;
            if (!userAttributePrefix.isEmpty()) {
                elementName = removeUserAttributePrefix(StringUtils.fromString(nameStr),
                        StringUtils.fromString(userAttributePrefix), (long) index).getValue();
            } else {
                elementName = nameStr.substring(index + 1, nameStr.length());
            }

            String namespaceUrl = attributes.get(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" +
                    prefix)).toString();

            if (namespaceUrl.isEmpty()) {
                namespaceUrl = namespaces.get(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" +
                    prefix)).toString();

                if (!namespaceUrl.isEmpty()) {
                    attributes.put(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" +
                        prefix), StringUtils.fromString(namespaceUrl));
                }
            }

            if (namespaceUrl.equals("")) {
                element = CreateElement.createElement(StringUtils.fromString(elementName), attributes, children);
            } else {
                element = CreateElement.createElement(StringUtils.fromString("{" + namespaceUrl + "}" + elementName),
                        attributes, children);
            }
        } else {
            if (nameStr.startsWith(attributePrefix)) {
                throw DiagnosticLog.createXmlError("attribute cannot be an object or array.");
            }

            BMap<BString, BString> newAttributes = attributes;
            if (newAttributes.containsKey(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}"))) {
                String value = newAttributes.get(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}")).toString();
                newAttributes.remove(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}"));
                newAttributes.put(XMLNS, StringUtils.fromString(value));
            }
            if (!userAttributePrefix.equals("")) {
                element = CreateElement.createElement(
                        removeUserAttributePrefix(StringUtils.fromString(nameStr),
                                StringUtils.fromString(userAttributePrefix), null), newAttributes, children);
            } else {
                element = CreateElement.createElement(StringUtils.fromString(nameStr), newAttributes, children);
            }

        }
        return element;
    }


    public static BString removeUserAttributePrefix(BString name, BString userAttributePrefix, Object index) {
        String nameStr = name.getValue();
        String userAttributePrefixStr = userAttributePrefix.getValue();

        int usrAttIndex = nameStr.indexOf(userAttributePrefixStr);
        if (usrAttIndex != -1) {
            return StringUtils.fromString(nameStr.substring(usrAttIndex + 1, nameStr.length()));
        }

        if (index instanceof Long indexNum) {
            return StringUtils.fromString(nameStr.substring(indexNum.intValue() + 1, nameStr.length()));
        }
        return StringUtils.fromString(nameStr);
    }

    public static BMap<BString, BString> getAttributesMap(Object jsonTree,
                                                          BMap<BString, Object> options,
                                                          BMap<BString, BString> namespaces,
                                                          BMap<BString, BString> parentNamespaces) {
        BMap<BString, BString> attributes = (BMap<BString, BString>) parentNamespaces.copy(new HashMap<>());
        try {
            BMap<BString, Object> attr = (BMap<BString, Object>) ValueUtils
                    .convert(jsonTree, TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));

            String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
            for (Map.Entry<BString, Object> entry : attr.entrySet()) {
                String key = entry.getKey().toString();
                Object value = entry.getValue();
                if (!key.startsWith(attributePrefix)) {
                    continue;
                }

                if (value instanceof BMap || value instanceof BArray) {
                    DiagnosticLog.createXmlError("attribute cannot be an object or array.");
                }

                int index = key.indexOf(":");
                if (index != -1) {
                    String suffix = key.substring(index + 1);
                    if (key.startsWith(attributePrefix + XMLNS)) {
                        attributes.put(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" + suffix),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    } else {
                        Long startIndex =
                                getStartIndex(StringUtils.fromString(attributePrefix), StringUtils
                                        .fromString(options.get(Constants.USER_ATTRIBUTE_PREFIX).toString()),
                                        StringUtils.fromString(key));
                        String prefix = key.substring(startIndex.intValue(), index);
                        BString namespaceUrl =
                                namespaces.get(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" + prefix));
                        attributes.put(StringUtils.fromString("{" + namespaceUrl + "}" + suffix),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    }
                } else {
                    if (key.equals(attributePrefix + XMLNS)) {
                        attributes.put(XMLNS, StringUtils.fromString(StringUtils.getStringValue(value)));
                    } else {
                        Long startIndex =
                                getStartIndex(StringUtils.fromString(attributePrefix),
                                    StringUtils.fromString(options.get(Constants.USER_ATTRIBUTE_PREFIX).toString()),
                                        StringUtils.fromString(key));
                        attributes.put(StringUtils.fromString(key.substring(startIndex.intValue())),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    }
                }
            }
            return attributes;
        } catch (BError e) {
            return attributes;
        }
    }

    public static Long getStartIndex(BString attributePrefix, BString userAttributePrefix, BString key) {
        String attributePrefixStr = attributePrefix.toString();
        String userAttributePrefixStr = userAttributePrefix.toString();
        String keyStr = key.toString();
        int startIndex = 1;

        if (!attributePrefixStr.equals(ATTRIBUTE_PREFIX.toString())) {
            return (long) startIndex;
        }

        int location = userAttributePrefixStr.equals("")
                ? keyStr.indexOf("_") : keyStr.indexOf(userAttributePrefixStr);
        if (location != -1) {
            startIndex = location + 1;
        }
        return (long) startIndex;
    }

    public static BMap<BString, BString> getNamespacesMap(Object jsonTree,
                                                           BMap<BString, Object> options,
                                                           BMap<BString, BString> parentNamespaces) {
        BMap<BString, BString> namespaces = (BMap<BString, BString>) parentNamespaces.copy(new HashMap<>());

        try {
            Object jsonTreeObject = ValueUtils
                    .convert(jsonTree, TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));

            BMap<BString, Object> attr = (BMap<BString, Object>) jsonTreeObject;
            String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();

            for (Map.Entry<BString, Object> entry : attr.entrySet()) {
                BString key = entry.getKey();
                Object value = entry.getValue();
                if (!key.getValue().startsWith(attributePrefix)) {
                    continue;
                }

                if (value instanceof BMap || value instanceof BArray) {
                    // TODO: Add error messages
                    throw DiagnosticLog.createXmlError("attribute cannot be an object or array.");
                }

                // TODO: Make this as a constant
                if (!key.getValue().startsWith(attributePrefix + XMLNS)) {
                    continue;
                }

                int index = key.getValue().indexOf(":");
                if (index != -1) {
                    String prefix = key.getValue().substring(index + 1);

                    // TODO: Add constants
                    namespaces.put(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" + prefix),
                            StringUtils.fromString(StringUtils.getStringValue(value)));
                } else {
                    namespaces.put(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}"),
                            StringUtils.fromString(StringUtils.getStringValue(value)));
                }
            }
            return namespaces;
        } catch (BError e) {
            return namespaces;
        }
    }

    public static void addNamespaces(BMap<BString, BString> allNamespaces, BMap<BString, BString> namespaces) {
        for (Map.Entry<BString, BString> entry: namespaces.entrySet()) {
            allNamespaces.put(entry.getKey(), entry.getValue());
        }
    }
}
