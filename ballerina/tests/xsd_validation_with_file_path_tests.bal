// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/io;

function readXmlFile(string path) returns xml|error {
    return io:fileReadXml(path);
}

@test:Config {groups: ["xsd"], dataProvider: xsdValidationDataProvider}
function testValidateSchema(string xsdPath, string validXmlPath, string invalidXmlPath) returns error? {
    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    Error? e = validate(validXml, xsdPath);
    test:assertTrue(e is (), msg = "Valid XML should pass validation");

    e = validate(invalidXml, xsdPath);
    test:assertTrue(e is Error, msg = "Invalid XML should fail validation");
    test:assertTrue((<Error>e).message().includes("Invalid XML found"), msg = "Invalid XML should fail validation");
}

function xsdValidationDataProvider() returns [string, string, string][] {
    return [
        ["tests/resources/xsd_tests/schemas/schema_1.xsd", "tests/resources/xsd_tests/xml_values/schema_1_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_1_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_2.xsd", "tests/resources/xsd_tests/xml_values/schema_2_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_2_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_3.xsd", "tests/resources/xsd_tests/xml_values/schema_3_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_3_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_4.xsd", "tests/resources/xsd_tests/xml_values/schema_4_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_4_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_5.xsd", "tests/resources/xsd_tests/xml_values/schema_5_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_5_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_6.xsd", "tests/resources/xsd_tests/xml_values/schema_6_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_6_invalid_xml.xml"], 
        ["tests/resources/xsd_tests/schemas/schema_7.xsd", "tests/resources/xsd_tests/xml_values/schema_7_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_7_invalid_xml.xml"], 
        ["tests/resources/xsd_tests/schemas/schema_8.xsd", "tests/resources/xsd_tests/xml_values/schema_8_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_8_invalid_xml.xml"], 
        ["tests/resources/xsd_tests/schemas/schema_9.xsd", "tests/resources/xsd_tests/xml_values/schema_9_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_9_invalid_xml.xml"], 
        ["tests/resources/xsd_tests/schemas/schema_10.xsd", "tests/resources/xsd_tests/xml_values/schema_10_valid_xml.xml", 
            "tests/resources/xsd_tests/xml_values/schema_10_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_11.xsd", "tests/resources/xsd_tests/xml_values/schema_11_valid_xml.xml",
            "tests/resources/xsd_tests/xml_values/schema_11_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_11.xsd", "tests/resources/xsd_tests/xml_values/schema_11_valid_xml.xml",
            "tests/resources/xsd_tests/xml_values/schema_11_invalid_xml_2.xml"],
        ["tests/resources/xsd_tests/schemas/schema_12.xsd", "tests/resources/xsd_tests/xml_values/schema_12_valid_xml.xml",
            "tests/resources/xsd_tests/xml_values/schema_12_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_12.xsd", "tests/resources/xsd_tests/xml_values/schema_12_valid_xml.xml",
            "tests/resources/xsd_tests/xml_values/schema_12_invalid_xml_2.xml"],
        ["tests/resources/xsd_tests/schemas/schema_13.xsd", "tests/resources/xsd_tests/xml_values/schema_13_valid_xml.xml",
            "tests/resources/xsd_tests/xml_values/schema_13_invalid_xml.xml"],
        ["tests/resources/xsd_tests/schemas/schema_13.xsd", "tests/resources/xsd_tests/xml_values/schema_13_valid_xml.xml",
            "tests/resources/xsd_tests/xml_values/schema_13_invalid_xml_2.xml"]

    ];
}
