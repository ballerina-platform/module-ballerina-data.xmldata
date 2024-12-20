// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

type XSDSequenceRecord record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord seq_XSDSequenceRecord;
|};

type Seq_XSDSequenceRecord record {|
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
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
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecord'");

    xmlStr = string `<Root><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord'");

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), ("required field 'seq_XSDSequenceRecord' not present in XML"), msg = (<Error>v).message());

    xmlStr = string `<Root><salary>11.1</salary><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecord'");

    // TODO: Create an issue
    // xmlStr = string `<Root><salary><age>13</age></salary></Root>`;
    // v = parseString(xmlStr);
    // test:assertTrue(v is Error);
    // test:assertTrue((<Error>v).message().includes("Element age is not in the correct order in"), msg = (<Error>v).message());
}

type XSDSequenceRecordP2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordP2 seq_XSDSequenceRecordP2;
|};

type Seq_XSDSequenceRecordP2 record {|
    @Element {
        minOccurs: 1,
        maxOccurs: 3
    }
    @SequenceOrder {
        value: 1
    }
    int[] age;

    @SequenceOrder {
        value: 2
    }
    float salary;

    @SequenceOrder {
        value: 3
    }
    @Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    string[] name;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceP2() returns error? {
    string xmlStr;
    XSDSequenceRecordP2|Error v;

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecordP2: {age: [13], salary: 11.1, name: ["ABC"]}});

    xmlStr = string `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecordP2: {age: [13, 13, 13], salary: 11.1, name: ["ABC"]}});

    xmlStr = string `<Root><age>13</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'name' is not in the correct order in 'seq_XSDSequenceRecordP2'");

    xmlStr = string `<Root><age>13</age><age>13</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'name' is not in the correct order in 'seq_XSDSequenceRecordP2'");

    xmlStr = string `<Root><age>13</age><salary>11.1</salary><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordP2'");

    xmlStr = string `<Root><age>13</age><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'age' occurs more than the max allowed times");

    xmlStr = string `<Root><salary>11.1</salary><name>ABC</name><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordP2'");

    xmlStr = string `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecordP2: {age: [13, 13, 13], salary: 11.1, name: ["ABC", "ABC"]}});

    xmlStr = string `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><name>ABC</name><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'name' occurs more than the max allowed times");

    xmlStr = string `<Root><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), ("Element(s) 'salary, name' is not found in 'seq_XSDSequenceRecordP2'"), msg = (<Error>v).message());
}

// TODO: Test with open records.
type XSDSequenceRecord2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord2 seq_XSDSequenceRecord2;

    int num;
|};

type Seq_XSDSequenceRecord2 record {|
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
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
    test:assertEquals((<Error>v).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord2'");
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
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
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord3'");
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
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
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord4'");
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
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
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord5'");
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord6_2 record {|
    @SequenceOrder {
        value: 1
    }
    string name;

    @SequenceOrder {
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
    test:assertEquals((<Error>v2).message(), "Element(s) 'status' is not found in 'seq_XSDSequenceRecord6_2'");

    xmlStr = string `<Root><age>13</age><status>success</status><salary>11.1</salary><name>SD</name></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord6_1'");

    xmlStr = string `<Root><status>success</status><name>SD</name><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'status' is not in the correct order in 'seq_XSDSequenceRecord6_2'");

    xmlStr = string `<Root><name>SD</name><status>success</status><salary>11.1</salary><age>13</age><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecord6_1'");

    xmlStr = string `<Root><name>SD</name><status>success</status><salary>11.1</salary><num><n><n>3</n></n></num><age>13</age><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecord6_1'");

    xmlStr = string `<Root><name>SD</name><status>success</status><age>11</age><num><n><n>3</n></n></num><salary>13.1</salary><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord6_1'");
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord7_2 record {|
    @SequenceOrder {
        value: 1
    }
    string name;

    @SequenceOrder {
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord8_2 record {|
    @SequenceOrder {
        value: 1
    }
    string name;

    @SequenceOrder {
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord9_2 record {|
    @SequenceOrder {
        value: 1
    }
    string name;

    @SequenceOrder {
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
    test:assertEquals((<Error>v2).message(), "Element(s) 'status' is not found in 'seq_XSDSequenceRecord9_2'");

    xmlStr = string `<Root><test><age>13</age><status>success</status><salary>11.1</salary><name>SD</name></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord9_1'");
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord10_2 record {|
    @SequenceOrder {
        value: 1
    }
    Rec10 name;

    @SequenceOrder {
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
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord10_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord10_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord10_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><name><value1>SD</value1><value2>AB</value2></name><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'status' is not found in 'seq_XSDSequenceRecord10_2'");

    xmlStr = string `<Root><test><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord10_1'");
}

type XSDSequenceRecord11 record {|
    XSDSequenceRecord11P test;
    int a;
    XSDSequenceRecord11P2 test2;
|};

type XSDSequenceRecord11P record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord11_1 seq_XSDSequenceRecord11_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord11_2 seq_XSDSequenceRecord11_2;
    record{record {int n;} n;} num2;
|};

type XSDSequenceRecord11P2 record {|
    record{record {int n;} n;} num;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord11_1 seq_XSDSequenceRecord11_1;
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord11_2 seq_XSDSequenceRecord11_2;
    record{record {int n;} n;} num2;
|};

type Seq_XSDSequenceRecord11_1 record {|
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecord11_2 record {|
    @SequenceOrder {
        value: 1
    }
    Rec11 name;

    @SequenceOrder {
        value: 2
    }
    Rec11 status;
|};

type Rec11 record {|
    string value1;
    string value2;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence11() returns error? {
    string xmlStr = string `<Root><test><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2></Root>`;
    XSDSequenceRecord11|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}, test2: {seq_XSDSequenceRecord11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2><test><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}, test2: {seq_XSDSequenceRecord11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><age>13</age><salary>11.1</salary></test><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {a: 2, test: {seq_XSDSequenceRecord11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}, test2: {seq_XSDSequenceRecord11_1: {age: 13, salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}, seq_XSDSequenceRecord11_2: {name: {value1: "SD", value2: "AB"}, status: {value1: "Success", value2: "Fail"}}}});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_1.age, 13);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_1.salary, 11.1);
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_2.name, {value1: "SD", value2: "AB"});
    test:assertEquals((check v2).test.seq_XSDSequenceRecord11_2.status, {value1: "Success", value2: "Fail"});
    test:assertEquals((check v2).test.num, {n: {n: 3}});
    test:assertEquals((check v2).test.num2, {n: {n: 3}});

    xmlStr = string `<Root><test2><num><n><n>3</n></n></num><name><value1>SD</value1><value2>AB</value2></name><status><value1>Success</value1><value2>Fail</value2></status><num2><n><n>3</n></n></num2><age>13</age><salary>11.1</salary></test2><test><age>13</age><status><value1>Success</value1><value2>Fail</value2></status><salary>11.1</salary><name><value1>SD</value1><value2>AB</value2></name></test><a>2</a></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecord11_1'");
}

type XSDSequenceRecord12 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord12_1 seq_XSDSequenceRecord12_1;
};

type Seq_XSDSequenceRecord12_1 record {
    @SequenceOrder {value: 1}
    Seq_A field1;

    @SequenceOrder {value: 2}
    Seq_B field2;

    @SequenceOrder {value: 3}
    Seq_C field3;
};

type Seq_A record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq value1;
};

type Seq_B record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq value2;
};

type Seq_C record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq value3;
};

type Seq record {
    @SequenceOrder {value: 1}
    string a;

    @SequenceOrder {value: 2}
    string b;

    @SequenceOrder {value: 3}
    string c;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence12() returns error? {
    string xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><a>1</a><b>2</b><c>3</c></field2><field3><a>1</a><b>2</b><c>3</c></field3></Root>`;
    XSDSequenceRecord12|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {seq_XSDSequenceRecord12_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {a: "1", b: "2", c: "3"}}, field3: {value3: {a: "1", b: "2", c: "3"}}}});
}

type XSDSequenceRecord13 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord13_1 seq_XSDSequenceRecord13_1?;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord13_2 seq_XSDSequenceRecord13_2;
};

type Seq_XSDSequenceRecord13_1 record {
    @SequenceOrder {value: 1}
    Seq_A_13 field1;

    @SequenceOrder {value: 2}
    Seq_B_13 field2;

    @SequenceOrder {value: 3}
    Seq_C_13 field3;
};

type Seq_XSDSequenceRecord13_2 record {
    @SequenceOrder {value: 1}
    Seq_D_13 field4;

    @SequenceOrder {value: 2}
    Seq_E_13 field5;

    @SequenceOrder {value: 3}
    Seq_F_13 field6;
};

type Seq_A_13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_13 value1;
};

type Seq_B_13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq2_13 value2;
};

type Seq_C_13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq3_13 value3;
};

type Seq_D_13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_13 value1;
};

type Seq_E_13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq2_13 value2;
};

type Seq_F_13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq3_13 value3;
};

type Seq_13 record {
    @SequenceOrder {value: 1}
    string a;

    @SequenceOrder {value: 2}
    string b;

    @SequenceOrder {value: 3}
    string c;
};

type Seq2_13 record {
    @SequenceOrder {value: 1}
    string d;

    @SequenceOrder {value: 2}
    string e;

    @SequenceOrder {value: 3}
    string f;
};

type Seq3_13 record {
    @SequenceOrder {value: 1}
    string g;

    @SequenceOrder {value: 2}
    string h;

    @SequenceOrder {value: 3}
    string i;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequence13() returns error? {
    string xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDSequenceRecord13|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, <XSDSequenceRecord13>{seq_XSDSequenceRecord13_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {d: "1", e: "2", f: "3"}}, field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XSDSequenceRecord13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}});

    xmlStr = string `<Root><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, <XSDSequenceRecord13>{seq_XSDSequenceRecord13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}});

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><g>1</g><h>2</h><i>3</i><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'field6' is not found in 'seq_XSDSequenceRecord13_2'");

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><g>1</g><h>2</h><i>3</i><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'f' is not found in 'value2'");

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><i>3</i><h>2</h></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'i' is not in the correct order in 'value3'");

    xmlStr = string `<Root><field1><a>1</a><c>3</c><b>2</b></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'c' is not in the correct order in 'value1'");

    xmlStr = string `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field4><a>1</a><b>2</b><c>3</c></field4><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), ("Element 'field5' is not in the correct order in 'seq_XSDSequenceRecord13_2'"), msg = (<Error>v2).message());
}
