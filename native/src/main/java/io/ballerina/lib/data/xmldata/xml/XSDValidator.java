/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.lib.data.xmldata.utils.ModuleUtils;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

/**
 * Represent native APIS for validating XML against a XSD.
 *
 * @since 1.1.0
 */
public class XSDValidator {
    private static final String SOURCE_OPTIONS = "SourceOptions";
    private static final String CONTENT_FIELD = "#content";
    private static final BString ATTRIBUTE_PREFIX = StringUtils.fromString("attributePrefix");
    private static final BString TEXT_FIELD_NAME = StringUtils.fromString("textFieldName");
    public static Object validate(Object xsd, BXml xml) throws ParserConfigurationException, IOException, SAXException {
        try {
            if (xsd instanceof BString) {
                return validateXmlFromXsdFile(xsd.toString(), xml);
            }
            return validateXsdFromXsdRecord((BTypedesc) xsd, xml);
        } catch (Exception e) {
            throw e;
        }
    }

    private static Object validateXmlFromXsdFile(String xsdFilePath, BXml xml)
            throws ParserConfigurationException, IOException, SAXException {
        try {
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            dbFactory.setIgnoringComments(true); // Ignore comments in the XML
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document document = dBuilder.parse(new InputSource(new StringReader(StringUtils.getStringValue(xml))));

            DOMSource source = new DOMSource(document);
            SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            Schema schema = factory.newSchema(new File(xsdFilePath));
            Validator validator = schema.newValidator();
            validator.validate(source);
            return null;
        } catch (Exception e) {
            throw e;
        }
    }

    private static Object validateXsdFromXsdRecord(BTypedesc xsdRecord, BXml xml) {
        try {
            Object result =  XmlTraversal.traverse(xml, getDefaultSourceOptions(), xsdRecord);
            if (result instanceof BError e) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_XML, e.getMessage());
            }
        } catch (Exception e) {
            throw e;
        }
        return null;
    }

    private static BMap<BString, Object> getDefaultSourceOptions() {
        BMap<BString, Object> sourceOptions = ValueCreator
                .createRecordValue(ModuleUtils.getModule(), SOURCE_OPTIONS);
        sourceOptions.put(ATTRIBUTE_PREFIX, StringUtils.fromString(""));
        sourceOptions.put(TEXT_FIELD_NAME, StringUtils.fromString(CONTENT_FIELD));
        return sourceOptions;
    }
}
