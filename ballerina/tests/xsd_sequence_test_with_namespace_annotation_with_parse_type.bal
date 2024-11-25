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

@Name {
    value: "Root"
}
type XsdSequenceWithNamespaceAnnotationWithXmlValue record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA1_NamespaceAnnotationWithXmlValue seq_EA1_NamespaceAnnotationWithXmlValue;
};

type Seq_EA1_NamespaceAnnotationWithXmlValue record {

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
function testXsdSequenceWithNamespaceAnnotationWithXmlValue() returns error? {
    xml xmlStr;
    XsdSequenceWithNamespaceAnnotationWithXmlValue|Error v;
    xml|Error toXmlResult;

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'EA3' is not found in 'seq_EA1_NamespaceAnnotationWithXmlValue'");
    toXmlResult = toXml(<XsdSequenceWithNamespaceAnnotationWithXmlValue>{seq_EA1_NamespaceAnnotationWithXmlValue: {EA1: "ABC", EA2: "ABC", EA3: []}});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'EA3' occurs less than the min required times");
    
    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {seq_EA1_NamespaceAnnotationWithXmlValue: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});
    // // BUG: https://github.com/ballerina-platform/ballerina-library/issues/7389
    // test:assertEquals(toXml(check v), xml `<Root><ea1:EA1 xmlns:ea1="example1.com">ABC</ea1:EA1><ea2:EA2 xmlns:ea2="example2.com">ABC</ea2:EA2><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`);

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotationWithXmlValue":{"EA2": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotationWithXmlValue":{"EA2": "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotationWithXmlValue":{EA3: ["AB", "AB"]}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");
    toXmlResult = toXml(<XsdSequenceWithNamespaceAnnotationWithXmlValue>{seq_EA1_NamespaceAnnotationWithXmlValue: {EA3: ["AB", "AB", "AB", "AB", "AB", "AB"]}});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), (<Error>v).message());

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotationWithXmlValue":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
    toXmlResult = toXml(<XsdSequenceWithNamespaceAnnotationWithXmlValue>{seq_EA1_NamespaceAnnotationWithXmlValue: {EA3: ["AB"]}});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), (<Error>v).message());

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}

type XsdSequenceWithNamespaceAnnotationWithXmlValue2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2_NamespaceAnnotationWithXmlValue seq_EA2_NamespaceAnnotationWithXmlValue;
};

type Seq_EA2_NamespaceAnnotationWithXmlValue record {
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
function testXsdSequenceWithNamespaceAnnotationWithXmlValue2() returns error? {
    xml xmlStr;
    XsdSequenceWithNamespaceAnnotationWithXmlValue2|Error v;

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
    
    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>CD</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);    
    test:assertEquals(v, {seq_EA2_NamespaceAnnotationWithXmlValue:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotationWithXmlValue": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotationWithXmlValue": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotationWithXmlValue": {EA: {EA3: ["AB", "AB"]}}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotationWithXmlValue": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>CD</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = xml `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseAsType(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}
