import ballerina/test;

// TODO: Add tests with attributes
type XsdSequenceWithNameAnnotationWithXmlValue record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA1_NameAnnotationWithXmlValue seq_EA1_NameAnnotationWithXmlValue;
};

type Seq_EA1_NameAnnotationWithXmlValue record {

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
function testXsdSequenceWithNameAnnotationWithXmlValue() returns error? {
    xml xmlValue;
    XsdSequenceWithNameAnnotationWithXmlValue|Error v;

    xmlValue = xml `<Root><A1>ABC</A1><A2>ABC</A2></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("Element EA3 not found in seq_EA1_NameAnnotationWithXmlValue"), (<Error>v).message());
    
    xmlValue = xml `<Root><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1_NameAnnotationWithXmlValue: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlValue = xml `<Root><A2>ABC</A2><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_NameAnnotationWithXmlValue":{"EA2": "ABC", EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><A2>ABC</A2><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_NameAnnotationWithXmlValue":{"EA2": "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_NameAnnotationWithXmlValue":{EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><A1>ABC</A1><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_NameAnnotationWithXmlValue":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><A1>ABC</A1><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));
}

type XsdSequenceWithNameAnnotationWithXmlValue2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2_NameAnnotationWithXmlValue seq_EA2_NameAnnotationWithXmlValue;
};

type Seq_EA2_NameAnnotationWithXmlValue record {
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
function testXsdSequenceWithNameAnnotationWithXmlValue2() returns error? {
    xml xmlValue;
    XsdSequenceWithNameAnnotationWithXmlValue2|Error v;

    xmlValue = xml `<Root><EA><A1>ABC</A1><A2>ABC</A2></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required times"), (<Error>v).message());
    
    xmlValue = xml `<Root><EA><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required times"), (<Error>v).message());

    xmlValue = xml `<Root><EA><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>CD</A3></EA></Root>`;
    v = parseAsType(xmlValue);    
    test:assertEquals(v, {seq_EA2_NameAnnotationWithXmlValue:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlValue = xml `<Root><EA><A2>ABC</A2><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_NameAnnotationWithXmlValue": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><A2>ABC</A2><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_NameAnnotationWithXmlValue": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_NameAnnotationWithXmlValue": {EA: {EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"));

    xmlValue = xml `<Root><EA><A1>ABC</A1><A3>AB</A3><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_NameAnnotationWithXmlValue": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><A1>ABC</A1><A2>ABC</A2><A3>CD</A3></EA></Root>`;
    v = parseAsType(xmlValue);    
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><A2>ABC</A2><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><A2>ABC</A2><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><A1>ABC</A1><A3>AB</A3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));
}
