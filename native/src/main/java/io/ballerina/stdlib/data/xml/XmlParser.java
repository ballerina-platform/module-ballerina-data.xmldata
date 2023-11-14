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
package io.ballerina.stdlib.data.xml;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.data.FromString;
import io.ballerina.stdlib.data.utils.Constants;
import io.ballerina.stdlib.data.utils.DataUtils;

import java.io.Reader;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Stack;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import static javax.xml.stream.XMLStreamConstants.CDATA;
import static javax.xml.stream.XMLStreamConstants.CHARACTERS;
import static javax.xml.stream.XMLStreamConstants.COMMENT;
import static javax.xml.stream.XMLStreamConstants.DTD;
import static javax.xml.stream.XMLStreamConstants.END_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.END_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.PROCESSING_INSTRUCTION;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;

/**
 * Convert Xml string to a ballerina record.
 *
 * @since 0.1.0
 */
public class XmlParser {

    // XMLInputFactory2
    private static final XMLInputFactory xmlInputFactory;

    static {
        xmlInputFactory = XMLInputFactory.newInstance();
        xmlInputFactory.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, false);
    }

    private XMLStreamReader xmlStreamReader;
    private static BMap<BString, Object> currentNode;
    private final ArrayType definedAnyDataArrayType = TypeCreator.createArrayType(PredefinedTypes.TYPE_ANYDATA);
    public static final String PARSE_ERROR = "failed to parse xml";
    public static final String PARSE_ERROR_PREFIX = PARSE_ERROR + ": ";

    public XmlParser(Reader stringReader) {
        try {
            xmlStreamReader = xmlInputFactory.createXMLStreamReader(stringReader);
        } catch (XMLStreamException e) {
            handleXMLStreamException(e);
        }
    }

    public static Object parse(Reader reader, Type type) {
        try {
            XmlParserData xmlParserData = new XmlParserData();
            XmlParser xmlParser = new XmlParser(reader);
            return xmlParser.parse(type, xmlParserData);
        } catch (BError e) {
            throw e;
        } catch (Throwable e) {
            throw DataUtils.getXmlError(PARSE_ERROR_PREFIX + e.getMessage());
        }
    }

    private static void initRootObject(Type recordType, XmlParserData xmlParserData) {
        if (recordType == null) {
            throw DataUtils.getXmlError("expected 'record' type for input type");
        }
        currentNode = ValueCreator.createRecordValue((RecordType) recordType);
        xmlParserData.nodesStack.push(currentNode);
    }

    private void handleXMLStreamException(Exception e) {
        String reason = e.getCause() == null ? e.getMessage() : e.getCause().getMessage();
        if (reason == null) {
            throw DataUtils.getXmlError(PARSE_ERROR);
        }
        throw DataUtils.getXmlError(PARSE_ERROR_PREFIX + reason);
    }

    public Object parse(Type type, XmlParserData xmlParserData) {
        if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throw DataUtils.getXmlError("unsupported type expected record type but found '" + type.getName() + "'");
        }
        xmlParserData.rootRecord = (RecordType) type;
        return parse(xmlParserData);
    }

    public Object parse(XmlParserData xmlParserData) {
        try {
            parseRootElement(xmlStreamReader, xmlParserData);

            while (xmlStreamReader.hasNext()) {
                int next = xmlStreamReader.next();
                switch (next) {
                    case START_ELEMENT:
                        readElement(xmlStreamReader, xmlParserData);
                        break;
                    case END_ELEMENT:
                        endElement(xmlStreamReader, xmlParserData);
                        break;
                    case CDATA:
                    case CHARACTERS:
                        readText(xmlStreamReader, xmlParserData);
                        break;
                    case END_DOCUMENT:
                        return buildDocument(xmlParserData);
                    case PROCESSING_INSTRUCTION:
                    case COMMENT:
                    case DTD:
                        // Ignore
                        break;
                    default:
                        assert false;
                }
            }
        } catch (NumberFormatException e) {
            throw DataUtils.getXmlError(PARSE_ERROR_PREFIX + e);
        } catch (BError e) {
            throw e;
        } catch (Exception e) {
            handleXMLStreamException(e);
        }

        return currentNode;
    }

    public void parseRecordRest(String startElementName, XmlParserData xmlParserData) {
        try {
            while (xmlStreamReader.hasNext()) {
                int next = xmlStreamReader.next();

                // Terminate the record rest field parsing if the end element is reached.
                if (next == END_ELEMENT) {
                    QName startElement = xmlStreamReader.getName();
                    if (startElement.getLocalPart().equals(startElementName)) {
                        validateRequiredFields(currentNode, xmlParserData);
                        xmlParserData.fieldHierarchy.pop();
                        xmlParserData.restTypes.pop();
                        xmlParserData.attributeHierarchy.pop();
                        break;
                    }
                }

                switch (next) {
                    case START_ELEMENT:
                        readElement(xmlStreamReader, xmlParserData);
                        break;
                    case END_ELEMENT:
                        endElement(xmlStreamReader, xmlParserData);
                        break;
                    case CDATA:
                    case CHARACTERS:
                        readText(xmlStreamReader, xmlParserData);
                        break;
                    case END_DOCUMENT:
                        buildDocument(xmlParserData);
                        break;
                    case PROCESSING_INSTRUCTION:
                    case COMMENT:
                    case DTD:
                        // Ignore
                        break;
                    default:
                        assert false;
                }
            }
        } catch (BError e) {
            throw e;
        } catch (Exception e) {
            handleXMLStreamException(e);
        }
    }

    private void parseRootElement(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        try {
            if (xmlStreamReader.hasNext()) {
                int next = xmlStreamReader.next();
                if (next == COMMENT || next == PROCESSING_INSTRUCTION) {
                    parseRootElement(xmlStreamReader, xmlParserData);
                    return;
                } else if (next != START_ELEMENT) {
                    throw DataUtils.getXmlError("XML root element is missing");
                }
            }

            RecordType rootRecord = xmlParserData.rootRecord;
            initRootObject(rootRecord, xmlParserData);

            String elementName = getElementName(xmlStreamReader);
            xmlParserData.rootElement =
                    validateAndGetXmlNameFromRecordAnnotation(rootRecord, rootRecord.getName(), elementName);

            QName qName = xmlStreamReader.getName();
            DataUtils.validateTypeNamespace(qName.getPrefix(), qName.getNamespaceURI(), rootRecord);

            // Keep track of fields and attributes
            updateExpectedTypeStacks(rootRecord, xmlParserData);
            handleAttributes(xmlStreamReader, rootRecord, xmlParserData);
        } catch (XMLStreamException e) {
            handleXMLStreamException(e);
        }
    }

    private void readText(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        Field currentField = xmlParserData.currentField;
        String text = xmlStreamReader.getText();
        if (text.strip().isBlank()) {
            return;
        }

        if (currentField == null) {
            Map<String, Field> currentFieldMap = xmlParserData.fieldHierarchy.peek();
            if (!currentFieldMap.containsKey(Constants.CONTENT)) {
                return;
            } else {
                currentField = currentFieldMap.remove(Constants.CONTENT);
            }
        }

        BString bText = StringUtils.fromString(text);
        String fieldName = currentField.getFieldName();
        BString bFieldName = StringUtils.fromString(fieldName);
        Type fieldType = TypeUtils.getReferredType(currentField.getFieldType());
        if (currentNode.containsKey(bFieldName)) {
            // Handle - <name>James <!-- FirstName --> Clark</name>
            if (!xmlParserData.siblings.get(
                    xmlParserData.modifiedNamesHierarchy.peek().getOrDefault(fieldName, fieldName))
                    && DataUtils.isStringValueAssignable(fieldType.getTag())) {
                currentNode.put(bFieldName,
                        StringUtils.fromString(currentNode.get(bFieldName) + xmlStreamReader.getText()));
                return;
            }

            if (!DataUtils.isArrayValueAssignable(fieldType.getTag())) {
                throw DataUtils.getXmlError("Expected an '" + fieldType + "' value for the field '" + fieldName
                        + "' found 'array' value");
            }

            int arraySize = ((ArrayType) fieldType).getSize();
            if (arraySize != -1 && arraySize <= ((BArray) currentNode.get(bFieldName)).getLength()) {
                return;
            }

            ((BArray) currentNode.get(bFieldName)).append(convertStringToExpType(bText, fieldType));
            return;
        }

        if (fieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            handleContentFieldInRecordType((RecordType) fieldType, bText, xmlParserData);
            return;
        } else if (fieldType.getTag() == TypeTags.ARRAY_TAG
                && ((ArrayType) fieldType).getElementType().getTag() == TypeTags.RECORD_TYPE_TAG) {
            handleContentFieldInRecordType((RecordType) ((ArrayType) fieldType).getElementType(), bText, xmlParserData);
            return;
        }
        currentNode.put(bFieldName, convertStringToRestExpType(bText, fieldType));
    }

    private void handleContentFieldInRecordType(RecordType recordType, BString text, XmlParserData xmlParserData) {
        removeLastElementFromStacks(xmlParserData);
        for (String key : recordType.getFields().keySet()) {
            if (key.contains(Constants.CONTENT)) {
                currentNode.put(StringUtils.fromString(key),
                        convertStringToExpType(text, recordType.getFields().get(key).getFieldType()));
                currentNode = (BMap<BString, Object>) xmlParserData.nodesStack.pop();
                return;
            }
        }

        Type restType = TypeUtils.getReferredType(recordType.getRestFieldType());
        if (restType == null) {
            return;
        }

        currentNode.put(StringUtils.fromString(Constants.CONTENT), convertStringToRestExpType(text, restType));
        currentNode = (BMap<BString, Object>) xmlParserData.nodesStack.pop();
    }

    private Object convertStringToExpType(BString value, Type expType) {
        if (expType.getTag() == TypeTags.ARRAY_TAG) {
            expType = ((ArrayType) expType).getElementType();
        }
        Object result = FromString.fromStringWithTypeInternal(value, expType);
        if (result instanceof BError) {
            throw (BError) result;
        }
        return result;
    }

    private Object convertStringToRestExpType(BString value, Type expType) {
        switch (expType.getTag()) {
            case TypeTags.ARRAY_TAG:
                return convertStringToExpType(value, ((ArrayType) expType).getElementType());
            case TypeTags.INT_TAG:
            case TypeTags.FLOAT_TAG:
            case TypeTags.DECIMAL_TAG:
            case TypeTags.STRING_TAG:
            case TypeTags.BOOLEAN_TAG:
            case TypeTags.UNION_TAG:
                return convertStringToExpType(value, expType);
            case TypeTags.ANYDATA_TAG:
            case TypeTags.JSON_TAG:
                return convertStringToExpType(value, PredefinedTypes.TYPE_STRING);
            case TypeTags.TYPE_REFERENCED_TYPE_TAG:
                return convertStringToExpType(value, TypeUtils.getReferredType(expType));
        }
        throw DataUtils.getXmlError("Invalid rest type '" + expType.getName() + "'");
    }

    private Object buildDocument(XmlParserData xmlParserData) {
        validateRequiredFields(currentNode, xmlParserData);
        return currentNode;
    }

    private void endElement(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        xmlParserData.currentField = null;
        String elemName = getElementName(xmlStreamReader);
        LinkedHashMap<String, Boolean> siblings = xmlParserData.siblings;
        Stack<LinkedHashMap<String, Boolean>> parents = xmlParserData.parents;
        if (siblings.containsKey(elemName) && !siblings.get(elemName)) {
            siblings.put(elemName, true);
        }
        if (parents.isEmpty() || !parents.peek().containsKey(elemName)) {
            return;
        }

        validateRequiredFields(currentNode, xmlParserData);
        currentNode = (BMap<BString, Object>) xmlParserData.nodesStack.pop();
        removeLastElementFromStacks(xmlParserData);
    }

    private void validateRequiredFields(BMap<BString, Object> currentMapValue, XmlParserData xmlParserData) {
        Map<String, Field> fields = xmlParserData.fieldHierarchy.peek();
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

        Map<String, Field> attributes = xmlParserData.attributeHierarchy.peek();
        for (String key : attributes.keySet()) {
            Field field = attributes.get(key);
            String fieldName = field.getFieldName();
            if (!SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)) {
                throw DataUtils.getXmlError("Required attribute '" + fieldName + "' not present in XML");
            }
        }
    }

    private void readElement(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        String elemName = getElementName(xmlStreamReader);
        Field currentField = xmlParserData.fieldHierarchy.peek().get(elemName);
        xmlParserData.currentField = currentField;
        if (xmlParserData.currentField == null) {
            if (xmlParserData.restTypes.peek() == null) {
                return;
            }
            currentNode = handleRestField(xmlParserData);
            return;
        }

        String fieldName = currentField.getFieldName();
        QName qName = xmlStreamReader.getName();
        DataUtils.validateFieldNamespace(qName.getPrefix(), qName.getNamespaceURI(), fieldName,
                xmlParserData.rootRecord);
        Object temp = currentNode.get(StringUtils.fromString(fieldName));
        BString bFieldName = StringUtils.fromString(fieldName);
        if (!xmlParserData.siblings.containsKey(elemName)) {
            xmlParserData.siblings.put(elemName, false);
            currentNode.remove(bFieldName);
        } else if (!(temp instanceof BArray)) {
            BArray tempArray = ValueCreator.createArrayValue(definedAnyDataArrayType);
            tempArray.append(temp);
            currentNode.put(bFieldName, tempArray);
        }

        Type fieldType = TypeUtils.getReferredType(currentField.getFieldType());
        if (fieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            updateNextRecord(xmlStreamReader, xmlParserData, fieldName, fieldType, (RecordType) fieldType);
        } else if (fieldType.getTag() == TypeTags.ARRAY_TAG) {
            Type referredType = TypeUtils.getReferredType(((ArrayType) fieldType).getElementType());
            if (!currentNode.containsKey(bFieldName)) {
                currentNode.put(StringUtils.fromString(fieldName),
                        ValueCreator.createArrayValue(definedAnyDataArrayType));
            }

            if (referredType.getTag() != TypeTags.RECORD_TYPE_TAG) {
                return;
            }
            updateNextRecord(xmlStreamReader, xmlParserData, fieldName, fieldType, (RecordType) referredType);
        } else if (fieldType.getTag() == TypeTags.MAP_TAG) {
            RecordType recordType = TypeCreator.createRecordType("$anonType$", fieldType.getPackage(), 0,
                    new HashMap<>(), ((MapType) fieldType).getConstrainedType(), false, 0);
            updateNextRecord(xmlStreamReader, xmlParserData, fieldName, fieldType, recordType);
        }
    }

    private void updateNextRecord(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData, String fieldName,
                                  Type fieldType, RecordType recordType) {
        xmlParserData.parents.push(xmlParserData.siblings);
        xmlParserData.siblings = new LinkedHashMap<>();
        xmlParserData.recordTypeStack.push(xmlParserData.rootRecord);
        xmlParserData.rootRecord = recordType;
        currentNode = updateNextValue(recordType, fieldName, fieldType, xmlParserData);
        QName qName = xmlStreamReader.getName();
        DataUtils.validateTypeNamespace(qName.getPrefix(), qName.getNamespaceURI(), recordType);
        handleAttributes(xmlStreamReader, recordType, xmlParserData);
    }

    private BMap<BString, Object> updateNextValue(RecordType rootRecord, String fieldName, Type fieldType,
                                                  XmlParserData xmlParserData) {
        BMap<BString, Object> nextValue = ValueCreator.createRecordValue(rootRecord);
        updateExpectedTypeStacks(rootRecord, xmlParserData);
        Object temp = currentNode.get(StringUtils.fromString(fieldName));
        if (temp instanceof BArray) {
            int arraySize = ((ArrayType) fieldType).getSize();
            if (arraySize > ((BArray) temp).getLength() || arraySize == -1) {
                ((BArray) temp).append(nextValue);
            }
        } else {
            currentNode.put(StringUtils.fromString(fieldName), nextValue);
        }
        xmlParserData.nodesStack.push(currentNode);
        return nextValue;
    }

    private void updateExpectedTypeStacks(RecordType recordType, XmlParserData xmlParserData) {
        xmlParserData.attributeHierarchy.push(new HashMap<>(DataUtils.getAllAttributesInRecordType(recordType)));
        xmlParserData.fieldHierarchy.push(new HashMap<>(getAllFieldsInRecordType(recordType, xmlParserData)));
        xmlParserData.restTypes.push(recordType.getRestFieldType());
    }

    private void removeLastElementFromStacks(XmlParserData xmlParserData) {
        xmlParserData.fieldHierarchy.pop();
        xmlParserData.restTypes.pop();
        xmlParserData.modifiedNamesHierarchy.pop();
        xmlParserData.attributeHierarchy.pop();
        xmlParserData.siblings = xmlParserData.parents.pop();
        xmlParserData.rootRecord = xmlParserData.recordTypeStack.pop();
    }

    private BMap<BString, Object> handleRestField(XmlParserData xmlParserData) {
        Optional<String> lastElement;
        if (xmlParserData.parents.isEmpty()) {
            lastElement = Optional.empty();
        } else {
            lastElement = Optional.ofNullable(getLastElementInSiblings(xmlParserData.parents.peek()));
        }
        String restStartPoint = lastElement.orElseGet(() -> xmlParserData.rootElement);
        xmlParserData.restFieldsPoints.push(restStartPoint);
        xmlParserData.nodesStack.push(currentNode);
        return (BMap<BString, Object>) parseRestField(xmlParserData);
    }

    private Object parseRestField(XmlParserData xmlParserData) {
        int next = xmlStreamReader.getEventType();
        Optional<Object> restNode = handleRecordRestType(xmlParserData, xmlStreamReader);
        if (restNode.isPresent()) {
            return restNode.get();
        }

        BString currentFieldName = null;
        try {
            while (!xmlParserData.restFieldsPoints.isEmpty()) {
                switch (next) {
                    case START_ELEMENT:
                        currentFieldName = readElementRest(xmlStreamReader, xmlParserData);
                        break;
                    case END_ELEMENT:
                        endElementRest(xmlStreamReader, xmlParserData);
                        break;
                    case CDATA:
                    case CHARACTERS:
                        readTextRest(xmlStreamReader, currentFieldName, xmlParserData);
                        break;
                    case PROCESSING_INSTRUCTION:
                    case COMMENT:
                    case DTD:
                        // Ignore
                        break;
                }

                if (xmlStreamReader.hasNext() && !xmlParserData.restFieldsPoints.isEmpty()) {
                    next = xmlStreamReader.next();
                } else {
                    break;
                }
            }
        } catch (XMLStreamException e) {
            throw new RuntimeException(e);
        }

        return xmlParserData.nodesStack.pop();
    }

    private BString readElementRest(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        String elemName = getElementName(xmlStreamReader);
        BString currentFieldName = StringUtils.fromString(elemName);
        String lastElement = getLastElementInSiblings(xmlParserData.siblings);
        Type restType = TypeUtils.getReferredType(xmlParserData.restTypes.peek());

        if (!xmlParserData.siblings.isEmpty() && lastElement != null
                && !xmlParserData.siblings.getOrDefault(lastElement, true)) {
            xmlParserData.parents.push(xmlParserData.siblings);
            xmlParserData.siblings = new LinkedHashMap<>();
            xmlParserData.siblings.put(elemName, false);
            BMap<BString, Object> temp =
                    (BMap<BString, Object>) currentNode.get(StringUtils.fromString(lastElement));
            temp.put(currentFieldName, ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE));
            xmlParserData.nodesStack.add(currentNode);
            currentNode = temp;
            return currentFieldName;
        } else if (!xmlParserData.siblings.containsKey(elemName)) {
            xmlParserData.siblings.put(elemName, false);
            if (restType.getTag() == TypeTags.ARRAY_TAG) {
                BArray tempArray = ValueCreator.createArrayValue(definedAnyDataArrayType);
                currentNode.put(StringUtils.fromString(elemName), tempArray);
            } else {
                currentNode.put(currentFieldName, ValueCreator.createMapValue(Constants.JSON_MAP_TYPE));
            }
            return currentFieldName;
        }

        xmlParserData.parents.push(xmlParserData.siblings);
        xmlParserData.siblings = new LinkedHashMap<>();
        Object currentElement = currentNode.get(StringUtils.fromString(elemName));
        xmlParserData.nodesStack.add(currentNode);

        if (currentElement instanceof BArray) {
            return currentFieldName;
        }

        if (!DataUtils.isArrayValueAssignable(restType.getTag())) {
            throw DataUtils.getXmlError("Expected an '" + restType + "' value for the field '" + elemName
                    + "' found 'array' value");
        }
        BArray tempArray = ValueCreator.createArrayValue(definedAnyDataArrayType);
        tempArray.append(currentElement);
        currentNode.put(StringUtils.fromString(elemName), tempArray);
        if (!(currentElement instanceof BMap)) {
            return currentFieldName;
        }
        BMap<BString, Object> temp = ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
        tempArray.append(temp);
        currentNode = temp;
        return currentFieldName;
    }

    private void endElementRest(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        String elemName = getElementName(xmlStreamReader);
        if (xmlParserData.siblings.containsKey(elemName) && !xmlParserData.siblings.get(elemName)) {
            xmlParserData.siblings.put(elemName, true);
        }

        if (xmlParserData.parents.isEmpty() || !xmlParserData.parents.peek().containsKey(elemName)) {
            return;
        }

        currentNode = (BMap<BString, Object>) xmlParserData.nodesStack.pop();
        xmlParserData.siblings = xmlParserData.parents.pop();
        if (xmlParserData.siblings.containsKey(elemName) && xmlParserData.restFieldsPoints.remove(elemName)) {
            xmlParserData.fieldHierarchy.pop();
            xmlParserData.restTypes.pop();
        }
        xmlParserData.siblings.put(elemName, true);
    }

    private void readTextRest(XMLStreamReader xmlStreamReader, BString currentFieldName, XmlParserData xmlParserData) {
        String text = xmlStreamReader.getText();
        if (text.strip().isBlank()) {
            return;
        }

        BString bText = StringUtils.fromString(text);
        Type restType = TypeUtils.getReferredType(xmlParserData.restTypes.peek());
        // TODO: <name>James <!-- FirstName --> Clark</name>
        if (currentNode.get(currentFieldName) instanceof BArray) {
            ((BArray) currentNode.get(currentFieldName)).append(
                    convertStringToRestExpType(bText, restType));
        } else {
            currentNode.put(currentFieldName, convertStringToRestExpType(bText, restType));
        }
    }

    private String getLastElementInSiblings(LinkedHashMap<String, Boolean> siblings) {
        Object[] arr = siblings.keySet().toArray();
        String lastElement = null;
        if (arr.length != 0) {
            lastElement = (String) arr[arr.length - 1];
        }
        return lastElement;
    }

    private String validateAndGetXmlNameFromRecordAnnotation(RecordType recordType, String recordName,
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

    private Map<String, Field> getAllFieldsInRecordType(RecordType recordType, XmlParserData xmlParserData) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        HashMap<String, String> modifiedNames = new LinkedHashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD)) {
                String fieldName = keyStr.split("\\$field\\$\\.")[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                modifiedNames.put(fieldName, getModifiedName(fieldAnnotation, fieldName));
            }
        }

        Map<String, Field> fields = new HashMap<>();
        Map<String, Field> recordFields = recordType.getFields();
        for (String key : recordFields.keySet()) {
            String modifiedName = modifiedNames.getOrDefault(key, key);
            if (fields.containsKey(modifiedName)) {
                // TODO: Handle the cases with different namespace by representing field with QName.
                // eg:- <x:foo xmlns:x="example.com" xmlns:y="example2.com" ><x:bar></x:bar><y:bar></y:bar></x:foo>
                throw DataUtils.getXmlError("Duplicate field '" + modifiedName + "'");
            } else if (xmlParserData.attributeHierarchy.peek().containsKey(key)) {
                continue;
            }

            fields.put(modifiedName, recordFields.get(key));
        }
        xmlParserData.modifiedNamesHierarchy.add(modifiedNames);
        return fields;
    }

    private String getModifiedName(Map<BString, Object> fieldAnnotation, String attributeName) {
        for (BString key : fieldAnnotation.keySet()) {
            if (key.getValue().endsWith(Constants.NAME)) {
                return ((Map<BString, Object>) fieldAnnotation.get(key)).get(Constants.VALUE).toString();
            }
        }
        return attributeName;
    }

    private void handleAttributes(XMLStreamReader xmlStreamReader, RecordType recordType, XmlParserData xmlParserData) {
        for (int i = 0; i < xmlStreamReader.getAttributeCount(); i++) {
            QName qName = xmlStreamReader.getAttributeName(i);
            String attributeName = qName.getLocalPart();
            Field field = xmlParserData.attributeHierarchy.peek().remove(attributeName);
            if (field == null) {
                field = xmlParserData.fieldHierarchy.peek().get(attributeName);
            }

            if (field == null) {
                return;
            }

            DataUtils.validateFieldNamespace(qName.getPrefix(), qName.getNamespaceURI(), field.getFieldName(),
                    recordType);

            try {
                currentNode.put(StringUtils.fromString(field.getFieldName()), convertStringToExpType(
                        StringUtils.fromString(xmlStreamReader.getAttributeValue(i)), field.getFieldType()));
            } catch (Exception e) {
                // Ignore: Expected type will mismatch when element and attribute having same name.
            }
        }
    }

    private Optional<Object> handleRecordRestType(XmlParserData xmlParserData, XMLStreamReader xmlStreamReader) {
        xmlParserData.currentField = null;
        Type restType = TypeUtils.getReferredType(xmlParserData.restTypes.peek());
        int restTypeTag = restType.getTag();
        String elementName = getElementName(xmlStreamReader);
        if (restTypeTag == TypeTags.RECORD_TYPE_TAG) {
            RecordType recordType = (RecordType) restType;
            currentNode = updateNextValue(recordType, elementName, restType, xmlParserData);;
            handleAttributes(xmlStreamReader, recordType, xmlParserData);
            parseRecordRest(elementName, xmlParserData);
            xmlParserData.siblings.clear();
            return Optional.ofNullable(xmlParserData.nodesStack.pop());
        } else if (restTypeTag == TypeTags.ARRAY_TAG) {
            ArrayType arrayType = (ArrayType) restType;
            Type elemType = TypeUtils.getReferredType(arrayType.getElementType());
            if (elemType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                // Create an array value since expected type is an array.
                if (!currentNode.containsKey(StringUtils.fromString(elementName))) {
                    currentNode.put(StringUtils.fromString(elementName),
                            ValueCreator.createArrayValue(definedAnyDataArrayType));
                }
                currentNode = updateNextValue((RecordType) elemType, elementName, arrayType, xmlParserData);
                handleAttributes(xmlStreamReader, (RecordType) elemType, xmlParserData);
                parseRecordRest(elementName, xmlParserData);
                xmlParserData.siblings.clear();
                return Optional.ofNullable(xmlParserData.nodesStack.pop());
            }
        }
        return Optional.empty();
    }

    private String getElementName(XMLStreamReader xmlStreamReader) {
        return xmlStreamReader.getName().getLocalPart();
    }

    public static class XmlParserData {
        private final Stack<Object> nodesStack = new Stack<>();
        private final Stack<Map<String, Field>> fieldHierarchy = new Stack<>();
        private final Stack<Map<String, Field>> attributeHierarchy = new Stack<>();
        private final Stack<Map<String, String>> modifiedNamesHierarchy = new Stack<>();
        private final Stack<Type> restTypes = new Stack<>();
        private final Stack<String> restFieldsPoints = new Stack<>();
        private final Stack<RecordType> recordTypeStack = new Stack<>();
        private RecordType rootRecord;
        private Field currentField;
        private String rootElement;
        private final Stack<LinkedHashMap<String, Boolean>> parents = new Stack<>();
        private LinkedHashMap<String, Boolean> siblings = new LinkedHashMap<>();
    }
}
