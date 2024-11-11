import ballerina/test;

type XsdChoiceWithElementAnnotation record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_EA1 seq_EA1?;
};

type Choice_EA1 record {

    @Element {
        maxOccurs: 2,
        minOccurs: 0
    }
    string[] EA1?;

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    string EA2?;

    @Element {
        maxOccurs: 4,
        minOccurs: 2
    }
    string[] EA3?;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithElementAnnotation() returns error? {
    string xmlStr;
    XsdChoiceWithElementAnnotation|Error v;

    xmlStr = string `<Root><EA1>ABC</EA1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {});
    
    xmlStr = string `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA3: ["AB", "AB", "AB", "AB"]}});

    xmlStr = string `<Root><EA2>ABC</EA2></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC"}});

    xmlStr = string `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"), (<Error>v).message());

    xmlStr = string `<Root><EA1>ABC</EA1><EA1>ABC</EA1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC", "ABC"]}});

    xmlStr = string `<Root><EA1>ABC</EA1></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"), (<Error>v).message());

    xmlStr = string `<Root><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"), (<Error>v).message());

    xmlStr = string `<Root><EA1>ABC</EA1><EA1>ABC</EA1><EA1>ABC</EA1></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA1 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><EA1>ABC</EA1><EA1>ABC</EA1><EA3>ABC</EA3><EA3>ABC</EA3><EA3>ABC</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("seq_EA1 Element occurs more than the max allowed times"), (<Error>v).message());
}

type XsdChoiceWithElementAnnotation2 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_EA2 seq_EA2;
};

type Choice_EA2 record {
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

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithElementAnnotation2() returns error? {
    string xmlStr;
    XsdChoiceWithElementAnnotation2|Error v;

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

type XsdChoiceWithElementAnnotation3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XsdChoiceWithElementAnnotation3_1 seq_XsdChoiceWithElementAnnotation3_1;

    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XsdChoiceWithElementAnnotation3_2 seq_XsdChoiceWithElementAnnotation3_2?;
};

type Choice_XsdChoiceWithElementAnnotation3_1 record {
    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice_A_3[] field1?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    Choice_B_3[] field2?;

    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice_C_3 field3?;
};

type Choice_XsdChoiceWithElementAnnotation3_2 record {
    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    Choice_D_3[] field4?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    Choice_E_3[] field5?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    Choice_F_3[] field6?;
};

type Choice_A_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_3 value1;
};

type Choice_B_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice2_3 value2;
};

type Choice_C_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice3_3 value3;
};

type Choice_D_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_3 value1;
};

type Choice_E_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice2_3 value2;
};

type Choice_F_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice3_3 value3;
};

type Choice_3 record {
    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    string[] a?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    string[] b?;
    string c?;
};

type Choice2_3 record {
    string d?;
    string e?;
    string f?;
};

type Choice3_3 record {
    string g?;
    string h?;
    string i?;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithElementAnnotation3() returns error? {
    string xmlStr;
    XsdChoiceWithElementAnnotation3|Error v2;

    xmlStr = string `<Root><field1><a>ABC</a></field1><field1><a>ABC</a><a>ABC</a></field1><field1><a>ABC</a><a>ABC</a><a>ABC</a></field1><field5><d>ABC</d></field5><field5><d>ABC</d></field5><field5><d>ABC</d></field5></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XsdChoiceWithElementAnnotation3_1: {field1: [{value1: {a: ["ABC"]}}, {value1: {a: ["ABC", "ABC"]}}, {value1: {a: ["ABC", "ABC", "ABC"]}}]}, seq_XsdChoiceWithElementAnnotation3_2: {field5: [{value2: {d: "ABC"}}, {value2: {d: "ABC"}}, {value2: {d: "ABC"}}]}});
}
