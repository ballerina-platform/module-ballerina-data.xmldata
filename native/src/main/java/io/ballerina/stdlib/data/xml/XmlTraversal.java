package io.ballerina.stdlib.data.xml;

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.XmlNodeType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BXml;
import io.ballerina.runtime.api.values.BXmlItem;
import io.ballerina.runtime.api.values.BXmlSequence;
import io.ballerina.stdlib.data.utils.Constants;
import io.ballerina.stdlib.data.utils.DataUtils;
import io.ballerina.stdlib.data.utils.DataUtils.XmlAnalyzerData;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * XML traversal.
 *
 * @since 1.0.0
 */

public class XmlTraversal {

    private static final ThreadLocal<XmlTree> tlXmlTree = ThreadLocal.withInitial(XmlTree::new);

    public static Object traverse(BXml xml, Type type) {
        XmlTree xmlTree = tlXmlTree.get();
        try {
            return xmlTree.traverseXml(xml, type);
        } finally {
//            jsonTree.reset();
        }
    }

    static class XmlTree {
        private Object currentNode;

        public Object traverseXml(BXml xml, Type type) {
            XmlAnalyzerData analyzerData = new XmlAnalyzerData();
            Type referredType = TypeUtils.getReferredType(type);
            switch (referredType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG:
                    RecordType recordType = (RecordType) referredType;
                    xml = validateRootElement(xml, recordType, analyzerData);
                    currentNode = DataUtils.createMapValue(recordType);
                    Object test = traverseXml(xml, recordType, analyzerData);
                    return test;
                case TypeTags.MAP_TAG:
                    // TODO: Need to handle this.
                    return DataUtils.getXmlError("handle this: " + type.getName());
                default:
                    return DataUtils.getXmlError("unsupported type: " + type.getName());
            }
        }

        private Object traverseXml(BXml xml, Type type, XmlAnalyzerData analyzerData) {
            switch (xml.getNodeType()) {
                case ELEMENT:
                    convertElement((BXmlItem) xml, type, analyzerData);
                    break;
                case SEQUENCE:
                    convertSequence((BXmlSequence) xml, type, analyzerData);
                    break;
                case TEXT:
                    convertText(xml.toString(), analyzerData);
                    break;
            }
            return currentNode;
        }

        private void convertText(String text, XmlAnalyzerData analyzerData) {
            Field currentField = analyzerData.currentField;

            BMap<BString, Object> mapValue = (BMap<BString, Object>) currentNode;

            if (currentField == null) {
                Map<String, Field> currentFieldMap = analyzerData.fieldHierarchy.peek();
                if (currentFieldMap.containsKey(Constants.CONTENT)) {
                    currentField = currentFieldMap.remove(Constants.CONTENT);
                } else {
                    return;
                }
            }

            BString fieldName = fromString(currentField.getFieldName());
            Type fieldType = currentField.getFieldType();

            Object convertedValue = DataUtils.convertStringToExpType(fromString(text), fieldType);
            if (mapValue.containsKey(fieldName)) {
                Object value = mapValue.get(fieldName);
                if (value instanceof BArray) {
                    ((BArray) value).append(convertedValue);
                } else {
                    BArray array = DataUtils.createNewAnydataList();
                    array.append(convertedValue);
                    mapValue.put(fieldName, array);
                }
            } else {
                mapValue.put(fieldName, convertedValue);
            }
        }

        private void convertElement(BXmlItem xmlItem, Type type, XmlAnalyzerData analyzerData) {
            String elementName = DataUtils.getElementName(xmlItem.getQName());
            Field currentField = analyzerData.fieldHierarchy.peek().get(elementName);
            analyzerData.currentField = currentField;

            if (currentField == null) {
                Type restType = analyzerData.restTypes.peek();
                if (restType == null) {
                    return;
                }
                convertToRestType(xmlItem, restType, analyzerData);
                return;
            }

            BMap<BString, Object> mapValue = (BMap<BString, Object>) currentNode;
            Type currentFieldType = currentField.getFieldType();
            if (type instanceof RecordType) {
                DataUtils.validateNamespace(xmlItem.getQName().getPrefix(), xmlItem.getQName().getNamespaceURI(),
                        (RecordType) type, true, analyzerData);
            }

            if (currentFieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                currentNode = updateNextValue((RecordType) currentFieldType, currentField.getFieldName(),
                        currentFieldType, mapValue, analyzerData);
                traverseXml(xmlItem.getChildrenSeq(), currentFieldType, analyzerData);
                analyzerData.fieldHierarchy.pop();
                analyzerData.restTypes.pop();
                currentNode = analyzerData.nodesStack.pop();
                return;
            } else if (currentFieldType.getTag() == TypeTags.ARRAY_TAG) {
                BString bCurrentFieldName = fromString(currentField.getFieldName());
                if (!mapValue.containsKey(bCurrentFieldName)) {
                    BArray array = DataUtils.createNewAnydataList();
                    mapValue.put(bCurrentFieldName, array);
                }
                Type elementType = ((ArrayType) currentFieldType).getElementType();
                if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                    currentNode = updateNextValue((RecordType) elementType, currentField.getFieldName(),
                            currentFieldType, mapValue, analyzerData);
                    traverseXml(xmlItem.getChildrenSeq(), currentFieldType, analyzerData);
                    analyzerData.fieldHierarchy.pop();
                    analyzerData.restTypes.pop();
                    currentNode = analyzerData.nodesStack.pop();
                    return;
                }
            }
            traverseXml(xmlItem.getChildrenSeq(), currentFieldType, analyzerData);
        }

        private Object updateNextValue(RecordType recordType, String fieldName, Type fieldType,
                                       BMap<BString, Object> currentNode, XmlAnalyzerData analyzerData) {
            analyzerData.currentField = null;
            analyzerData.fieldHierarchy.push(DataUtils.getAllFieldsInRecordType(recordType, analyzerData));
            analyzerData.restTypes.push(recordType.getRestFieldType());
            BMap<BString, Object> nextValue = ValueCreator.createRecordValue(recordType);

            Object temp = currentNode.get(StringUtils.fromString(fieldName));
            if (temp instanceof BArray) {
                int arraySize = ((ArrayType) fieldType).getSize();
                if (arraySize > ((BArray) temp).getLength() || arraySize == -1) {
                    ((BArray) temp).append(nextValue);
                }
            } else {
                currentNode.put(StringUtils.fromString(fieldName), nextValue);
            }
            analyzerData.nodesStack.push(currentNode);
            return nextValue;
        }

        private void convertToRestType(BXmlItem xmlItem, Type restType, XmlAnalyzerData analyzerData) {
            String elemName = xmlItem.getQName().getLocalPart();
            analyzerData.currentField = TypeCreator.createField(restType, elemName, SymbolFlags.PUBLIC);
            BMap<BString, Object> mapValue = (BMap<BString, Object>) currentNode;

            if (restType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                currentNode = updateNextValue((RecordType) restType, xmlItem.getQName().getLocalPart(),
                        restType, mapValue, analyzerData);
                traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
                analyzerData.fieldHierarchy.pop();
                analyzerData.restTypes.pop();
                currentNode = analyzerData.nodesStack.pop();
                return;
            } else if (restType.getTag() == TypeTags.ARRAY_TAG) {
                BString bElementName = fromString(elemName);
                if (!mapValue.containsKey(bElementName)) {
                    BArray array = DataUtils.createNewAnydataList();
                    mapValue.put(bElementName, array);
                }
                Type elementType = ((ArrayType) restType).getElementType();
                if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                    currentNode = updateNextValue((RecordType) elementType, elemName,
                            restType, mapValue, analyzerData);
                    traverseXml(xmlItem.getChildrenSeq(), elementType, analyzerData);
                    analyzerData.fieldHierarchy.pop();
                    analyzerData.restTypes.pop();
                    currentNode = analyzerData.nodesStack.pop();
                    return;
                }
            }
            traverseXml(xmlItem.getChildrenSeq(), restType, analyzerData);
        }

        private void convertSequence(BXmlSequence xmlSequence, Type type, XmlAnalyzerData analyzerData) {
            List<BXml> sequence = xmlSequence.getChildrenList();
            List<BXml> newSequence = new ArrayList<>();
            for (BXml value: sequence) {
                String textValue = value.toString();
                if (textValue.isEmpty() || !textValue.trim().isEmpty()) {
                    newSequence.add(value);
                }
            }

            if (newSequence.isEmpty()) {
                return;
            }

            if (newSequence.size() == 1) {
                currentNode = traverseXml(newSequence.get(0), type, analyzerData);
                return;
            }
            currentNode = convertHeterogeneousSequence(newSequence, type, analyzerData);
        }

        private Object convertHeterogeneousSequence(List<BXml> sequence, Type type, XmlAnalyzerData analyzerData) {
            for (BXml bXml: sequence) {
                if (isCommentOrPi(bXml)) {
                    continue;
                } else {
                    traverseXml(bXml, type, analyzerData);
                }
            }
            return currentNode;
        }

        private static boolean isCommentOrPi(BXml bxml) {
            return bxml.getNodeType() == XmlNodeType.COMMENT || bxml.getNodeType() == XmlNodeType.PI;
        }

        private BXml validateRootElement(BXml xml, RecordType recordType, XmlAnalyzerData analyzerData) {
            if (!(xml instanceof BXmlItem)) {
                throw DataUtils.getXmlError("XML root element is missing");
            }
            BXmlItem xmlItem = (BXmlItem) xml;
            analyzerData.rootRecord = recordType;
            String elementName = xml.getElementName();
            analyzerData.rootElement =
                    DataUtils.validateAndGetXmlNameFromRecordAnnotation(recordType, recordType.getName(), elementName);
            DataUtils.validateNamespace(xmlItem.getQName().getPrefix(), xmlItem.getQName().getNamespaceURI(),
                    recordType, false, analyzerData);

            // Keep track of fields and attributes
            analyzerData.fieldHierarchy.push(DataUtils.getAllFieldsInRecordType(recordType, analyzerData));
            analyzerData.restTypes.push(recordType.getRestFieldType());
            analyzerData.attributeHierarchy.push(DataUtils.getAllAttributesInRecordType(recordType));
            // TODO: Validate and capture attributes.
            return xmlItem.getChildrenSeq();
        }
    }
}
