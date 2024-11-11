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
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"), (<Error>v).message());

    xmlStr = string `<Root><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC", "ABC"]}});

    xmlStr = string `<Root><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlStr = string `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"), (<Error>v).message());

    xmlStr = string `<Root><A3>AB</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"), (<Error>v).message());

    xmlStr = string `<Root><A1>ABC</A1><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A1 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><A1>ABC</A1><A1>ABC</A1><A3>ABC</A3><A3>ABC</A3><A3>ABC</A3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("seq_EA1 Element occurs more than the max allowed times"), (<Error>v).message());
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
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required times"), (<Error>v).message());
    
    xmlStr = string `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required times"), (<Error>v).message());

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
    test:assertTrue((<Error>v).message().includes("A3 Element occurs more than the max allowed times"));

    xmlStr = string `<Root><A><A1>ABC</A1><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>CD</A3></A></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));

    xmlStr = string `<Root><A><A1>ABC</A1><A3>AB</A3></A></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("A3 Element occurs less than the min required"));
}
