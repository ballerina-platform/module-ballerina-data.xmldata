import ballerina/test;

type XsdChoiceArray record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    Choice_XsdChoiceArray choice_XsdChoiceArray;
|};

type Choice_XsdChoiceArray record {|
    int[] age?;
    float[] salary?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceArray() returns error? {
    string xmlStr;
    XsdChoiceArray|Error v;

    xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray: {age: [13], salary: [11.1]}});

    xmlStr = string `<Root><age>13</age><age>12</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray: {age: [13, 12]}});

    xmlStr = string `<Root><salary>11.1</salary><salary>12.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray: {salary: [11.1, 12.1]}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'choice_XsdChoiceArray' occurs more than the max allowed times");
}

type XsdChoiceArray2 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    Choice_XsdChoiceArray2 choice_XsdChoiceArray2;

    @Choice {
        minOccurs: 0,
        maxOccurs: 2
    }
    Choice_XsdChoiceArray2_2 choice_XsdChoiceArray2_2?;
|};

type Choice_XsdChoiceArray2 record {|
    int[] age?;
    float[] salary?;
|};

type Choice_XsdChoiceArray2_2 record {|
    int[] age2?;
    float[] salary2?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceArray2() returns error? {
    string xmlStr;
    XsdChoiceArray2|Error v;

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><age2>13</age2><salary2>11.1</salary2></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray2: {age: [13], salary: [11.1]}, choice_XsdChoiceArray2_2: {age2: [13], salary2: [11.1]}});

    xmlStr = string `<Root><age>13</age><age>13</age><age2>13</age2><age2>13</age2></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray2: {age: [13, 13]}, choice_XsdChoiceArray2_2: {age2: [13, 13]}});

    xmlStr = string `<Root><age>13</age><age>13</age><age2>13</age2><salary2>11.1</salary2></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray2: {age: [13, 13]}, choice_XsdChoiceArray2_2: {age2: [13], salary2: [11.1]}});

    xmlStr = string `<Root><age>13</age><age>13</age><age2>13</age2><salary2>11.1</salary2><age2>14</age2><age2>15</age2></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'choice_XsdChoiceArray2_2' occurs more than the max allowed times");

    xmlStr = string `<Root><age>13</age><age>13</age><age>13</age><age2>13</age2></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'choice_XsdChoiceArray2' occurs more than the max allowed times");

    xmlStr = string `<Root><age>13</age><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray2: {age: [13, 13]}});

    xmlStr = string `<Root><age2>13</age2><age2>13</age2></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "required field 'choice_XsdChoiceArray2' not present in XML");
}

type XSDChoiceArrayRecord13 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice_XSDChoiceArrayRecord13_1 choice_XSDChoiceArrayRecord13_1;

    @Choice {
        minOccurs: 2,
        maxOccurs: 3
    }
    Choice_XSDChoiceArrayRecord13_2 choice_XSDChoiceArrayRecord13_2;
};

type Choice_XSDChoiceArrayRecord13_1 record {
    Choice_Array_A_3[] field1?;
    Choice_Array_B_3[] field2?;
    Choice_Array_C_3[] field3?;
};

type Choice_XSDChoiceArrayRecord13_2 record {
    Choice_Array_D_3[] field4?;
    Choice_Array_E_3[] field5?;
    Choice__Array_F_3[] field6?;
};

type Choice_Array_A_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice_Array_3 value1;
};

type Choice_Array_B_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice2_Array_3 value2;
};

type Choice_Array_C_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice3_Array_3 value3;
};

type Choice_Array_D_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice_Array_3 value1;
};

type Choice_Array_E_3 record {
    @Choice {
        minOccurs: 2,
        maxOccurs: 3
    }
    Choice2_Array_3 value2;
};

type Choice__Array_F_3 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice3_Array_3 value3;
};

type Choice_Array_3 record {
    string[] a?;
    string[] b?;
    string[] c?;
};

type Choice2_Array_3 record {
    string[] d?;
    string[] e?;
    string[] f?;
};

type Choice3_Array_3 record {
    string[] g?;
    string[] h?;
    string[] i?;
};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXSDChoiceArrayRecord4() returns error? {
    string xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDChoiceArrayRecord13|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceArrayRecord13_1: {field1: [{value1: {a: ["1"], b:["2"], c: ["3"]}}],field2: [{value2: {d: ["1"], e: ["2"], f: ["3"]}}], field3: [{value3: {g: ["1"], h: ["2"], i: ["3"]}}]}, choice_XSDChoiceArrayRecord13_2: {field4: [{value1: {a: ["1"], b: ["2"], c: ["3"]}}], field5: [{value2: {d: ["1"], e: ["2"], f:["3"]}}], field6: [{value3: {g: ["1"], h: ["2"], i: ["3"]}}]}});

    xmlStr = string `<Root><field1><b>2</b><b>2</b></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><h>2</h><i>3</i><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceArrayRecord13_1: {field1: [{value1: {b:["2", "2"]}}, {value1: {a: ["1"], b:["2"], c: ["3"]}}], field3: [{value3: {h: ["2"], i: ["3", "3"]}}]}, choice_XSDChoiceArrayRecord13_2: {field5: [{value2: {d: ["1"], e: ["2"], f:["3"]}}, {value2: {d: ["1"], e: ["2"], f:["3"]}}], field6: [{value3: {g: ["1"], h: ["2"], i: ["3"]}}]}});

    xmlStr = string `<Root><field1><b>2</b><b>2</b></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><h>2</h><i>3</i><i>3</i></field3><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceArrayRecord13_2' occurs less than the min required times");

    xmlStr = string `<Root><field1><b>2</b><b>2</b></field1><field1><a>1</a><b>2</b><c>3</c></field1><field3><h>2</h><i>3</i><i>3</i></field3><field5><d>1</d></field5><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is error);
    test:assertEquals((<Error>v2).message(), "'value2' occurs less than the min required times");
}

type XsdChoiceArray5 record {|
    @Choice {
        minOccurs: 2,
        maxOccurs: 3
    }
    Choice_XsdChoiceArray5 choice_XsdChoiceArray5;
|};

type Choice_XsdChoiceArray5 record {|
    int[] age?;
    float[] salary?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceArray5() returns error? {
    string xmlStr;
    XsdChoiceArray5|Error v;

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><age>14</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray5: {age: [13, 14], salary: [11.1]}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XsdChoiceArray5: {age: [13], salary: [11.1]}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XsdChoiceArray5' occurs more than the max allowed times");

    xmlStr = string `<Root><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XsdChoiceArray5' occurs less than the min required times");
}

type XSDChoiceArrayRecord6 record {
    @Choice {
        minOccurs: 2,
        maxOccurs: 4
    }
    Choice_XSDChoiceArrayRecord6_1 choice_XSDChoiceArrayRecord6_1;

    @Choice {
        minOccurs: 2,
        maxOccurs: 4
    }
    Choice_XSDChoiceArrayRecord6_2 choice_XSDChoiceArrayRecord6_2;
};

type Choice_XSDChoiceArrayRecord6_1 record {
    Choice_Array_A_6[] field1?;
    Choice_Array_B_6[] field2?;
};

type Choice_XSDChoiceArrayRecord6_2 record {
    Choice_Array_D_6[] field4?;
    Choice_Array_E_6[] field5?;
};

type Choice_Array_A_6 record {
    @Choice {
        minOccurs: 2,
        maxOccurs: 3
    }
    Choice_Array_6 value1;
};

type Choice_Array_B_6 record {
    @Choice {
        minOccurs: 2,
        maxOccurs: 3
    }
    Choice2_Array_6 value2;
};

type Choice_Array_D_6 record {
    @Choice {
        minOccurs: 2,
        maxOccurs: 4
    }
    Choice_Array_6 value1;
};

type Choice_Array_E_6 record {
    @Choice {
        minOccurs: 2,
        maxOccurs: 4
    }
    Choice2_Array_6 value2;
};

type Choice_Array_6 record {
    string[] a?;
};

type Choice2_Array_6 record {
    string[] d?;
};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXSDChoiceArrayRecord6() returns error? {
    string xmlStr = string `<Root><field1><a>1</a><a>1</a></field1><field2><d>1</d><d>1</d></field2><field1><a>1</a><a>1</a></field1><field2><d>1</d><d>1</d></field2><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5></Root>`;
    XSDChoiceArrayRecord6|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceArrayRecord6_1: {field1: [{value1: {a: ["1", "1"]}}, {value1: {a:["1", "1"]}}], field2: [{value2: {d: ["1", "1"]}}, {value2: {d: ["1", "1"]}}]}, choice_XSDChoiceArrayRecord6_2: {field4: [{value1: {a: ["1", "1"]}}, {value1: {a:["1", "1"]}}], field5: [{value2: {d: ["1", "1"]}}, {value2: {d: ["1","1"]}}]}});
}
