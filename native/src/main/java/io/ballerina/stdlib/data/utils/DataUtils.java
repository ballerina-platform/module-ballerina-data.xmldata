/*
 * Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.data.utils;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.data.FromString;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Stack;

import javax.xml.namespace.QName;

/**
 * A util class for the Data package's native implementation.
 *
 * @since 0.1.0
 */
public class DataUtils {

    private static final String ERROR = "ConversionError";
    private static final String NAME = "Name";
    private static final String ATTRIBUTE_PREFIX = "attribute_";
    private static final String VALUE = "value";

    public static BError getError(String message) {
        return ErrorCreator.createError(ModuleUtils.getModule(), ERROR, StringUtils.fromString(message),
                null, null);
    }

    public static BError getXmlError(String message) {
        return ErrorCreator.createError(ModuleUtils.getModule(), ERROR, StringUtils.fromString(message),
                null, null);
    }

    public static String validateAndGetXmlNameFromRecordAnnotation(RecordType recordType, String recordName,
                                                             String elementName) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        for (BString annotationsKey : annotations.getKeys()) {
            String key = annotationsKey.getValue();
            if (!key.contains(Constants.FIELD) && key.endsWith(Constants.NAME)) {
                String name = ((BMap<BString, Object>) annotations.get(annotationsKey)).get(Constants.VALUE).toString();
                if (!name.equals(elementName)) {
                    throw DataUtils.getXmlError("the record type name `" + name +
                            "` mismatch with given XML name `" + elementName + "`");
                }
                return name;
            }
        }
        return recordName;
    }

    public static void validateFieldNamespace(String prefix, String uri, String fieldName, RecordType recordType) {
        ArrayList<String> namespace = getFieldNamespace(recordType, fieldName);

        if (namespace.isEmpty()) {
            return;
        }

        if (prefix.equals(namespace.get(0)) && uri.equals(namespace.get(1))) {
            return;
        }
        throw DataUtils.getXmlError("namespace mismatched for the field: " + fieldName);
    }

    public static ArrayList<String> getFieldNamespace(RecordType recordType, String fieldName) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        String namespacePrefix = null;
        String namespaceUri = null;
        for (BString annotationsKey : annotations.getKeys()) {
            String key = annotationsKey.getValue();
            if (key.contains(Constants.FIELD) && key.split("\\$field\\$\\.")[1].equals(fieldName)) {
                BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotations.get(annotationsKey);
                for (BString keyStr : namespaceAnnotation.getKeys()) {
                    if (keyStr.getValue().endsWith(Constants.NAME_SPACE)) {
                        namespaceAnnotation = (BMap<BString, Object>) namespaceAnnotation.get(keyStr);
                        namespacePrefix = namespaceAnnotation.containsKey(Constants.PREFIX) ?
                                ((BString) namespaceAnnotation.get(Constants.PREFIX)).getValue() : "";
                        namespaceUri = ((BString) namespaceAnnotation.get(Constants.URI)).getValue();
                        break;
                    }
                }
                break;
            }
        }
        ArrayList<String> namespace = new ArrayList<>();
        if (namespacePrefix != null && namespaceUri != null) {
            namespace.add(namespacePrefix);
            namespace.add(namespaceUri);
        }
        return namespace;
    }

    public static void validateTypeNamespace(String prefix, String uri, RecordType recordType) {
        ArrayList<String> namespace = getNamespace(recordType);

        if (namespace.isEmpty()) {
            return;
        }

        if (prefix.equals(namespace.get(0)) && uri.equals(namespace.get(1))) {
            return;
        }
        throw DataUtils.getXmlError("namespace mismatched for the type: " + recordType.getName());
    }

    private static ArrayList<String> getNamespace(RecordType recordType) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        String namespacePrefix = null;
        String namespaceUri = null;
        for (BString annotationsKey : annotations.getKeys()) {
            String key = annotationsKey.getValue();
            if (!key.contains(Constants.FIELD) && key.endsWith(Constants.NAME_SPACE)) {
                BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotations.get(annotationsKey);
                namespacePrefix = namespaceAnnotation.containsKey(Constants.PREFIX) ?
                        ((BString) namespaceAnnotation.get(Constants.PREFIX)).getValue() : "";
                namespaceUri = ((BString) namespaceAnnotation.get(Constants.URI)).getValue();
                break;
            }
        }
        ArrayList<String> namespace = new ArrayList<>();
        if (namespacePrefix != null && namespaceUri != null) {
            namespace.add(namespacePrefix);
            namespace.add(namespaceUri);
        }
        return namespace;
    }

    public static Map<String, Field> getAllFieldsInRecordType(RecordType recordType, XmlAnalyzerData analyzerData) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        HashMap<String, String> modifiedNames = new LinkedHashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD)) {
                String elementName = keyStr.split("\\$field\\$\\.")[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                modifiedNames.put(elementName, getModifiedName(fieldAnnotation, elementName));
            }
        }

        Map<String, Field> fields = new HashMap<>();
        Map<String, Field> recordFields = recordType.getFields();
        for (String key : recordFields.keySet()) {
            if (analyzerData.attributeHierarchy.peek().containsKey(key)) {
                continue;
            }
            fields.put(modifiedNames.getOrDefault(key, key), recordFields.get(key));
        }
        return fields;
    }

    public static Map<String, Field> getAllAttributesInRecordType(RecordType recordType) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        Map<String, Field> attributes = new HashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD)) {
                String attributeName = keyStr.split("\\$field\\$\\.")[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                for (BString key : fieldAnnotation.keySet()) {
                    if (key.getValue().endsWith(Constants.ATTRIBUTE)) {
                        attributes.put(getModifiedName(fieldAnnotation, attributeName),
                                recordType.getFields().get(attributeName));
                    }
                }
            }
        }
        return attributes;
    }

    private static String getModifiedName(Map<BString, Object> fieldAnnotation, String attributeName) {
        for (BString key : fieldAnnotation.keySet()) {
            if (key.getValue().endsWith(Constants.NAME)) {
                return ((Map<BString, Object>) fieldAnnotation.get(key)).get(Constants.VALUE).toString();
            }
        }
        return attributeName;
    }

    public static BMap<BString, Object> createMapValue(Type type) {
        if (type != null) {
            if (type.getTag() == TypeTags.MAP_TAG) {
                return ValueCreator.createMapValue((MapType) type);
            } else if (type.getTag() == TypeTags.RECORD_TYPE_TAG) {
                return ValueCreator.createRecordValue((RecordType) type);
            }
        }
        return ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
    }

    public static BArray createNewAnydataList() {
        return ValueCreator.createArrayValue(Constants.ANYDATA_ARRAY_TYPE);
    }

    public static String getElementName(QName qName) {
        return qName.getLocalPart();
    }

    public static Object convertStringToExpType(BString value, Type expType) {
        Object result;
        switch (expType.getTag()) {
            case TypeTags.ANYDATA_TAG:
            case TypeTags.ANY_TAG:
            case TypeTags.JSON_TAG:
                result = FromString.fromStringWithTypeInternal(value, PredefinedTypes.TYPE_STRING);
                break;
            case TypeTags.ARRAY_TAG:
                expType = ((ArrayType) expType).getElementType();
                result = convertStringToExpType(value, expType);
                break;
            default:
                result = FromString.fromStringWithTypeInternal(value, expType);
        }

        if (result instanceof BError) {
            throw (BError) result;
        }
        return result;
    }

    public static void validateRequiredFields(BMap<BString, Object> currentMapValue, XmlAnalyzerData analyzerData) {
        Map<String, Field> fields = analyzerData.fieldHierarchy.peek();
        for (String key : fields.keySet()) {
            // Validate required array size
            Field field = fields.get(key);
            String fieldName = field.getFieldName();
            if (field.getFieldType().getTag() == TypeTags.ARRAY_TAG) {
                ArrayType arrayType = (ArrayType) field.getFieldType();
                if (arrayType.getSize() != -1
                        && arrayType.getSize() != ((BArray) currentMapValue.get(
                        StringUtils.fromString(fieldName))).getLength()) {
                    throw DataUtils.getXmlError("Array size is not compatible with the expected size");
                }
            }

            if (!SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)
                    && !currentMapValue.containsKey(StringUtils.fromString(fieldName))) {
                throw DataUtils.getXmlError("Required field '" + fieldName + "' not present in XML");
            }
        }

        Map<String, Field> attributes = analyzerData.attributeHierarchy.peek();
        for (String key : attributes.keySet()) {
            Field field = attributes.get(key);
            String fieldName = field.getFieldName();
            if (!SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)) {
                throw DataUtils.getXmlError("Required attribute '" + fieldName + "' not present in XML");
            }
        }
    }

    public static boolean isArrayValueAssignable(int typeTag) {
        return typeTag == TypeTags.ARRAY_TAG || typeTag == TypeTags.ANYDATA_TAG || typeTag == TypeTags.JSON_TAG;
    }

    public static boolean isStringValueAssignable(int typeTag) {
        return typeTag == TypeTags.STRING_TAG || typeTag == TypeTags.ANYDATA_TAG || typeTag == TypeTags.JSON_TAG;
    }

    /**
     * Holds data required for the parsing and traversing.
     *
     * @since 1.0.0
     */
    public static class XmlAnalyzerData {
        public final Stack<Object> nodesStack = new Stack<>();
        public final Stack<Map<String, Field>> fieldHierarchy = new Stack<>();
        public final Stack<Map<String, Field>> attributeHierarchy = new Stack<>();
        public final Stack<Type> restTypes = new Stack<>();
        public RecordType rootRecord;
        public Field currentField;
        public String rootElement;
    }
}
