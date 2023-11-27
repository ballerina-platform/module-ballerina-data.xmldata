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
import io.ballerina.stdlib.data.utils.DiagnosticErrorCode;
import io.ballerina.stdlib.data.utils.DiagnosticLog;

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
 * @since 0.0.1
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
            throw DiagnosticLog.getXmlError(PARSE_ERROR_PREFIX + e.getMessage());
        }
    }

    private static void initRootObject(Type recordType, XmlParserData xmlParserData) {
        currentNode = ValueCreator.createRecordValue((RecordType) recordType);
        xmlParserData.nodesStack.push(currentNode);
    }

    private void handleXMLStreamException(Exception e) {
        String reason = e.getCause() == null ? e.getMessage() : e.getCause().getMessage();
        if (reason == null) {
            throw DiagnosticLog.getXmlError(PARSE_ERROR);
        }
        throw DiagnosticLog.getXmlError(PARSE_ERROR_PREFIX + reason);
    }

    public Object parse(Type type, XmlParserData xmlParserData) {
        if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE, Constants.RECORD, type.getName());
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
            throw DiagnosticLog.getXmlError(PARSE_ERROR_PREFIX + e);
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
                    QName endElement = xmlStreamReader.getName();
                    if (endElement.getLocalPart().equals(startElementName)) {
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
                    throw DiagnosticLog.error(DiagnosticErrorCode.XML_ROOT_MISSING);
                }
            }

            RecordType rootRecord = xmlParserData.rootRecord;
            initRootObject(rootRecord, xmlParserData);

            QualifiedName elementQName = getElementName(xmlStreamReader);
            xmlParserData.rootElement =
                    DataUtils.validateAndGetXmlNameFromRecordAnnotation(rootRecord, rootRecord.getName(), elementQName);
            DataUtils.validateTypeNamespace(elementQName.getPrefix(), elementQName.getNamespaceURI(), rootRecord);

            // Keep track of fields and attributes
            updateExpectedTypeStacks(rootRecord, xmlParserData);
            handleAttributes(xmlStreamReader, xmlParserData);
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
            Map<QualifiedName, Field> currentFieldMap = xmlParserData.fieldHierarchy.peek();
            if (!currentFieldMap.containsKey(Constants.CONTENT_QNAME)) {
                return;
            } else {
                currentField = currentFieldMap.remove(Constants.CONTENT_QNAME);
            }
        }

        BString bText = StringUtils.fromString(text);
        String fieldName = currentField.getFieldName();
        BString bFieldName = StringUtils.fromString(fieldName);
        Type fieldType = TypeUtils.getReferredType(currentField.getFieldType());
        if (currentNode.containsKey(bFieldName)) {
            // Handle - <name>James <!-- FirstName --> Clark</name>
            if (!xmlParserData.siblings.get(
                    xmlParserData.modifiedNamesHierarchy.peek().getOrDefault(fieldName,
                            new QualifiedName(QualifiedName.NS_ANNOT_NOT_DEFINED, fieldName, "")))
                    && DataUtils.isStringValueAssignable(fieldType.getTag())) {
                currentNode.put(bFieldName,
                        StringUtils.fromString(currentNode.get(bFieldName) + xmlStreamReader.getText()));
                return;
            }

            if (!DataUtils.isArrayValueAssignable(fieldType.getTag())) {
                throw DiagnosticLog.error(DiagnosticErrorCode.FOUND_ARRAY_FOR_NON_ARRAY_TYPE, fieldType, fieldName);
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

    @SuppressWarnings("unchecked")
    private void handleContentFieldInRecordType(RecordType recordType, BString text, XmlParserData xmlParserData) {
        popStacks(xmlParserData);
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
                return convertStringToRestExpType(value, ((ArrayType) expType).getElementType());
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
        throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_REST_TYPE, expType.getName());
    }

    private Object buildDocument(XmlParserData xmlParserData) {
        validateRequiredFields(currentNode, xmlParserData);
        return currentNode;
    }

    @SuppressWarnings("unchecked")
    private void endElement(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        xmlParserData.currentField = null;
        QualifiedName elemQName = getElementName(xmlStreamReader);
        LinkedHashMap<QualifiedName, Boolean> siblings = xmlParserData.siblings;
        Stack<LinkedHashMap<QualifiedName, Boolean>> parents = xmlParserData.parents;
        if (siblings.containsKey(elemQName) && !siblings.get(elemQName)) {
            siblings.put(elemQName, true);
        }
        if (parents.isEmpty() || !parents.peek().containsKey(elemQName)) {
            return;
        }

        validateRequiredFields(currentNode, xmlParserData);
        currentNode = (BMap<BString, Object>) xmlParserData.nodesStack.pop();
        popStacks(xmlParserData);
    }

    private void validateRequiredFields(BMap<BString, Object> currentMapValue, XmlParserData xmlParserData) {
        Map<QualifiedName, Field> fields = xmlParserData.fieldHierarchy.peek();
        for (QualifiedName key : fields.keySet()) {
            // Validate required array size
            Field field = fields.get(key);
            String fieldName = field.getFieldName();
            if (field.getFieldType().getTag() == TypeTags.ARRAY_TAG) {
                ArrayType arrayType = (ArrayType) field.getFieldType();
                if (arrayType.getSize() != -1
                        && arrayType.getSize() != ((BArray) currentMapValue.get(
                                StringUtils.fromString(fieldName))).getLength()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                }
            }

            if (!SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)
                    && !currentMapValue.containsKey(StringUtils.fromString(fieldName))) {
                throw DiagnosticLog.error(DiagnosticErrorCode.REQUIRED_FIELD_NOT_PRESENT, fieldName);
            }
        }

        Map<QualifiedName, Field> attributes = xmlParserData.attributeHierarchy.peek();
        for (QualifiedName key : attributes.keySet()) {
            Field field = attributes.get(key);
            if (!SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.REQUIRED_ATTRIBUTE_NOT_PRESENT, field.getFieldName());
            }
        }
    }

    private void readElement(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        QualifiedName elemQName = getElementName(xmlStreamReader);
        Field currentField = xmlParserData.fieldHierarchy.peek().get(elemQName);
        xmlParserData.currentField = currentField;
        if (xmlParserData.currentField == null) {
            if (xmlParserData.restTypes.peek() == null) {
                return;
            }
            currentNode = handleRestField(xmlParserData);
            return;
        }

        String fieldName = currentField.getFieldName();
        Object temp = currentNode.get(StringUtils.fromString(fieldName));
        BString bFieldName = StringUtils.fromString(fieldName);
        if (!xmlParserData.siblings.containsKey(elemQName)) {
            xmlParserData.siblings.put(elemQName, false);
            currentNode.remove(bFieldName); // This handles attribute and element with same name. Removes attribute.
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
            RecordType recordType = TypeCreator.createRecordType(Constants.ANON_TYPE, fieldType.getPackage(), 0,
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
        handleAttributes(xmlStreamReader, xmlParserData);
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
        xmlParserData.attributeHierarchy.push(new HashMap<>(getAllAttributesInRecordType(recordType)));
        xmlParserData.fieldHierarchy.push(new HashMap<>(getAllFieldsInRecordType(recordType, xmlParserData)));
        xmlParserData.restTypes.push(recordType.getRestFieldType());
    }

    private void popStacks(XmlParserData xmlParserData) {
        xmlParserData.fieldHierarchy.pop();
        xmlParserData.restTypes.pop();
        xmlParserData.modifiedNamesHierarchy.pop();
        xmlParserData.attributeHierarchy.pop();
        xmlParserData.siblings = xmlParserData.parents.pop();
        xmlParserData.rootRecord = xmlParserData.recordTypeStack.pop();
    }

    @SuppressWarnings("unchecked")
    private BMap<BString, Object> handleRestField(XmlParserData xmlParserData) {
        QualifiedName restStartPoint;
        if (xmlParserData.parents.isEmpty()) {
            restStartPoint = xmlParserData.rootElement;
        } else {
            restStartPoint = getLastElementInSiblings(xmlParserData.parents.peek());
        }
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

    @SuppressWarnings("unchecked")
    private BString readElementRest(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        QualifiedName elemQName = getElementName(xmlStreamReader);
        BString currentFieldName = StringUtils.fromString(elemQName.getLocalPart());
        QualifiedName lastElement = getLastElementInSiblings(xmlParserData.siblings);
        Type restType = TypeUtils.getReferredType(xmlParserData.restTypes.peek());

        if (!xmlParserData.siblings.isEmpty() && lastElement != null
                && !xmlParserData.siblings.getOrDefault(lastElement, true)) {
            xmlParserData.parents.push(xmlParserData.siblings);
            xmlParserData.siblings = new LinkedHashMap<>();
            xmlParserData.siblings.put(elemQName, false);
            BMap<BString, Object> temp =
                    (BMap<BString, Object>) currentNode.get(StringUtils.fromString(lastElement.getLocalPart()));
            temp.put(currentFieldName, ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE));
            xmlParserData.nodesStack.add(currentNode);
            currentNode = temp;
            handleAttributesRest(xmlStreamReader, restType, currentNode);
            return currentFieldName;
        } else if (!xmlParserData.siblings.containsKey(elemQName)) {
            xmlParserData.siblings.put(elemQName, false);
            if (restType.getTag() == TypeTags.ARRAY_TAG) {
                BArray tempArray = ValueCreator.createArrayValue(definedAnyDataArrayType);
                currentNode.put(currentFieldName, tempArray);
            } else {
                BMap<BString, Object> next = ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
                currentNode.put(currentFieldName, next);
                currentNode = next;
                handleAttributesRest(xmlStreamReader, restType, next);
            }
            return currentFieldName;
        }

        xmlParserData.parents.push(xmlParserData.siblings);
        xmlParserData.siblings = new LinkedHashMap<>();
        Object currentElement = currentNode.get(currentFieldName);
        xmlParserData.nodesStack.add(currentNode);

        if (currentElement instanceof BArray) {
            BMap<BString, Object> temp = ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
            ((BArray) currentElement).append(temp);
            currentNode = temp;
            handleAttributesRest(xmlStreamReader, restType, currentNode);
            return currentFieldName;
        }

        if (!DataUtils.isArrayValueAssignable(restType.getTag())) {
            throw DiagnosticLog.error(
                    DiagnosticErrorCode.FOUND_ARRAY_FOR_NON_ARRAY_TYPE, restType, elemQName.getLocalPart());
        }
        BArray tempArray = ValueCreator.createArrayValue(definedAnyDataArrayType);
        tempArray.append(currentElement);
        currentNode.put(currentFieldName, tempArray);
        BMap<BString, Object> temp = ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
        tempArray.append(temp);
        currentNode = temp;
        handleAttributesRest(xmlStreamReader, restType, currentNode);
        return currentFieldName;
    }

    @SuppressWarnings("unchecked")
    private void endElementRest(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        QualifiedName elemQName = getElementName(xmlStreamReader);
        if (xmlParserData.siblings.containsKey(elemQName) && !xmlParserData.siblings.get(elemQName)) {
            xmlParserData.siblings.put(elemQName, true);
        }

        if (xmlParserData.parents.isEmpty() || !xmlParserData.parents.peek().containsKey(elemQName)) {
            return;
        }

        currentNode = (BMap<BString, Object>) xmlParserData.nodesStack.pop();
        xmlParserData.siblings = xmlParserData.parents.pop();
        if (xmlParserData.siblings.containsKey(elemQName) && xmlParserData.restFieldsPoints.remove(elemQName)) {
            xmlParserData.fieldHierarchy.pop();
            xmlParserData.restTypes.pop();
        }
        xmlParserData.siblings.put(elemQName, true);
    }

    @SuppressWarnings("unchecked")
    private void readTextRest(XMLStreamReader xmlStreamReader, BString currentFieldName, XmlParserData xmlParserData) {
        String text = xmlStreamReader.getText();
        if (text.strip().isBlank()) {
            return;
        }

        BString bText = StringUtils.fromString(text);
        Type restType = TypeUtils.getReferredType(xmlParserData.restTypes.peek());
        // TODO: <name>James <!-- FirstName --> Clark</name>
        Object currentElement = currentNode.get(currentFieldName);
        BMap<BString, Object> parent = (BMap<BString, Object>) xmlParserData.nodesStack.peek();

        if (currentElement == null && !currentNode.isEmpty()) { // Add text to the #content field
            currentNode.put(StringUtils.fromString(Constants.CONTENT), convertStringToRestExpType(bText, restType));
            currentNode = parent;
        } else if (currentElement == null) {
            currentElement = parent.get(currentFieldName);
            if (currentElement instanceof BArray) {
                BArray tempArray = (BArray) parent.get(currentFieldName);
                BMap<BString, Object> temp = (BMap<BString, Object>) tempArray.get(tempArray.getLength() - 1);
                if (temp.isEmpty()) {
                    tempArray.add(tempArray.getLength() - 1, convertStringToRestExpType(bText, restType));
                } else {
                    temp.put(StringUtils.fromString(Constants.CONTENT), convertStringToRestExpType(bText, restType));
                }
            } else {
                parent.put(currentFieldName, convertStringToRestExpType(bText, restType));
                currentNode = parent;
            }
        } else {
            currentNode.put(currentFieldName, convertStringToRestExpType(bText, restType));
        }
    }

    private QualifiedName getLastElementInSiblings(LinkedHashMap<QualifiedName, Boolean> siblings) {
        Object[] arr = siblings.keySet().toArray();
        QualifiedName lastElement = null;
        if (arr.length != 0) {
            lastElement = (QualifiedName) arr[arr.length - 1];
        }
        return lastElement;
    }

    @SuppressWarnings("unchecked")
    private Map<QualifiedName, Field> getAllFieldsInRecordType(RecordType recordType, XmlParserData xmlParserData) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        HashMap<String, QualifiedName> modifiedNames = new LinkedHashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD)) {
                // Capture namespace and name from the field annotation.
                String fieldName = keyStr.split(Constants.FIELD_REGEX)[1];
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                QualifiedName fieldQName = DataUtils.getFieldNameFromRecord(fieldAnnotation, fieldName);
                fieldQName.setLocalPart(getModifiedName(fieldAnnotation, fieldName));
                modifiedNames.put(fieldName, fieldQName);
            }
        }

        Map<QualifiedName, Field> fields = new HashMap<>();
        Map<String, Field> recordFields = recordType.getFields();
        for (String key : recordFields.keySet()) {
            QualifiedName modifiedQName =
                    modifiedNames.getOrDefault(key, new QualifiedName(QualifiedName.NS_ANNOT_NOT_DEFINED, key, ""));
            if (fields.containsKey(modifiedQName)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.DUPLICATE_FIELD, modifiedQName.getLocalPart());
            } else if (xmlParserData.attributeHierarchy.peek().containsKey(modifiedQName)) {
                continue;
            }

            fields.put(modifiedQName, recordFields.get(key));
        }
        xmlParserData.modifiedNamesHierarchy.add(modifiedNames);
        return fields;
    }

    @SuppressWarnings("unchecked")
    private Map<QualifiedName, Field> getAllAttributesInRecordType(RecordType recordType) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        Map<QualifiedName, Field> attributes = new HashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (keyStr.contains(Constants.FIELD) && DataUtils.isAttributeField(annotationKey, annotations)) {
                String attributeName = keyStr.split("\\$field\\$\\.")[1].replaceAll("\\\\", "");
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
                QualifiedName fieldQName = DataUtils.getFieldNameFromRecord(fieldAnnotation, attributeName);
                fieldQName.setLocalPart(getModifiedName(fieldAnnotation, attributeName));
                attributes.put(fieldQName, recordType.getFields().get(attributeName));
            }
        }
        return attributes;
    }

    @SuppressWarnings("unchecked")
    private String getModifiedName(Map<BString, Object> fieldAnnotation, String attributeName) {
        for (BString key : fieldAnnotation.keySet()) {
            if (key.getValue().endsWith(Constants.NAME)) {
                return ((Map<BString, Object>) fieldAnnotation.get(key)).get(Constants.VALUE).toString();
            }
        }
        return attributeName;
    }

    private void handleAttributes(XMLStreamReader xmlStreamReader, XmlParserData xmlParserData) {
        for (int i = 0; i < xmlStreamReader.getAttributeCount(); i++) {
            QName attributeQName = xmlStreamReader.getAttributeName(i);
            QualifiedName attQName = new QualifiedName(attributeQName.getNamespaceURI(),
                    attributeQName.getLocalPart(), attributeQName.getPrefix());
            Field field = xmlParserData.attributeHierarchy.peek().remove(attQName);
            if (field == null) {
                field = xmlParserData.fieldHierarchy.peek().get(attQName);
            }

            if (field == null) {
                return;
            }

            try {
                currentNode.put(StringUtils.fromString(field.getFieldName()), convertStringToExpType(
                        StringUtils.fromString(xmlStreamReader.getAttributeValue(i)), field.getFieldType()));
            } catch (Exception e) {
                // Ignore: Expected type will mismatch when element and attribute having same name.
            }
        }
    }

    private void handleAttributesRest(XMLStreamReader xmlStreamReader, Type restType, BMap<BString, Object> mapNode) {
        for (int i = 0; i < xmlStreamReader.getAttributeCount(); i++) {
            QName attributeQName = xmlStreamReader.getAttributeName(i);
            QualifiedName attQName = new QualifiedName(attributeQName.getNamespaceURI(),
                    attributeQName.getLocalPart(), attributeQName.getPrefix());

            try {
                mapNode.put(StringUtils.fromString(attQName.getLocalPart()), convertStringToRestExpType(
                        StringUtils.fromString(xmlStreamReader.getAttributeValue(i)), restType));
            } catch (Exception e) {
                // Ignore: Expected type will mismatch when element and attribute having same name.
            }
        }
    }

    private Optional<Object> handleRecordRestType(XmlParserData xmlParserData, XMLStreamReader xmlStreamReader) {
        xmlParserData.currentField = null;
        Type restType = TypeUtils.getReferredType(xmlParserData.restTypes.peek());
        int restTypeTag = restType.getTag();
        QualifiedName elementQName = getElementName(xmlStreamReader);
        String fieldName = elementQName.getLocalPart(); // Since local part equals to field name.
        if (restTypeTag == TypeTags.RECORD_TYPE_TAG) {
            RecordType recordType = (RecordType) restType;
            currentNode = updateNextValue(recordType, fieldName, restType, xmlParserData);
            handleAttributes(xmlStreamReader, xmlParserData);
            parseRecordRest(fieldName, xmlParserData);
            xmlParserData.siblings.clear();
            return Optional.ofNullable(xmlParserData.nodesStack.pop());
        } else if (restTypeTag == TypeTags.ARRAY_TAG) {
            ArrayType arrayType = (ArrayType) restType;
            Type elemType = TypeUtils.getReferredType(arrayType.getElementType());
            if (elemType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                // Create an array value since expected type is an array.
                if (!currentNode.containsKey(StringUtils.fromString(fieldName))) {
                    currentNode.put(StringUtils.fromString(fieldName),
                            ValueCreator.createArrayValue(definedAnyDataArrayType));
                }
                currentNode = updateNextValue((RecordType) elemType, fieldName, arrayType, xmlParserData);
                handleAttributes(xmlStreamReader, xmlParserData);
                parseRecordRest(fieldName, xmlParserData);
                xmlParserData.siblings.clear();
                return Optional.ofNullable(xmlParserData.nodesStack.pop());
            }
        }
        return Optional.empty();
    }

    private QualifiedName getElementName(XMLStreamReader xmlStreamReader) {
        QName qName = xmlStreamReader.getName();
        return new QualifiedName(qName.getNamespaceURI(), qName.getLocalPart(), qName.getPrefix());
    }

    public static class XmlParserData {
        private final Stack<Object> nodesStack = new Stack<>();
        private final Stack<Map<QualifiedName, Field>> fieldHierarchy = new Stack<>();
        private final Stack<Map<QualifiedName, Field>> attributeHierarchy = new Stack<>();
        private final Stack<Map<String, QualifiedName>> modifiedNamesHierarchy = new Stack<>();
        private final Stack<Type> restTypes = new Stack<>();
        private final Stack<QualifiedName> restFieldsPoints = new Stack<>();
        private final Stack<RecordType> recordTypeStack = new Stack<>();
        private RecordType rootRecord;
        private Field currentField;
        private QualifiedName rootElement;
        private final Stack<LinkedHashMap<QualifiedName, Boolean>> parents = new Stack<>();
        private LinkedHashMap<QualifiedName, Boolean> siblings = new LinkedHashMap<>();
    }
}
