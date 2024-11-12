import ballerina/test;

type XSDChoiceWithXmlValueRecord record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord choice_XSDChoiceWithXmlValueRecord?;
|};

type Choice_XSDChoiceWithXmlValueRecord record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceWithXmlValue() returns error? {
    xml xmlValue;
    XSDChoiceWithXmlValueRecord|Error v;

    xmlValue = xml `<Root><age>10</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecord: {age: 10}});

    xmlValue = xml `<Root><salary>10.5</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecord: {salary: 10.5}});

    xmlValue = xml `<Root><age>10</age><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecord Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><salary>11.1</salary><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecord Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecord Element occurs less than the min required times"), (<Error>v).message());
}

type XSDChoiceWithXmlValueRecordP2 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecordP2 choice_XSDChoiceWithXmlValueRecordP2;
|};

type Choice_XSDChoiceWithXmlValueRecordP2 record {|
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

type XSDChoiceWithXmlValueP1Record record {|
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueP1Record choice_XSDChoiceWithXmlValueP1Record?;
|};

type Choice_XSDChoiceWithXmlValueP1Record record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceWithXmlValueP1() returns error? {
    xml xmlValue;
    XSDChoiceWithXmlValueP1Record|Error v;

    xmlValue = xml `<Root><age>10</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueP1Record: {age: 10}});

    xmlValue = xml `<Root><salary>10.5</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueP1Record: {salary: 10.5}});

    xmlValue = xml `<Root><age>10</age><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueP1Record Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><salary>11.1</salary><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueP1Record Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {});
}

@test:Config {groups: ["xsd", "xsd_Choice"]}
function testXsdChoiceWithXmlValueP2() returns error? {
    xml xmlValue = xml `<Root><age>10</age></Root>`;
    XSDChoiceWithXmlValueRecordP2|Error v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecordP2: {age: [10]}});

    xmlValue = xml `<Root><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecordP2: {name: ["ABC"]}});

    xmlValue = xml `<Root><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecordP2: {salary: 11.1}});

    xmlValue = xml `<Root><age>10</age><age>10</age><age>10</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecordP2 Element occurs more than the max allowed times"), msg = (<Error>v).message());

    xmlValue = xml `<Root><age>10</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecordP2 Element occurs more than the max allowed times"), msg = (<Error>v).message());
}

type XSDChoiceWithXmlValueRecord2 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord2 choice_XSDChoiceWithXmlValueRecord2;

    int num;
|};

type Choice_XSDChoiceWithXmlValueRecord2 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue2() returns error? {
    xml xmlValue = xml `<Root><num>3</num><age>10</age></Root>`;
    XSDChoiceWithXmlValueRecord2|Error v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecord2: {age: 10}, num: 3});
    test:assertEquals((check v).choice_XSDChoiceWithXmlValueRecord2.age, 10);
    test:assertEquals((check v).num, 3);

    xmlValue = xml `<Root><salary>11.1</salary><num>3</num></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {choice_XSDChoiceWithXmlValueRecord2: {salary: 11.1}, num: 3});
    test:assertEquals((check v).choice_XSDChoiceWithXmlValueRecord2.salary, 11.1);
    test:assertEquals((check v).num, 3);

    xmlValue = xml `<Root><salary>11.1</salary><age>10</age><num>3</num></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecord2 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlValue = xml `<Root><age>10</age><num>3</num><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceWithXmlValueRecord2 Element occurs more than the max allowed times"), (<Error>v).message());
}

type XSDChoiceWithXmlValueRecord3 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord3 choice_XSDChoiceWithXmlValueRecord3;
    
    record{int n;} num;
|};

type Choice_XSDChoiceWithXmlValueRecord3 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue3() returns error? {
    xml xmlValue = xml `<Root><num><n>3</n></num><age>10</age></Root>`;
    XSDChoiceWithXmlValueRecord3|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord3: {age: 10}, num: {n: 3}});
    test:assertEquals((check v2).choice_XSDChoiceWithXmlValueRecord3.age, 10);
    test:assertEquals((check v2).num, {n: 3});

    xmlValue = xml `<Root><salary>11.1</salary><num><n>3</n></num></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord3: {salary: 11.1}, num: {n: 3}});

    xmlValue = xml `<Root><age>10</age><num><n>3</n></num><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord3 Element occurs more than the max allowed times"));

    xmlValue = xml `<Root><num><n>3</n></num><age>10</age><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord3 Element occurs more than the max allowed times"));
}

type XSDChoiceWithXmlValueRecord4 record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord4 choice_XSDChoiceWithXmlValueRecord4;
|};

type Choice_XSDChoiceWithXmlValueRecord4 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue4() returns error? {
    xml xmlValue = xml `<Root><num><n><n>3</n></n></num><age>10</age></Root>`;
    XSDChoiceWithXmlValueRecord4|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord4: {age: 10}, num: {n: {n: 3}}});
    test:assertEquals((check v2).choice_XSDChoiceWithXmlValueRecord4.age, 10);
    test:assertEquals((check v2).num, {n: {n: 3}});

    xmlValue = xml `<Root><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord4: {salary: 11.1}, num: {n: {n: 3}}});

    xmlValue = xml `<Root><age>10</age><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord4 Element occurs more than the max allowed times"));

    xmlValue = xml `<Root><num><n><n>3</n></n></num><age>10</age><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord4 Element occurs more than the max allowed times"));
}

type XSDChoiceWithXmlValueRecord5 record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord5 choice_XSDChoiceWithXmlValueRecord5;
    record{record {int n;} n;} num2;
|};

type Choice_XSDChoiceWithXmlValueRecord5 record {|
    int age?;
    float salary?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue5() returns error? {
    xml xmlValue = xml `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>10</age></Root>`;
    XSDChoiceWithXmlValueRecord5|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord5: {age: 10}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlValue = xml `<Root><num2><n><n>3</n></n></num2><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord5: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlValue = xml `<Root><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord5: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlValue = xml `<Root><age>10</age><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord5 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("required field 'choice_XSDChoiceWithXmlValueRecord5' not present in XML"), (<Error>v2).message());
}

type XSDChoiceWithXmlValueRecord6 record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord6_1 choice_XSDChoiceWithXmlValueRecord6_1;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord6_2 choice_XSDChoiceWithXmlValueRecord6_2;
    record{record {int n;} n;} num2;
|};

type Choice_XSDChoiceWithXmlValueRecord6_1 record {|
    int age?;
    float salary?;
|};

type Choice_XSDChoiceWithXmlValueRecord6_2 record {|
    string name?;
    string status?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue6() returns error? {
    xml xmlValue = xml `<Root><num><n><n>3</n></n></num><status>success</status><num2><n><n>3</n></n></num2><age>10</age></Root>`;
    XSDChoiceWithXmlValueRecord6|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord6_1: {age: 10}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceWithXmlValueRecord6_2: {status: "success"}});
    test:assertEquals((check v2).choice_XSDChoiceWithXmlValueRecord6_1.age, 10);
    test:assertEquals((check v2).choice_XSDChoiceWithXmlValueRecord6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlValue = xml `<Root><name>SD</name><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("required field 'choice_XSDChoiceWithXmlValueRecord6_1' not present in XML"), msg = (<Error>v2).message());

    xmlValue = xml `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name>SD</name></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("required field 'choice_XSDChoiceWithXmlValueRecord6_1' not present in XML"), msg = (<Error>v2).message());

    xmlValue = xml `<Root><name>SD</name><status>success</status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord6_2 Element occurs more than the max allowed times"), msg = (<Error>v2).message());
}

type XSDChoiceWithXmlValueRecord7 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord7_1 choice_XSDChoiceWithXmlValueRecord7_1;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord7_2 choice_XSDChoiceWithXmlValueRecord7_2;
|};

type Choice_XSDChoiceWithXmlValueRecord7_1 record {|
    int age?;
    float salary?;
|};

type Choice_XSDChoiceWithXmlValueRecord7_2 record {|
    string name?;
    string status?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue7() returns error? {
    xml xmlValue = xml `<Root><status>success</status><salary>11.1</salary></Root>`;
    XSDChoiceWithXmlValueRecord7|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord7_1: {salary: 11.1}, choice_XSDChoiceWithXmlValueRecord7_2: {status: "success"}});
}

type XSDChoiceWithXmlValueRecord8 record {|
    XSDChoiceWithXmlValueRecord8P test;
    int a;
|};

type XSDChoiceWithXmlValueRecord8P record {|
    record{record {int n;} n;} num;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord8_1 choice_XSDChoiceWithXmlValueRecord8_1;

    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord8_2 choice_XSDChoiceWithXmlValueRecord8_2;
    record{record {int n;} n;} num2;
|};

type Choice_XSDChoiceWithXmlValueRecord8_1 record {|
    int age?;
    float salary?;
|};

type Choice_XSDChoiceWithXmlValueRecord8_2 record {|
    RecChoice8 name?;
    RecChoice8 status?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue8() returns error? {
    xml xmlValue;
    XSDChoiceWithXmlValueRecord8|Error v2;

    xmlValue = xml `<Root><test><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><num2><n><n>3</n></n></num2><age>10</age></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {choice_XSDChoiceWithXmlValueRecord8_1: {age: 10}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceWithXmlValueRecord8_2: {name: {value1: "SD", value2: "AB"}}}});
    test:assertEquals((check v2).test.choice_XSDChoiceWithXmlValueRecord8_1.age, 10);
    test:assertEquals((check v2).test.choice_XSDChoiceWithXmlValueRecord8_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlValue = xml `<Root><test><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {choice_XSDChoiceWithXmlValueRecord8_1: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceWithXmlValueRecord8_2: {status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.choice_XSDChoiceWithXmlValueRecord8_1.salary, 11.1);
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlValue = xml `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {choice_XSDChoiceWithXmlValueRecord8_1: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, choice_XSDChoiceWithXmlValueRecord8_2: {status: {value1: "Success", value2: "Fail"}}}});

    xmlValue = xml `<Root><test><name><value1>SD</value1><value2>AB</value2></name><age>10</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord8_2 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><test><age>10</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord8_1 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><test><age>10</age></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord8_2 Element occurs less than the min required times"), (<Error>v2).message());

    xmlValue = xml `<Root><test><status><value1>Success</value1><value2>Fail</value2></status></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord8_1 Element occurs less than the min required times"), (<Error>v2).message());
}

type XSDChoiceWithXmlValueRecord9 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord9_1 choice_XSDChoiceWithXmlValueRecord9_1;
};

type Choice_XSDChoiceWithXmlValueRecord9_1 record {
    Choice_A field1?;
    Choice_B field2?;
    Choice_C field3?;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue9() returns error? {
    xml xmlValue;
    XSDChoiceWithXmlValueRecord9|Error v2;

    xmlValue = xml `<Root><field2><a>1</a></field2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord9_1: {field2: {value2: {a: "1"}}}});

    xmlValue = xml `<Root><field3><c>1</c></field3></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {choice_XSDChoiceWithXmlValueRecord9_1: {field3: {value3: {c: "1"}}}});

    xmlValue = xml `<Root><field1><c>1</c></field1><field1><c>1</c></field1></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord9_1 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><field1><b>1</b><c>1</c></field1></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("value1 Element occurs more than the max allowed times"), (<Error>v2).message());
}

type XSDChoiceWithXmlValueRecord10 record {
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord10_1 choice_XSDChoiceWithXmlValueRecord10_1?;

    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_XSDChoiceWithXmlValueRecord10_2 choice_XSDChoiceWithXmlValueRecord10_2;
};

type Choice_XSDChoiceWithXmlValueRecord10_1 record {
    Choice_A_10 field1?;
    Choice_B_10 field2?;
    Choice_C_10 field3?;
};

type Choice_XSDChoiceWithXmlValueRecord10_2 record {
    Choice_D_10 field4?;
    Choice_E_10 field5?;
    Choice_F_10 field6?;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdChoiceWithXmlValue10() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a></field1><field5><d>2</d></field5></Root>`;
    XSDChoiceWithXmlValueRecord10|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, <XSDChoiceWithXmlValueRecord10>{choice_XSDChoiceWithXmlValueRecord10_1: {field1: {value1: {a: "1"}}}, choice_XSDChoiceWithXmlValueRecord10_2: {field5: {value2: {"d": "2"}}}});

    xmlValue = xml `<Root><field1><a>1</a></field1><field2><d>1</d></field2><field5><d>2</d></field5></Root>`;
    v2 = parseAsType(xmlValue); 
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord10_1 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a></field1><field5><d>2</d></field5><field6><h>2</h></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceWithXmlValueRecord10_2 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><field2><d>1</d><e>1</e></field2><field5><d>2</d></field5></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("value2 Element occurs more than the max allowed times"), (<Error>v2).message());
}
