// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

import ballerina/file;
import ballerina/io;
import ballerina/test;

string testResourcesPath = check file:joinPath("tests", "resources", "xsd_tests", "xxe_tests");

@test:Config {groups: ["xsd", "xxe", "security"]}
function testXxePreventionWithMaliciousDtd() returns error? {
    string validXmlPath = check file:joinPath(testResourcesPath, "simple_valid.xml");
    xml validXml = check io:fileReadXml(validXmlPath);
    string schemaPath = check file:joinPath(testResourcesPath, "malicious_xxe_schema.xsd");
    Error? result = validate(validXml, schemaPath);
    test:assertTrue(result is Error, msg = "XXE attack via external DTD should be blocked");
}

@test:Config {groups: ["xsd", "xxe", "security"]}
function testXxePreventionWithExternalEntity() returns error? {
    string validXmlPath = check file:joinPath(testResourcesPath, "simple_valid.xml");
    xml validXml = check io:fileReadXml(validXmlPath);
    string schemaPath = check file:joinPath(testResourcesPath, "xxe_entity_schema.xsd");
    Error? result = validate(validXml, schemaPath);
    test:assertTrue(result is Error, msg = "XXE attack via external entity should be blocked");
}

@test:Config {groups: ["xsd", "xxe", "security"]}
function testNormalXsdValidationStillWorks() returns error? {
    string validXmlPath = check file:joinPath(testResourcesPath, "simple_valid.xml");
    xml validXml = check io:fileReadXml(validXmlPath);
    string schemaPath = check file:joinPath(testResourcesPath, "simple_valid_schema.xsd");
    Error? result = validate(validXml, schemaPath);
    test:assertTrue(result is (), msg = "Normal XSD validation should work after XXE fix");
}
