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

    // xmlStr = string `<Root><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    // v2 = parseString(xmlStr);
    // test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    // test:assertEquals((check v2).num, {n: {n: 3}});

    // xmlStr = string `<Root><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    // v2 = parseString(xmlStr);
    // test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    // test:assertEquals((check v2).num, {n: {n: 3}});

    // xmlStr = string `<Root><age>13</age><num2><num><n><n>3</n></n></num2><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    // v2 = parseString(xmlStr);
    // test:assertTrue(v2 is Error);
    // test:assertTrue((<Error>v2).message().includes("Element salary not found in"), (<Error>v2).message());
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

    // xmlStr = string `<Root><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    // v2 = parseString(xmlStr);
    // test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    // test:assertEquals((check v2).num, {n: {n: 3}});

    // xmlStr = string `<Root><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    // v2 = parseString(xmlStr);
    // test:assertEquals(v2, {seq_XSDSequenceRecord5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.age, 13);
    // test:assertEquals((check v2).seq_XSDSequenceRecord5.salary, 11.1);
    // test:assertEquals((check v2).num, {n: {n: 3}});

    // xmlStr = string `<Root><age>13</age><num2><num><n><n>3</n></n></num2><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    // v2 = parseString(xmlStr);
    // test:assertTrue(v2 is Error);
    // test:assertTrue((<Error>v2).message().includes("Element salary not found in"), (<Error>v2).message());
}
