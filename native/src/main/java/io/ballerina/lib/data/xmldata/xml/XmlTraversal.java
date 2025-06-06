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

package io.ballerina.lib.data.xmldata.xml;

import io.ballerina.lib.data.xmldata.utils.Constants;
import io.ballerina.lib.data.xmldata.utils.DataUtils;
import io.ballerina.lib.data.xmldata.utils.DataUtils.XmlAnalyzerData;
import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.lib.data.xmldata.xml.xsd.ModelGroupInfo;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.types.XmlNodeType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import io.ballerina.runtime.api.values.BXmlItem;
import io.ballerina.runtime.api.values.BXmlSequence;
import org.ballerinalang.langlib.xml.Concat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.xml.namespace.QName;

import static io.ballerina.lib.data.xmldata.utils.Constants.ENABLE_CONSTRAINT_VALIDATION;
import static io.ballerina.lib.data.xmldata.utils.XsdUtils.initializeXsdInformation;
import static io.ballerina.lib.data.xmldata.utils.XsdUtils.updateElementOccurrence;
import static io.ballerina.lib.data.xmldata.utils.XsdUtils.validateCurrentElementInfo;
import static io.ballerina.lib.data.xmldata.utils.XsdUtils.validateElementInfoStack;
import static io.ballerina.lib.data.xmldata.utils.XsdUtils.validateModelGroupInfoStack;
import static io.ballerina.lib.data.xmldata.utils.XsdUtils.validateModelGroupStack;

/**
 * Convert Xml value to a ballerina record.
 *
 * @since 0.1.0
 */
public class XmlTraversal {

    private static final ThreadLocal<XmlTree> tlXmlTree = ThreadLocal.withInitial(XmlTree::new);

    public static Object traverse(BXml xml, BMap<BString, Object> options, BTypedesc typed) {
        Object convertedValue = traverse(xml, options, typed.getDescribingType());

        if (convertedValue instanceof BError) {
            return convertedValue;
        }
        return DataUtils.validateConstraints(convertedValue, typed,
                (Boolean) options.get(ENABLE_CONSTRAINT_VALIDATION));
    }

    public static Object traverse(BXml xml, BMap<BString, Object> options, Type type) {
        XmlTree xmlTree = tlXmlTree.get();
        return xmlTree.traverseXml(xml, options, type);
    }

    static class XmlTree {
        public Object traverseXml(BXml xml, BMap<BString, Object> options, Type type) {
            XmlAnalyzerData analyzerData = new XmlAnalyzerData();
            DataUtils.updateOptions(options, analyzerData);
            traverseXml(xml, analyzerData, type);
            validateElementInfoStack(analyzerData);
            validateModelGroupInfoStack(analyzerData);
            return analyzerData.currentNode;
        }

        public Object traverseXml(BXml xml, XmlAnalyzerData analyzerData, Type type) {
            Type referredType = TypeUtils.getReferredType(type);
            switch (referredType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG -> {
                    return traverseXmlWithRecordAsExpectedType(xml, analyzerData, (RecordType) referredType);
                }
                case TypeTags.MAP_TAG -> {
                    return traverseXmlWithMapAsExpectedType(xml, (MapType) referredType, analyzerData);
                }
                case TypeTags.UNION_TAG -> {
                    return traverseXmlToUnion(xml, analyzerData, (UnionType) referredType);
                }
                default -> throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, Constants.RECORD_OR_MAP, type);
            }
        }
        
        private Object traverseXmlWithRecordAsExpectedType(BXml xml, XmlAnalyzerData analyzerData,
                                                           RecordType recordType) {
            analyzerData.currentNode = ValueCreator.createRecordValue(recordType.getPackage(), recordType.getName());
            BXml nextXml = validateRootElement(xml, recordType, analyzerData);
            Object resultRecordValue = traverseXml(nextXml, recordType, analyzerData);
            validateModelGroupStackForRootElement(analyzerData);
            validateCurrentElementInfo(analyzerData);
            DataUtils.validateRequiredFields(analyzerData, analyzerData.currentNode);
            return resultRecordValue;
        }

        private Object traverseXmlWithMapAsExpectedType(BXml xml, MapType mapType, XmlAnalyzerData analyzerData) {
            RecordType anonRecType = TypeCreator.createRecordType(Constants.ANON_TYPE, mapType.getPackage(), 0,
                    new HashMap<>(), mapType.getConstrainedType(), false, 0);
            return traverseXml(xml, analyzerData, anonRecType);
        }

        private Object traverseXmlToUnion(BXml xml, XmlAnalyzerData options, UnionType unionType) {
            XmlAnalyzerData clonedAnalyzerData = XmlAnalyzerData.copy(options);
            for (Type memberType: unionType.getMemberTypes()) {
                memberType = TypeUtils.getReferredType(memberType);
                try {
                    if (memberType.getTag() == TypeTags.ERROR_TAG) {
                        continue;
                    }
                    return traverseXml(xml, options, memberType);
                } catch (Exception ex) {
                    options.resetFrom(clonedAnalyzerData);
                    // ignore
                }
            }
            throw DiagnosticLog.error(DiagnosticErrorCode.CANNOT_CONVERT_SOURCE_INTO_EXP_TYPE, unionType);
        }

        private Object traverseXml(BXml xml, Type type, XmlAnalyzerData analyzerData) {
            switch (xml.getNodeType()) {
                case ELEMENT -> {
                    if (!(DataUtils.isXMLArrayType(type) || TypeTags.isXMLTypeTag(type.getTag()))) {
                        convertElement((BXmlItem) xml, analyzerData);
                    } else {
                        convertXml(xml, type.getTag(), analyzerData);
                    }
                }
                case SEQUENCE -> convertSequence((BXmlSequence) xml, type, analyzerData);
                case TEXT -> convertXml(xml, TypeTags.STRING_TAG, analyzerData);
            }

            return analyzerData.currentNode;
        }

        @SuppressWarnings("unchecked")
        private void convertXml(BXml xml, int typeTag, XmlAnalyzerData analyzerData) {
            Field currentField = analyzerData.currentField;
            BMap<BString, Object> mapValue = analyzerData.currentNode;
            boolean isText = typeTag == TypeTags.STRING_TAG;
            String textFieldName = analyzerData.textFieldName;
            if (currentField == null) {
                QualifiedName contentQName = QualifiedNameFactory.createQualifiedName("", textFieldName, "",
                        analyzerData.useSemanticEquality);
                if (analyzerData.fieldHierarchy.peek().contains(contentQName)) {
                    currentField = analyzerData.fieldHierarchy.peek().remove(contentQName);
                } else if (analyzerData.visitedFieldHierarchy.peek().contains(contentQName)) {
                    currentField = analyzerData.visitedFieldHierarchy.peek().get(contentQName);
                } else if (analyzerData.restTypes.peek() != null) {
                    currentField = TypeCreator.createField(analyzerData.restTypes.peek(),
                            analyzerData.textFieldName, SymbolFlags.REQUIRED);
                } else if (!analyzerData.allowDataProjection) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.UNDEFINED_FIELD, textFieldName,
                            analyzerData.rootRecord);
                } else {
                    return;
                }
            }

            Type fieldType = currentField.getFieldType();

            Object convertedValue = null;
            if (DataUtils.isRegExpType(fieldType)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE);
            }

            fieldType = TypeUtils.getReferredType(fieldType);
            BString fieldName = StringUtils.fromString(currentField.getFieldName());
            Object value = mapValue.get(fieldName);
            if (fieldType.getTag() == TypeTags.UNION_TAG) {
                XmlAnalyzerData clonedAnalyzerData = XmlAnalyzerData.copy(analyzerData);
                for (Type memberType: ((UnionType) fieldType).getMemberTypes()) {
                    try {
                        if (!(value instanceof BArray) && memberType.getTag() == TypeTags.ARRAY_TAG) {
                            continue;
                        }
                        convertedValue = isText ? DataUtils.convertStringToExpType(StringUtils.fromString(xml.
                                toString()), memberType) : xml.copy(new HashMap<>());
                        fieldType = memberType;
                        break;
                    } catch (Exception ex) {
                        analyzerData.resetFrom(clonedAnalyzerData);
                        // ignore
                    }
                }
                if (convertedValue == null) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.FIELD_CANNOT_CAST_INTO_TYPE, fieldName, fieldType);
                }
            } else {
                convertedValue = isText ? DataUtils.convertStringToExpType(StringUtils.fromString(xml.toString()),
                        fieldType) : xml.copy(new HashMap<>());
            }

            if (value instanceof BArray) {
                if (fieldName.getValue().equals(textFieldName)) {
                    mapValue.put(fieldName, convertedValue);
                    return;
                }

                if (DataUtils.isAnydataOrJson(fieldType.getTag())) {
                    ((BArray) value).append(convertedValue);
                    return;
                }

                ArrayType arrayType = (ArrayType) fieldType;
                int currentIndex = analyzerData.arrayIndexes.peek().get(fieldName.getValue());
                if (arrayType.getState() == ArrayType.ArrayState.CLOSED && arrayType.getSize() <= currentIndex) {
                    DataUtils.logArrayMismatchErrorIfProjectionNotAllowed(analyzerData.allowDataProjection);
                    return;
                }
                ((BArray) value).add(currentIndex, convertedValue);
            } else {
                if (fieldType.getTag() == TypeTags.ARRAY_TAG) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.CANNOT_CONVERT_TO_EXPECTED_TYPE,
                            PredefinedTypes.TYPE_STRING.getName(), xml, fieldType);
                }
                mapValue.put(fieldName, convertedValue);
            }
        }

        @SuppressWarnings("unchecked")
        private void convertElement(BXmlItem xmlItem, XmlAnalyzerData analyzerData) {
            QualifiedName elementQName = DataUtils.getElementName(xmlItem.getQName(), analyzerData.useSemanticEquality);
            updateElementOccurrence(analyzerData, elementQName);
            validateModelGroupStack(analyzerData, elementQName, true);
            QualifiedNameMap<Field> fieldsMap = analyzerData.fieldHierarchy.peek();
            Field currentField;
            if (analyzerData.visitedFieldHierarchy.peek().contains(elementQName)) {
                currentField = analyzerData.visitedFieldHierarchy.peek().get(elementQName);
                Type fieldType = TypeUtils.getReferredType(currentField.getFieldType());
                String fieldName = currentField.getFieldName();
                if (!analyzerData.modelGroupStack.isEmpty()) {
                    ModelGroupInfo modelGroup = analyzerData.modelGroupStack.peek();

                    // Check whether this is a model group array
                    if (fieldType.getTag() != TypeTags.ARRAY_TAG && modelGroup == null) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.FOUND_ARRAY_FOR_NON_ARRAY_TYPE,
                                fieldType, fieldName);
                    }
                } else if (!DataUtils.isArrayValueAssignable(fieldType)) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.FOUND_ARRAY_FOR_NON_ARRAY_TYPE, fieldType, fieldName);
                }
            } else {
                currentField = fieldsMap.get(elementQName);
                if (currentField != null
                        && TypeUtils.getReferredType(currentField.getFieldType()).getTag() != TypeTags.ARRAY_TAG) {
                    fieldsMap.remove(elementQName);
                }
            }

            analyzerData.currentField = currentField;

            if (currentField == null) {
                // TODO: In here assume that if XSD is present then no rest type can be there.
                HashMap<String, ModelGroupInfo> modelGroupInfo = null;
                if (!analyzerData.xsdModelGroupInfo.isEmpty()) {
                    modelGroupInfo = analyzerData.xsdModelGroupInfo.peek();
                }

                if (modelGroupInfo != null && !modelGroupInfo.isEmpty()) {
                    validateElementInXsdSequenceOrElement(elementQName, modelGroupInfo,
                            xmlItem, analyzerData, analyzerData.visitedFieldHierarchy.peek(), fieldsMap);
                    return;
                }

                Type restType = analyzerData.restTypes.peek();
                String elementName = elementQName.getLocalPart();
                if (restType != null) {
                    if (fieldsMap.contains(elementName)) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.UNDEFINED_FIELD, elementName,
                                analyzerData.rootRecord);
                    }
                    convertToRestType(xmlItem, restType, analyzerData);
                } else if (!analyzerData.allowDataProjection) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.UNDEFINED_FIELD, elementName,
                            analyzerData.rootRecord);
                }
                return;
            }

            analyzerData.visitedFieldHierarchy.peek().put(elementQName, currentField);
            Type currentFieldType = currentField.getFieldType();
            if (!DataUtils.isSupportedType(currentFieldType)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE, currentFieldType);
            }

            if (DataUtils.isRegExpType(currentFieldType)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE);
            }

            convertToFieldType(xmlItem, currentField, currentField.getFieldName(), currentFieldType,
                    analyzerData.currentNode, analyzerData);
            validateModelGroupStack(analyzerData, elementQName, false);
        }

        private void convertToFieldType(BXmlItem xmlItem, Field currentField, String fieldName, Type currentFieldType,
                                        BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            switch (currentFieldType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG -> convertToRecordType(xmlItem, currentFieldType, fieldName,
                        (RecordType) currentFieldType, mapValue, analyzerData);
                case TypeTags.ARRAY_TAG -> convertToArrayType(xmlItem, currentField, mapValue,
                        StringUtils.fromString(fieldName), (ArrayType) currentFieldType, analyzerData);
                case TypeTags.MAP_TAG -> convertToMapType(xmlItem, currentFieldType, currentFieldType,
                        fieldName, mapValue, analyzerData);
                case TypeTags.JSON_TAG, TypeTags.ANYDATA_TAG -> {
                    updateNextMap(currentFieldType, analyzerData);
                    analyzerData.arrayIndexes.push(new HashMap<>());
                    convertToRestType(xmlItem, currentFieldType, analyzerData);
                    validateCurrentElementInfo(analyzerData);
                    DataUtils.popExpectedTypeStacks(analyzerData);
                }
                case TypeTags.TYPE_REFERENCED_TYPE_TAG ->
                    convertToFieldType(xmlItem, currentField, fieldName, TypeUtils.getReferredType(currentFieldType),
                            mapValue, analyzerData);
                case TypeTags.UNION_TAG -> convertFieldTypeToUnion(xmlItem, currentField, fieldName,
                        currentFieldType, mapValue, analyzerData);
                default -> {
                    if (TypeTags.isXMLTypeTag(currentFieldType.getTag())) {
                        traverseXml(xmlItem, currentFieldType, analyzerData);
                    } else {
                        traverseXml(xmlItem.getChildrenSeq(), currentFieldType, analyzerData);
                    }
                }
            }
        }

        private void convertFieldTypeToUnion(BXmlItem xmlItem, Field currentField, String fieldName,
                             Type currentFieldType, BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            XmlAnalyzerData clonedAnalyzerData = XmlAnalyzerData.copy(analyzerData);
            for (Type memberType: ((UnionType) currentFieldType).getMemberTypes()) {
                memberType = TypeUtils.getReferredType(memberType);
                try {
                    if (memberType.getTag() == TypeTags.ERROR_TAG) {
                        continue;
                    }
                    convertToFieldType(xmlItem, currentField, fieldName, memberType, mapValue, analyzerData);
                    return;
                } catch (Exception ex) {
                    analyzerData.resetFrom(clonedAnalyzerData);
                    mapValue.put(StringUtils.fromString(fieldName), null);
                    // ignore
                }
            }
            throw DiagnosticLog.error(DiagnosticErrorCode.FIELD_CANNOT_CAST_INTO_TYPE, fieldName, currentFieldType);
        }

        private void convertToArrayType(BXmlItem xmlItem, Field field, BMap<BString, Object> mapValue,
                                        BString bCurrentFieldName, ArrayType arrayType, XmlAnalyzerData analyzerData) {
            Object temp = mapValue.get(bCurrentFieldName);
            Type elementType = arrayType.getElementType();

            if (DataUtils.isRegExpType(elementType)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE);
            }

            String fieldName = field.getFieldName();
            int referredElementTypeTag = TypeUtils.getReferredType(elementType).getTag();
            if (referredElementTypeTag == TypeTags.JSON_TAG || referredElementTypeTag == TypeTags.ANYDATA_TAG) {
                convertToRestType(xmlItem, arrayType, analyzerData);
                return;
            }

            if (temp == null) {
                analyzerData.arrayIndexes.peek().put(fieldName, 0);
                mapValue.put(bCurrentFieldName, DataUtils.createArrayValue(arrayType));
            } else {
                HashMap<String, Integer> indexes = analyzerData.arrayIndexes.peek();
                indexes.put(fieldName, indexes.get(fieldName) + 1);
            }

            convertToArrayMemberType(xmlItem, fieldName, arrayType, elementType, mapValue, analyzerData);
        }

        private void convertToArrayMemberType(BXmlItem xmlItem, String fieldName, ArrayType fieldType, Type elementType,
                                              BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            switch (elementType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG -> convertToRecordType(xmlItem, fieldType, fieldName,
                        (RecordType) elementType, mapValue, analyzerData);
                case TypeTags.MAP_TAG ->
                    convertToMapType(xmlItem, fieldType, elementType, fieldName, mapValue, analyzerData);
                case TypeTags.TYPE_REFERENCED_TYPE_TAG ->
                    convertToArrayMemberType(xmlItem, fieldName, fieldType, TypeUtils.getReferredType(elementType),
                            mapValue, analyzerData);
                case TypeTags.UNION_TAG -> convertToUnionMemberType(xmlItem, fieldName, fieldType,
                        elementType, mapValue, analyzerData);
                case TypeTags.XML_TAG -> traverseXml(xmlItem, fieldType, analyzerData);
                default -> traverseXml(xmlItem.getChildrenSeq(), fieldType, analyzerData);
            }
        }

        private void convertToUnionMemberType(BXmlItem xmlItem, String fieldName, ArrayType fieldType,
                      Type elementType, BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            XmlAnalyzerData clonedAnalyzerData = XmlAnalyzerData.copy(analyzerData);
            for (Type memberType: ((UnionType) elementType).getMemberTypes()) {
                memberType = TypeUtils.getReferredType(memberType);
                if (memberType.getTag() == TypeTags.ERROR_TAG) {
                    continue;
                }
                try {
                    convertToArrayMemberType(xmlItem, fieldName, fieldType, memberType, mapValue, analyzerData);
                    return;
                } catch (Exception ex) {
                    analyzerData.resetFrom(clonedAnalyzerData);
                    // ignore
                }
            }
            throw DiagnosticLog.error(DiagnosticErrorCode.FIELD_CANNOT_CAST_INTO_TYPE, fieldName, fieldType);
        }

        private void convertToRecordType(BXmlItem xmlItem, Type currentFieldType, String fieldName,
                                         RecordType elementType, BMap<BString, Object> mapValue,
                                         XmlAnalyzerData analyzerData) {
            analyzerData.currentNode = updateNextRecord(xmlItem, elementType, fieldName,
                    currentFieldType, mapValue, analyzerData);
            RecordType prevRecord = analyzerData.rootRecord;
            analyzerData.rootRecord = elementType;
            traverseXml(xmlItem.getChildrenSeq(), currentFieldType, analyzerData);
            validateCurrentElementInfo(analyzerData);
            DataUtils.validateRequiredFields(analyzerData, analyzerData.currentNode);
            DataUtils.popExpectedTypeStacks(analyzerData);
            analyzerData.rootRecord = prevRecord;
            analyzerData.currentNode = (BMap<BString, Object>) analyzerData.nodesStack.pop();
        }

        private void convertToMapType(BXmlItem xmlItem, Type fieldType, Type elementType, String fieldName,
                                      BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            updateNextMap(elementType, analyzerData);
            analyzerData.currentNode = updateNextMappingValue(
                    elementType, fieldName, fieldType, mapValue, analyzerData);
            traverseXml(xmlItem.getChildrenSeq(), fieldType, analyzerData);
            validateCurrentElementInfo(analyzerData);
            DataUtils.validateRequiredFields(analyzerData, analyzerData.currentNode);
            DataUtils.popExpectedTypeStacks(analyzerData);
            analyzerData.currentNode = (BMap<BString, Object>) analyzerData.nodesStack.pop();
        }

        private void updateNextMap(Type fieldType, XmlAnalyzerData analyzerData) {
            if (fieldType.getTag() == TypeTags.MAP_TAG) {
                analyzerData.restTypes.push(((MapType) fieldType).getConstrainedType());
            } else {
                analyzerData.restTypes.push(fieldType);
            }
            analyzerData.fieldHierarchy.push(new QualifiedNameMap<>(new HashMap<>()));
            analyzerData.visitedFieldHierarchy.push(new QualifiedNameMap<>(new HashMap<>()));
            analyzerData.attributeHierarchy.push(new QualifiedNameMap<>(new HashMap<>()));
            analyzerData.xsdModelGroupInfo.push(new HashMap<>());
            analyzerData.xmlElementInfo.push(new HashMap<>());
        }

        private BMap<BString, Object> updateNextRecord(BXmlItem xmlItem, RecordType recordType, String fieldName,
                                                       Type fieldType, BMap<BString, Object> currentMapValue,
                                                       XmlAnalyzerData analyzerData) {
            DataUtils.updateExpectedTypeStacks(recordType, analyzerData);
            initializeXsdInformation(recordType, analyzerData);
            BMap<BString, Object> nextValue =
                    updateNextMappingValue(recordType, fieldName, fieldType, currentMapValue, analyzerData);
            QName qName = xmlItem.getQName();
            DataUtils.validateTypeNamespace(qName.getPrefix(), qName.getNamespaceURI(), recordType);
            handleAttributes(xmlItem, nextValue, analyzerData);
            return nextValue;
        }

        private BMap<BString, Object> updateNextMappingValue(Type type, String fieldName, Type fieldType,
                                                             BMap<BString, Object> currentMapValue,
                                                             XmlAnalyzerData analyzerData) {
            analyzerData.currentField = null;

            BMap<BString, Object> nextValue;
            switch (type.getTag()) {
                case TypeTags.RECORD_TYPE_TAG -> {
                    RecordType recordType = (RecordType) type;
                    nextValue = ValueCreator.createRecordValue(recordType.getPackage(), recordType.getName());
                }
                case TypeTags.MAP_TAG -> nextValue = ValueCreator.createMapValue((MapType) type);
                case TypeTags.ANYDATA_TAG, TypeTags.JSON_TAG ->
                        nextValue = ValueCreator.createMapValue(TypeCreator.createMapType(type));
                default -> throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE, type);
            }

            Object temp = currentMapValue.get(StringUtils.fromString(fieldName));
            if (temp instanceof BArray tempArray) {
                ArrayType arrayType = (ArrayType) fieldType;
                int currentIndex = analyzerData.arrayIndexes.peek().get(fieldName);

                if (arrayType.getState() == ArrayType.ArrayState.OPEN || currentIndex < arrayType.getSize()) {
                    tempArray.add(currentIndex, nextValue);
                } else {
                    DataUtils.logArrayMismatchErrorIfProjectionNotAllowed(analyzerData.allowDataProjection);
                }
            } else {
                currentMapValue.put(StringUtils.fromString(fieldName), nextValue);
            }
            analyzerData.nodesStack.push(currentMapValue);
            analyzerData.arrayIndexes.push(new HashMap<>());
            return nextValue;
        }

        @SuppressWarnings("unchecked")
        private void convertToRestType(BXmlItem xmlItem, Type restType, XmlAnalyzerData analyzerData) {
            String elemName = xmlItem.getQName().getLocalPart();
            analyzerData.currentField = TypeCreator.createField(restType, elemName, SymbolFlags.PUBLIC);
            BMap<BString, Object> mapValue = analyzerData.currentNode;
            checkRestTypeAndConvert(xmlItem, elemName, restType, restType, mapValue, analyzerData);
        }

        private void checkRestTypeAndConvert(BXmlItem xmlItem, String elemName, Type restType, Type elementType,
                                             BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            switch (elementType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG ->
                    convertToRecordType(xmlItem, restType, elemName, (RecordType) elementType, mapValue, analyzerData);
                case TypeTags.ARRAY_TAG -> {
                    HashMap<String, Integer> indexes = analyzerData.arrayIndexes.peek();
                    if (!indexes.containsKey(elemName)) {
                        indexes.put(elemName, 0);
                        mapValue.put(StringUtils.fromString(elemName), DataUtils.createArrayValue(restType));
                    } else {
                        indexes.put(elemName, indexes.get(elemName) + 1);
                    }

                    checkRestTypeAndConvert(xmlItem, elemName, restType, ((ArrayType) restType).getElementType(),
                            mapValue, analyzerData);
                }
                case TypeTags.UNION_TAG -> checkRestTypeAndConvertForUnionTypes(xmlItem, elemName, restType,
                        elementType, mapValue, analyzerData);
                default -> {
                    BString bElementName = StringUtils.fromString(elemName);
                    if (mapValue.containsKey(bElementName) && mapValue.get(bElementName) != null) {
                        handleArrayValueForRestType(xmlItem, elemName, restType, mapValue, analyzerData);
                        return;
                    }

                    if (isNextElementContent(xmlItem)) {
                        convertContentToRestType(xmlItem, bElementName, restType, mapValue, analyzerData);
                        return;
                    }

                    if (restType.getTag() != TypeTags.ANYDATA_TAG && restType.getTag() != TypeTags.JSON_TAG) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.EXPECTED_ANYDATA_OR_JSON);
                    }

                    convertToJsonOrAnydataAsRestType(xmlItem, bElementName, restType, mapValue, analyzerData);
                }
            }
        }

        private void checkRestTypeAndConvertForUnionTypes(BXmlItem xmlItem, String elemName,
                  Type restType, Type elementType, BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            boolean isRestTypeUnion = restType.getTag() == TypeTags.UNION_TAG;
            XmlAnalyzerData clonedAnalyzerData = XmlAnalyzerData.copy(analyzerData);

            for (Type memberType: ((UnionType) elementType).getMemberTypes()) {
                memberType = TypeUtils.getReferredType(memberType);
                if (memberType.getTag() == TypeTags.ERROR_TAG) {
                    continue;
                }
                try {
                    checkRestTypeAndConvert(xmlItem, elemName, isRestTypeUnion ? memberType : restType,
                            memberType, mapValue, analyzerData);
                    return;
                } catch (Exception ex) {
                    analyzerData.resetFrom(clonedAnalyzerData);
                    if (restType.getTag() != TypeTags.ARRAY_TAG) {
                        mapValue.put(StringUtils.fromString(elemName), null);
                    }
                    // ignore
                }
            }
            throw DiagnosticLog.error(DiagnosticErrorCode.FIELD_CANNOT_CAST_INTO_TYPE, elemName, elementType);
        }

        private void handleArrayValueForRestType(BXmlItem xmlItem, String elemName, Type restType,
                                                 BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            BString bElementName = StringUtils.fromString(elemName);
            Object currentElement = mapValue.get(bElementName);
            boolean useSemanticEquality = analyzerData.useSemanticEquality;
            BArray arrayValue;
            if (!(currentElement instanceof BArray)) {
                if (!DataUtils.isArrayValueAssignable(restType)) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.FOUND_ARRAY_FOR_NON_ARRAY_TYPE, restType,
                            elemName);
                }
                arrayValue = DataUtils.createArrayValue(restType);
                arrayValue.append(currentElement);
                mapValue.put(bElementName, arrayValue);
            } else {
                arrayValue = (BArray) currentElement;
            }

            if (isNextElementContent(xmlItem)) {
                if (isElementHasAttributes(xmlItem)) {
                    BMap<BString, Object> nextValue =
                            ValueCreator.createMapValue(DataUtils.getMapTypeFromConstraintType(restType));
                    handleAttributesRest(xmlItem, nextValue, restType, useSemanticEquality);

                    if (!nextValue.isEmpty()) {
                        arrayValue.append(nextValue);
                        analyzerData.currentField =
                                TypeCreator.createField(restType, analyzerData.textFieldName, SymbolFlags.REQUIRED);
                        analyzerData.nodesStack.push(analyzerData.currentNode);
                        analyzerData.currentNode = nextValue;
                        traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
                        analyzerData.currentNode = (BMap<BString, Object>) analyzerData.nodesStack.pop();
                        return;
                    }
                }
                traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
                return;
            }
            BMap<BString, Object> nextValue =
                    ValueCreator.createMapValue(DataUtils.getMapTypeFromConstraintType(restType));
            if (DataUtils.isAnydataOrJson(restType.getTag())) {
                arrayValue.append(nextValue);
            } else {
                ArrayType arrayType = (ArrayType) restType;
                int currentIndex = analyzerData.arrayIndexes.peek().get(elemName);
                if (arrayType.getState() == ArrayType.ArrayState.CLOSED
                        && arrayType.getSize() <= currentIndex) {
                    DataUtils.logArrayMismatchErrorIfProjectionNotAllowed(analyzerData.allowDataProjection);
                } else {
                    arrayValue.add(currentIndex, nextValue);
                }
            }
            analyzerData.nodesStack.push(analyzerData.currentNode);
            analyzerData.currentNode = nextValue;
            handleAttributesRest(xmlItem, nextValue, restType, useSemanticEquality);

            analyzerData.fieldHierarchy.push(new QualifiedNameMap<>(new HashMap<>()));
            analyzerData.visitedFieldHierarchy.push(new QualifiedNameMap<>(new HashMap<>()));
            analyzerData.xsdModelGroupInfo.push(new HashMap<>());
            analyzerData.xmlElementInfo.push(new HashMap<>());
            analyzerData.arrayIndexes.push(new HashMap<>());
            if (restType.getTag() == TypeTags.ARRAY_TAG) {
                Type memberType = ((ArrayType) restType).getElementType();
                analyzerData.restTypes.push(memberType);
                traverseXml(xmlItem.getChildrenSeq(), memberType, analyzerData);
            } else {
                analyzerData.restTypes.push(restType);
                traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
            }
            analyzerData.fieldHierarchy.pop();
            analyzerData.visitedFieldHierarchy.pop();
            analyzerData.restTypes.pop();
            analyzerData.arrayIndexes.pop();
            analyzerData.currentNode = (BMap<BString, Object>) analyzerData.nodesStack.pop();
        }

        private void convertContentToRestType(BXmlItem xmlItem, BString bElementName, Type restType,
                                              BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            if (isElementHasAttributes(xmlItem)) {
                BMap<BString, Object> nextValue =
                        ValueCreator.createMapValue(DataUtils.getMapTypeFromConstraintType(restType));
                handleAttributesRest(xmlItem, nextValue, restType, analyzerData.useSemanticEquality);

                if (!nextValue.isEmpty()) {
                    mapValue.put(bElementName, nextValue);
                    analyzerData.currentField =
                            TypeCreator.createField(restType, analyzerData.textFieldName, SymbolFlags.REQUIRED);
                    analyzerData.nodesStack.push(analyzerData.currentNode);
                    analyzerData.currentNode = nextValue;
                    traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
                    analyzerData.currentNode = (BMap<BString, Object>) analyzerData.nodesStack.pop();
                    return;
                }
            }
            traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
        }

        private void convertToJsonOrAnydataAsRestType(BXmlItem xmlItem, BString bElementName, Type restType,
                                                      BMap<BString, Object> mapValue, XmlAnalyzerData analyzerData) {
            BMap<BString, Object> nextValue =
                    ValueCreator.createMapValue(DataUtils.getMapTypeFromConstraintType(restType));
            mapValue.put(bElementName, nextValue);
            analyzerData.nodesStack.push(analyzerData.currentNode);
            analyzerData.currentNode = nextValue;
            handleAttributesRest(xmlItem, nextValue, restType, analyzerData.useSemanticEquality);
            traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
            analyzerData.currentNode = (BMap<BString, Object>) analyzerData.nodesStack.pop();
        }

        private boolean isElementHasAttributes(BXmlItem xmlItem) {
            return !xmlItem.getAttributesMap().isEmpty();
        }

        private boolean isNextElementContent(BXmlItem xml) {
            for (BXml bXml : xml.getChildrenSeq().getChildrenList()) {
                String textValue = bXml.toString();
                if (isCommentOrPi(bXml) || textValue.trim().isEmpty()) {
                    continue;
                }

                if (bXml.getNodeType() == XmlNodeType.TEXT) {
                    return true;
                }
            }
            return false;
        }

        private List<BXml> filterEmptyValuesOrCommentOrPi(List<BXml> sequence) {
            List<BXml> newSequence = new ArrayList<>();
            for (BXml value: sequence) {
                if (isCommentOrPi(value)) {
                    continue;
                }

                String textValue = value.toString();
                if (textValue.isEmpty() || !textValue.trim().isEmpty()) {
                    newSequence.add(value);
                }
            }
            return newSequence;
        }

        private void convertSequence(BXmlSequence xmlSequence, Type type, XmlAnalyzerData analyzerData) {
            List<BXml> newSequence = filterEmptyValuesOrCommentOrPi(xmlSequence.getChildrenList());

            if (newSequence.isEmpty()) {
                return;
            }

            if (newSequence.size() == 1) {
                analyzerData.currentNode = (BMap<BString, Object>) traverseXml(newSequence.get(0), type, analyzerData);
                return;
            }
            analyzerData.currentNode =
                    (BMap<BString, Object>) convertHeterogeneousSequence(newSequence, type, analyzerData);
        }

        private Object convertHeterogeneousSequence(List<BXml> sequence, Type type, XmlAnalyzerData analyzerData) {
            if (isAllChildrenText(sequence)) {
                return handleCommentInMiddleOfText(sequence, type, analyzerData);
            }

            for (BXml bXml: sequence) {
                if (!isCommentOrPi(bXml)) {
                    traverseXml(bXml, type, analyzerData);
                }
            }
            return analyzerData.currentNode;
        }

        private boolean isAllChildrenText(List<BXml> sequence) {
            for (BXml bXml: sequence) {
                if (bXml.getNodeType() != XmlNodeType.TEXT) {
                    return false;
                }
            }
            return true;
        }

        private Object handleCommentInMiddleOfText(List<BXml> sequence, Type type, XmlAnalyzerData analyzerData) {
            if (!DataUtils.isStringValueAssignable(type.getTag())) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, type, PredefinedTypes.TYPE_STRING);
            }
            convertXml(Concat.concat(sequence.toArray()), TypeTags.STRING_TAG, analyzerData);
            return analyzerData.currentNode;
        }

        private static boolean isCommentOrPi(BXml bxml) {
            return bxml.getNodeType() == XmlNodeType.COMMENT || bxml.getNodeType() == XmlNodeType.PI;
        }

        @SuppressWarnings("unchecked")
        private BXml validateRootElement(BXml xml, RecordType recordType, XmlAnalyzerData analyzerData) {
            if (xml.getNodeType() == XmlNodeType.SEQUENCE) {
                List<BXml> newSequence = filterEmptyValuesOrCommentOrPi(((BXmlSequence) xml).getChildrenList());
                if (newSequence.size() == 1) {
                    return validateRootElement(newSequence.get(0), recordType, analyzerData);
                }
                throw DiagnosticLog.error(DiagnosticErrorCode.XML_ROOT_MISSING);
            } else if (xml.getNodeType() == XmlNodeType.TEXT) {
                throw DiagnosticLog.error(DiagnosticErrorCode.XML_ROOT_MISSING);
            }
            BXmlItem xmlItem = (BXmlItem) xml;
            analyzerData.rootRecord = recordType;
            boolean useSemanticEquality = analyzerData.useSemanticEquality;
            QualifiedName elementQName = DataUtils.getElementName(xmlItem.getQName(), useSemanticEquality);
            DataUtils.validateAndGetXmlNameFromRecordAnnotation(recordType, recordType.getName(), elementQName,
                            useSemanticEquality);
            DataUtils.validateTypeNamespace(elementQName.getPrefix(), elementQName.getNamespaceURI(), recordType);

            // Keep track of fields and attributes
            DataUtils.updateExpectedTypeStacks(recordType, analyzerData);
            initializeXsdInformation(recordType, analyzerData);
            handleAttributes(xmlItem, analyzerData.currentNode, analyzerData);
            analyzerData.arrayIndexes.push(new HashMap<>());
            return xmlItem.getChildrenSeq();
        }

        private void handleAttributes(BXmlItem xmlItem, BMap<BString, Object> currentNode,
                                      XmlAnalyzerData analyzerData) {
            HashSet<String> innerElements = findAllInnerElement(xmlItem);
            BMap<BString, BString> attributeMap = xmlItem.getAttributesMap();
            Map<String, String> nsPrefixMap = getNamespacePrefixes(attributeMap);
            for (Map.Entry<BString, BString> entry : attributeMap.entrySet()) {
                if (isNamespacePrefixEntry(entry)) {
                    continue;
                }
                BString key = entry.getKey();
                QualifiedName attribute = getAttributePreservingNamespace(nsPrefixMap, key.getValue(),
                        analyzerData.attributePrefix, analyzerData.useSemanticEquality);
                Field field = analyzerData.attributeHierarchy.peek().remove(attribute);
                if (field == null) {
                    if (innerElements.contains(attribute.getLocalPart())) {
                        // Element and Attribute have same name. Priority given to element.
                        continue;
                    }
                    if (analyzerData.visitedFieldHierarchy.peek().contains(attribute)) {
                        field = analyzerData.visitedFieldHierarchy.peek().get(attribute);
                    } else {
                        field = analyzerData.fieldHierarchy.peek().remove(attribute);
                        analyzerData.visitedFieldHierarchy.peek().put(attribute, field);
                    }
                }

                if (field == null) {
                    if (analyzerData.allowDataProjection) {
                        continue;
                    }
                    throw DiagnosticLog.error(DiagnosticErrorCode.UNDEFINED_FIELD, attribute.getLocalPart(),
                            analyzerData.rootRecord);
                }

                Type fieldType = field.getFieldType();

                if (DataUtils.isRegExpType(fieldType)) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE);
                }

                if (!DataUtils.isSupportedTypeForAttributes(TypeUtils.getReferredType(fieldType))) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.CANNOT_CONVERT_ATTRIBUTE_TO_ARRAY_TYPE,
                            field.getFieldName(), fieldType);
                }

                try {
                    currentNode.put(StringUtils.fromString(field.getFieldName()),
                            DataUtils.convertStringToExpType(attributeMap.get(key), fieldType));
                } catch (Exception e) {
                    // Ignore: Expected type will mismatch when element and attribute having same name.
                }
            }
        }

        private void handleAttributesRest(BXmlItem xmlItem, BMap<BString, Object> currentNode, Type restType,
                                          boolean useSemanticEquality) {
            HashSet<String> innerElements = findAllInnerElement(xmlItem);
            BMap<BString, BString> attributeMap = xmlItem.getAttributesMap();
            Map<String, String> nsPrefixMap = getNamespacePrefixes(attributeMap);
            for (Map.Entry<BString, BString> entry : attributeMap.entrySet()) {
                if (isNamespacePrefixEntry(entry)) {
                    continue;
                }
                BString key = entry.getKey();
                QualifiedName attribute = getAttributePreservingNamespace(nsPrefixMap, key.getValue(), "",
                        useSemanticEquality);

                if (innerElements.contains(attribute.getLocalPart())) {
                    // Element and Attribute have same name. Priority given to element.
                    continue;
                }

                try {
                    currentNode.put(StringUtils.fromString(attribute.getLocalPart()),
                            DataUtils.convertStringToExpType(attributeMap.get(key), restType));
                } catch (Exception e) {
                    // Ignore: Expected type will mismatch when element and attribute having same name.
                }
            }
        }

        private ConcurrentHashMap<String, String> getNamespacePrefixes(BMap<BString, BString> xmlAttributeMap) {
            ConcurrentHashMap<String, String> nsPrefixMap = new ConcurrentHashMap<>();
            for (Map.Entry<BString, BString> entry : xmlAttributeMap.entrySet()) {
                if (isNamespacePrefixEntry(entry)) {
                    String prefix = entry.getKey().getValue().substring(Constants.NS_PREFIX_BEGIN_INDEX);
                    String ns = entry.getValue().getValue();
                    nsPrefixMap.put(ns, prefix);
                }
            }
            return nsPrefixMap;
        }

        private boolean isNamespacePrefixEntry(Map.Entry<BString, BString> entry) {
            return entry.getKey().getValue().startsWith(BXmlItem.XMLNS_NS_URI_PREFIX);
        }

        private QualifiedName getAttributePreservingNamespace(Map<String, String> nsPrefixMap, String attributeKey,
                                                              String attributePrefix, boolean useSemanticEquality) {
            int nsEndIndex = attributeKey.lastIndexOf('}');
            if (nsEndIndex > 0) {
                String ns = attributeKey.substring(1, nsEndIndex);
                String local = attributeKey.substring(nsEndIndex + 1);
                String nsPrefix = nsPrefixMap.get(ns);
                // `!nsPrefix.equals("xmlns")` because attributes does not belong to default namespace.
                if (nsPrefix == null) {
                    nsPrefix = "";
                }
                return QualifiedNameFactory.createQualifiedName(ns, attributePrefix + local, nsPrefix,
                        useSemanticEquality);
            }
            return QualifiedNameFactory.createQualifiedName("", attributePrefix + attributeKey, "",
                    useSemanticEquality);
        }

        private HashSet<String> findAllInnerElement(BXmlItem xmlItem) {
            HashSet<String> elements = new HashSet<>();
            for (BXml xmlElem : xmlItem.getChildrenSeq().getChildrenList()) {
                elements.add(xmlElem.getElementName());
            }
            return elements;
        }

        private void validateElementInXsdSequenceOrElement(QualifiedName elemQName,
                                       HashMap<String, ModelGroupInfo> modelGroupInfo, BXmlItem xmlItem,
                                       XmlAnalyzerData xmlAnalyzerData, QualifiedNameMap<Field> visitedFields,
                                       QualifiedNameMap<Field> fieldMap) {
            if (modelGroupInfo != null) {
                for (Map.Entry<String, ModelGroupInfo> entry : modelGroupInfo.entrySet()) {
                    ModelGroupInfo modelGroupValue = entry.getValue();
                    String key = entry.getKey();
                    QualifiedName qualifiedName = QualifiedNameFactory
                            .createQualifiedName("", key, "", xmlAnalyzerData.useSemanticEquality);

                    if (modelGroupValue.isElementContains(elemQName.getLocalPart())) {
                        Object temp = null;
                        Field field = xmlAnalyzerData.rootRecord.getFields().get(key);
                        if (visitedFields.contains(qualifiedName)) {
                            temp = (xmlAnalyzerData.currentNode).get(StringUtils.fromString(key));
                        }
                        xmlAnalyzerData.modelGroupStack.push(modelGroupValue);
                        visitedFields.put(qualifiedName, field);
                        fieldMap.remove(qualifiedName);
                        Type referredType = TypeUtils.getReferredType(field.getFieldType());
                        updateNextRecordForXsd(xmlAnalyzerData, key, referredType, temp, xmlAnalyzerData.currentNode);
                        convertElement(xmlItem, xmlAnalyzerData);
                        return;
                    }
                }
            }
        }

        private void updateNextRecordForXsd(XmlAnalyzerData xmlAnalyzerData, String fieldName,
                                            Type fieldType, Object temp, Object currentNode) {
            if (fieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                RecordType recType = (RecordType) fieldType;
                DataUtils.updateExpectedTypeStacks((RecordType) fieldType, xmlAnalyzerData);
                initializeXsdInformation(recType, xmlAnalyzerData);
                xmlAnalyzerData.currentNode = updateNextMappingValue(recType, fieldName, fieldType,
                        (BMap<BString, Object>) currentNode, xmlAnalyzerData);
                xmlAnalyzerData.recordTypeStack.push(xmlAnalyzerData.rootRecord);
                xmlAnalyzerData.rootRecord = recType;
                return;
            }

            if (fieldType.getTag() == TypeTags.ARRAY_TAG) {
                Type elementType = TypeUtils.getReferredType(((ArrayType) fieldType).getElementType());
                if (temp == null) {
                    xmlAnalyzerData.arrayIndexes.peek().put(fieldName, 0);
                    ((BMap<BString, Object>) currentNode).put(StringUtils.fromString(fieldName),
                            ValueCreator.createArrayValue((ArrayType) fieldType));
                } else {
                    HashMap<String, Integer> indexes = xmlAnalyzerData.arrayIndexes.peek();
                    indexes.put(fieldName, indexes.get(fieldName) + 1);
                }

                if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                    RecordType recType = (RecordType) elementType;
                    DataUtils.updateExpectedTypeStacks((RecordType) elementType, xmlAnalyzerData);
                    initializeXsdInformation(recType, xmlAnalyzerData);
                    xmlAnalyzerData.recordTypeStack.push(xmlAnalyzerData.rootRecord);
                    xmlAnalyzerData.rootRecord = recType;
                    xmlAnalyzerData.currentNode = updateNextMappingValue(recType, fieldName,
                            fieldType, (BMap<BString, Object>) currentNode, xmlAnalyzerData);
                    return;
                }
            }
            throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_XSD_ANNOTATION, fieldName, fieldType);
        }

        private void validateModelGroupStackForRootElement(XmlAnalyzerData analyzerData) {
            validateModelGroupStack(analyzerData,
                    QualifiedNameFactory.createQualifiedName("", "", "", analyzerData.useSemanticEquality), false);
        }
    }
}
