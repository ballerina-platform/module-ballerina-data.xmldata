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

@test:Config {groups: ["xsd"]}
function testValidateSchema1() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_1.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_1_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_1_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    Error? e = validate(xsdPath, validXml);
    test:assertTrue(e is (), msg = "Valid XML should pass validation");

    e = validate(xsdPath, invalidXml);
    test:assertTrue(e is Error, msg = "Invalid XML should fail validation");
    test:assertTrue((<Error>e).message().includes("Invalid XML found"), msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema2() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_2.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_2_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_2_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    Error? e = validate(xsdPath, validXml);
    test:assertTrue(e is (), msg = "Valid XML should pass validation");

    e = validate(xsdPath, invalidXml);
    test:assertTrue(e is Error, msg = "Invalid XML should fail validation");
    test:assertTrue((<Error>e).message().includes("Invalid XML found"), msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema3() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_3.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_3_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_3_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    Error? e = validate(xsdPath, validXml);
    test:assertTrue(e is (), msg = "Valid XML should pass validation");

    e = validate(xsdPath, invalidXml);
    test:assertTrue(e is Error, msg = "Invalid XML should fail validation");
    test:assertTrue((<Error>e).message().includes("Invalid XML found"), msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema4() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_4.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_4_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_4_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    Error? e = validate(xsdPath, validXml);
    test:assertTrue(e is (), msg = "Valid XML should pass validation");

    e = validate(xsdPath, invalidXml);
    test:assertTrue(e is Error, msg = "Invalid XML should fail validation");
    test:assertTrue((<Error>e).message().includes("Invalid XML found"), msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema5() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_5.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_5_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_5_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    Error? e = validate(xsdPath, validXml);
    test:assertTrue(e is (), msg = "Valid XML should pass validation");

    e = validate(xsdPath, invalidXml);
    test:assertTrue(e is Error, msg = "Invalid XML should fail validation");
    test:assertTrue((<Error>e).message().includes("Invalid XML found"), msg = "Invalid XML should fail validation");
}
