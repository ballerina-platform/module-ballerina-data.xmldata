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

type XsdSequenceWithNamespaceAnnotation record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA1_NamespaceAnnotation seq_EA1_NamespaceAnnotation;
};

type Seq_EA1_NamespaceAnnotation record {

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @SequenceOrder {
        value: 1
    }
    @Namespace {
        uri: "example1.com",
        prefix: "ea1"
    }
    string EA1?;

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @SequenceOrder {
        value: 2
    }
    @Namespace {
        uri: "example2.com",
        prefix: "ea2"
    }
    string EA2?;

    @Element {
        maxOccurs: 4,
        minOccurs: 2
    }
    @Namespace {
        uri: "example3.com",
        prefix: "ea3"
    }
    @SequenceOrder {
        value: 3
    }
    string[] EA3?;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithNamespaceAnnotation() returns error? {
    string xmlStr;
    XsdSequenceWithNamespaceAnnotation|Error v;

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'EA3' is not found in 'seq_EA1_NamespaceAnnotation'");
    
    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1_NamespaceAnnotation: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotation":{"EA2": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotation":{"EA2": "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotation":{EA3: ["AB", "AB"]}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotation":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}

type XsdSequenceWithNamespaceAnnotation2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2_NamespaceAnnotation seq_EA2_NamespaceAnnotation;
};

type Seq_EA2_NamespaceAnnotation record {
    @SequenceOrder {
        value: 1
    }
    record {
        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @SequenceOrder {
            value: 1
        }
        @Namespace {
            uri: "example1.com",
            prefix: "ea1"
        }
        string EA1?;

        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @SequenceOrder {
            value: 2
        }
        @Namespace {
            uri: "example2.com",
            prefix: "ea2"
        }
        string EA2?;

        @Element {
            maxOccurs: 4,
            minOccurs: 2
        }

        @Namespace {
            uri: "example3.com",
            prefix: "ea3"
        }
        @SequenceOrder {
            value: 3
        }
        string[] EA3?;
    } EA;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithNamespaceAnnotation2() returns error? {
    string xmlStr;
    XsdSequenceWithNamespaceAnnotation2|Error v;

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
    
    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>CD</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertEquals(v, {seq_EA2_NamespaceAnnotation:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotation": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotation": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotation": {EA: {EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotation": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>CD</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}
