import ballerina/test;

type XsdChoiceWithNameAnnotationWithXmlValue record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_Name_EA1 seq_EA1?;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithNameAnnotationWithXmlValue() returns error? {
    xml xmlValue;
    XsdChoiceWithNameAnnotationWithXmlValue|Error v;

    xmlValue = xml `<Root><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {});
    
    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA3: ["AB", "AB", "AB", "AB"]}});

    xmlValue = xml `<Root><A2>ABC</A2></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1":{"EA2": "ABC"}});

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1":{EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlValue = xml `<Root><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC", "ABC"]}});

    xmlValue = xml `<Root><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1: {EA1: ["ABC"]}});

    xmlValue = xml `<Root><A2>ABC</A2><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A3>AB</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A1>ABC</A1><A1>ABC</A1><A1>ABC</A1></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A1' occurs more than the max allowed times");

    xmlValue = xml `<Root><A1>ABC</A1><A1>ABC</A1><A3>ABC</A3><A3>ABC</A3><A3>ABC</A3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'seq_EA1' occurs more than the max allowed times");
}

type XsdChoiceWithNameAnnotationWithXmlValue2 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_Name_EA2 seq_EA2;
};

@test:Config {groups: ["xsd", "xsd_choice", "xsd_element", "xsd_element_and_sequence"]}
function testXsdChoiceWithNameAnnotationWithXmlValue2() returns error? {
    xml xmlValue;
    XsdChoiceWithNameAnnotationWithXmlValue2|Error v;

    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");
    
    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>AB</A3><A3>CD</A3></A></Root>`;
    v = parseAsType(xmlValue);    
    test:assertEquals(v, {seq_EA2:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs more than the max allowed times");

    xmlValue = xml `<Root><A><A1>ABC</A1><A3>AB</A3><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><A><A1>ABC</A1><A2>ABC</A2><A3>CD</A3></A></Root>`;
    v = parseAsType(xmlValue);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A2>ABC</A2><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");

    xmlValue = xml `<Root><A><A1>ABC</A1><A3>AB</A3></A></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'A3' occurs less than the min required times");
}
