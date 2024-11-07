import ballerina/test;

type XSDSequenceRecord record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord seq_XSDSequenceRecord;
|};

type Seq_XSDSequenceRecord record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence() returns error? {
    string xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord|Error v = parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecord: {age: 13, salary: 11.1}});
    test:assertEquals((check v).seq_XSDSequenceRecord.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecord.salary, 11.1);

    xmlStr = string `<Root><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    // TODO: Change error messageas
    // test:assertTrue((<Error>v).message().includes("Element age not found in"), msg = (<Error>v).message());
    test:assertTrue((<Error>v).message().includes("required field 'age' not present in XML"), msg = (<Error>v).message());

    xmlStr = string `<Root><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    // test:assertTrue((<Error>v).message().includes("Element salary not found in"), msg = (<Error>v).message());
    test:assertTrue((<Error>v).message().includes("required field 'salary' not present in XML"), msg = (<Error>v).message());

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);

    // TODO: Change the error message in validate Fields function
    test:assertTrue((<Error>v).message().includes("required field 'seq_XSDSequenceRecord' not present in XML"), msg = (<Error>v).message());
}

// TODO: Test with open records.
type XSDSequenceRecord2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord2 seq_XSDSequenceRecord2;

    // TODO: After adding XSD validation for traverse, check union fields as well
    int num;
|};

type Seq_XSDSequenceRecord2 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence2() returns error? {
    string xmlStr = string `<Root><num>3</num><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord2|Error v = parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecord2: {age: 13, salary: 11.1}, num: 3});
    test:assertEquals((check v).seq_XSDSequenceRecord2.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecord2.salary, 11.1);
    test:assertEquals((check v).num, 3);

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><num>3</num></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecord2: {age: 13, salary: 11.1}, num: 3});
    test:assertEquals((check v).seq_XSDSequenceRecord2.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecord2.salary, 11.1);
    test:assertEquals((check v).num, 3);

    xmlStr = string `<Root><age>13</age><num>3</num><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("Element salary not found in"));
}

type XSDSequenceRecord3 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord3 seq_XSDSequenceRecord3;
    
    // TODO: After adding XSD validation for traverse, check union fields as well
    record{int n;} num;
|};

type Seq_XSDSequenceRecord3 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence3() returns error? {
    string xmlStr = string `<Root><num><n>3</n></num><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord3|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord3: {age: 13, salary: 11.1}, num: {n: 3}});
    test:assertEquals((check v2).seq_XSDSequenceRecord3.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord3.salary, 11.1);
    test:assertEquals((check v2).num, {n: 3});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><num><n>3</n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord3: {age: 13, salary: 11.1}, num: {n: 3}});
    test:assertEquals((check v2).seq_XSDSequenceRecord3.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord3.salary, 11.1);
    test:assertEquals((check v2).num, {n: 3});

    xmlStr = string `<Root><age>13</age><num><n>3</n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element salary not found in"));
}

type XSDSequenceRecord4 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord4 seq_XSDSequenceRecord4;
|};

type Seq_XSDSequenceRecord4 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence4() returns error? {
    string xmlStr = string `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord4|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord4: {age: 13, salary: 11.1}, num: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecord4.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord4.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord4: {age: 13, salary: 11.1}, num: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecord4.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord4.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});

    xmlStr = string `<Root><age>13</age><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element salary not found in"));
}

type XSDSequenceRecord5 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord5 seq_XSDSequenceRecord5;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecord5 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence5() returns error? {
    string xmlStr = string `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord5|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><age>13</age><num2><num><n><n>3</n></n></num2><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element salary not found in"), (<Error>v2).message());
}

type XSDSequenceRecord6 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord6_1 seq_XSDSequenceRecord6_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord6_2 seq_XSDSequenceRecord6_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecord6_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord6_2 record {|
    @Order {
        value: 1
    }
    string name;

    @Order {
        value: 2
    }
    string status;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence6() returns error? {
    string xmlStr = string `<Root><num><n><n>3</n></n></num><name>SD</name><status>success</status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord6|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><name>SD</name><status>success</status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><name>SD</name><status>success</status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecord6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});

    xmlStr = string `<Root><name>SD</name><age>13</age><status>success</status><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element status not found in"), (<Error>v2).message());

    xmlStr = string `<Root><age>13</age><status>success</status><salary>11.1</salary><name>SD</name></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element salary not found in"), (<Error>v2).message());
}

type XSDSequenceRecord7 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord7_1 seq_XSDSequenceRecord7_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord7_2 seq_XSDSequenceRecord7_2;
|};

type Seq_XSDSequenceRecord7_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord7_2 record {|
    @Order {
        value: 1
    }
    string name;

    @Order {
        value: 2
    }
    string status;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence7() returns error? {
    string xmlStr = string `<Root><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord7|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord7_1: {age: 13, salary: 11.1}, seq_XSDSequenceRecord7_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecord7_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecord7_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecord7_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecord7_2.status, "success");
}

type XSDSequenceRecord8 record {|
    XSDSequenceRecord8P2 test;
    int 'check;
|};

type XSDSequenceRecord8P2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord8_1 seq_XSDSequenceRecord8_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord8_2 seq_XSDSequenceRecord8_2;
|};

type Seq_XSDSequenceRecord8_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord8_2 record {|
    @Order {
        value: 1
    }
    string name;

    @Order {
        value: 2
    }
    string status;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence8() returns error? {
    string xmlStr = string `<Root><test><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></test><check>2</check></Root>`;
    XSDSequenceRecord8|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {'check: 2, test: {seq_XSDSequenceRecord8_1: {age: 13, salary: 11.1}, seq_XSDSequenceRecord8_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord8_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord8_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord8_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord8_2.status, "success");
}

type XSDSequenceRecord9 record {|
    XSDSequenceRecord9P test;
    int a;
|};

type XSDSequenceRecord9P record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord9_1 seq_XSDSequenceRecord9_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord9_2 seq_XSDSequenceRecord9_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecord9_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord9_2 record {|
    @Order {
        value: 1
    }
    string name;

    @Order {
        value: 2
    }
    string status;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence9() returns error? {
    string xmlStr = string `<Root><test><num><n><n>3</n></n></num><name>SD</name><status>success</status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    XSDSequenceRecord9|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name>SD</name><status>success</status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name>SD</name><status>success</status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name>SD</name><age>13</age><status>success</status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element status not found in"), (<Error>v2).message());

    xmlStr = string `<Root><test><age>13</age><status>success</status><salary>11.1</salary><name>SD</name></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element salary not found in"), (<Error>v2).message());
}

type XSDSequenceRecord10 record {|
    XSDSequenceRecord10P test;
    int a;
|};

type XSDSequenceRecord10P record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord10_1 seq_XSDSequenceRecord10_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord10_2 seq_XSDSequenceRecord10_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecord10_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord10_2 record {|
    @Order {
        value: 1
    }
    Rec10 name;

    @Order {
        value: 2
    }
    Rec10 status;
|};

type Rec10 record {|
    string value1;
    string value2;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence10() returns error? {
    string xmlStr = string `<Root><test><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    XSDSequenceRecord10|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element status not found in"), (<Error>v2).message());

    xmlStr = string `<Root><test><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element salary not found in"), (<Error>v2).message());
}
