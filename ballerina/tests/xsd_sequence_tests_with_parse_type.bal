import ballerina/test;

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue seq_XSDSequenceRecordWithXmlValue;
|};

type Seq_XSDSequenceRecordWithXmlValue record {|
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
function testXsdSequenceWithXmlValue() returns error? {
    xml xmlValue = xml `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue|Error v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValue: {age: 13, salary: 11.1}});
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue.salary, 11.1);
    test:assertEquals(toXml(check v.ensureType(XSDSequenceRecordWithXmlValue)), xmlValue);

    xmlValue = xml `<Root><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue'");

    xmlValue = xml `<Root><age>13</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue'");

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), ("required field 'seq_XSDSequenceRecordWithXmlValue' not present in XML"), msg = (<Error>v).message());

    xmlValue = xml `<Root><salary>11.1</salary><age>13</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValueP2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValueP2 seq_XSDSequenceRecordWithXmlValueP2;
|};

type Seq_XSDSequenceRecordWithXmlValueP2 record {|
    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    @Order {
        value: 1
    }
    int[] age;

    @Order {
        value: 2
    }
    float salary;

    @Order {
        value: 3
    }
    @Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    string[] name;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithXmlValueP2() returns error? {
    xml xmlValue;
    XSDSequenceRecordWithXmlValueP2|Error v;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValueP2: {age: [13], salary: 11.1, name: ["ABC"]}});
    test:assertEquals(toXml(check v.ensureType(XSDSequenceRecordWithXmlValueP2)), xmlValue);

    xmlValue = xml `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValueP2: {age: [13, 13, 13], salary: 11.1, name: ["ABC"]}});
    test:assertEquals(toXml(check v.ensureType(XSDSequenceRecordWithXmlValueP2)), xmlValue);

    xmlValue = xml `<Root><age>13</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'name' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValueP2'");

    xmlValue = xml `<Root><age>13</age><age>13</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'name' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValueP2'");

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValueP2'");

    xmlValue = xml `<Root><age>13</age><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><salary>11.1</salary><name>ABC</name><age>13</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValueP2'");

    xmlValue = xml `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValueP2: {age: [13, 13, 13], salary: 11.1, name: ["ABC", "ABC"]}});

    xmlValue = xml `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><name>ABC</name><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'name' occurs more than the max allowed times");

    xmlValue = xml `<Root><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><age>13</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), ("Element(s) 'salary, name' is not found in 'seq_XSDSequenceRecordWithXmlValueP2'"), msg = (<Error>v).message());
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue2 seq_XSDSequenceRecordWithXmlValue2;
    int num;
|};

type Seq_XSDSequenceRecordWithXmlValue2 record {|
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
function testXsdSequenceWithXmlValue2() returns error? {
    xml xmlValue = xml `<Root><num>3</num><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue2|Error v = parseAsType(xmlValue);
    test:assertEquals(v, {num: 3, seq_XSDSequenceRecordWithXmlValue2: {age: 13, salary: 11.1}});
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue2.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue2.salary, 11.1);
    test:assertEquals((check v).num, 3);
    test:assertEquals(toXml(check v), xml `<Root><age>13</age><salary>11.1</salary><num>3</num></Root>`);

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><num>3</num></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValue2: {age: 13, salary: 11.1}, num: 3});
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue2.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue2.salary, 11.1);
    test:assertEquals((check v).num, 3);
    test:assertEquals(toXml(check v), xmlValue);

    xmlValue = xml `<Root><age>13</age><num>3</num><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue2'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue3 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue3 seq_XSDSequenceRecordWithXmlValue3;

    record{int n;} num;
|};

type Seq_XSDSequenceRecordWithXmlValue3 record {|
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
function testXsdSequenceWithXmlValue3() returns error? {
    xml xmlValue = xml `<Root><num><n>3</n></num><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue3|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {num: {n: 3}, seq_XSDSequenceRecordWithXmlValue3: {age: 13, salary: 11.1}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue3.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue3.salary, 11.1);
    test:assertEquals((check v2).num, {n: 3});
    test:assertEquals(toXml(check v2), xml `<Root><age>13</age><salary>11.1</salary><num><n>3</n></num></Root>`);

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><num><n>3</n></num></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue3: {age: 13, salary: 11.1}, num: {n: 3}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue3.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue3.salary, 11.1);
    test:assertEquals((check v2).num, {n: 3});
    test:assertEquals(toXml(check v2), xmlValue);

    xmlValue = xml `<Root><age>13</age><num><n>3</n></num><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue3'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue4 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue4 seq_XSDSequenceRecordWithXmlValue4;
|};

type Seq_XSDSequenceRecordWithXmlValue4 record {|
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
function testXsdSequenceWithXmlValue4() returns error? {
    xml xmlValue = xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue4|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue4: {age: 13, salary: 11.1}, num: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue4.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue4.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xmlValue);

    xmlValue = xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue4: {age: 13, salary: 11.1}, num: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue4.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue4.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xmlValue);

    xmlValue = xml `<Root><age>13</age><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue4'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue5 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue5 seq_XSDSequenceRecordWithXmlValue5;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecordWithXmlValue5 record {|
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
function testXsdSequenceWithXmlValue5() returns error? {
    xml xmlValue = xml `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue5|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue5.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue5.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue5.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue5.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue5: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue5.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue5.salary, 11.1);
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><age>13</age><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue5'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue6 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue6_1 seq_XSDSequenceRecordWithXmlValue6_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue6_2 seq_XSDSequenceRecordWithXmlValue6_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecordWithXmlValue6_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue6_2 record {|
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
function testXsdSequenceWithXmlValue6() returns error? {
    xml xmlValue = xml `<Root><num><n><n>3</n></n></num><name>SD</name><status>success</status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue6|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><name>SD</name><status>success</status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><name>SD</name><status>success</status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue6_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue6_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.name, "SD");
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue6_2.status, "success");
    test:assertEquals((check v2).num, {n: {n: 3}});
    test:assertEquals((check v2).num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></Root>`);

    xmlValue = xml `<Root><name>SD</name><age>13</age><status>success</status><salary>11.1</salary></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'status' is not found in 'seq_XSDSequenceRecordWithXmlValue6_2'");

    xmlValue = xml `<Root><age>13</age><status>success</status><salary>11.1</salary><name>SD</name></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue6_1'");

    xmlValue = xml `<Root><status>success</status><name>SD</name><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'status' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue6_2'");

    xmlValue = xml `<Root><name>SD</name><status>success</status><salary>11.1</salary><age>13</age><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue6_1'");

    xmlValue = xml `<Root><name>SD</name><status>success</status><salary>11.1</salary><num><n><n>3</n></n></num><age>13</age><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue6_1'");

    xmlValue = xml `<Root><name>SD</name><status>success</status><age>11</age><num><n><n>3</n></n></num><salary>13.1</salary><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue6_1'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue7 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue7_1 seq_XSDSequenceRecordWithXmlValue7_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue7_2 seq_XSDSequenceRecordWithXmlValue7_2;
|};

type Seq_XSDSequenceRecordWithXmlValue7_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue7_2 record {|
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
function testXsdSequenceWithXmlValue7() returns error? {
    xml xmlValue = xml `<Root><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue7|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue7_1: {age: 13, salary: 11.1}, seq_XSDSequenceRecordWithXmlValue7_2: {name: "SD", status: "success"}});
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue7_1.age, 13);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue7_1.salary, 11.1);
    test:assertEquals((check v2).seq_XSDSequenceRecordWithXmlValue7_2.name, "SD");
    test:assertEquals(toXml(check v2), xml `<Root><age>13</age><salary>11.1</salary><name>SD</name><status>success</status></Root>`);
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue8 record {|
    XSDSequenceRecordWithXmlValue8P2 test;
    int 'check;
|};

type XSDSequenceRecordWithXmlValue8P2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue8_1 seq_XSDSequenceRecordWithXmlValue8_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue8_2 seq_XSDSequenceRecordWithXmlValue8_2;
|};

type Seq_XSDSequenceRecordWithXmlValue8_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue8_2 record {|
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
function testXsdSequenceWithXmlValue8() returns error? {
    xml xmlValue = xml `<Root><test><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></test><check>2</check></Root>`;
    XSDSequenceRecordWithXmlValue8|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {'check: 2, test: {seq_XSDSequenceRecordWithXmlValue8_1: {salary: 11.1, age: 13}, seq_XSDSequenceRecordWithXmlValue8_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue8_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue8_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue8_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue8_2.status, "success");
    test:assertEquals(toXml(check v2), xml `<Root><test><age>13</age><salary>11.1</salary><name>SD</name><status>success</status></test><check>2</check></Root>`);
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue9 record {|
    XSDSequenceRecordWithXmlValue9P test;
    int a;
|};

type XSDSequenceRecordWithXmlValue9P record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue9_1 seq_XSDSequenceRecordWithXmlValue9_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue9_2 seq_XSDSequenceRecordWithXmlValue9_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecordWithXmlValue9_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue9_2 record {|
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
function testXsdSequenceWithXmlValue9() returns error? {
    xml xmlValue = xml `<Root><test><num><n><n>3</n></n></num><name>SD</name><status>success</status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    XSDSequenceRecordWithXmlValue9|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><name>SD</name><status>success</status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name>SD</name><status>success</status><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><name>SD</name><status>success</status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue9_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue9_2: {name: "SD", status: "success"}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.name, "SD");
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue9_2.status, "success");
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name>SD</name><status>success</status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><name>SD</name><age>13</age><status>success</status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'status' is not found in 'seq_XSDSequenceRecordWithXmlValue9_2'");

    xmlValue = xml `<Root><test><age>13</age><status>success</status><salary>11.1</salary><name>SD</name></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue9_1'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue10 record {|
    XSDSequenceRecordWithXmlValue10P test;
    int a;
|};

type XSDSequenceRecordWithXmlValue10P record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue10_1 seq_XSDSequenceRecordWithXmlValue10_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue10_2 seq_XSDSequenceRecordWithXmlValue10_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecordWithXmlValue10_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue10_2 record {|
    @Order {
        value: 1
    }
    Rec10 name;

    @Order {
        value: 2
    }
    Rec10 status;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithXmlValue10() returns error? {
    xml xmlValue = xml `<Root><test><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    XSDSequenceRecordWithXmlValue10|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a></Root>`);

    xmlValue = xml `<Root><test><name><value1>SD</value1><value2>AB</value2></name><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'status' is not found in 'seq_XSDSequenceRecordWithXmlValue10_2'");

    xmlValue = xml `<Root><test><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue10_1'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue11 record {|
    XSDSequenceRecordWithXmlValue11P test;
    int a;
    XSDSequenceRecordWithXmlValue11P2 test2;
|};

type XSDSequenceRecordWithXmlValue11P record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue11_1 seq_XSDSequenceRecordWithXmlValue11_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue11_2 seq_XSDSequenceRecordWithXmlValue11_2;
    record{record {int n;} n;} num2;
|};

type XSDSequenceRecordWithXmlValue11P2 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue11_1 seq_XSDSequenceRecordWithXmlValue11_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue11_2 seq_XSDSequenceRecordWithXmlValue11_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecordWithXmlValue11_1 record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue11_2 record {|
    @Order {
        value: 1
    }
    Rec11 name;

    @Order {
        value: 2
    }
    Rec11 status;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithXmlValue11() returns error? {
    xml xmlValue = xml `<Root><test><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2></Root>`;
    XSDSequenceRecordWithXmlValue11|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}, test2: {seq_XSDSequenceRecordWithXmlValue11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a><test2><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test2></Root>`);

    xmlValue = xml `<Root><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}, test2: {seq_XSDSequenceRecordWithXmlValue11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a><test2><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test2></Root>`);

    xmlValue = xml `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary></test><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecordWithXmlValue11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}, test2: {seq_XSDSequenceRecordWithXmlValue11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecordWithXmlValue11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecordWithXmlValue11_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});
    test:assertEquals(toXml(check v2), xml `<Root><test><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test><a>2</a><test2><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2></test2></Root>`);

    xmlValue = xml `<Root><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2><test><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name></test><a>2</a></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue11_1'");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue12 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue12_1 seq_XSDSequenceRecordWithXmlValue12_1;
};

type Seq_XSDSequenceRecordWithXmlValue12_1 record {
    @Order {value: 1}
    Seq_A field1;

    @Order {value: 2}
    Seq_B field2;

    @Order {value: 3}
    Seq_C field3;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithXmlValue12() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><a>1</a><b>2</b><c>3</c></field2><field3><a>1</a><b>2</b><c>3</c></field3></Root>`;
    XSDSequenceRecordWithXmlValue12|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceRecordWithXmlValue12_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {a: "1", b: "2", c: "3"}}, field3: {value3: {a: "1", b: "2", c: "3"}}}});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><a>1</a><b>2</b><c>3</c></field2><field3><a>1</a><b>2</b><c>3</c></field3></Root>`);
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithXmlValue13 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue13_1 seq_XSDSequenceRecordWithXmlValue13_1?;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithXmlValue13_2 seq_XSDSequenceRecordWithXmlValue13_2;
};

type Seq_XSDSequenceRecordWithXmlValue13_1 record {
    @Order {value: 1}
    Seq_A_13 field1;

    @Order {value: 2}
    Seq_B_13 field2;

    @Order {value: 3}
    Seq_C_13 field3;
};

type Seq_XSDSequenceRecordWithXmlValue13_2 record {
    @Order {value: 1}
    Seq_D_13 field4;

    @Order {value: 2}
    Seq_E_13 field5;

    @Order {value: 3}
    Seq_F_13 field6;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithXmlValue13() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDSequenceRecordWithXmlValue13|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, <XSDSequenceRecordWithXmlValue13>{seq_XSDSequenceRecordWithXmlValue13_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {d: "1", e: "2", f: "3"}}, field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XSDSequenceRecordWithXmlValue13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`);

    xmlValue = xml `<Root><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, <XSDSequenceRecordWithXmlValue13>{seq_XSDSequenceRecordWithXmlValue13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}});
    test:assertEquals(toXml(check v2), xml `<Root><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`);

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><g>1</g><h>2</h><i>3</i><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'field6' is not found in 'seq_XSDSequenceRecordWithXmlValue13_2'");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><g>1</g><h>2</h><i>3</i><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'f' is not found in 'value2'");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><i>3</i><h>2</h></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'i' is not in the correct order in 'value3'");

    xmlValue = xml `<Root><field1><a>1</a><c>3</c><b>2</b></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'c' is not in the correct order in 'value1'");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field4><a>1</a><b>2</b><c>3</c></field4><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), ("Element 'field5' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue13_2'"), msg = (<Error>v2).message());
}
