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

type XsdChoiceWithNameAnnotationWithXmlValue record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_Name_EA1 seq_EA1?;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithNameAnnotationWithXmlValue() returns error? {
    xml xmlValue;
    XsdChoiceWithNameAnnotationWithXmlValue|Error v;

    xmlValue = xml `<Root><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {});
    
    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA3: ["AB", "AB", "AB", "AB"]}});

    xmlValue = xml `<Root><A2>ABC</A2></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC"}});

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlValue = xml `<Root><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC", "ABC"]}});

    xmlValue = xml `<Root><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlValue = xml `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A1>ABC</A1><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A1' occurs more than the max allowed times");

    xmlValue = xml `<Root><A1>ABC</A1><A1>ABC</A1><A3>ABC</A3><A3>ABC</A3><A3>ABC</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'seq_EA1' occurs more than the max allowed times");
}

type XsdChoiceWithNameAnnotationWithXmlValue2 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_Name_EA2 seq_EA2;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithNameAnnotationWithXmlValue2() returns error? {
    xml xmlValue;
    XsdChoiceWithNameAnnotationWithXmlValue2|Error v;

    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");
    
    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>CD</A3></A></Root>`;
    v = parseAsType(xmlValue);    
    test:assertEquals(v, {seq_EA2:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlValue = xml `<Root><A><A1>ABC</A1><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>CD</A3></A></Root>`;
    v = parseAsType(xmlValue);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A1>ABC</A1><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");
}
