import ballerina/test;

// TODO: Add tests with attributes
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
    @Order {
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
    @Order {
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
    @Order {
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
    test:assertTrue((<Error>v).message().includes("Element EA3 not found in seq_EA1_NamespaceAnnotation"), (<Error>v).message());
    
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
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NamespaceAnnotation":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));
}

type XsdSequenceWithNamespaceAnnotation2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2_NamespaceAnnotation seq_EA2_NamespaceAnnotation;
};

type Seq_EA2_NamespaceAnnotation record {
    @Order {
        value: 1
    }
    record {
        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @Order {
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
        @Order {
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
        @Order {
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
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required times"), (<Error>v).message());
    
    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required times"), (<Error>v).message());

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
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NamespaceAnnotation": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea2:EA2>ABC</ea2:EA2><ea3:EA3>CD</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea2:EA2>ABC</ea2:EA2><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root xmlns:ea1="example1.com" xmlns:ea2="example2.com" xmlns:ea3="example3.com"><EA><ea1:EA1>ABC</ea1:EA1><ea3:EA3>AB</ea3:EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));
}
