import ballerina/test;

// TODO: Add tests with attributes
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
    test:assertEquals((<Error>v).message(), "Element(s) 'EA3' is not found in 'seq_EA1'");
    
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
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlStr = string `<Root><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA1":{"EA1": "ABC", EA3: ["AB", "AB"]}});

    xmlStr = string `<Root><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA2>ABC</EA2><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA1>ABC</EA1><EA3>AB</EA3></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}

type XsdSequenceWithElementAnnotation2 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_EA2 seq_EA2;
};

type Seq_EA2 record {
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
function testXsdSequenceWithElementAnnotation2() returns error? {
    string xmlStr;
    XsdSequenceWithElementAnnotation2|Error v;

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
    
    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

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
    test:assertEquals((<Error>v).message(), "'EA3' occurs more than the max allowed times");

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {"seq_EA2": {EA: {"EA1": "ABC", EA3: ["AB", "AB"]}}});

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA2>ABC</EA2><EA3>CD</EA3></EA></Root>`;
    v = parseString(xmlStr);    
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA><EA2>ABC</EA2><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");

    xmlStr = string `<Root><EA><EA1>ABC</EA1><EA3>AB</EA3></EA></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'EA3' occurs less than the min required times");
}

type XsdSequenceWithElementAnnotation3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XsdSequenceWithElementAnnotation3_1 seq_XsdSequenceWithElementAnnotation3_1;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XsdSequenceWithElementAnnotation3_2 seq_XsdSequenceWithElementAnnotation3_2?;
};

type Seq_XsdSequenceWithElementAnnotation3_1 record {
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

type Seq_XsdSequenceWithElementAnnotation3_2 record {
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

type Seq_A_3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_3 value1;
};

type Seq_B_3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq2_3 value2;
};

type Seq_C_3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq3_3 value3;
};

type Seq_D_3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_3 value1;
};

type Seq_E_3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq2_3 value2;
};

type Seq_F_3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq3_3 value3;
};

type Seq_3 record {
    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    @Order {value: 1}
    string[] a?;

    @Element {
        minOccurs: 0,
        maxOccurs: 3
    }
    @Order {value: 2}
    string[] b?;

    @Order {value: 3}
    string c;
};

type Seq2_3 record {
    @Order {value: 1}
    string d;

    @Order {value: 2}
    string e;

    @Order {value: 3}
    string f;
};

type Seq3_3 record {
    @Order {value: 1}
    string g;

    @Order {value: 2}
    string h;

    @Order {value: 3}
    string i;
};

@test:Config {groups: ["xsd", "xsd_sequence", "xsd_element", "xsd_element_and_sequence"]}
function testXsdSequenceWithElementAnnotation3() returns error? {
    string xmlStr;
    XsdSequenceWithElementAnnotation3|Error v2;

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotation3_1: {field1: [{value1: {a: ["1"], b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field2: [{value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotation3_2: {field4: [{value1: {a: ["1"], b: ["2"], c: "3"}}], field5: [{value2: {d: "1", e: "2", f: "3"}}], field6: [{value3: {g: "1", h: "2", i: "3"}}, {value3: {g: "1", h: "2", i: "3"}}]}});

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotation3_1: {field1: [{value1: {a: ["1"], b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field2: [{value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotation3_2: {field4: [{value1: {a: ["1"], b: ["2"], c: "3"}}], field5: [{value2: {d: "1", e: "2", f: "3"}}]}});

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotation3_1: {field1: [{value1: {a: ["1"], b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field2: [{value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}, {value2: {d: "1", e: "2", f: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotation3_2: {field5: [{value2: {d: "1", e: "2", f: "3"}}], field6: [{value3: {g: "1", h: "2", i: "3"}}]}});

    xmlStr = string `<Root><field1><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><a>2</a><a>3</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XsdSequenceWithElementAnnotation3_1: {field1: [{value1: {b: ["2"], c: "3"}}, {value1: {a: ["1"], b: ["2"], c: "3"}}], field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XsdSequenceWithElementAnnotation3_2: {field4: [{value1: {a: ["1", "2", "3"], b: ["2"], c: "3"}}], field5: [{value2: {d: "1", e: "2", f: "3"}}], field6: [{value3: {g: "1", h: "2", i: "3"}}]}});

    xmlStr = string `<Root><field1><c>3</c></field1><field1><c>3</c></field1><field3><g>1</g><h>2</h><i>3</i></field3></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'seq_XsdSequenceWithElementAnnotation3_2' occurs less than the min required times");

    xmlStr = string `<Root><field1><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field4><a>1</a><a>2</a><a>3</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'field3' is not found in 'seq_XsdSequenceWithElementAnnotation3_1'");

    xmlStr = string `<Root><field1><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><a>2</a><a>3</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "required field 'i' not present in XML");

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'field5' occurs more than the max allowed times");

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field1><a>1</a><b>2</b><b>2</b><b>2</b><b>2</b><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'b' occurs more than the max allowed times");
}
