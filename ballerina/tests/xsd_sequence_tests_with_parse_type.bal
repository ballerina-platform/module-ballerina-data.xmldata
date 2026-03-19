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
function testXsdSequenceWithXmlValue() returns error? {
    xml xmlValue = xml `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecordWithXmlValue|Error v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValue: {age: 13, salary: 11.1}});
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue.age, 13);
    test:assertEquals((check v).seq_XSDSequenceRecordWithXmlValue.salary, 11.1);
    test:assertEquals(toXml(check v), xmlValue);
    Error? e = validate(xmlValue, XSDSequenceRecordWithXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error> e).message(), "Invalid XML found: 'Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue''");

    xmlValue = xml `<Root><age>13</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error> e).message(), "Invalid XML found: 'Element(s) 'salary' is not found in 'seq_XSDSequenceRecordWithXmlValue''");

    xmlValue = xml `<Root></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), ("required field 'seq_XSDSequenceRecordWithXmlValue' not present in XML"), msg = (<Error>v).message());
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error> e).message(), "Invalid XML found: 'required field 'seq_XSDSequenceRecordWithXmlValue' not present in XML'");

    xmlValue = xml `<Root><salary>11.1</salary><age>13</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error> e).message(), "Invalid XML found: 'Element 'salary' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue''");
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
function testXsdSequenceWithXmlValueP2() returns error? {
    xml xmlValue;
    XSDSequenceRecordWithXmlValueP2|Error v;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValueP2: {age: [13], salary: 11.1, name: ["ABC"]}});
    test:assertEquals(toXml(check v), xmlValue);

    xmlValue = xml `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XSDSequenceRecordWithXmlValueP2: {age: [13, 13, 13], salary: 11.1, name: ["ABC"]}});
    test:assertEquals(toXml(check v), xmlValue);

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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue6_2 record {|
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue7_2 record {|
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue8_2 record {|
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue9_2 record {|
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue10_2 record {|
    @SequenceOrder {
        value: 1
    }
    Rec10 name;

    @SequenceOrder {
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
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XSDSequenceRecordWithXmlValue11_2 record {|
    @SequenceOrder {
        value: 1
    }
    Rec11 name;

    @SequenceOrder {
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
    @SequenceOrder {value: 1}
    Seq_A field1;

    @SequenceOrder {value: 2}
    Seq_B field2;

    @SequenceOrder {value: 3}
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
    @SequenceOrder {value: 1}
    Seq_A_13 field1;

    @SequenceOrder {value: 2}
    Seq_B_13 field2;

    @SequenceOrder {value: 3}
    Seq_C_13 field3;
};

type Seq_XSDSequenceRecordWithXmlValue13_2 record {
    @SequenceOrder {value: 1}
    Seq_D_13 field4;

    @SequenceOrder {value: 2}
    Seq_E_13 field5;

    @SequenceOrder {value: 3}
    Seq_F_13 field6;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithXmlValue13() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDSequenceRecordWithXmlValue13|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, <XSDSequenceRecordWithXmlValue13>{seq_XSDSequenceRecordWithXmlValue13_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {d: "1", e: "2", f: "3"}}, field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XSDSequenceRecordWithXmlValue13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`);
    Error? e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, <XSDSequenceRecordWithXmlValue13>{seq_XSDSequenceRecordWithXmlValue13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}});
    test:assertEquals(toXml(check v2), xml `<Root><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`);
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><g>1</g><h>2</h><i>3</i><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'field6' is not found in 'seq_XSDSequenceRecordWithXmlValue13_2'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element(s) 'field6' is not found in 'seq_XSDSequenceRecordWithXmlValue13_2''");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><g>1</g><h>2</h><i>3</i><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'f' is not found in 'value2'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element(s) 'f' is not found in 'value2''");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><i>3</i><h>2</h></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'i' is not in the correct order in 'value3'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element 'i' is not in the correct order in 'value3''");

    xmlValue = xml `<Root><field1><a>1</a><c>3</c><b>2</b></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element 'c' is not in the correct order in 'value1'");
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element 'c' is not in the correct order in 'value1''");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field4><a>1</a><b>2</b><c>3</c></field4><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), ("Element 'field5' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue13_2'"), msg = (<Error>v2).message());
    e = validate(xmlValue, XSDSequenceRecordWithXmlValue13);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element 'field5' is not in the correct order in 'seq_XSDSequenceRecordWithXmlValue13_2''");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithArrayAndXmlValue record {|
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithArrayAndXmlValue seq?;
|};

type Seq_XSDSequenceRecordWithArrayAndXmlValue record {|
    @SequenceOrder {value: 1}
    string[] Source;
    @SequenceOrder {value: 2}
    string Dest;
|};

@test:Config {
    groups: ["xsd", "xsd_sequence"]
}
function testXsdSequenceWithArrayFieldAndXmlValue() returns error? {
    xml xmlValue = xml `<Root><Source>A</Source><Source>B</Source><Dest>Z</Dest></Root>`;
    XSDSequenceRecordWithArrayAndXmlValue|Error value = parseAsType(xmlValue);
    test:assertEquals(value, {seq: {Source: ["A", "B"], Dest: "Z"}});
    Error? response = validate(xmlValue, XSDSequenceRecordWithArrayAndXmlValue);
    test:assertTrue(response is ());

    xmlValue = xml `<Root><Source>A</Source><Dest>Z</Dest></Root>`;
    value = parseAsType(xmlValue);
    test:assertEquals(value, {seq: {Source: ["A"], Dest: "Z"}});
    response = validate(xmlValue, XSDSequenceRecordWithArrayAndXmlValue);
    test:assertTrue(response is ());

    xmlValue = xml `<Root><Dest>Z</Dest><Source>A</Source></Root>`;
    value = parseAsType(xmlValue);
    test:assertTrue(value is Error);
    test:assertEquals((<Error>value).message(), "Element 'Dest' is not in the correct order in 'seq'");
    response = validate(xmlValue, XSDSequenceRecordWithArrayAndXmlValue);
    test:assertTrue(response is Error);
    test:assertEquals((<Error>response).message(), "Invalid XML found: 'Element 'Dest' is not in the correct order in 'seq''");
}

@Name {
    value: "Root"
}
type XSDSequenceRecordWithUnboundedArrayAndXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithUnboundedArrayAndXmlValue seq;
|};

type Seq_XSDSequenceRecordWithUnboundedArrayAndXmlValue record {|
    @SequenceOrder {value: 1}
    string[] tags;
    @SequenceOrder {value: 2}
    string label;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithUnboundedArrayFieldAndXmlValue() returns error? {
    xml xmlValue = xml `<Root><tags>a</tags><label>end</label></Root>`;
    XSDSequenceRecordWithUnboundedArrayAndXmlValue|Error value = parseAsType(xmlValue);
    test:assertEquals(value, {seq: {tags: ["a"], label: "end"}});
    Error? response = validate(xmlValue, XSDSequenceRecordWithUnboundedArrayAndXmlValue);
    test:assertTrue(response is ());

    xmlValue = xml `<Root><tags>a</tags><tags>b</tags><tags>c</tags><tags>d</tags><tags>e</tags><label>end</label></Root>`;
    value = parseAsType(xmlValue);
    test:assertEquals(value, {seq: {tags: ["a", "b", "c", "d", "e"], label: "end"}});
    response = validate(xmlValue, XSDSequenceRecordWithUnboundedArrayAndXmlValue);
    test:assertTrue(response is ());

    xmlValue = xml `<Root><label>end</label><tags>a</tags></Root>`;
    value = parseAsType(xmlValue);
    test:assertTrue(value is Error);
    test:assertEquals((<Error>value).message(), "Element 'label' is not in the correct order in 'seq'");
    response = validate(xmlValue, XSDSequenceRecordWithUnboundedArrayAndXmlValue);
    test:assertTrue(response is Error);
    test:assertEquals((<Error>response).message(), "Invalid XML found: 'Element 'label' is not in the correct order in 'seq''");

    xmlValue = xml `<Root><tags>a</tags><tags>b</tags></Root>`;
    value = parseAsType(xmlValue);
    test:assertTrue(value is Error);
    test:assertEquals((<Error>value).message(), "Element(s) 'label' is not found in 'seq'");
    response = validate(xmlValue, XSDSequenceRecordWithUnboundedArrayAndXmlValue);
    test:assertTrue(response is Error);
    test:assertEquals((<Error>response).message(), "Invalid XML found: 'Element(s) 'label' is not found in 'seq''");
}

@Name {
    value: "Root"
}
type XSDNestedSequenceWithArrayInnerAndXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    OuterArraySeqXmlValue outerSeq;
|};

type OuterArraySeqXmlValue record {|
    @SequenceOrder {value: 1}
    string header;

    @SequenceOrder {value: 2}
    @Sequence {minOccurs: 1, maxOccurs: 1}
    OuterArraySeqInnerXmlValue innerSeq;
|};

type OuterArraySeqInnerXmlValue record {|
    @SequenceOrder {value: 1}
    string item;
    @SequenceOrder {value: 2}
    int count;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdNestedSequenceWithArrayInnerFieldAndXmlValue() returns error? {
    xml xmlValue = xml `<Root><header>h1</header><item>x</item><count>3</count></Root>`;
    XSDNestedSequenceWithArrayInnerAndXmlValue|Error value = parseAsType(xmlValue);
    test:assertFalse(value is Error, (value is Error) ? (<Error>value).message() : "");
    test:assertEquals(value, {outerSeq: {header: "h1", innerSeq: {item: "x", count: 3}}});
    Error? response = validate(xmlValue, XSDNestedSequenceWithArrayInnerAndXmlValue);
    test:assertTrue(response is ());

    xmlValue = xml `<Root><item>x</item><count>3</count><header>h1</header></Root>`;
    value = parseAsType(xmlValue);
    test:assertTrue(value is Error);
    response = validate(xmlValue, XSDNestedSequenceWithArrayInnerAndXmlValue);
    test:assertTrue(response is Error);

    xmlValue = xml `<Root><header>h1</header><count>3</count></Root>`;
    value = parseAsType(xmlValue);
    test:assertTrue(value is Error);
    response = validate(xmlValue, XSDNestedSequenceWithArrayInnerAndXmlValue);
    test:assertTrue(response is Error);
}

@Name {
    value: "Root"
}
type XSDSeqOptionalLeadingRequiredTrailingXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_OptionalLeadingRequiredTrailingXmlValue seq_optionalLeadingRequiredTrailing;
|};

type Seq_OptionalLeadingRequiredTrailingXmlValue record {|
    @SequenceOrder {value: 1}
    string optionalElem?;

    @SequenceOrder {value: 2}
    int requiredElem;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSeqOptionalLeadingRequiredTrailingXmlValue() returns error? {
    xml xmlValue;
    XSDSeqOptionalLeadingRequiredTrailingXmlValue|Error v;

    xmlValue = xml `<Root><optionalElem>hello</optionalElem><requiredElem>42</requiredElem></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {seq_optionalLeadingRequiredTrailing: {optionalElem: "hello", requiredElem: 42}});
    Error? e = validate(xmlValue, XSDSeqOptionalLeadingRequiredTrailingXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><requiredElem>42</requiredElem></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {seq_optionalLeadingRequiredTrailing: {requiredElem: 42}});
    e = validate(xmlValue, XSDSeqOptionalLeadingRequiredTrailingXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><optionalElem>hello</optionalElem></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'requiredElem' is not found in 'seq_optionalLeadingRequiredTrailing'");
    e = validate(xmlValue, XSDSeqOptionalLeadingRequiredTrailingXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element(s) 'requiredElem' is not found in 'seq_optionalLeadingRequiredTrailing''");
}

@Name {
    value: "Root"
}
type XSDNestedSeqWithRecordArrayAndXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    OuterSeqRecordArrayXmlValue outerSeqRecordArray;
|};

type OuterSeqRecordArrayXmlValue record {|
    @SequenceOrder {value: 1}
    string header;

    @SequenceOrder {value: 2}
    @Sequence {minOccurs: 1, maxOccurs: 2}
    InnerSeqRecordArrayXmlValue[] innerSeqs;
|};

type InnerSeqRecordArrayXmlValue record {|
    @SequenceOrder {value: 1}
    string item;

    @SequenceOrder {value: 2}
    int count;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdNestedSeqWithRecordArrayAndXmlValue() returns error? {
    xml xmlValue;
    XSDNestedSeqWithRecordArrayAndXmlValue|Error v;

    xmlValue = xml `<Root><header>h1</header><item>x</item><count>3</count></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {outerSeqRecordArray: {header: "h1", innerSeqs: [{item: "x", count: 3}]}});
    Error? e = validate(xmlValue, XSDNestedSeqWithRecordArrayAndXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><header>h1</header><item>x</item><count>3</count><item>y</item><count>4</count></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {outerSeqRecordArray: {header: "h1", innerSeqs: [{item: "x", count: 3}, {item: "y", count: 4}]}});
    e = validate(xmlValue, XSDNestedSeqWithRecordArrayAndXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><header>h1</header><item>x</item><count>3</count><item>y</item><count>4</count><item>z</item><count>5</count></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'innerSeqs' occurs more than the max allowed times");
    e = validate(xmlValue, XSDNestedSeqWithRecordArrayAndXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: ''innerSeqs' occurs more than the max allowed times'");

    xmlValue = xml `<Root><header>h1</header></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    e = validate(xmlValue, XSDNestedSeqWithRecordArrayAndXmlValue);
    test:assertTrue(e is Error);
}

@Name {
    value: "Root"
}
type XSDThreeLevelNestedSeqXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Level1SeqXmlValue level1Seq;
|};

type Level1SeqXmlValue record {|
    @SequenceOrder {value: 1}
    string level1Field;

    @SequenceOrder {value: 2}
    @Sequence {minOccurs: 1, maxOccurs: 1}
    Level2SeqXmlValue level2Seq;
|};

type Level2SeqXmlValue record {|
    @SequenceOrder {value: 1}
    string level2Field;

    @SequenceOrder {value: 2}
    @Sequence {minOccurs: 1, maxOccurs: 1}
    Level3SeqXmlValue level3Seq;
|};

type Level3SeqXmlValue record {|
    @SequenceOrder {value: 1}
    string level3Field;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdThreeLevelNestedSeqAndXmlValue() returns error? {
    xml xmlValue;
    XSDThreeLevelNestedSeqXmlValue|Error v;

    xmlValue = xml `<Root><level1Field>a</level1Field><level2Field>b</level2Field><level3Field>c</level3Field></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {level1Seq: {level1Field: "a", level2Seq: {level2Field: "b", level3Seq: {level3Field: "c"}}}});
    Error? e = validate(xmlValue, XSDThreeLevelNestedSeqXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><level2Field>b</level2Field><level1Field>a</level1Field><level3Field>c</level3Field></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    e = validate(xmlValue, XSDThreeLevelNestedSeqXmlValue);
    test:assertTrue(e is Error);

    xmlValue = xml `<Root><level1Field>a</level1Field><level2Field>b</level2Field></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message() == "Element(s) 'level3Field' is not found in 'level3Seq'" ||
        (<Error>v).message() == "Element(s) 'level3Seq' is not found in 'level2Seq'");
    e = validate(xmlValue, XSDThreeLevelNestedSeqXmlValue);
    test:assertTrue(e is Error);
    test:assertTrue((<Error>e).message() == "Invalid XML found: 'Element(s) 'level3Field' is not found in 'level3Seq''" ||
        (<Error>e).message() == "Invalid XML found: 'Element(s) 'level3Seq' is not found in 'level2Seq''");

    xmlValue = xml `<Root><level1Field>a</level1Field><level3Field>c</level3Field></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    e = validate(xmlValue, XSDThreeLevelNestedSeqXmlValue);
    test:assertTrue(e is Error);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element(s) 'level2Field' is not found in 'level2Seq''");
}

type XSDSeqWithSharedElementNameXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    SeqWithSharedNameXmlValue seqMain;
|};

type SeqWithSharedNameXmlValue record {|
    @SequenceOrder {value: 1}
    string id;

    @Sequence {minOccurs: 1, maxOccurs: 1}
    @SequenceOrder {value: 2}
    SharedNameNestedXmlValue nested;
|};

type SharedNameNestedXmlValue record {|
    @SequenceOrder {value: 1}
    string name;

    @SequenceOrder {value: 2}
    string id;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSeqWithSharedElementNameAndXmlValue() returns error? {
    xml xmlValue;
    XSDSeqWithSharedElementNameXmlValue|Error v;

    xmlValue = xml `<Root><id>parent-id</id><name>some-name</name><id>nested-id</id></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {seqMain: {id: "parent-id", nested: {name: "some-name", id: "nested-id"}}});
    Error? e = validate(xmlValue, XSDSeqWithSharedElementNameXmlValue);
    test:assertTrue(e is ());

    xmlValue = xml `<Root><name>some-name</name><id>nested-id</id><id>parent-id</id></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    e = validate(xmlValue, XSDSeqWithSharedElementNameXmlValue);
    test:assertTrue(e is Error);

    xmlValue = xml `<Root><id>parent-id</id><name>some-name</name></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    e = validate(xmlValue, XSDSeqWithSharedElementNameXmlValue);
    test:assertTrue(e is Error);
}

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testErrorInXsdSeqWithSharedElementNameAndXmlValue() returns error? {
    xml xmlValue;
    XSDSeqWithSharedElementNameXmlValue|Error v;

    xmlValue = xml `<Root><age>12</age><id>parent-id</id><name>some-name</name><id>nested-id</id></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
}

@Name {value: "Root"}
type XSDSeqWithNestedChoiceXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    SeqWithNestedChoiceXmlValue seq_with_choice;
|};

type SeqWithNestedChoiceXmlValue record {|
    @SequenceOrder {value: 1}
    string before;

    @SequenceOrder {value: 2}
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    ChoiceInSeqXmlValue choice_in_seq;

    @SequenceOrder {value: 3}
    string after;
|};

type ChoiceInSeqXmlValue record {|
    int p?;
    string q?;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSeqWithNestedChoiceXmlValue() returns error? {
    xml xmlValue;
    XSDSeqWithNestedChoiceXmlValue|Error v;

    xmlValue = xml `<Root><before>start</before><p>1</p><after>end</after></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {seq_with_choice: {before: "start", choice_in_seq: {p: 1}, after: "end"}});
    Error? e = validate(xmlValue, XSDSeqWithNestedChoiceXmlValue);
    test:assertEquals(e, ());

    xmlValue = xml `<Root><before>start</before><q>hello</q><after>end</after></Root>`;
    v = parseAsType(xmlValue);
    test:assertFalse(v is Error, (v is Error) ? (<Error>v).message() : "");
    test:assertEquals(v, {seq_with_choice: {before: "start", choice_in_seq: {q: "hello"}, after: "end"}});
    e = validate(xmlValue, XSDSeqWithNestedChoiceXmlValue);
    test:assertEquals(e, ());

    xmlValue = xml `<Root><before>start</before><p>1</p><q>hello</q><after>end</after></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'choice_in_seq' occurs more than the max allowed times");
    e = validate(xmlValue, XSDSeqWithNestedChoiceXmlValue);
    test:assertEquals((<Error>e).message(), "Invalid XML found: ''choice_in_seq' occurs more than the max allowed times'");

    xmlValue = xml `<Root><before>start</before><after>end</after></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "Element(s) 'choice_in_seq' is not found in 'seq_with_choice'");
    e = validate(xmlValue, XSDSeqWithNestedChoiceXmlValue);
    test:assertEquals((<Error>e).message(), "Invalid XML found: 'Element(s) 'choice_in_seq' is not found in 'seq_with_choice''");
}
