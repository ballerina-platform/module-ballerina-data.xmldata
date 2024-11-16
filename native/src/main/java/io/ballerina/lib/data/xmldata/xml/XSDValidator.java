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

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import java.io.File;
import java.io.StringReader;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

public class XSDValidator {
    public static boolean validate(Object xsd, BXml xml) {
        if (xsd instanceof BString) {
            return validateXmlFromXsdFile(xsd.toString(), xml);
        }
        return validateXsdFromXsdRecord((BTypedesc) xsd, xml);
    }

    private static boolean validateXmlFromXsdFile(String xsdFilePath, BXml xml) {
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
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean validateXsdFromXsdRecord(BTypedesc xsdRecord, BXml xml) {
        try {
            Object result =  XmlTraversal.traverse(xml,
                    ValueCreator.createMapValue(PredefinedTypes.TYPE_STRING), xsdRecord);
            if (result instanceof BError) {
                return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
