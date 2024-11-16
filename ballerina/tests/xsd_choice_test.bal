import ballerina/test;

type XSDChoiceRecord record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord choice_XSDChoiceRecord?;
|};

type Choice_XSDChoiceRecord record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoice() returns error? {
    string xmlStr;
    XSDChoiceRecord|Error v;

    xmlStr = string `<Root><age>10</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord: {age: 10}});

    xmlStr = string `<Root><salary>10.5</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord: {salary: 10.5}});

    xmlStr = string `<Root><age>10</age><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecord' occurs more than the max allowed times");

    xmlStr = string `<Root><salary>11.1</salary><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecord' occurs more than the max allowed times");

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecord' occurs less than the min required times");
}

type XSDChoiceRecordP2 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecordP2 choice_XSDChoiceRecordP2;
|};

type Choice_XSDChoiceRecordP2 record {|
    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    int[] age?;
    float salary?;
    @Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    string[] name?;
|};

type XSDChoiceP1Record record {|
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_XSDChoiceP1Record choice_XSDChoiceP1Record?;
|};

type Choice_XSDChoiceP1Record record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceP1() returns error? {
    string xmlStr;
    XSDChoiceP1Record|Error v;

    xmlStr = string `<Root><age>10</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceP1Record: {age: 10}});

    xmlStr = string `<Root><salary>10.5</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceP1Record: {salary: 10.5}});

    xmlStr = string `<Root><age>10</age><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceP1Record' occurs more than the max allowed times");

    xmlStr = string `<Root><salary>11.1</salary><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceP1Record' occurs more than the max allowed times");

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {});
}

@test:Config {groups: ["xsd", "xsd_Choice"]}
function testXsdChoiceP2() returns error? {
    string xmlStr = string `<Root><age>10</age></Root>`;
    XSDChoiceRecordP2|Error v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecordP2: {age: [10]}});

    xmlStr = string `<Root><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecordP2: {name: ["ABC"]}});

    xmlStr = string `<Root><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecordP2: {salary: 11.1}});

    xmlStr = string `<Root><age>10</age><age>10</age><age>10</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecordP2' occurs more than the max allowed times");

    xmlStr = string `<Root><age>10</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecordP2' occurs more than the max allowed times");
}

type XSDChoiceRecord2 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord2 choice_XSDChoiceRecord2;

    int num;
|};

type Choice_XSDChoiceRecord2 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice2() returns error? {
    string xmlStr = string `<Root><num>3</num><age>10</age></Root>`;
    XSDChoiceRecord2|Error v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord2: {age: 10}, num: 3});
    test:assertEquals((check v).choice_XSDChoiceRecord2.age, 10);
    test:assertEquals((check v).num, 3);

    xmlStr = string `<Root><salary>11.1</salary><num>3</num></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord2: {salary: 11.1}, num: 3});
    test:assertEquals((check v).choice_XSDChoiceRecord2.salary, 11.1);
    test:assertEquals((check v).num, 3);

    xmlStr = string `<Root><salary>11.1</salary><age>10</age><num>3</num></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecord2' occurs more than the max allowed times");

    xmlStr = string `<Root><age>10</age><num>3</num><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_XSDChoiceRecord2' occurs more than the max allowed times");
}

type XSDChoiceRecord3 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord3 choice_XSDChoiceRecord3;
    
    record{int n;} num;
|};

type Choice_XSDChoiceRecord3 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice3() returns error? {
    string xmlStr = string `<Root><num><n>3</n></num><age>10</age></Root>`;
    XSDChoiceRecord3|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord3: {age: 10}, num: {n: 3}});
    test:assertEquals((check v2).choice_XSDChoiceRecord3.age, 10);
    test:assertEquals((check v2).num, {n: 3});

    xmlStr = string `<Root><salary>11.1</salary><num><n>3</n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord3: {salary: 11.1}, num: {n: 3}});

    xmlStr = string `<Root><age>10</age><num><n>3</n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord3' occurs more than the max allowed times");

    xmlStr = string `<Root><num><n>3</n></num><age>10</age><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord3' occurs more than the max allowed times");
}

type XSDChoiceRecord4 record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord4 choice_XSDChoiceRecord4;
|};

type Choice_XSDChoiceRecord4 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice4() returns error? {
    string xmlStr = string `<Root><num><n><n>3</n></n></num><age>10</age></Root>`;
    XSDChoiceRecord4|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord4: {age: 10}, num: {n: {n: 3}}});
    test:assertEquals((check v2).choice_XSDChoiceRecord4.age, 10);
    test:assertEquals((check v2).num, {n: {n: 3}});

    xmlStr = string `<Root><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord4: {salary: 11.1}, num: {n: {n: 3}}});

    xmlStr = string `<Root><age>10</age><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord4' occurs more than the max allowed times");

    xmlStr = string `<Root><num><n><n>3</n></n></num><age>10</age><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord4' occurs more than the max allowed times");
}

type XSDChoiceRecord5 record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord5 choice_XSDChoiceRecord5;
    record{record {int n;} n;} num2;
|};

type Choice_XSDChoiceRecord5 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice5() returns error? {
    string xmlStr = string `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>10</age></Root>`;
    XSDChoiceRecord5|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord5: {age: 10}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlStr = string `<Root><num2><n><n>3</n></n></num2><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord5: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlStr = string `<Root><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord5: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlStr = string `<Root><age>10</age><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord5' occurs more than the max allowed times");

    xmlStr = string `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "required field 'choice_XSDChoiceRecord5' not present in XML");
}

type XSDChoiceRecord6 record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord6_1 choice_XSDChoiceRecord6_1;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord6_2 choice_XSDChoiceRecord6_2;
    record{record {int n;} n;} num2;
|};

type Choice_XSDChoiceRecord6_1 record {|
    int age?;
    float salary?;
|};

type Choice_XSDChoiceRecord6_2 record {|
    string name?;
    string status?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice6() returns error? {
    string xmlStr = string `<Root><num><n><n>3</n></n></num><status>success</status><num2><n><n>3</n></n></num2><age>10</age></Root>`;
    XSDChoiceRecord6|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord6_1: {age: 10}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceRecord6_2: {status: "success"}});
    test:assertEquals((check v2).choice_XSDChoiceRecord6_1.age, 10);
    test:assertEquals((check v2).choice_XSDChoiceRecord6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><name>SD</name><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "required field 'choice_XSDChoiceRecord6_1' not present in XML");

    xmlStr = string `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name>SD</name></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "required field 'choice_XSDChoiceRecord6_1' not present in XML");

    xmlStr = string `<Root><name>SD</name><status>success</status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord6_2' occurs more than the max allowed times");
}

type XSDChoiceRecord7 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord7_1 choice_XSDChoiceRecord7_1;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord7_2 choice_XSDChoiceRecord7_2;
|};

type Choice_XSDChoiceRecord7_1 record {|
    int age?;
    float salary?;
|};

type Choice_XSDChoiceRecord7_2 record {|
    string name?;
    string status?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice7() returns error? {
    string xmlStr = string `<Root><status>success</status><salary>11.1</salary></Root>`;
    XSDChoiceRecord7|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord7_1: {salary: 11.1}, choice_XSDChoiceRecord7_2: {status: "success"}});
}

type XSDChoiceRecord8 record {|
    XSDChoiceRecord8P test;
    int a;
|};

type XSDChoiceRecord8P record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord8_1 choice_XSDChoiceRecord8_1;

    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord8_2 choice_XSDChoiceRecord8_2;
    record{record {int n;} n;} num2;
|};

type Choice_XSDChoiceRecord8_1 record {|
    int age?;
    float salary?;
|};

type Choice_XSDChoiceRecord8_2 record {|
    RecChoice8 name?;
    RecChoice8 status?;
|};

type RecChoice8 record {|
    string value1;
    string value2;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice8() returns error? {
    string xmlStr;
    XSDChoiceRecord8|Error v2;

    xmlStr = string `<Root><test><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><num2><n><n>3</n></n></num2><age>10</age></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {choice_XSDChoiceRecord8_1: {age: 10}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceRecord8_2: {name: {value1: "SD", value2: "AB"}}}});
    test:assertEquals((check v2).test.choice_XSDChoiceRecord8_1.age, 10);
    test:assertEquals((check v2).test.choice_XSDChoiceRecord8_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {choice_XSDChoiceRecord8_1: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceRecord8_2: {status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.choice_XSDChoiceRecord8_1.salary, 11.1);
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {choice_XSDChoiceRecord8_1: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceRecord8_2: {status: {value1: "Success", value2: "Fail"}}}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><age>10</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord8_2' occurs more than the max allowed times");

    xmlStr = string `<Root><test><age>10</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord8_1' occurs more than the max allowed times");

    xmlStr = string `<Root><test><age>10</age></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord8_2' occurs less than the min required times");

    xmlStr = string `<Root><test><status><value1>Success</value1><value2>Fail</value2></status></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord8_1' occurs less than the min required times");
}

type XSDChoiceRecord9 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord9_1 choice_XSDChoiceRecord9_1;
};

type Choice_XSDChoiceRecord9_1 record {
    Choice_A field1?;
    Choice_B field2?;
    Choice_C field3?;
};

type Choice_A record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice value1;
};

type Choice_B record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice value2;
};

type Choice_C record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice value3;
};

type Choice record {
    string a?;
    string b?;
    string c?;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice9() returns error? {
    string xmlStr;
    XSDChoiceRecord9|Error v2;

    xmlStr = string `<Root><field2><a>1</a></field2></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord9_1: {field2: {value2: {a: "1"}}}});

    xmlStr = string `<Root><field3><c>1</c></field3></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord9_1: {field3: {value3: {c: "1"}}}});

    xmlStr = string `<Root><field1><c>1</c></field1><field1><c>1</c></field1></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord9_1' occurs more than the max allowed times");

    xmlStr = string `<Root><field1><b>1</b><c>1</c></field1></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'value1' occurs more than the max allowed times");
}

type XSDChoiceRecord10 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord10_1 choice_XSDChoiceRecord10_1?;

    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceRecord10_2 choice_XSDChoiceRecord10_2;
};

type Choice_XSDChoiceRecord10_1 record {
    Choice_A_10 field1?;
    Choice_B_10 field2?;
    Choice_C_10 field3?;
};

type Choice_XSDChoiceRecord10_2 record {
    Choice_D_10 field4?;
    Choice_E_10 field5?;
    Choice_F_10 field6?;
};

type Choice_A_10 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_10 value1;
};

type Choice_B_10 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice2_10 value2;
};

type Choice_C_10 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice3_10 value3;
};

type Choice_D_10 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_10 value1;
};

type Choice_E_10 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice2_10 value2;
};

type Choice_F_10 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice3_10 value3;
};

type Choice_10 record {
    string a?;
    string b?;
    string c?;
};

type Choice2_10 record {
    string d?;
    string e?;
    string f?;
};

type Choice3_10 record {
    string g?;
    string h?;
    string i?;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoice10() returns error? {
    string xmlStr = string `<Root><field1><a>1</a></field1><field5><d>2</d></field5></Root>`;
    XSDChoiceRecord10|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, <XSDChoiceRecord10>{choice_XSDChoiceRecord10_1: {field1: {value1: {a: "1"}}}, choice_XSDChoiceRecord10_2: {field5: {value2: {"d": "2"}}}});

    xmlStr = string `<Root><field1><a>1</a></field1><field2><d>1</d></field2><field5><d>2</d></field5></Root>`;
    v2 = parseString(xmlStr); 
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord10_1' occurs more than the max allowed times");

    xmlStr = string `<Root><field1><a>1</a></field1><field5><d>2</d></field5><field6><h>2</h></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'choice_XSDChoiceRecord10_2' occurs more than the max allowed times");

    xmlStr = string `<Root><field2><d>1</d><e>1</e></field2><field5><d>2</d></field5></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'value2' occurs more than the max allowed times");
}
