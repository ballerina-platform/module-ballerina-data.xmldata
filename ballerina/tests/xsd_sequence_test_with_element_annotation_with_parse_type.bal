import ballerina/test;

type XsdSequenceWithElementAnnotationWithXmlValue record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA1_Xml_Value seq_EA1_Xml_Value;
};

type Seq_EA1_Xml_Value record {

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
function testXsdSequenceWithElementAnnotationWithXmlValue() returns error? {
    xml xmlValue;
    XsdSequenceWithElementAnnotationWithXmlValue|Error v;

    xmlValue = xml `<Root><EA1>ABC</EA1><EA2>ABC</EA2></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'EA3' is not found in 'seq_EA1_Xml_Value'");
    
    xmlValue = xml `<Root><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_EA1_Xml_Value: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlValue = xml `<Root><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_Xml_Value":{"EA2": "ABC", EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_Xml_Value":{"EA2": "ABC", EA3: ["AB", "AB", "AB"]}});

    xmlValue = xml `<Root><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_Xml_Value":{EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlValue = xml `<Root><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA1_Xml_Value":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlValue = xml `<Root><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA1>ABC</EA1><EA3>AB</EA3></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}

type XsdSequenceWithElementAnnotationWithXmlValue2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2_With_Xml_Value seq_EA2_With_Xml_Value;
};

type Seq_EA2_With_Xml_Value record {
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
function testXsdSequenceWithElementAnnotationWithXmlValue2() returns error? {
    xml xmlValue;
    XsdSequenceWithElementAnnotationWithXmlValue2|Error v;

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
    
    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3><EA3>CD</EA3></EA></Root>`;
    v = parseAsType(xmlValue);    
    test:assertEquals(v, {seq_EA2_With_Xml_Value:  {EA: {EA1: "ABC", EA2: "ABC", EA3: ["AB", "CD"]}}});

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_With_Xml_Value": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_With_Xml_Value": {EA: {"EA2": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_With_Xml_Value": {EA: {EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {"seq_EA2_With_Xml_Value": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>CD</EA3></EA></Root>`;
    v = parseAsType(xmlValue);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlValue = xml `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3></EA></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}

type XsdSequenceWithElementAnnotationWithXmlValue3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XsdSequenceWithElementAnnotationWithXmlValue3_1 seq_XsdSequenceWithElementAnnotationWithXmlValue3_1;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XsdSequenceWithElementAnnotationWithXmlValue3_2 seq_XsdSequenceWithElementAnnotationWithXmlValue3_2?;
};

type Seq_XsdSequenceWithElementAnnotationWithXmlValue3_1 record {
    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    @Order {value: 1}
    Seq_A_3[] field1;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    @Order {value: 2}
    Seq_B_3[] field2?;

    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    @Order {value: 3}
    Seq_C_3 field3;
};

type Seq_XsdSequenceWithElementAnnotationWithXmlValue3_2 record {
    @Order {value: 1}
    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    Seq_D_3[] field4?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    @Order {value: 2}
    Seq_E_3[] field5?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    @Order {value: 3}
    Seq_F_3[] field6?;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithElementAnnotationWithXmlValue3() returns error? {
    xml xmlValue;
    XsdSequenceWithElementAnnotationWithXmlValue3|Error v2;

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotationWithXmlValue3_1: {field1: [{value1: {a: ["1"], b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field2: [{value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotationWithXmlValue3_2: {field4: [{value1: {a: ["1"], b: ["2"], c: "3"}}], field5: [{value2: {d: "1", e: "2", f: "3"}}], field6: [{value3: {g: "1", h: "2", i: "3"}}, {value3: {g: "1", h: "2", i: "3"}}]}});

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotationWithXmlValue3_1: {field1: [{value1: {a: ["1"], b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field2: [{value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotationWithXmlValue3_2: {field4: [{value1: {a: ["1"], b: ["2"], c: "3"}}], field5: [{value2: {d: "1", e: "2", f: "3"}}]}});

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotationWithXmlValue3_1: {field1: [{value1: {a: ["1"], b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field2: [{value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotationWithXmlValue3_2: {field5: [{value2: {d: "1", e: "2", f: "3"}}], field6: [{value3: {g: "1", h: "2", i: "3"}}]}});

    xmlValue = xml `<Root><field1><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><a>2</a><a>3</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotationWithXmlValue3_1: {field1: [{value1: {b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotationWithXmlValue3_2: {field4: [{value1: {a: ["1", "2", "3"], b: ["2"], c: "3"}}], field5: [{value2: {d: "1", e: "2", f: "3"}}], field6: [{value3: {g: "1", h: "2", i: "3"}}]}});

    xmlValue = xml `<Root><field1><c>3</c></field1><field1><c>3</c></field1><field3><g>1</g><h>2</h><i>3</i></field3></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'seq_XsdSequenceWithElementAnnotationWithXmlValue3_2' occurs less than the min required times");

    xmlValue = xml `<Root><field1><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field4><a>1</a><a>2</a><a>3</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'field3' is not found in 'seq_XsdSequenceWithElementAnnotationWithXmlValue3_1'");

    xmlValue = xml `<Root><field1><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><a>2</a><a>3</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "required field 'i' not present in XML");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'field5' occurs more than the max allowed times");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><b>2</b><b>2</b><b>2</b><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'b' occurs more than the max allowed times");
}
