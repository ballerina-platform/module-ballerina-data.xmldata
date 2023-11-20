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
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.data.FromString;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
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

    public static void updateExpectedTypeStacks(RecordType recordType, XmlAnalyzerData analyzerData) {
        analyzerData.attributeHierarchy.push(new HashMap<>(getAllAttributesInRecordType(recordType)));
        analyzerData.fieldHierarchy.push(new HashMap<>(getAllFieldsInRecordType(recordType, analyzerData)));
        analyzerData.restTypes.push(recordType.getRestFieldType());
    }

    public static void removeExpectedTypeStacks(XmlAnalyzerData analyzerData) {
        analyzerData.attributeHierarchy.pop();
        analyzerData.fieldHierarchy.pop();
        analyzerData.restTypes.pop();
    }

    @SuppressWarnings("unchecked")
    public static Object getModifiedRecord(BMap<BString, Object> input, BTypedesc type) {
        Type describingType = type.getDescribingType();
        Object value = input.get(input.getKeys()[0]);
        if (describingType.getTag() == TypeTags.MAP_TAG && value instanceof BArray) {
            BArray objectArray = (BArray) value;
            Type elementType = TypeUtils.getReferredType(((ArrayType) objectArray.getType()).getElementType());
            if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                BMap<BString, Object> jsonMap = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                for (Map.Entry<BString, Object> entry : input.entrySet()) {
                    List<BMap<BString, Object>> records = new ArrayList<>();
                    BArray arrayValue = (BArray) entry.getValue();
                    for (int i = 0; i < arrayValue.getLength(); i++) {
                        BMap<BString, Object> record = addFields(((BMap<BString, Object>) arrayValue.get(i)),
                                elementType);
                        BMap<BString, Object> parentRecord = processParentAnnotation(elementType, record);
                        // Remove parent element
                        records.add((BMap<BString, Object>) parentRecord.get(parentRecord.getKeys()[0]));
                    }
                    jsonMap.put(entry.getKey(), ValueCreator.createArrayValue(records.toArray(),
                            TypeCreator.createArrayType(elementType)));
                }
                return jsonMap;
            }
        }
        if (describingType.getTag() == TypeTags.RECORD_TYPE_TAG &&
                describingType.getFlags() != Constants.DEFAULT_TYPE_FLAG) {
            BArray jsonArray = ValueCreator.createArrayValue(PredefinedTypes.TYPE_JSON_ARRAY);
            BMap<BString, Object> recordField =  addFields(input, type.getDescribingType());
            BMap<BString, Object> processedRecord = processParentAnnotation(type.getDescribingType(), recordField);
            BString rootTagName = processedRecord.getKeys()[0];
            jsonArray.append(processedRecord.get(rootTagName));
            jsonArray.append(rootTagName);
            return jsonArray;
        }
        return input;
    }

    @SuppressWarnings("unchecked")
    private static BMap<BString, Object> addFields(BMap<BString, Object> input, Type type) {
        BMap<BString, Object> recordValue = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        Map<String, Field> fields = ((RecordType) type).getFields();
        BMap<BString, Object> annotations = ((RecordType) type).getAnnotations();
        for (Map.Entry<BString, Object> entry: input.entrySet()) {
            String key = entry.getKey().getValue();
            Object value = entry.getValue();
            if (fields.containsKey(key)) {
                Type fieldType = fields.get(key).getFieldType();
                fieldType = getTypeFromUnionType(fieldType, value);
                if (fieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                    processRecord(key, annotations, recordValue, value, fieldType);
                } else if (fieldType.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG) {
                    Type referredType = TypeUtils.getReferredType(fieldType);
                    if (annotations.size() > 0) {
                        key = getKeyNameFromAnnotation(annotations, key);
                    }
                    BMap<BString, Object> subRecordAnnotations = ((RecordType) referredType).getAnnotations();
                    key = getElementName(subRecordAnnotations, key);
                    BMap<BString, Object>  annotationRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                    processSubRecordAnnotation(subRecordAnnotations, annotationRecord);
                    BMap<BString, Object> subRecordValue = addFields(((BMap<BString, Object>) value), referredType);
                    if (annotationRecord.size() > 0) {
                        subRecordValue.put(annotationRecord.getKeys()[0],
                                annotationRecord.get(annotationRecord.getKeys()[0]));
                    }
                    recordValue.put(StringUtils.fromString(key), subRecordValue);
                } else if (fieldType.getTag() == TypeTags.ARRAY_TAG) {
                    processArray(fieldType, annotations, recordValue, entry);
                } else {
                    addPrimitiveValue(addFieldNamespaceAnnotation(key, annotations, recordValue),
                            annotations, recordValue, value);
                }
            } else {
                recordValue.put(StringUtils.fromString(key), value);
            }
        }
        return recordValue;
    }

    private static QName addFieldNamespaceAnnotation(String key, BMap<BString, Object> annotations,
                                                    BMap<BString, Object> recordValue) {
        BString annotationKey =
                StringUtils.fromString((Constants.FIELD + key).replace(Constants.COLON, "\\:"));
        boolean isAttributeField = isAttributeField(annotationKey, annotations);
        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            for (BString fieldKey : annotationValue.getKeys()) {
                if (fieldKey.toString().endsWith(Constants.NAME_SPACE)) {
                    return processFieldNamespaceAnnotation(annotationValue, key, fieldKey, recordValue,
                            isAttributeField);
                }
            }
        }
        return new QName("", key, "");
    }

    private static boolean isAttributeField(BString annotationKey, BMap<BString, Object> annotations) {
        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            for (BString fieldKey : annotationValue.getKeys()) {
                if (fieldKey.toString().endsWith(Constants.ATTRIBUTE)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static BMap<BString, Object> getFieldNamespaceAndNameAnnotations(String key,
                                                                             BMap<BString, Object> parentAnnotations) {
        BMap<BString, Object> nsFieldAnnotation = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BString annotationKey =
                StringUtils.fromString((Constants.FIELD + key).replace(Constants.COLON, "\\:"));
        if (parentAnnotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) parentAnnotations.get(annotationKey);
            for (BString fieldKey : annotationValue.getKeys()) {
                String keyName = fieldKey.getValue();
                if (keyName.endsWith(Constants.NAME_SPACE) || keyName.endsWith(Constants.NAME)) {
                    nsFieldAnnotation.put(fieldKey, annotationValue.get(fieldKey));
                    break;
                }
            }
        }
        return nsFieldAnnotation;
    }

    @SuppressWarnings("unchecked")
    private static void processRecord(String key, BMap<BString, Object> parentAnnotations,
                                      BMap<BString, Object> record, Object value, Type childType) {
        BMap<BString, Object>  parentRecordAnnotations = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BMap<BString, Object> annotation = ((RecordType) childType).getAnnotations();
        if (parentAnnotations.size() > 0) {
            annotation.merge(getFieldNamespaceAndNameAnnotations(key, parentAnnotations), true);
            processSubRecordAnnotation(parentAnnotations, parentRecordAnnotations);
        }
        BMap<BString, Object> subRecord = addFields(((BMap<BString, Object>) value), childType);
        if (annotation.size() > 0) {
            processSubRecordAnnotation(annotation, subRecord);
        }
        key = getElementName(annotation, key);
        record.put(StringUtils.fromString(key), subRecord);
        if (parentRecordAnnotations.size() > 0) {
            record.put(parentRecordAnnotations.getKeys()[0],
                    parentRecordAnnotations.get(parentRecordAnnotations.getKeys()[0]));
        }
    }

    @SuppressWarnings("unchecked")
    private static void addPrimitiveValue(QName qName, BMap<BString, Object> annotations,
                                          BMap<BString, Object> record, Object value) {
        BString localPart = StringUtils.fromString(qName.getLocalPart());
        BString key = qName.getPrefix().isBlank() ?
                localPart : StringUtils.fromString(qName.getPrefix() + ":" + localPart);
        BString annotationKey =
                StringUtils.fromString((Constants.FIELD + localPart).replace(Constants.COLON, "\\:"));
        BMap<BString, Object> currentValue;
        if (record.containsKey(key)) {
            currentValue = (BMap<BString, Object>) record.get(key);
            key = StringUtils.fromString("#content");
        } else {
            currentValue = record;
        }

        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            currentValue.put(StringUtils.fromString(processFieldAnnotation(annotationValue, key.getValue())), value);
        } else {
            currentValue.put(key, value);
        }
    }

    @SuppressWarnings("unchecked")
    private static void processArray(Type childType, BMap<BString, Object> annotations,
                                     BMap<BString, Object> record, Map.Entry<BString, Object> entry) {
        Type elementType = TypeUtils.getReferredType(((ArrayType) childType).getElementType());
        BMap<BString, Object>  annotationRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        String keyName = entry.getKey().getValue();
        if (annotations.size() > 0) {
            keyName = getKeyNameFromAnnotation(annotations, keyName);
            processSubRecordAnnotation(annotations, annotationRecord);
        }
        BArray arrayValue = (BArray) entry.getValue();
        if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            List<BMap<BString, Object>> records = new ArrayList<>();
            for (int i = 0; i < arrayValue.getLength(); i++) {
                BMap<BString, Object> subRecord = addFields(((BMap<BString, Object>) arrayValue.get(i)),
                        elementType);
                subRecord = processParentAnnotation(elementType, subRecord);
                records.add((BMap<BString, Object>) subRecord.get(subRecord.getKeys()[0]));
            }
            record.put(
                    StringUtils.fromString(getElementName(((RecordType) elementType).getAnnotations(), keyName)),
                    ValueCreator.createArrayValue(records.toArray(),
                            TypeCreator.createArrayType(Constants.JSON_ARRAY_TYPE)));
        } else {
            List<Object> records = new ArrayList<>();
            for (int i = 0; i < arrayValue.getLength(); i++) {
                records.add(arrayValue.get(i));
            }
            record.put(StringUtils.fromString(keyName), ValueCreator.createArrayValue(records.toArray(),
                    TypeCreator.createArrayType(Constants.JSON_ARRAY_TYPE)));
        }
        if (annotationRecord.size() > 0) {
            record.put(annotationRecord.getKeys()[0],
                    annotationRecord.get(annotationRecord.getKeys()[0]));
        }
    }

    @SuppressWarnings("unchecked")
    private static String getKeyNameFromAnnotation(BMap<BString, Object> annotations, String keyName) {
        BString annotationKey = StringUtils.fromString((Constants.FIELD + keyName).
                replace(Constants.COLON, "\\:"));
        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            return processFieldAnnotation(annotationValue, keyName);
        }
        return keyName;
    }

    public static Type getTypeFromUnionType(Type childType, Object value) {
        if (childType instanceof UnionType) {
            UnionType bUnionType = ((UnionType) childType);
            for (Type memberType : bUnionType.getMemberTypes()) {
                if (value.getClass().getName().toUpperCase(Locale.ROOT).contains(
                        memberType.getName().toUpperCase(Locale.ROOT))) {
                    childType = TypeUtils.getReferredType(memberType);
                }
            }
        }
        return childType;
    }

    private static BMap<BString, Object> processParentAnnotation(Type type, BMap<BString, Object> record) {
        BMap<BString, Object> parentRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BMap<BString, Object> namespaces = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BMap<BString, Object> annotations = ((RecordType) type).getAnnotations();
        BString rootName = processAnnotation(annotations, type.getName(), namespaces);
        if (namespaces.size() > 0) {
            for (Map.Entry<BString, Object> namespace : namespaces.entrySet()) {
                record.put(namespace.getKey(), namespace.getValue());
            }
        }
        parentRecord.put(rootName, record);
        return parentRecord;
    }

    @SuppressWarnings("unchecked")
    private static String processFieldAnnotation(BMap<BString, Object> annotation, String key) {
        for (BString value : annotation.getKeys()) {
            String stringValue = value.getValue();
            if (stringValue.endsWith(Constants.NAME)) {
                BMap<BString, Object> names = (BMap<BString, Object>) annotation.get(value);
                String name = names.get(StringUtils.fromString(VALUE)).toString();
                if (key.contains(Constants.COLON)) {
                    key = key.substring(0, key.indexOf(Constants.COLON) + 1) + name;
                } else if (key.contains(ATTRIBUTE_PREFIX)) {
                    key = key.substring(0, key.indexOf(Constants.UNDERSCORE) + 1) + name;
                } else {
                    key = name;
                }
            }
            if (stringValue.endsWith(Constants.ATTRIBUTE)) {
                key = ATTRIBUTE_PREFIX.concat(key);
            }
        }
        return key;
    }

    private static BString processAnnotation(BMap<BString, Object> annotation, String key,
                                             BMap<BString, Object> namespaces) {
        boolean hasNamespaceAnnotation = false;
        for (BString value : annotation.getKeys()) {
            if (!value.getValue().contains(Constants.FIELD)) {
                String stringValue = value.getValue();
                if (stringValue.endsWith(Constants.NAME)) {
                    key = processNameAnnotation(annotation, key, value, hasNamespaceAnnotation);
                }
                if (stringValue.endsWith(Constants.NAME_SPACE)) {
                    hasNamespaceAnnotation = true;
                    key = processNamespaceAnnotation(annotation, key, value, namespaces);
                }
            }
        }
        return StringUtils.fromString(key);
    }

    private static void processSubRecordAnnotation(BMap<BString, Object> annotation,
                                                   BMap<BString, Object>  subRecord) {
        BString[] keys = annotation.getKeys();
        for (BString value : keys) {
            if (value.getValue().endsWith(Constants.NAME_SPACE)) {
                processNamespaceAnnotation(annotation, "", value, subRecord);
            }
        }
    }

    @SuppressWarnings("unchecked")
    private static String getElementName(BMap<BString, Object> annotation, String key) {
        BString[] keys = annotation.getKeys();
        boolean hasNamespaceAnnotation = false;
        for (BString value : keys) {
            if (value.getValue().endsWith(Constants.NAME_SPACE)) {
                hasNamespaceAnnotation = true;
                BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotation.get(value);
                BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
                if (prefix != null) {
                    key = prefix.getValue().concat(Constants.COLON).concat(key);
                }
            }
            if (value.getValue().endsWith(Constants.NAME)) {
                key = processNameAnnotation(annotation, key, value, hasNamespaceAnnotation);
            }
        }
        return key;
    }

    @SuppressWarnings("unchecked")
    private static String processNameAnnotation(BMap<BString, Object> annotation, String key, BString value,
                                                boolean hasNamespaceAnnotation) {
        String nameValue = ((BMap<BString, Object>) annotation.get(value)).
                get(StringUtils.fromString(VALUE)).toString();
        if (hasNamespaceAnnotation) {
            return key.substring(0, key.indexOf(Constants.COLON) + 1) + nameValue;
        } else {
            return nameValue;
        }
    }

    @SuppressWarnings("unchecked")
    private static String processNamespaceAnnotation(BMap<BString, Object> annotation, String key, BString value,
                                                     BMap<BString, Object>  subRecord) {
        BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotation.get(value);
        BString uri = (BString) namespaceAnnotation.get(Constants.URI);
        BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
        if (prefix ==  null) {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns"), uri);
        } else {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns:" + prefix), uri);
            key = prefix.getValue().concat(Constants.COLON).concat(key);
        }
        return key;
    }

    @SuppressWarnings("unchecked")
    private static QName processFieldNamespaceAnnotation(BMap<BString, Object> annotation, String key, BString value,
                                                          BMap<BString, Object>  subRecord, boolean isAttributeField) {
        BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotation.get(value);
        BString uri = (BString) namespaceAnnotation.get(Constants.URI);
        BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
        QName qName = new QName(uri == null ? "" : uri.getValue(), key, prefix == null ? "" : prefix.getValue());
        if (isAttributeField) {
            addAttributeToRecord(prefix, uri, key, subRecord);
        } else {
            BMap<BString, Object> nextMapValue = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
            key = addAttributeToRecord(prefix, uri, key, nextMapValue);
            subRecord.put(StringUtils.fromString(key), nextMapValue);
        }
        return qName;
    }

    private static String addAttributeToRecord(BString prefix, BString uri, String key,
                                               BMap<BString, Object> subRecord) {
        if (prefix ==  null) {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns"), uri);
        } else {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns:" + prefix), uri);
            key = prefix.getValue().concat(Constants.COLON).concat(key);
        }
        return key;
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
