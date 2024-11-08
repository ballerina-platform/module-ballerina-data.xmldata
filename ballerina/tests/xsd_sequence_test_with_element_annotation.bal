import ballerina/test;

type XsdSequenceWithElementAnnotation record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA1 seq_EA1;
};

type Seq_EA1 record {

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @Order {
        value: 1
    }
    string EA1?;

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    @Order {
        value: 2
    }
    string EA2?;

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
function testXsdSequenceWithElementAnnotation() returns error? {
    string xmlStr;
    XsdSequenceWithElementAnnotation|Error v;

    xmlStr = string `<Root><EA1>ABC</EA1><EA2>ABC</EA2></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("Element EA3 not found in seq_EA1"), (<Error>v).message());
    
    xmlStr = string `<Root><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlStr = string `<Root><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA1>ABC</EA1><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));
}

type XsdSequenceWithElementAnnotation2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2 seq_EA2;
};

type Seq_EA2 record {
    record {
        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @Order {
            value: 1
        }
        string EA1?;

        @Element {
            maxOccurs: 1,
            minOccurs: 0
        }
        @Order {
            value: 2
        }
        string EA2?;

        @Element {
            maxOccurs: 4,
            minOccurs: 2
        }
        @Order {
            value: 3
        }
        string[] EA3?;
    } EA;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithElementAnnotation2() returns error? {
    string xmlStr;
    XsdSequenceWithElementAnnotation2|Error v;

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required times"), (<Error>v).message());
    
    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required times"), (<Error>v).message());

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3><EA3>CD</EA3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertEquals(v, {seq_EA2:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlStr = string `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"));

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>CD</EA3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));
}

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function test110() returns error? {
    // string xmlStr;
    // // XsdSequenceWithElementAnnotation|Error v;

    // string xmlStr;
    // XSDSequenceRecord2|Error v;

    // // xmlStr = string `<Root><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    // // v = parseString(xmlStr);
    // // test:assertEquals(v, {seq_EA1: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});

    // xmlStr = string `<Root><age>13</age><salary>11.1</salary><num>3</num></Root>`;
    // v = parseString(xmlStr);
    // test:assertEquals(v, {seq_XSDSequenceRecord2: {age: 13, salary: 11.1}, num: 3});
    // test:assertEquals((check v).seq_XSDSequenceRecord2.age, 13);
    // test:assertEquals((check v).seq_XSDSequenceRecord2.salary, 11.1);
    // test:assertEquals((check v).num, 3);
}