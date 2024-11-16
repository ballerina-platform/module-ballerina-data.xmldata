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

    public static BXml fromRecordToXml(Object jsonValue, BMap<BString, Object> options, BTypedesc typed) {
        Type type = typed.getDescribingType();
        Type referredType = TypeUtils.getReferredType(type);
        Object rootTag = options.get(StringUtils.fromString(Constants.ROOT_TAG));
        BMap<BString, BString> allNamespaces = getEmptyStringMap();
        BString rootTagBstring = StringUtils.fromString(rootTag == null ? Constants.EMPTY_STRING : rootTag.toString());

        if (!isSingleRecordMember(jsonValue)) {
            addNamespaces(allNamespaces, getNamespacesMap(jsonValue, options, getEmptyStringMap()));
            return getElementFromRecordMember(rootTag == null ? StringUtils.fromString(Constants.ROOT) : rootTagBstring,
                    traverseRecordAndGenerateXml(jsonValue, allNamespaces,
                            getEmptyStringMap(), options, null, referredType, false, false),
                    allNamespaces, options, getAttributesMap(jsonValue, options, allNamespaces, getEmptyStringMap()));
        }

        try {
            BMap<BString, Object> jMap = (BMap<BString, Object>) ValueUtils
                    .convert(jsonValue, TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));

            if (jMap.isEmpty()) {
                return ValueCreator.createXmlValue(Constants.EMPTY_STRING);
            }

            BString key = jMap.getKeys()[0];
            String keyStr = key.getValue();
            HashMap<String, String> elementNamesMap = DataUtils.getElementNameMap(referredType);
            ArrayList<String> sequenceFieldNames = getSequenceFieldNames(referredType, elementNamesMap);
            boolean isSequenceField = sequenceFieldNames.contains(keyStr);
            ArrayList<String> modelGroupRelatedFieldNames =
                    getModelGroupRelatedFieldNames(referredType, elementNamesMap);
            String localJsonKeyPart = keyStr.contains(Constants.COLON)
                    ? keyStr.substring(keyStr.indexOf(Constants.COLON) + 1) : keyStr;
            String recordKey = elementNamesMap.getOrDefault(localJsonKeyPart, localJsonKeyPart);
            boolean isContainsModelGroup = modelGroupRelatedFieldNames.contains(recordKey);

            Object value = ToArray.toArray(jMap).getValues()[0];
            addNamespaces(allNamespaces, getNamespacesMap(value, options, getEmptyStringMap()));

            if (value instanceof BArray) {
                return getElementFromRecordMember(rootTag == null
                                ? StringUtils.fromString(Constants.ROOT) : rootTagBstring,
                        traverseRecordAndGenerateXml(value, allNamespaces, getEmptyStringMap(), options, key,
                        getChildElementType(referredType, keyStr), isSequenceField, isSequenceField),
                    allNamespaces, options, getAttributesMap(value, options, allNamespaces, getEmptyStringMap()));
            }

            if (key.equals(options.get(Constants.TEXT_FIELD_NAME))) {
                return CreateText.createText(StringUtils.fromString(value.toString()));
            }

            BXml output = getElementFromRecordMember(key,
                    traverseRecordAndGenerateXml(value, allNamespaces, getEmptyStringMap(), options, null,
                        getChildElementType(referredType, recordKey), isSequenceField, isSequenceField),
                    allNamespaces, options, getAttributesMap(value, options, allNamespaces, getEmptyStringMap()));
            if (isContainsModelGroup) {
                output = output.children();
            }
            if (rootTag != null) {
                return CreateElement.createElement(rootTagBstring, getEmptyStringMap(), output);
            }
            return output;
        } catch (BError e) {
            return jsonValue == null ? ValueCreator.createXmlValue(Constants.EMPTY_STRING)
                    : CreateText.createText(StringUtils.fromString(jsonValue.toString()));
        }
    }

    private static BMap<BString, BString> getEmptyStringMap() {
        return (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue());
    }

    public static BXml traverseRecordAndGenerateXml(Object jNode, BMap<BString, BString> allNamespaces,
                    BMap<BString, BString> parentNamespaces, BMap<BString, Object> options,
                    Object keyObj, Type type, boolean isParentSequence, boolean isParentSequenceArray) {
        BMap<BString, BString> namespacesOfElem;
        BXml xNode = ValueCreator.createXmlValue(Constants.EMPTY_STRING);
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        Type referredType = TypeUtils.getReferredType(type);
        HashMap<String, String> elementNamesMap = DataUtils.getElementNameMap(referredType);
        ArrayList<String> modelGroupRelatedFieldNames = getModelGroupRelatedFieldNames(referredType, elementNamesMap);
        ArrayList<String> sequenceFieldNames = getSequenceFieldNames(referredType, elementNamesMap);
        BXml childElement;

        if (jNode instanceof BMap jMap) {
            BMap<BString, Object> mapNode = (BMap<BString, Object>) jMap;
            BString[] orderedRecordKeysIfXsdSequencePresent = DataUtils.getOrderedRecordKeysIfXsdSequencePresent(
                    mapNode, DataUtils.getXsdSequencePriorityOrder(referredType, isParentSequence));

            for (BString k : orderedRecordKeysIfXsdSequencePresent) {
                Object value = mapNode.get(k);
                String jsonKey = k.getValue().trim();
                String localJsonKeyPart = jsonKey.contains(Constants.COLON) ?
                        jsonKey.substring(jsonKey.indexOf(Constants.COLON) + 1) : jsonKey;
                String recordKey = elementNamesMap.getOrDefault(localJsonKeyPart, localJsonKeyPart);
                boolean isContainsModelGroup = modelGroupRelatedFieldNames.contains(recordKey);
                boolean isSequenceField = sequenceFieldNames.contains(recordKey);

                if (jsonKey.startsWith(attributePrefix)) {
                    continue;
                }

                if (jsonKey.equals(options.get(Constants.TEXT_FIELD_NAME).toString())) {
                    xNode = Concat.concat(xNode, CreateText.createText(StringUtils.fromString(value.toString())));
                } else {
                    namespacesOfElem = getNamespacesMap(value, options, parentNamespaces);
                    addNamespaces(allNamespaces, namespacesOfElem);

                    if (value instanceof BArray) {
                        childElement = traverseRecordAndGenerateXml(value, allNamespaces, namespacesOfElem, options, k,
                                getChildElementType(referredType, recordKey), isSequenceField, isSequenceField);
                        xNode = Concat.concat(xNode, childElement);
                    } else {
                        childElement = getElementFromRecordMember(k, traverseRecordAndGenerateXml(
                                    value, allNamespaces, namespacesOfElem, options, null,
                                    getChildElementType(referredType, recordKey), isSequenceField, isSequenceField),
                                allNamespaces, options, getAttributesMap(
                                        value, options, allNamespaces, parentNamespaces));
                        xNode = Concat.concat(xNode, !isContainsModelGroup || isParentSequenceArray ? childElement
                                : childElement.children());
                    }
                }
            }
        } else if (jNode instanceof BArray arrayNode) {
            for (Object i : arrayNode.getValues()) {
                if (i == null) {
                    continue;
                }
                String arrayEntryTagKey = Constants.EMPTY_STRING;
                if (keyObj instanceof BString key) {
                    arrayEntryTagKey = key.getValue();
                } else if (!options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    arrayEntryTagKey = options.get(Constants.ARRAY_ENTRY_TAG).toString();
                }

                namespacesOfElem = getNamespacesMap(i, options, parentNamespaces);
                addNamespaces(allNamespaces, namespacesOfElem);
                if (options.get(Constants.ARRAY_ENTRY_TAG).toString().isEmpty()) {
                    childElement = getElementFromRecordMember(StringUtils.fromString(arrayEntryTagKey),
                            traverseRecordAndGenerateXml(i, allNamespaces, namespacesOfElem,
                                    options, keyObj, getChildElementType(referredType, null),
                                    isParentSequence, isParentSequenceArray),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces));
                } else {
                    childElement = getElementFromRecordMember(StringUtils.fromString(arrayEntryTagKey),
                            traverseRecordAndGenerateXml(i, allNamespaces, namespacesOfElem,
                                    options, null, getChildElementType(referredType, null),
                                    isParentSequence, isParentSequenceArray),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces));
                }
                xNode = Concat.concat(xNode, isParentSequenceArray ? childElement.children() : childElement);
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
            throw DiagnosticLog.createXmlError("Invalid xml provided");
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

    public static boolean isSingleRecordMember(Object node) {
        if (node instanceof BArray arrayNode) {
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

    public static BXml getElementFromRecordMember(BString name, BXml children, BMap<BString, BString> namespaces,
                                  BMap<BString, Object> options, BMap<BString, BString> attributes) {
        return getElementFromRecordMember(
                name, children, namespaces, options, attributes, PredefinedTypes.TYPE_ANYDATA);
    }

    public static BXml getElementFromRecordMember(BString name, BXml children, BMap<BString, BString> namespaces,
                                  BMap<BString, Object> options, BMap<BString, BString> attributes, Type type) {
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        String userAttributePrefix = options.get(Constants.USER_ATTRIBUTE_PREFIX).toString();
        BXml element;
        String nameStr = name.getValue();
        int index = nameStr.indexOf(Constants.COLON);

        if (index != -1) {
            String prefix = nameStr.substring(0, index);
            String elementName;

            if (!userAttributePrefix.isEmpty()) {
                elementName = removeUserAttributePrefix(StringUtils.fromString(nameStr),
                        StringUtils.fromString(userAttributePrefix), (long) index).getValue();
            } else {
                elementName = nameStr.substring(index + 1, nameStr.length());
            }

            String namespaceUrl = attributes.get(StringUtils.fromString(getXmlnsNameUrI() + prefix)).toString();

            if (namespaceUrl.isEmpty()) {
                namespaceUrl = namespaces.get(StringUtils.fromString(getXmlnsNameUrI() + prefix)).toString();

                if (!namespaceUrl.isEmpty()) {
                    attributes.put(StringUtils.fromString(getXmlnsNameUrI() + prefix),
                            StringUtils.fromString(namespaceUrl));
                }
            }

            if (namespaceUrl.equals(Constants.EMPTY_STRING)) {
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
            if (newAttributes.containsKey(StringUtils.fromString(getXmlnsNameUrI()))) {
                String value = newAttributes.get(StringUtils.fromString(getXmlnsNameUrI())).toString();
                newAttributes.remove(StringUtils.fromString(getXmlnsNameUrI()));
                newAttributes.put(XMLNS, StringUtils.fromString(value));
            }
            if (!userAttributePrefix.equals(Constants.EMPTY_STRING)) {
                element = CreateElement.createElement(removeUserAttributePrefix(StringUtils.fromString(nameStr),
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
            BMap<BString, Object> attr = (BMap<BString, Object>) ValueUtils.convert(
                    jsonTree, TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));

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

                int index = key.indexOf(Constants.COLON);
                if (index != -1) {
                    String suffix = key.substring(index + 1);
                    if (key.startsWith(attributePrefix + XMLNS)) {
                        attributes.put(StringUtils.fromString(getXmlnsNameUrI() + suffix),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    } else {
                        Long startIndex = getStartIndex(StringUtils.fromString(attributePrefix), StringUtils.fromString(
                                options.get(Constants.USER_ATTRIBUTE_PREFIX).toString()), StringUtils.fromString(key));
                        String prefix = key.substring(startIndex.intValue(), index);
                        BString namespaceUrl = namespaces.get(StringUtils.fromString(getXmlnsNameUrI() + prefix));
                        attributes.put(StringUtils.fromString("{" + namespaceUrl + "}" + suffix),
                                StringUtils.fromString(StringUtils.getStringValue(value)));
                    }
                } else {
                    if (key.equals(attributePrefix + XMLNS)) {
                        attributes.put(XMLNS, StringUtils.fromString(StringUtils.getStringValue(value)));
                    } else {
                        Long startIndex = getStartIndex(StringUtils.fromString(attributePrefix),
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

        int location = userAttributePrefixStr.equals(Constants.EMPTY_STRING) ? keyStr.indexOf("_")
                : keyStr.indexOf(userAttributePrefixStr);
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
            Object jsonTreeObject = ValueUtils.convert(jsonTree, TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));
            BMap<BString, Object> attr = (BMap<BString, Object>) jsonTreeObject;
            String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();

            for (Map.Entry<BString, Object> entry : attr.entrySet()) {
                BString key = entry.getKey();
                Object value = entry.getValue();
                if (!key.getValue().startsWith(attributePrefix)) {
                    continue;
                }

                if (value instanceof BMap || value instanceof BArray) {
                    throw DiagnosticLog.createXmlError("attribute cannot be an object or array.");
                }

                if (!key.getValue().startsWith(attributePrefix + XMLNS)) {
                    continue;
                }

                int index = key.getValue().indexOf(Constants.COLON);
                if (index != -1) {
                    String prefix = key.getValue().substring(index + 1);
                    namespaces.put(StringUtils.fromString(getXmlnsNameUrI() + prefix),
                            StringUtils.fromString(StringUtils.getStringValue(value)));
                } else {
                    namespaces.put(StringUtils.fromString(getXmlnsNameUrI()),
                            StringUtils.fromString(StringUtils.getStringValue(value)));
                }
            }
            return namespaces;
        } catch (BError e) {
            return namespaces;
        }
    }

    private static String getXmlnsNameUrI() {
        return "{" + XMLNS_NAMESPACE_URI + "}";
    }

    public static void addNamespaces(BMap<BString, BString> allNamespaces, BMap<BString, BString> namespaces) {
        for (Map.Entry<BString, BString> entry: namespaces.entrySet()) {
            allNamespaces.put(entry.getKey(), entry.getValue());
        }
    }
}
