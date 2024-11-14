package io.ballerina.lib.data.xmldata.utils;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
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

import java.util.HashMap;
import java.util.Map;

public class ToXmlUtils {
    private static final BString XMLNS_NAMESPACE_URI = StringUtils.fromString("http://www.w3.org/2000/xmlns/");
    private static final BString ATTRIBUTE_PREFIX = StringUtils.fromString("attribute_");
    private static final BString XMLNS = StringUtils.fromString("xmlns");

//    public isolated function fromModifiedRecordToXml(json jsonValue, JsonOptions options = {}) returns xml|Error {
//        string? rootTag = options.rootTag;
//        map<string> allNamespaces = {};
//        if !isSingleNode(jsonValue) {
//            addNamespaces(allNamespaces, check getNamespacesMap(jsonValue, options, {}));
//            return getElement(rootTag ?: "root",
//                    check traverseNode(jsonValue, allNamespaces, {}, options), allNamespaces, options,
//                    check getAttributesMap(jsonValue, options, allNamespaces));
//        }
//
//        map<json>|error jMap = jsonValue.ensureType();
//        if jMap is map<json> {
//            if jMap.length() == 0 {
//                return xml ``;
//            }
//
//            json value = jMap.toArray()[0];
//            addNamespaces(allNamespaces, check getNamespacesMap(value, options, {}));
//            if value is json[] {
//                return getElement(rootTag ?: "root",
//                        check traverseNode(value, allNamespaces, {}, options, jMap.keys()[0]),
//                        allNamespaces, options, check getAttributesMap(value, options, allNamespaces));
//            }
//
//            string key = jMap.keys()[0];
//            if key == options.textFieldName {
//                return xml:createText(value.toString());
//            }
//            xml output = check getElement(jMap.keys()[0], check traverseNode(value, allNamespaces, {}, options),
//                    allNamespaces, options,
//                    check getAttributesMap(value, options, allNamespaces));
//            if rootTag is string {
//                return xml:createElement(rootTag, {}, output);
//            }
//            return output;
//        }
//        return jsonValue is null ? xml `` : xml:createText(jsonValue.toString());
//    }

    public static BXml fromModifiedRecordToXml(Object jsonValue, BMap<BString, Object> options, BTypedesc typed) {
        Object rootTag = options.get(StringUtils.fromString("rootTag"));
        BMap<BString, BString> allNamespaces = (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue());

        if (!isSingleNode(jsonValue)) {
            addNamespaces(allNamespaces, getNamespacesMap(jsonValue, options,
                    (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue())));
            return getElement(rootTag == null ? StringUtils.fromString("root")
                            : StringUtils.fromString(rootTag.toString()),
                    traverseNode(jsonValue, allNamespaces,
                            (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue()), options),
                    allNamespaces, options, getAttributesMap(jsonValue, options, allNamespaces,
                            (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue())));
        }

        try {
            BMap<BString, Object> jMap = (BMap<BString, Object>) ValueUtils.convert(jsonValue,
                    TypeCreator.createMapType(PredefinedTypes.TYPE_JSON));
            if (jMap.size() == 0) {
                return ValueCreator.createXmlValue("");
            }

            Object value = ToArray.toArray(jMap).getValues()[0];
            addNamespaces(allNamespaces, getNamespacesMap(value, options,
                    (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue())));

            if (value instanceof BArray arrayNode) {
                return getElement(rootTag == null ? StringUtils.fromString("root")
                                : StringUtils.fromString(rootTag.toString()),
                        traverseNode(value, allNamespaces, (BMap<BString, BString>) ((BMap<?, ?>)
                                ValueCreator.createMapValue()), options, jMap.getKeys()[0]),
                                allNamespaces, options, getAttributesMap(value, options, allNamespaces,
                                (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue())));
            }

            BString key = jMap.getKeys()[0];
            if (key.equals(options.get(StringUtils.fromString("textFieldName")))) {
                return CreateText.createText(StringUtils.fromString(value.toString()));
            }
            BXml output = getElement(jMap.getKeys()[0],
                    traverseNode(value, allNamespaces,
                            (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue()), options),
                    allNamespaces, options, getAttributesMap(value, options, allNamespaces,
                            (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue())));
            if (rootTag != null) {
                return CreateElement.createElement(StringUtils.fromString(rootTag.toString()),
                        (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue()), output);
            }
            return output;
        } catch (BError e) {
            return jsonValue == null ? ValueCreator.createXmlValue("")
                    : CreateText.createText(StringUtils.fromString(jsonValue.toString()));
        }
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
                    xNode = Concat.concat(xNode, CreateElement.createElement(key,
                            (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue()), (BXml) i));
                }
            } else {
                xNode = Concat.concat(xNode, CreateElement.createElement(key,
                        (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue()), (BXml) value));
            }
        }
        return CreateElement.createElement(StringUtils.fromString("root"),
                (BMap<BString, BString>) ((BMap<?, ?>) ValueCreator.createMapValue()), xNode);
    }

    public static BXml traverseNode(Object jNode, BMap<BString, BString> allNamespaces,
                                    BMap<BString, BString> parentNamespaces, BMap<BString, Object> options) {
        return traverseNode(jNode, allNamespaces, parentNamespaces, options, null);
    }

    public static BXml traverseNode(Object jNode, BMap<BString, BString> allNamespaces,
                    BMap<BString, BString> parentNamespaces, BMap<BString, Object> options, Object keyObj) {
        BMap<BString, BString> namespacesOfElem;
        BXml xNode = ValueCreator.createXmlValue("");
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();

        if (jNode instanceof BMap jMap) {
            BMap<BString, Object> mapNode = (BMap<BString, Object>) jMap;
            for (Map.Entry<BString, Object> entry : mapNode.entrySet()) {
                BString k = entry.getKey();
                Object value = entry.getValue();
                String jsonKey = k.getValue().trim();
                if (jsonKey.startsWith(attributePrefix)) {
                    continue;
                }

                if (jsonKey.equals(options.get(Constants.TEXT_FIELD_NAME).toString())) {
                    xNode = Concat.concat(xNode, CreateText.createText(StringUtils.fromString(value.toString())));
                } else {
                    namespacesOfElem = getNamespacesMap(value, options, parentNamespaces);
                    addNamespaces(allNamespaces, namespacesOfElem);
                    if (value instanceof BArray arrayNode) {
                        xNode = Concat.concat(xNode, traverseNode(value, allNamespaces, namespacesOfElem, options, k));
                    } else {
                        xNode = Concat.concat(xNode, getElement(k,
                                traverseNode(value, allNamespaces, namespacesOfElem, options),
                                allNamespaces, options,
                                getAttributesMap(value, options, allNamespaces, parentNamespaces)));
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
                } else if (!options.get(Constants.ARRAY_ENTRY_TAG).toString().equals("")) {
                    arrayEntryTagKey = options.get(Constants.ARRAY_ENTRY_TAG).toString();
                }

                namespacesOfElem = getNamespacesMap(i, options, parentNamespaces);
                addNamespaces(allNamespaces, namespacesOfElem);
                if (options.get(Constants.ARRAY_ENTRY_TAG).toString().equals("")) {
                    xNode = Concat.concat(xNode, getElement(StringUtils.fromString(arrayEntryTagKey),
                            traverseNode(i, allNamespaces, namespacesOfElem, options, keyObj),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces)));
                } else {
                    xNode = Concat.concat(xNode, getElement(StringUtils.fromString(arrayEntryTagKey),
                            traverseNode(i, allNamespaces, namespacesOfElem, options),
                            allNamespaces, options, getAttributesMap(i, options, allNamespaces, parentNamespaces)));
                }
            }
        } else {
            xNode = CreateText.createText(StringUtils.fromString(StringUtils.getStringValue(jNode)));
        }
        return xNode;
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
        String attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        String userAttributePrefix = options.get(Constants.USER_ATTRIBUTE_PREFIX).toString();
        BXml element;

        String nameStr = name.getValue();

        int index = nameStr.indexOf(":");

        if (index != -1) {
            String prefix = nameStr.substring(0, index);

            String elementName;
            if (!userAttributePrefix.equals("")) {
                elementName = removeUserAttributePrefix(StringUtils.fromString(nameStr),
                        StringUtils.fromString(userAttributePrefix), (long) index).getValue();
            } else {
                elementName = nameStr.substring(index + 1, nameStr.length());
            }

            String namespaceUrl = attributes.get(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" +
                    prefix)).toString();

            if (namespaceUrl.equals("")) {
                namespaceUrl = namespaces.get(StringUtils.fromString("{" + XMLNS_NAMESPACE_URI + "}" +
                    prefix)).toString();

                if (!namespaceUrl.equals("")) {
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
