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

package io.ballerina.lib.data.xmldata.utils;

import io.ballerina.lib.data.xmldata.FromString;
import io.ballerina.lib.data.xmldata.xml.QualifiedName;
import io.ballerina.lib.data.xmldata.xml.QualifiedNameFactory;
import io.ballerina.lib.data.xmldata.xml.QualifiedNameMap;
import io.ballerina.lib.data.xmldata.xml.QualifiedNameSemantic;
import io.ballerina.lib.data.xmldata.xml.xsd.ChoiceInfo;
import io.ballerina.lib.data.xmldata.xml.xsd.ElementInfo;
import io.ballerina.lib.data.xmldata.xml.xsd.ModelGroupInfo;
import io.ballerina.lib.data.xmldata.xml.xsd.SequenceInfo;
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.AnnotatableType;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.ReferenceType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.constraint.Constraints;

import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import javax.xml.namespace.QName;

import static io.ballerina.lib.data.xmldata.utils.XsdUtils.popXsdValidationStacks;
import static io.ballerina.lib.data.xmldata.xml.QualifiedName.AttributeState.ATTRIBUTE;
import static io.ballerina.lib.data.xmldata.xml.QualifiedName.AttributeState.ELEMENT;
import static io.ballerina.lib.data.xmldata.xml.QualifiedName.AttributeState.NOT_DEFINED;

/**
 * A util class for the Data package's native implementation.
 *
 * @since 0.1.0
 */
public class DataUtils {
    private static final String ATTRIBUTE_PREFIX = "attribute_";
    private static final String VALUE = "value";
    private static String contentFieldName = Constants.CONTENT;

    @SuppressWarnings("unchecked")
    public static QualifiedName validateAndGetXmlNameFromRecordAnnotation(RecordType recordType, String recordName,
                                                                          QualifiedName elementName,
                                                                          boolean useSemanticEquality) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        String localName = recordName;
        for (BString annotationsKey : annotations.getKeys()) {
            if (isNameAnnotationKey(annotationsKey.getValue())) {
                String name = ((BMap<BString, Object>) annotations.get(annotationsKey)).get(Constants.VALUE).toString();
                String localPart = elementName.getLocalPart();
                if (!name.equals(localPart)) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.TYPE_NAME_MISMATCH_WITH_XML_ELEMENT, name, localPart);
                }
                localName = name;
                break;
            }
        }

        // Handle the namespace annotation.
        for (BString annotationsKey : annotations.getKeys()) {
            String key = annotationsKey.getValue();
            if (isNamespaceAnnotationKey(key)) {
                Map<BString, Object> namespaceAnnotation =
                        ((Map<BString, Object>) annotations.get(StringUtils.fromString(key)));
                BString uri = (BString) namespaceAnnotation.get(Constants.URI);
                BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
                return QualifiedNameFactory.createQualifiedName(uri == null ? "" : uri.getValue(), localName,
                        prefix == null ? "" : prefix.getValue(), useSemanticEquality);
            }
        }
        return QualifiedNameFactory.createQualifiedName(Constants.NS_ANNOT_NOT_DEFINED, localName, "",
                useSemanticEquality);
    }

    public static void validateTypeNamespace(String prefix, String uri, RecordType recordType) {
        ArrayList<String> namespace = getNamespace(recordType);
        if (namespace.isEmpty() || prefix.equals(namespace.get(0)) && uri.equals(namespace.get(1))) {
            return;
        }
        throw DiagnosticLog.error(DiagnosticErrorCode.NAMESPACE_MISMATCH, recordType.getName());
    }

    @SuppressWarnings("unchecked")
    private static ArrayList<String> getNamespace(RecordType recordType) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        ArrayList<String> namespace = new ArrayList<>();
        for (BString annotationsKey : annotations.getKeys()) {
            if (isNamespaceAnnotationKey(annotationsKey.getValue())) {
                BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotations.get(annotationsKey);
                namespace.add(namespaceAnnotation.containsKey(Constants.PREFIX) ?
                        ((BString) namespaceAnnotation.get(Constants.PREFIX)).getValue() : "");
                namespace.add(((BString) namespaceAnnotation.get(Constants.URI)).getValue());
                break;
            }
        }
        return namespace;
    }

    @SuppressWarnings("unchecked")
    public static Map<QualifiedName, Field> getAllFieldsInRecordType(RecordType recordType,
                                                                     XmlAnalyzerData analyzerData) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        HashMap<String, QualifiedName> modifiedNames = new LinkedHashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD)) {
                // Capture namespace and name from the field annotation.
                String fieldName = keyStr.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                QualifiedName fieldQName = DataUtils.getFieldNameFromRecord(fieldAnnotation, fieldName,
                        analyzerData.useSemanticEquality);
                fieldQName.setLocalPart(getModifiedName(fieldAnnotation, fieldName));
                modifiedNames.put(fieldName, fieldQName);
            }
        }

        Map<QualifiedName, Field> fieldMap = new HashMap<>();
        Map<String, List<QualifiedName>> fieldNames = new HashMap<>();
        Map<String, Field> recordFields = recordType.getFields();
        for (String key : recordFields.keySet()) {
            QualifiedNameMap<Field> attributeMap = analyzerData.attributeHierarchy.peek();
            QualifiedName modifiedQName =
                    modifiedNames.getOrDefault(key,
                            QualifiedNameFactory.createQualifiedName(Constants.NS_ANNOT_NOT_DEFINED, key, "",
                                    analyzerData.useSemanticEquality));
            String localName = modifiedQName.getLocalPart();
            if (attributeMap.contains(modifiedQName) && modifiedQName.getAttributeState() == NOT_DEFINED) {
                if (!key.equals(attributeMap.get(modifiedQName).getFieldName())) {
                    modifiedQName.setAttributeState(ELEMENT);
                    fieldMap.put(modifiedQName, recordFields.get(key));
                    fieldNames.put(localName, new ArrayList<>(List.of(modifiedQName)));
                }
            } else if (fieldMap.containsKey(modifiedQName)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.DUPLICATE_FIELD, localName);
            } else if (fieldNames.containsKey(localName)) {
                List<QualifiedName> qNames = fieldNames.get(localName);
                qNames.forEach(qName -> {
                    if (DataUtils.isSameAttributeFlag(qName.getAttributeState(), modifiedQName.getAttributeState())
                            && DataUtils.isSameNamespace(qName, modifiedQName)) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.DUPLICATE_FIELD, localName);
                    }
                });
                fieldMap.put(modifiedQName, recordFields.get(key));
                fieldNames.get(localName).add(modifiedQName);
            } else if (!attributeMap.contains(modifiedQName)) {
                fieldMap.put(modifiedQName, recordFields.get(key));
                fieldNames.put(localName, new ArrayList<>(List.of(modifiedQName)));
            }
        }
        return fieldMap;
    }

    @SuppressWarnings("unchecked")
    public static Map<QualifiedName, Field> getAllAttributesInRecordType(RecordType recordType,
                                                                         boolean useSemanticEquality) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        Map<QualifiedName, Field> attributes = new HashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD) && DataUtils.isAttributeField(annotationKey, annotations)) {
                String attributeName = keyStr.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                QualifiedName fieldQName = getFieldNameFromRecord(fieldAnnotation, attributeName, useSemanticEquality);
                fieldQName.setAttributeState(ATTRIBUTE);
                fieldQName.setLocalPart(getModifiedName(fieldAnnotation, attributeName));
                attributes.put(fieldQName, recordType.getFields().get(attributeName));
            }
        }
        return attributes;
    }

    @SuppressWarnings("unchecked")
    public static QualifiedName getFieldNameFromRecord(Map<BString, Object> fieldAnnotation, String fieldName,
                                                       boolean useSemanticEquality) {
        for (BString key : fieldAnnotation.keySet()) {
            if (isNamespaceAnnotationKey(key.getValue())) {
                Map<BString, Object> namespaceAnnotation = ((Map<BString, Object>) fieldAnnotation.get(key));
                BString uri = (BString) namespaceAnnotation.get(Constants.URI);
                BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
                return QualifiedNameFactory.createQualifiedName(uri == null ? "" : uri.getValue(), fieldName,
                        prefix == null ? "" : prefix.getValue(), useSemanticEquality);
            }
        }
        return QualifiedNameFactory.createQualifiedName(Constants.NS_ANNOT_NOT_DEFINED, fieldName, "",
                useSemanticEquality);
    }

    @SuppressWarnings("unchecked")
    static String getModifiedName(Map<BString, Object> fieldAnnotation, String attributeName) {
        for (BString key : fieldAnnotation.keySet()) {
            if (isNameAnnotationKey(key.getValue())) {
                return ((Map<BString, Object>) fieldAnnotation.get(key)).get(Constants.VALUE).toString();
            }
        }
        return attributeName;
    }

    public static QualifiedName getElementName(QName qName, boolean useSemanticEquality) {
        return QualifiedNameFactory.createQualifiedName(qName.getNamespaceURI(), qName.getLocalPart(),
                qName.getPrefix(), ELEMENT, useSemanticEquality);
    }

    public static Object convertStringToExpType(BString value, Type expType) {
        Object result;
        Type refferedType = TypeUtils.getReferredType(expType);
        switch (refferedType.getTag()) {
            case TypeTags.ANYDATA_TAG, TypeTags.ANY_TAG, TypeTags.JSON_TAG ->
                    result = FromString.fromStringWithType(value, PredefinedTypes.TYPE_JSON);
            case TypeTags.ARRAY_TAG -> result = convertStringToExpType(value,
                    ((ArrayType) refferedType).getElementType());
            case TypeTags.UNION_TAG -> result = convertStringToUnionExpType(value, expType);
            case TypeTags.XML_TAG -> result = ValueUtils.convert(value, expType);
            default -> result = FromString.fromStringWithType(value, expType);
        }

        if (result instanceof BError) {
            throw (BError) result;
        }
        return result;
    }

    private static Object convertStringToUnionExpType(BString value, Type expType) {
        for (Type memberType : ((UnionType) expType).getMemberTypes()) {
            memberType = TypeUtils.getReferredType(memberType);
            try {
                return convertStringToExpType(value, memberType);
            } catch (Exception ex) {
                // ignore
            }
        }
        throw DiagnosticLog.error(DiagnosticErrorCode.FIELD_CANNOT_CAST_INTO_TYPE, expType);
    }

    public static void validateRequiredFields(XmlAnalyzerData analyzerData, BMap<BString, Object> currentMapValue) {
        Map<QualifiedName, Field> fields = analyzerData.fieldHierarchy.peek().getMembers();
        for (QualifiedName key : fields.keySet()) {
            // Validate required array size
            Field field = fields.get(key);
            String fieldName = field.getFieldName();
            Type fieldType = TypeUtils.getReferredType(field.getFieldType());
            if (fieldType.getTag() == TypeTags.ARRAY_TAG) {
                ArrayType arrayType = (ArrayType) fieldType;
                if (arrayType.getSize() != -1
                        && arrayType.getSize() != ((BArray) currentMapValue.get(
                        StringUtils.fromString(fieldName))).getLength()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                }
                continue;
            }

            if (SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.REQUIRED)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.REQUIRED_FIELD_NOT_PRESENT, fieldName);
            }
        }

        Map<QualifiedName, Field> attributes = analyzerData.attributeHierarchy.peek().getMembers();
        for (QualifiedName key : attributes.keySet()) {
            Field field = attributes.get(key);
            if (!SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.REQUIRED_ATTRIBUTE_NOT_PRESENT, field.getFieldName());
            }
        }
    }

    public static boolean isArrayValueAssignable(Type type) {
        int typeTag = type.getTag();
        if (typeTag == TypeTags.UNION_TAG) {
            for (Type memberType : ((UnionType) type).getMemberTypes()) {
                memberType = TypeUtils.getReferredType(memberType);
                if (isArrayValueAssignable(memberType.getTag())) {
                    return true;
                }
            }
        }
        return isArrayValueAssignable(typeTag);
    }

    public static boolean isArrayValueAssignable(int typeTag) {
        return typeTag == TypeTags.ARRAY_TAG || typeTag == TypeTags.ANYDATA_TAG || typeTag == TypeTags.JSON_TAG;
    }

    public static boolean isStringValueAssignable(int typeTag) {
        return typeTag == TypeTags.STRING_TAG || typeTag == TypeTags.ANYDATA_TAG || typeTag == TypeTags.JSON_TAG;
    }

    public static BArray createArrayValue(Type type) {
        return switch (type.getTag()) {
            case TypeTags.ARRAY_TAG -> ValueCreator.createArrayValue((ArrayType) type);
            case TypeTags.JSON_TAG -> ValueCreator.createArrayValue(PredefinedTypes.TYPE_JSON_ARRAY);
            case TypeTags.ANYDATA_TAG -> ValueCreator.createArrayValue(PredefinedTypes.TYPE_ANYDATA_ARRAY);
            case TypeTags.TYPE_REFERENCED_TYPE_TAG -> createArrayValue(TypeUtils.getReferredType(type));
            default -> throw new IllegalStateException("Unexpected value: " + type.getTag());
        };
    }

    public static MapType getMapTypeFromConstraintType(Type constraintType) {
        return switch (constraintType.getTag()) {
            case TypeTags.MAP_TAG -> (MapType) constraintType;
            case TypeTags.INT_TAG, TypeTags.FLOAT_TAG, TypeTags.STRING_TAG, TypeTags.BOOLEAN_TAG, TypeTags.BYTE_TAG,
                 TypeTags.DECIMAL_TAG, TypeTags.JSON_TAG, TypeTags.RECORD_TYPE_TAG, TypeTags.OBJECT_TYPE_TAG,
                 TypeTags.XML_TAG, TypeTags.NULL_TAG -> TypeCreator.createMapType(constraintType);
            case TypeTags.ARRAY_TAG -> TypeCreator.createMapType(((ArrayType) constraintType).getElementType());
            case TypeTags.TYPE_REFERENCED_TYPE_TAG ->
                    getMapTypeFromConstraintType(TypeUtils.getReferredType(constraintType));
            default -> TypeCreator.createMapType(PredefinedTypes.TYPE_ANYDATA);
        };
    }

    public static void updateExpectedTypeStacks(RecordType recordType, XmlAnalyzerData analyzerData) {
        analyzerData.attributeHierarchy.push(new QualifiedNameMap<>(getAllAttributesInRecordType(recordType,
                analyzerData.useSemanticEquality)));
        analyzerData.fieldHierarchy.push(new QualifiedNameMap<>(getAllFieldsInRecordType(recordType, analyzerData)));
        analyzerData.visitedFieldHierarchy.push(new QualifiedNameMap<>(new HashMap<>()));
        analyzerData.restTypes.push(recordType.getRestFieldType());
        analyzerData.xsdModelGroupInfo.push(new HashMap<>());
        analyzerData.xmlElementInfo.push(new HashMap<>());
    }

    public static void popExpectedTypeStacks(XmlAnalyzerData analyzerData) {
        analyzerData.fieldHierarchy.pop();
        analyzerData.visitedFieldHierarchy.pop();
        analyzerData.restTypes.pop();
        analyzerData.attributeHierarchy.pop();
        analyzerData.arrayIndexes.pop();
        popXsdValidationStacks(analyzerData);
    }

    public static boolean isAnydataOrJson(int typeTag) {
        return typeTag == TypeTags.ANYDATA_TAG || typeTag == TypeTags.JSON_TAG;
    }

    public static boolean isSupportedType(Type type) {
        switch (type.getTag()) {
            case TypeTags.NULL_TAG, TypeTags.INT_TAG, TypeTags.BYTE_TAG, TypeTags.FLOAT_TAG, TypeTags.DECIMAL_TAG,
                 TypeTags.BOOLEAN_TAG, TypeTags.STRING_TAG, TypeTags.RECORD_TYPE_TAG, TypeTags.MAP_TAG,
                    TypeTags.JSON_TAG, TypeTags.ANYDATA_TAG,  TypeTags.FINITE_TYPE_TAG,
                    TypeTags.XML_TAG, TypeTags.XML_ELEMENT_TAG, TypeTags.XML_TEXT_TAG -> {
                return true;
            }
            case TypeTags.ARRAY_TAG -> {
                return isSupportedType(((ArrayType) type).getElementType());
            }
            case TypeTags.UNION_TAG -> {
                return isSupportedUnionType((UnionType) type);
            }
            case TypeTags.TYPE_REFERENCED_TYPE_TAG -> {
                return isSupportedType(TypeUtils.getReferredType(type));
            }
        }
        return false;
    }

    private static boolean isSupportedUnionType(UnionType type) {
        for (Type memberType : type.getMemberTypes()) {
            if (isSupportedType(memberType)) {
                return true;
            }
        }
        return false;
    }

    public static void updateOptions(BMap<BString, Object> options, XmlAnalyzerData analyzerData) {
        analyzerData.attributePrefix = options.get(Constants.ATTRIBUTE_PREFIX).toString();
        analyzerData.textFieldName = options.get(Constants.TEXT_FIELD_NAME).toString();
        analyzerData.allowDataProjection = (boolean) options.get(Constants.ALLOW_DATA_PROJECTION);
        analyzerData.useSemanticEquality = (boolean) options.get(Constants.USE_SEMANTIC_EQUALITY);
    }

    public static void logArrayMismatchErrorIfProjectionNotAllowed(boolean allowDataProjection) {
        if (allowDataProjection) {
            return;
        }
        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
    }

    public static boolean isSameNamespace(QualifiedName q1, QualifiedName q2) {
        String ns1 = q1.getNamespaceURI();
        String ns2 = q2.getNamespaceURI();
        if (q1 instanceof QualifiedNameSemantic && q2 instanceof QualifiedNameSemantic) {
            return ns1.equals(ns2)
                    || ns1.equals(Constants.NS_ANNOT_NOT_DEFINED) || ns2.equals(Constants.NS_ANNOT_NOT_DEFINED);
        } else {
            return (ns1.equals(ns2) && q1.getPrefix().equals(q2.getPrefix()))
                    || ns1.equals(Constants.NS_ANNOT_NOT_DEFINED) || ns2.equals(Constants.NS_ANNOT_NOT_DEFINED);
        }
    }

    public static boolean isSameAttributeFlag(QualifiedName.AttributeState flag1, QualifiedName.AttributeState flag2) {
        return flag1 == NOT_DEFINED || flag2 == NOT_DEFINED || flag1.equals(flag2);
    }

    public static boolean isXMLArrayType(Type type) {
        if (type.getTag() != TypeTags.ARRAY_TAG) {
            return false;
        }

        ArrayType arrayType = (ArrayType) type;
        Type elementType = TypeUtils.getReferredType(arrayType.getElementType());
        return TypeTags.isXMLTypeTag(elementType.getTag());
    }

    public static Object getModifiedRecord(BMap<BString, Object> input, BString textFieldName, BTypedesc type) {
        Type describingType = type.getDescribingType();
        Type referredType = TypeUtils.getReferredType(describingType);
        contentFieldName = textFieldName.getValue();

        if (describingType.getTag() == TypeTags.MAP_TAG) {
            Type constraintType = TypeUtils.getReferredType(((MapType) describingType).getConstrainedType());
            switch (constraintType.getTag()) {
                case TypeTags.ARRAY_TAG -> {
                    return processArrayValue(input, (ArrayType) constraintType);
                }
                case TypeTags.MAP_TAG -> {
                    BMap<BString, Object> jsonMap =
                            ValueCreator.createMapValue(TypeCreator.createMapType(PredefinedTypes.TYPE_XML));
                    for (Map.Entry<BString, Object> entry : input.entrySet()) {
                        jsonMap.put(entry.getKey(), entry.getValue());
                    }
                    return jsonMap;
                }
                case TypeTags.UNION_TAG -> {
                    return DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE);
                }
            }
        }
        if (referredType instanceof RecordType &&
                describingType.getFlags() != Constants.DEFAULT_TYPE_FLAG) {
            BArray jsonArray = ValueCreator.createArrayValue(PredefinedTypes.TYPE_JSON_ARRAY);
            BMap<BString, Object> recordField = addFields(input, describingType);
            BMap<BString, Object> processedRecord = processParentAnnotation(describingType, recordField);
            BString rootTagName = processedRecord.getKeys()[0];
            jsonArray.append(processedRecord.get(rootTagName));
            jsonArray.append(rootTagName);
            return jsonArray;
        }
        return input;
    }

    private static BMap<BString, Object> mergeOriginalAndCurrentAnnotations(
                                BMap<BString, Object> originalTypeAnnotations, BMap<BString, Object> typeAnnotations) {
        BMap<BString, Object> mergedAnnotations = ValueCreator.createMapValue();
        for (Map.Entry<BString, Object> entry : originalTypeAnnotations.entrySet()) {
            if (!mergedAnnotations.containsKey(entry.getKey())) {
                mergedAnnotations.put(entry.getKey(), entry.getValue());
            }
        }

        for (Map.Entry<BString, Object> entry : typeAnnotations.entrySet()) {
            if (!mergedAnnotations.containsKey(entry.getKey())) {
                mergedAnnotations.put(entry.getKey(), entry.getValue());
            }
        }  
        
        return mergedAnnotations; 
    }

    @SuppressWarnings("unchecked")
    private static BMap<BString, Object> processArrayValue(BMap<BString, Object> input, ArrayType arrayType) {
        Type elementType = arrayType.getElementType();
        Type referedType = TypeUtils.getReferredType(elementType);
        switch (referedType.getTag()) {
            case TypeTags.RECORD_TYPE_TAG -> {
                BMap<BString, Object> jsonMap = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                for (Map.Entry<BString, Object> entry : input.entrySet()) {
                    List<BMap<BString, Object>> records = new ArrayList<>();
                    BArray arrayValue = (BArray) entry.getValue();
                    for (int i = 0; i < arrayValue.getLength(); i++) {
                        BMap<BString, Object> record = addFields(((BMap<BString, Object>) arrayValue.get(i)),
                                elementType);
                        BMap<BString, Object> parentRecord = processParentAnnotation(referedType, record);
                        // Remove parent element
                        records.add((BMap<BString, Object>) parentRecord.get(parentRecord.getKeys()[0]));
                    }
                    jsonMap.put(entry.getKey(), ValueCreator.createArrayValue(records.toArray(),
                            TypeCreator.createArrayType(referedType)));
                }
                return jsonMap;
            }
            case TypeTags.XML_TAG -> {
                ArrayType xmlArrayType = TypeCreator.createArrayType(PredefinedTypes.TYPE_XML);
                BMap<BString, Object> jsonMap =
                        ValueCreator.createMapValue(TypeCreator.createMapType(xmlArrayType));
                for (Map.Entry<BString, Object> entry : input.entrySet()) {
                    BArray arrayValue = (BArray) entry.getValue();
                    BArray xmlArrayValue = ValueCreator.createArrayValue(xmlArrayType);
                    for (int i = 0; i < arrayValue.getLength(); i++) {
                        xmlArrayValue.append(arrayValue.get(i));
                    }
                    jsonMap.put(entry.getKey(), xmlArrayValue);
                }
                return jsonMap;
            }
            default -> {
                return input;
            }
        }
    }

    private static BMap<BString, Object> addFields(BMap<BString, Object> input, Type type) {
        BMap<BString, Object> recordValue = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BMap<BString, Object> annotations = ValueCreator.createMapValue();
        BMap<BString, Object> mergedAnnotations;
        if (type instanceof AnnotatableType annotatableType) {
            annotations = annotatableType.getAnnotations();
        }

        RecordType recordType = (RecordType) TypeUtils.getReferredType(type);
        if (type instanceof ReferenceType) {
            mergedAnnotations = mergeOriginalAndCurrentAnnotations(annotations, recordType.getAnnotations());
        } else {
            mergedAnnotations = annotations;
        }

        Map<String, Field> fields = recordType.getFields();
        for (Map.Entry<BString, Object> entry: input.entrySet()) {
            String key = entry.getKey().getValue();
            Object value = entry.getValue();
            if (fields.containsKey(key)) {
                processRecordField(fields.get(key).getFieldType(), mergedAnnotations, recordValue, entry, key, value);
            } else {
                recordValue.put(StringUtils.fromString(key), value);
            }
        }
        return recordValue;
    }

    static BString[] getOrderedRecordKeysIfXsdSequencePresent(BMap<BString, Object> input,
                                                              HashMap<String, Integer> xsdSequencePriorityOrder) {
        HashMap<String, String> localPartKeys = getLocalPartKeys(input);
        if (xsdSequencePriorityOrder.isEmpty()) {
            return input.getKeys();
        } else {
            return xsdSequencePriorityOrder.entrySet().stream()
                    .filter(entry -> localPartKeys.containsKey(entry.getKey()))
                    .sorted(Comparator.comparingInt(Map.Entry::getValue))
                    .map(entry -> StringUtils.fromString(localPartKeys.get(entry.getKey())))
                    .toArray(BString[]::new);
        }
    }

    private static HashMap<String, String> getLocalPartKeys(BMap<BString, Object> input) {
        HashMap<String, String> localPartKeys = new HashMap<>();
        for (Map.Entry<BString, Object> entry : input.entrySet()) {
            String k = entry.getKey().getValue();
            if (k.contains(ATTRIBUTE_PREFIX)) {
                continue;
            }
            int i = k.indexOf(Constants.COLON);
            if (i != -1) {
                localPartKeys.put(k.substring(i + 1), k);
            } else {
                localPartKeys.put(k, k);
            }
        }
        return localPartKeys;
    }

    private static void processRecordField(Type fieldType, BMap<BString, Object> annotations,
                                           BMap<BString, Object> recordValue, Map.Entry<BString, Object> entry,
                                           String key, Object value) {
        fieldType = getTypeFromUnionType(fieldType, value);
        switch (fieldType.getTag()) {
            case TypeTags.RECORD_TYPE_TAG -> processRecord(key, annotations, recordValue, value,
                    (RecordType) fieldType);
            case TypeTags.ARRAY_TAG -> processArray(fieldType, annotations, recordValue, entry);
            case TypeTags.TYPE_REFERENCED_TYPE_TAG -> {
                Type referredType = TypeUtils.getReferredType(fieldType);
                if (referredType.getTag() != TypeTags.RECORD_TYPE_TAG) {
                    processRecordField(referredType, annotations, recordValue, entry, key, value);
                    return;
                }
                processTypeReferenceType(fieldType, annotations, recordValue, key, value);
            }
            default -> addPrimitiveValue(addFieldNamespaceAnnotation(key, key, annotations, recordValue),
                    annotations, recordValue, value);
        }
    }

    @SuppressWarnings("unchecked")
    private static void processTypeReferenceType(Type fieldType, BMap<BString, Object> annotations,
                                                 BMap<BString, Object> recordValue, String key, Object value) {
        BMap<BString, Object> namespaceAnnotRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        Type referredType = TypeUtils.getReferredType(fieldType);
        RecordType recType = (RecordType) referredType;
        BMap<BString, Object> mergedAnnotations =
                mergeOriginalAndCurrentAnnotations(annotations, (recType).getAnnotations());
        boolean doesNamespaceDefinedInField = false;
        if (!mergedAnnotations.isEmpty()) {
            String fieldName = key;
            key = getKeyNameFromAnnotation(mergedAnnotations, key);
            QName qName = addFieldNamespaceAnnotation(fieldName, key, mergedAnnotations, namespaceAnnotRecord);
            if (!qName.getNamespaceURI().isEmpty()) {
                doesNamespaceDefinedInField = true;
            }
            String localPart = qName.getLocalPart();
            key = qName.getPrefix().isBlank() ? localPart : qName.getPrefix() + ":" + localPart;
        }

        BMap<BString, Object> annotationRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);

        if (!doesNamespaceDefinedInField) {
            BMap<BString, Object> subRecordAnnotations = recType.getAnnotations();
            key = getElementName(subRecordAnnotations, key);
            processSubRecordAnnotation(subRecordAnnotations, annotationRecord);
        }

        BMap<BString, Object> subRecordValue = addFields(((BMap<BString, Object>) value), referredType);
        addNamespaceToSubRecord(key, namespaceAnnotRecord, subRecordValue);
        if (!annotationRecord.isEmpty()) {
            subRecordValue.put(annotationRecord.getKeys()[0], annotationRecord.get(annotationRecord.getKeys()[0]));
        }
        recordValue.put(StringUtils.fromString(key), subRecordValue);
    }

    @SuppressWarnings("unchecked")
    private static void addNamespaceToSubRecord(String key, BMap<BString, Object> namespaceAnnotRecord,
                                                BMap<BString, Object> subRecord) {
        if (namespaceAnnotRecord.isEmpty()) {
            return;
        }

        Object value = namespaceAnnotRecord.get(StringUtils.fromString(key));
        if (value == null) {
            return;
        }

        for (Map.Entry<BString, Object> nsAnnotEntry : ((BMap<BString, Object>) value).entrySet()) {
            subRecord.put(nsAnnotEntry.getKey(), nsAnnotEntry.getValue());
        }
    }

    @SuppressWarnings("unchecked")
    private static QName addFieldNamespaceAnnotation(String fieldName, String key, BMap<BString, Object> annotations,
                                                     BMap<BString, Object> recordValue) {
        BString annotationKey = StringUtils.fromString(Constants.FIELD
                + (fieldName.replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, "\\\\$0")));
        boolean isAttributeField = isAttributeField(annotationKey, annotations);
        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            for (BString fieldKey : annotationValue.getKeys()) {
                if (isNamespaceAnnotationKey(fieldKey.getValue())) {
                    return processFieldNamespaceAnnotation(annotationValue, key, fieldKey, recordValue,
                            isAttributeField);
                }
            }
        }
        return new QName("", key, "");
    }

    @SuppressWarnings("unchecked")
    public static boolean isAttributeField(BString annotationKey, BMap<BString, Object> annotations) {
        if (!annotations.containsKey(annotationKey)) {
            return false;
        }

        BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
        for (BString fieldKey : annotationValue.getKeys()) {
            if (isAttributeAnnotationKey(fieldKey.getValue())) {
                return true;
            }
        }
        return false;
    }

    @SuppressWarnings("unchecked")
    private static BMap<BString, Object> getFieldNamespaceAndNameAnnotations(String key,
                                                                             BMap<BString, Object> parentAnnotations) {
        BMap<BString, Object> nsFieldAnnotation = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BString annotationKey =
                StringUtils.fromString((Constants.FIELD
                        + (key.replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, "\\\\$0"))));
        if (!parentAnnotations.containsKey(annotationKey)) {
            return nsFieldAnnotation;
        }

        BMap<BString, Object> annotationValue = (BMap<BString, Object>) parentAnnotations.get(annotationKey);
        for (BString fieldKey : annotationValue.getKeys()) {
            String keyName = fieldKey.getValue();
            if (isNamespaceAnnotationKey(keyName) || isNameAnnotationKey(keyName)) {
                nsFieldAnnotation.put(fieldKey, annotationValue.get(fieldKey));
                break;
            }
        }
        return nsFieldAnnotation;
    }

    @SuppressWarnings("unchecked")
    private static void processRecord(String key, BMap<BString, Object> parentAnnotations,
                                      BMap<BString, Object> record, Object value, RecordType childType) {
        BMap<BString, Object> parentRecordAnnotations = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BMap<BString, Object> annotation = childType.getAnnotations();
        if (!parentAnnotations.isEmpty()) {
            annotation.merge(getFieldNamespaceAndNameAnnotations(key, parentAnnotations), true);
            processSubRecordAnnotation(parentAnnotations, parentRecordAnnotations);
        }
        BMap<BString, Object> subRecord = addFields(((BMap<BString, Object>) value), childType);
        if (!annotation.isEmpty()) {
            processSubRecordAnnotation(annotation, subRecord);
        }

        key = getElementName(annotation, key);
        record.put(StringUtils.fromString(key), subRecord);

        if (!parentRecordAnnotations.isEmpty()) {
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
        BString annotationKey = StringUtils.fromString(Constants.FIELD
                + (localPart.getValue().replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, "\\\\$0")));
        BMap<BString, Object> currentValue;
        BString prevKey = key;
        if (record.containsKey(key)) {
            currentValue = (BMap<BString, Object>) record.get(key);
            prevKey = key;
            key = StringUtils.fromString(contentFieldName);
        } else {
            currentValue = record;
        }

        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            String keyName = processFieldAnnotation(annotationValue, prevKey.getValue());
            String prevKeyValue = prevKey.getValue(); 
            BString formattedKeyName = StringUtils.fromString(keyName);
            BString formattedContentFieldName = StringUtils.fromString(contentFieldName); 
            if (key.getValue().equals(contentFieldName)) {
                currentValue.put(formattedContentFieldName, value);
                if (!keyName.equals(prevKeyValue)) {
                    record.put(formattedKeyName, record.remove(prevKey));
                }
            } else {
                currentValue.put(formattedKeyName, value);
            }
        } else {
            currentValue.put(key, value);
        }
    }

    @SuppressWarnings("unchecked")
    private static void processArray(Type childType, BMap<BString, Object> annotations,
                                     BMap<BString, Object> record, Map.Entry<BString, Object> entry) {
        Type elementType = ((ArrayType) childType).getElementType();
        Type referedType = TypeUtils.getReferredType(elementType);
        BMap<BString, Object>  annotationRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        String keyName = entry.getKey().getValue();
        if (!annotations.isEmpty()) {
            keyName = getKeyNameFromAnnotation(annotations, keyName);
            processSubRecordAnnotation(annotations, annotationRecord);
        }
        BArray arrayValue = (BArray) entry.getValue();
        if (referedType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            List<BMap<BString, Object>> records = new ArrayList<>();
            for (int i = 0; i < arrayValue.getLength(); i++) {
                BMap<BString, Object> subRecord = addFields(((BMap<BString, Object>) arrayValue.get(i)),
                        elementType);
                subRecord = processParentAnnotation(referedType, subRecord);
                records.add((BMap<BString, Object>) subRecord.get(subRecord.getKeys()[0]));
            }
            record.put(
                    StringUtils.fromString(getElementName(((RecordType) referedType).getAnnotations(), keyName)),
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
        if (!annotationRecord.isEmpty()) {
            record.put(annotationRecord.getKeys()[0],
                    annotationRecord.get(annotationRecord.getKeys()[0]));
        }
    }

    @SuppressWarnings("unchecked")
    private static String getKeyNameFromAnnotation(BMap<BString, Object> annotations, String keyName) {
        BString annotationKey = StringUtils.fromString(Constants.FIELD
                + (keyName.replaceAll(Constants.RECORD_FIELD_NAME_ESCAPE_CHAR_REGEX, "\\\\$0")));
        if (annotations.containsKey(annotationKey)) {
            BMap<BString, Object> annotationValue = (BMap<BString, Object>) annotations.get(annotationKey);
            return processFieldAnnotation(annotationValue, keyName);
        }
        return keyName;
    }

    public static Type getTypeFromUnionType(Type childType, Object value) {
        if (childType instanceof UnionType bUnionType) {
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
        BMap<BString, Object> annotations = ValueCreator.createMapValue();
        BMap<BString, Object> mergedAnnotations;
        if (type instanceof AnnotatableType annotatableType) {
            annotations = annotatableType.getAnnotations();
        }
        Type referedType = TypeUtils.getReferredType(type);
        if (type instanceof ReferenceType) {
            mergedAnnotations =
                    mergeOriginalAndCurrentAnnotations(annotations, ((RecordType) referedType).getAnnotations());
        } else {
            mergedAnnotations = annotations;
        }

        BMap<BString, Object> parentRecord = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BMap<BString, Object> namespaces = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
        BString rootName = processAnnotation(mergedAnnotations, type.getName(), namespaces);
        if (!namespaces.isEmpty()) {
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
            if (isNameAnnotationKey(stringValue)) {
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
            if (isAttributeAnnotationKey(stringValue)) {
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
                if (isNameAnnotationKey(stringValue)) {
                    key = processNameAnnotation(annotation, key, value, hasNamespaceAnnotation);
                }
                if (isNamespaceAnnotationKey(stringValue)) {
                    hasNamespaceAnnotation = true;
                    key = processNamespaceAnnotation(annotation, key, value, namespaces);
                }
            }
        }
        return StringUtils.fromString(key);
    }

    private static void processSubRecordAnnotation(BMap<BString, Object> annotation, BMap<BString, Object> subRecord) {
        BString[] keys = annotation.getKeys();
        for (BString value : keys) {
            if (isNamespaceAnnotationKey(value.getValue())) {
                processNamespaceAnnotation(annotation, "", value, subRecord);
            }
        }
    }

    @SuppressWarnings("unchecked")
    private static String getElementName(BMap<BString, Object> annotation, String key) {
        BString[] keys = annotation.getKeys();
        boolean hasNamespaceAnnotation = false;
        for (BString value : keys) {
            if (isNamespaceAnnotationKey(value.getValue())) {
                hasNamespaceAnnotation = true;
                BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotation.get(value);
                BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
                if (prefix != null) {
                    key = prefix.getValue().concat(Constants.COLON).concat(key);
                }
            }
        }

        for (BString value : keys) {
            if (isNameAnnotationKey(value.getValue())) {
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
                                                     BMap<BString, Object> subRecord) {
        BMap<BString, Object> namespaceAnnotation = (BMap<BString, Object>) annotation.get(value);
        BString uri = (BString) namespaceAnnotation.get(Constants.URI);
        BString prefix = (BString) namespaceAnnotation.get(Constants.PREFIX);
        if (prefix == null) {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns"), uri);
        } else {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns:" + prefix), uri);
            key = prefix.getValue().concat(Constants.COLON).concat(key);
        }
        return key;
    }

    @SuppressWarnings("unchecked")
    private static QName processFieldNamespaceAnnotation(BMap<BString, Object> annotation, String key, BString value,
                                                         BMap<BString, Object> subRecord, boolean isAttributeField) {
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
        if (prefix == null) {
            subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns"), uri);
            return key;
        }
        subRecord.put(StringUtils.fromString(ATTRIBUTE_PREFIX + "xmlns:" + prefix), uri);
        return prefix.getValue().concat(Constants.COLON).concat(key);
    }

    public static boolean isRegExpType(Type type) {
        Module module = type.getPackage();
        if (module == null) {
            return false;
        }

        String moduleName = module.getName();
        String typeName = type.getName();
        if (typeName == null || moduleName == null) {
            return false;
        }
        if (moduleName.equals(Constants.REGEXP_MODULE_NAME) && typeName.equals(Constants.REGEXP_TYPE_NAME)) {
            return true;
        }

        if (type.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG) {
            return isRegExpType(((ReferenceType) type).getReferredType());
        }
        return false;
    }

    private static boolean isNamespaceAnnotationKey(String key) {
        return key.startsWith(Constants.MODULE_NAME) && key.endsWith(Constants.NAMESPACE);
    }

    public static boolean isNameAnnotationKey(String key) {
        return key.startsWith(Constants.MODULE_NAME) && key.endsWith(Constants.NAME);
    }

    private static boolean isAttributeAnnotationKey(String key) {
        return key.startsWith(Constants.MODULE_NAME) && key.endsWith(Constants.ATTRIBUTE);
    }

    public static Object validateConstraints(Object convertedValue, BTypedesc typed, boolean requireValidation) {
        if (!requireValidation) {
            return convertedValue;
        }

        Object result = Constraints.validate(convertedValue, typed);
        if (result instanceof BError bError) {
            return DiagnosticLog.createXmlError(getPrintableErrorMsg(bError));
        }
        return convertedValue;
    }

    private static String getPrintableErrorMsg(BError err) {
        String errorMsg = err.getMessage() != null ? err.getMessage() : "";
        Object details = err.getDetails();
        if (details != null && !details.toString().equals("{}")) {
            errorMsg += ", " + details;
        }
        return errorMsg;
    }

    public static boolean isEqualQualifiedName(QualifiedName firstQName, QualifiedName secondQName) {
        if (firstQName == null || secondQName == null) {
            return false;
        }

        if (firstQName.equals(secondQName)) {
            return true;
        }

        return firstQName.getLocalPart().equals(secondQName.getLocalPart())
                && (firstQName.getNamespaceURI().equals(Constants.NS_ANNOT_NOT_DEFINED)
                || secondQName.getNamespaceURI().equals(Constants.NS_ANNOT_NOT_DEFINED));
    }

    public static boolean isSimpleType(Type type) {
        return switch (type.getTag()) {
            case TypeTags.JSON_TAG, TypeTags.ANYDATA_TAG, TypeTags.MAP_TAG, TypeTags.OBJECT_TYPE_TAG,
                 TypeTags.RECORD_TYPE_TAG, TypeTags.XML_TAG -> false;
            case TypeTags.ARRAY_TAG -> isSimpleType(((ArrayType) type).getElementType());
            case TypeTags.TYPE_REFERENCED_TYPE_TAG -> isSimpleType(((ReferenceType) type).getReferredType());
            default -> true;
        };
    }

    public static String generateStringFromXmlReader(Reader reader) throws IOException {
        StringBuilder builder = new StringBuilder();
        char[] buffer = new char[1024];
        int numCharsRead;
        while ((numCharsRead = reader.read(buffer)) != -1) {
            builder.append(buffer, 0, numCharsRead);
        }
        return builder.toString();
    }

    public static boolean isSupportedTypeForAttributes(Type fieldType) {
        if (TypeTags.isIntegerTypeTag(fieldType.getTag())) {
            return true;
        }

        if (TypeTags.isStringTypeTag(fieldType.getTag())) {
            return true;
        }

        if (TypeTags.isXMLTypeTag(fieldType.getTag())) {
            return false;
        }

        return switch (fieldType.getTag()) {
            case TypeTags.FLOAT_TAG, TypeTags.BOOLEAN_TAG, TypeTags.NULL_TAG,
                    TypeTags.DECIMAL_TAG, TypeTags.BYTE_TAG, TypeTags.UNION_TAG, TypeTags.ANYDATA_TAG,
                    TypeTags.ANY_TAG, TypeTags.JSON_TAG -> true;
            default -> false;
        };
    }

    public static boolean isContainsUnionType(Type expType) {
        if (expType == null) {
            return false;
        }
        expType = TypeUtils.getReferredType(expType);
        if (expType.getTag() == TypeTags.UNION_TAG) {
            for (Type memberType : ((UnionType) expType).getMemberTypes()) {
                if (!isSimpleType(memberType)) {
                    return true;
                }
            }
        }

        if (expType.getTag() == TypeTags.ARRAY_TAG) {
            Type memberType = TypeUtils.getReferredType(((ArrayType) expType).getElementType());
            return isContainsUnionType(memberType);
        }

        if (expType.getTag() == TypeTags.MAP_TAG) {
            Type memberType = TypeUtils.getReferredType(((MapType) expType).getConstrainedType());
            return isContainsUnionType(memberType);
        }

        if (expType.getTag() == TypeTags.TUPLE_TAG) {
            TupleType tupleType = (TupleType) expType;
            for (Type type : tupleType.getTupleTypes()) {
                if (isContainsUnionType(type)) {
                    return true;
                }
            }
            return isContainsUnionType(tupleType.getRestType());
        }

        if (expType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            RecordType recordType = (RecordType) expType;
            for (Field field : recordType.getFields().values()) {
                if (isContainsUnionType(field.getFieldType())) {
                    return true;
                }
            }
            return isContainsUnionType(recordType.getRestFieldType());
        }
        return false;
    }


    public static Collection<String> getXmlElementNames(RecordType fieldType) {
        HashSet<String> elementNames = new HashSet<>(fieldType.getFields().keySet());
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (key.contains(Constants.FIELD)) {
                String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                    updateFieldSetWithName(fieldAnnotation, elementNames, fieldAnnotationKey, fieldName);
                }
            }
        }
        return elementNames;
    }

    private static void updateFieldSetWithName(Map<BString, Object> fieldAnnotation, Set<String> elementNames,
                                               BString fieldAnnotationKey, String fieldName) {
        String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
        if (fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
            if (fieldAnnotationKeyStr.endsWith(Constants.NAME)) {
                BMap<BString, Object> fieldAnnotationValue =
                        (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
                String xmlElementName = StringUtils.getStringValue(fieldAnnotationValue
                        .getStringValue(Constants.VALUE));
                elementNames.remove(fieldName);
                elementNames.add(xmlElementName);
            }
        }
    }

    public static HashMap<String, String> getXmlElementNameMap(RecordType fieldType) {
        HashMap<String, String> elementMap = new HashMap<>();
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (key.contains(Constants.FIELD)) {
                String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                    getXmlElementNameFromFieldAnnotation(fieldAnnotation, fieldAnnotationKey, fieldName, elementMap);
                }
            }
        }
        return elementMap;
    }

    private static void getXmlElementNameFromFieldAnnotation(Map<BString, Object> fieldAnnotation,
                                               BString fieldAnnotationKey, String fieldName,
                                               HashMap<String, String> xmlElementNameMap) {
        String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
        if (fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
            if (fieldAnnotationKeyStr.endsWith(Constants.NAME)) {
                BMap<BString, Object> fieldAnnotationValue =
                        (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
                String xmlElementName = StringUtils.getStringValue(fieldAnnotationValue
                        .getStringValue(Constants.VALUE));
                xmlElementNameMap.remove(fieldName);
                xmlElementNameMap.put(xmlElementName, fieldName);
            }
        }
    }

    public static void popMappingTypeStacks(XmlAnalyzerMetaData xmlParserData) {
        xmlParserData.fieldHierarchy.pop();
        xmlParserData.visitedFieldHierarchy.pop();
        xmlParserData.restTypes.pop();
    }

    public static HashMap<String, Integer> getXsdSequencePriorityOrder(RecordType fieldType) {
        return getXsdSequencePriorityOrder(fieldType, false);
    }

    public static HashMap<String, Integer> getXsdSequencePriorityOrder(Type type, boolean isSequenceElements) {
        if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
            return new HashMap<>();
        }

        RecordType fieldType = (RecordType) type;
        HashMap<String, Integer> elementPriorityOrder = new HashMap<>();
        if (!isSequenceElements) {
            return elementPriorityOrder;
        }
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (!key.contains(Constants.FIELD)) {
                continue;
            }

            String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
            Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
            for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                if (!fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                    continue;
                }
                if (fieldAnnotationKeyStr.endsWith(Constants.ORDER)) {
                    BMap<BString, Object> fieldAnnotationValue =
                            (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
                    elementPriorityOrder.put(fieldName,
                            fieldAnnotationValue.getIntValue(Constants.VALUE).intValue());
                }
            }
        }
        return elementPriorityOrder;
    }

    public static HashMap<String, ModelGroupInfo> getFieldNamesWithModelGroupAnnotations(RecordType fieldType,
                                                                           HashMap<String, String> elementNamesMap) {
        HashMap<String, ModelGroupInfo> fieldNamesWithModelGroupAnnotations = new HashMap<>();
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (!key.contains(Constants.FIELD)) {
                continue;
            }

            String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
            if (elementNamesMap.containsKey(fieldName)) {
                fieldName = elementNamesMap.get(fieldName);
            }

            Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
            for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                if (!fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                    continue;
                }
                if (fieldAnnotationKeyStr.endsWith(Constants.SEQUENCE)) {
                    SequenceInfo sequenceInfo = new SequenceInfo(fieldName,
                            (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey),
                            fieldType, null);
                    fieldNamesWithModelGroupAnnotations.put(fieldName, sequenceInfo);
                }

                if (fieldAnnotationKeyStr.endsWith(Constants.CHOICE)) {
                    ChoiceInfo choiceInfo = new ChoiceInfo(fieldName,
                            (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey),
                            fieldType, null);
                    fieldNamesWithModelGroupAnnotations.put(fieldName, choiceInfo);
                }
            }
        }
        return fieldNamesWithModelGroupAnnotations;
    }

    public static HashMap<String, ElementInfo> getFieldNamesWithElementGroupAnnotations(
                    RecordType fieldType, HashMap<String, String> elementNamesMap, String xmlElementName) {
        HashMap<String, ElementInfo> fieldNamesWithElementInfoAnnotations = new HashMap<>();
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (!key.contains(Constants.FIELD)) {
                continue;
            }

            String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
            if (elementNamesMap.containsKey(fieldName)) {
                fieldName = elementNamesMap.get(fieldName);
            }

            Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
            for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                if (!fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                    continue;
                }

                if (fieldAnnotationKeyStr.endsWith(Constants.ELEMENT)) {
                    ElementInfo elementInfo = new ElementInfo(xmlElementName, fieldName,
                            (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey));
                    fieldNamesWithElementInfoAnnotations.put(fieldName, elementInfo);
                }
            }
        }
        return fieldNamesWithElementInfoAnnotations;
    }


    public static ArrayList<String> getFieldNamesWithSequenceAnnotations(RecordType fieldType,
                                                                           HashMap<String, String> elementNamesMap) {
        ArrayList<String> fieldNamesWithModelGroupAnnotations = new ArrayList<>();
        BMap<BString, Object> annotations = fieldType.getAnnotations();
        for (BString annotationKey : annotations.getKeys()) {
            String key = annotationKey.getValue();
            if (!key.contains(Constants.FIELD)) {
                continue;
            }

            String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
            Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
            for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                if (!fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                    continue;
                }

                if (fieldAnnotationKeyStr.endsWith(Constants.SEQUENCE)) {
                    if (elementNamesMap.containsKey(fieldName)) {
                        fieldNamesWithModelGroupAnnotations.add(elementNamesMap.get(fieldName));
                    } else {
                        fieldNamesWithModelGroupAnnotations.add(fieldName);
                    }
                }
            }
        }
        return fieldNamesWithModelGroupAnnotations;
    }

    public static HashMap<String, String> getElementNameMap(Type type) {
        HashMap<String, String> names = new HashMap<>();
        if (type instanceof RecordType recordType) {
            BMap<BString, Object> annotations = recordType.getAnnotations();
            for (BString annotationKey : annotations.getKeys()) {
                String key = annotationKey.getValue();
                if (!key.contains(Constants.FIELD)) {
                    continue;
                }
                String fieldName = key.split(Constants.FIELD_REGEX)[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                for (BString fieldAnnotationKey : fieldAnnotation.keySet()) {
                    String fieldAnnotationKeyStr = fieldAnnotationKey.getValue();
                    if (!fieldAnnotationKeyStr.startsWith(Constants.MODULE_NAME)) {
                        continue;
                    }

                    if (fieldAnnotationKeyStr.endsWith(Constants.NAME)) {
                        BMap<BString, Object> fieldAnnotationValue =
                                (BMap<BString, Object>) fieldAnnotation.get(fieldAnnotationKey);
                        String xmlElementName = StringUtils.getStringValue(fieldAnnotationValue
                                .getStringValue(Constants.VALUE));
                        names.put(xmlElementName, fieldName);
                    }
                }
            }
            return names;
        }
        return names;
    }

    /**
     * Holds data required for the processing.
     *
     * @since 1.1.0
     */
    public static class XmlAnalyzerMetaData {
        public Stack<QualifiedNameMap<Field>> attributeHierarchy = new Stack<>();
        public Stack<HashMap<String, Integer>> arrayIndexes = new Stack<>();
        public Stack<HashMap<String, ElementInfo>> xmlElementInfo = new Stack<>();
        public Stack<HashMap<String, ModelGroupInfo>> xsdModelGroupInfo = new Stack<>();
        public Stack<ModelGroupInfo> modelGroupStack = new Stack<>();

        public Stack<Object> nodesStack = new Stack<>();
        public Stack<QualifiedNameMap<Field>> fieldHierarchy = new Stack<>();
        public Stack<QualifiedNameMap<Field>> visitedFieldHierarchy = new Stack<>();
        public Stack<Type> restTypes = new Stack<>();
        public RecordType rootRecord;
        public Field currentField;
        public boolean allowDataProjection;
        public boolean useSemanticEquality;
        public String attributePrefix;
        public String textFieldName;
        public BMap<BString, Object> currentNode;
        public final Stack<RecordType> recordTypeStack = new Stack<>();
    }

    /**
     * Holds data required for the traversing.
     *
     * @since 0.1.0
     */
    public static class XmlAnalyzerData extends XmlAnalyzerMetaData {
        @SuppressWarnings("unchecked")
        public static XmlAnalyzerData copy(XmlAnalyzerData analyzerData) {
            XmlAnalyzerData data = new XmlAnalyzerData();
            data.nodesStack = (Stack<Object>) analyzerData.nodesStack.clone();
            data.fieldHierarchy = (Stack<QualifiedNameMap<Field>>) analyzerData.fieldHierarchy.clone();
            data.visitedFieldHierarchy = (Stack<QualifiedNameMap<Field>>) analyzerData.visitedFieldHierarchy.clone();
            data.attributeHierarchy = (Stack<QualifiedNameMap<Field>>) analyzerData.attributeHierarchy.clone();
            data.restTypes = (Stack<Type>) analyzerData.restTypes.clone();
            data.arrayIndexes = (Stack<HashMap<String, Integer>>) analyzerData.arrayIndexes.clone();
            data.rootRecord = analyzerData.rootRecord;
            data.currentField = analyzerData.currentField;
            data.attributePrefix = analyzerData.attributePrefix;
            data.textFieldName = analyzerData.textFieldName;
            data.allowDataProjection = analyzerData.allowDataProjection;
            data.useSemanticEquality = analyzerData.useSemanticEquality;
            data.xmlElementInfo = (Stack<HashMap<String, ElementInfo>>) analyzerData.xmlElementInfo.clone();
            data.xsdModelGroupInfo = (Stack<HashMap<String, ModelGroupInfo>>) analyzerData.xsdModelGroupInfo.clone();
            data.modelGroupStack = (Stack<ModelGroupInfo>) analyzerData.modelGroupStack.clone();

            return data;
        }

        public void resetFrom(XmlAnalyzerData analyzerData) {
            this.nodesStack = analyzerData.nodesStack;
            this.fieldHierarchy = analyzerData.fieldHierarchy;
            this.visitedFieldHierarchy = analyzerData.visitedFieldHierarchy;
            this.attributeHierarchy = analyzerData.attributeHierarchy;
            this.restTypes = analyzerData.restTypes;
            this.arrayIndexes = analyzerData.arrayIndexes;
            this.rootRecord = analyzerData.rootRecord;
            this.currentField = analyzerData.currentField;
            this.attributePrefix = analyzerData.attributePrefix;
            this.textFieldName = analyzerData.textFieldName;
            this.allowDataProjection = analyzerData.allowDataProjection;
            this.useSemanticEquality = analyzerData.useSemanticEquality;
            this.xmlElementInfo = analyzerData.xmlElementInfo;
            this.xsdModelGroupInfo = analyzerData.xsdModelGroupInfo;
            this.modelGroupStack = analyzerData.modelGroupStack;
        }
    }

    /**
     * Holds data required for the parsing.
     *
     * @since 0.1.1
     */
    public static class XmlParserData extends XmlAnalyzerMetaData {
        public final Stack<QualifiedName> restFieldsPoints = new Stack<>();
        public final Stack<QualifiedNameMap<Boolean>> parents = new Stack<>();
        public QualifiedNameMap<Boolean> siblings = new QualifiedNameMap<>(new LinkedHashMap<>());
    }
}
