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

import io.ballerina.lib.data.xmldata.io.BallerinaByteBlockInputStream;
import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;

import static io.ballerina.lib.data.xmldata.utils.DataReader.resolveCloseMethod;
import static io.ballerina.lib.data.xmldata.utils.DataReader.resolveNextMethod;

/**
 * Xml conversion.
 *
 * @since 0.1.0
 */
public class Native {

    public static Object parseAsType(BXml xml, BMap<BString, Object> options, BTypedesc typed) {
        try {
            return XmlTraversal.traverse(xml, options, typed);
        } catch (Exception e) {
            return DiagnosticLog.createXmlError(e.getMessage());
        }
    }
    public static Object parseString(BString xml, BMap<BString, Object> options, BTypedesc typed) {
        try {
            return XmlParser.parse(new StringReader(xml.getValue()), options, typed);
        } catch (Exception e) {
            return DiagnosticLog.error(DiagnosticErrorCode.XML_PARSE_ERROR, e.getMessage());
        }
    }

    public static Object parseBytes(BArray xml, BMap<BString, Object> options, BTypedesc typed) {
        try {
            return XmlParser.parse(new InputStreamReader(new ByteArrayInputStream(xml.getBytes())), options, typed);
        } catch (Exception e) {
            return DiagnosticLog.error(DiagnosticErrorCode.XML_PARSE_ERROR, e.getMessage());
        }
    }

    public static Object parseStream(Environment env, BStream xml, BMap<BString, Object> options, BTypedesc typed) {
        try {
            final BObject iteratorObj = xml.getIteratorObj();
            BallerinaByteBlockInputStream byteBlockSteam = new BallerinaByteBlockInputStream(env,
                    iteratorObj, resolveNextMethod(iteratorObj), resolveCloseMethod(iteratorObj));
            Object result = XmlParser.parse(new InputStreamReader(byteBlockSteam), options, typed);
            if (byteBlockSteam.getError() != null) {
                return byteBlockSteam.getError();
            }
            return result;
        } catch (Exception e) {
            return DiagnosticLog.error(DiagnosticErrorCode.XML_PARSE_ERROR, e.getMessage());
        }
    }

    public static Object validate(Object xsd, BXml xml) {
        try {
            return XSDValidator.validate(xsd, xml);
        } catch (Exception e) {
            return DiagnosticLog.error(DiagnosticErrorCode.INVALID_XML, e.getMessage());
        }
    }
}
