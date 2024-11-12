import ballerina/test;

// TODO: Add tests with attributes
type XsdSequenceWithNameAnnotation record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA1_NameAnnotation seq_EA1_NameAnnotation;
};

type Seq_EA1_NameAnnotation record {

    @Name {value: "A1"}
    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @Order {
        value: 1
    }
    string EA1?;

    @Name {value: "A2"}
    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @Order {
        value: 2
    }
    string EA2?;

    @Name {value: "A3"}
    @Element {
        maxOccurs: 4,
        minOccurs: 2
    }
    @Order {
        value: 3
    }
    string[] EA3?;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithNameAnnotation() returns error? {
    string xmlStr;
    XsdSequenceWithNameAnnotation|Error v;

    xmlStr = string `<Root><A1>ABC</A1><A2>ABC</A2></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("Element EA3 not found in seq_EA1_NameAnnotation"), (<Error>v).message());
    
    xmlStr = string `<Root><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1_NameAnnotation: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = string `<Root><A2>ABC</A2><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NameAnnotation":{"EA2": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><A2>ABC</A2><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NameAnnotation":{"EA2": "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NameAnnotation":{EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><A1>ABC</A1><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1_NameAnnotation":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A1>ABC</A1><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));
}

type XsdSequenceWithNameAnnotation2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2_NameAnnotation seq_EA2_NameAnnotation;
};

type Seq_EA2_NameAnnotation record {
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
        @Name {value: "A1"}
        string EA1?;

        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @Order {
            value: 2
        }
        @Name {value: "A2"}
        string EA2?;

        @Element {
            maxOccurs: 4,
            minOccurs: 2
        }

        @Name {value: "A3"}
        @Order {
            value: 3
        }
        string[] EA3?;
    } EA;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithNameAnnotation2() returns error? {
    string xmlStr;
    XsdSequenceWithNameAnnotation2|Error v;

    xmlStr = string `<Root><EA><A1>ABC</A1><A2>ABC</A2></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required times"), (<Error>v).message());
    
    xmlStr = string `<Root><EA><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required times"), (<Error>v).message());

    xmlStr = string `<Root><EA><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>CD</A3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertEquals(v, {seq_EA2_NameAnnotation:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlStr = string `<Root><EA><A2>ABC</A2><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NameAnnotation": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><A2>ABC</A2><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NameAnnotation": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NameAnnotation": {EA: {EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"));

    xmlStr = string `<Root><EA><A1>ABC</A1><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2_NameAnnotation": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><A1>ABC</A1><A2>ABC</A2><A3>CD</A3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><A2>ABC</A2><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><A2>ABC</A2><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><A1>ABC</A1><A3>AB</A3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));
}
