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

type XsdChoiceWithNameAnnotation record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_Name_EA1 seq_EA1?;
};

type Choice_Name_EA1 record {

    @Element {
        maxOccurs: 2,
        minOccurs: 0
    }
    @Name {
        value: "A1"
    }
    string[] EA1?;

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @Name {
        value: "A2"
    }
    string EA2?;

    @Element {
        maxOccurs: 4,
        minOccurs: 2
    }
    @Name {
        value: "A3"
    }
    string[] EA3?;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithNameAnnotation() returns error? {
    string xmlStr;
    XsdChoiceWithNameAnnotation|Error v;

    xmlStr = string `<Root><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {});
    
    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA3: ["AB", "AB", "AB", "AB"]}});

    xmlStr = string `<Root><A2>ABC</A2></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC"}});

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlStr = string `<Root><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC", "ABC"]}});

    xmlStr = string `<Root><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlStr = string `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A1>ABC</A1><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A1' occurs more than the max allowed times");

    xmlStr = string `<Root><A1>ABC</A1><A1>ABC</A1><A3>ABC</A3><A3>ABC</A3><A3>ABC</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'seq_EA1' occurs more than the max allowed times");
}

type XsdChoiceWithNameAnnotation2 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_Name_EA2 seq_EA2;
};

type Choice_Name_EA2 record {
    @Name {
        value: "A"
    }
    record {
        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @Name {
            value: "A1"
        }
        string EA1?;

        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @Name {
            value: "A2"
        }
        string EA2?;

        @Element {
            maxOccurs: 4,
            minOccurs: 2
        }
        @Name {
            value: "A3"
        }
        string[] EA3?;
    } EA;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithNameAnnotation2() returns error? {
    string xmlStr;
    XsdChoiceWithNameAnnotation2|Error v;

    xmlStr = string `<Root><A><A1>ABC</A1><A2>ABC</A2></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");
    
    xmlStr = string `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>CD</A3></A></Root>`;
    v = parseString(xmlStr);    
    test:assertEquals(v, {seq_EA2:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlStr = string `<Root><A><A2>ABC</A2><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><A><A2>ABC</A2><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><A><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><A><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlStr = string `<Root><A><A1>ABC</A1><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>CD</A3></A></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlStr = string `<Root><A><A1>ABC</A1><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");
}
