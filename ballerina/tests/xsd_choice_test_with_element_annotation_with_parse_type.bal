import ballerina/test;

type XsdChoiceWithElementAnnotationWithXmlValue record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_EA1 seq_EA1?;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithElementAnnotationWithXmlValue() returns error? {
    xml xmlValue;
    XsdChoiceWithElementAnnotationWithXmlValue|Error v;

    xmlValue = xml `<Root><EA1>ABC</EA1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {});
    
    xmlValue = xml `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA3: ["AB", "AB", "AB", "AB"]}});

    xmlValue = xml `<Root><EA2>ABC</EA2></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC"}});

    xmlValue = xml `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"), (<Error>v).message());

    xmlValue = xml `<Root><EA1>ABC</EA1><EA1>ABC</EA1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC", "ABC"]}});

    xmlValue = xml `<Root><EA1>ABC</EA1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlValue = xml `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"), (<Error>v).message());

    xmlValue = xml `<Root><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"), (<Error>v).message());

    xmlValue = xml `<Root><EA1>ABC</EA1><EA1>ABC</EA1><EA1>ABC</EA1></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA1 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><EA1>ABC</EA1><EA1>ABC</EA1><EA3>ABC</EA3><EA3>ABC</EA3><EA3>ABC</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("seq_EA1 Element occurs more than the max allowed times"), (<Error>v).message());
}

type XsdChoiceWithElementAnnotationWithXmlValue2 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_EA2 seq_EA2;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithElementAnnotationWithXmlValue2() returns error? {
    xml xmlValue;
    XsdChoiceWithElementAnnotationWithXmlValue2|Error v;

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required times"), (<Error>v).message());
    
    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required times"), (<Error>v).message());

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3><EA3>CD</EA3></EA></Root>`;
    v = parseAsType(xmlValue);    
    test:assertEquals(v, {seq_EA2:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs more than the max allowed times"));

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>CD</EA3></EA></Root>`;
    v = parseAsType(xmlValue);    
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("EA3 Element occurs less than the min required"));
}

type XsdChoiceWithElementAnnotationWithXmlValue3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XsdChoiceWithElementAnnotationWithXmlValue3_1 seq_XsdChoiceWithElementAnnotationWithXmlValue3_1;

    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XsdChoiceWithElementAnnotationWithXmlValue3_2 seq_XsdChoiceWithElementAnnotationWithXmlValue3_2?;
};

type Choice_XsdChoiceWithElementAnnotationWithXmlValue3_1 record {
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

type Choice_XsdChoiceWithElementAnnotationWithXmlValue3_2 record {
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

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithElementAnnotationWithXmlValue3() returns error? {
    xml xmlValue;
    XsdChoiceWithElementAnnotationWithXmlValue3|Error v2;

    xmlValue = xml `<Root><field1><a>ABC</a></field1><field1><a>ABC</a><a>ABC</a></field1><field1><a>ABC</a><a>ABC</a><a>ABC</a></field1><field5><d>ABC</d></field5><field5><d>ABC</d></field5><field5><d>ABC</d></field5></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XsdChoiceWithElementAnnotationWithXmlValue3_1: {field1: [{value1: {a: ["ABC"]}}, {value1: {a: ["ABC", "ABC"]}}, {value1: {a: ["ABC", "ABC", "ABC"]}}]}, seq_XsdChoiceWithElementAnnotationWithXmlValue3_2: {field5: [{value2: {d: "ABC"}}, {value2: {d: "ABC"}}, {value2: {d: "ABC"}}]}});
}
