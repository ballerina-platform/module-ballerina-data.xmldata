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
type XsdSequenceArrayWithXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    Seq_XsdSequenceArrayWithXmlValue[] seq_XsdSequenceArrayWithXmlValue;
|};

type Seq_XsdSequenceArrayWithXmlValue record {|
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
function testXsdSequenceArrayWithXmlValue() returns error? {
    xml xmlValue;
    XsdSequenceArrayWithXmlValue|Error v;
    xml|Error toXmlresult;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XsdSequenceArrayWithXmlValue: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}]});
    test:assertEquals(toXml(check v), xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary></Root>`);

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'seq_XsdSequenceArrayWithXmlValue' occurs more than the max allowed times");
    toXmlresult = toXml(<XsdSequenceArrayWithXmlValue>{seq_XsdSequenceArrayWithXmlValue: [{age: 13, salary: 11.1}, {age: 14, salary: 14.1}, {age: 15, salary: 15.1}]});
    test:assertTrue(toXmlresult is error);
    test:assertEquals((<Error>toXmlresult).message(), "'seq_XsdSequenceArrayWithXmlValue' occurs more than the max allowed times");

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "Element(s) 'salary' is not found in 'seq_XsdSequenceArrayWithXmlValue'");

    xmlValue = xml `<Root><age>13</age><age>14</age><salary>15.1</salary><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'age' occurs more than the max allowed times in 'seq_XsdSequenceArrayWithXmlValue'");
}

@Name {
    value: "Root"
}
type XsdSequenceArrayWithXmlValue2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    Seq_XsdSequenceArrayWithXmlValue2[] seq_XsdSequenceArrayWithXmlValue2;

    @Sequence {
        minOccurs: 0,
        maxOccurs: 2
    }
    Seq_XsdSequenceArrayWithXmlValue2_2[] seq_XsdSequenceArrayWithXmlValue2_2 = [];
|};

type Seq_XsdSequenceArrayWithXmlValue2 record {|
    @SequenceOrder {
        value: 1
    }
    int age;

    @SequenceOrder {
        value: 2
    }
    float salary;
|};

type Seq_XsdSequenceArrayWithXmlValue2_2 record {|
    @SequenceOrder {
        value: 1
    }
    int age2;

    @SequenceOrder {
        value: 2
    }
    float salary2;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceArrayWithXmlValue2() returns error? {
    xml xmlValue;
    XsdSequenceArrayWithXmlValue2|Error v;
    xml|Error toXmlresult;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XsdSequenceArrayWithXmlValue2: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}], seq_XsdSequenceArrayWithXmlValue2_2: [{age2: 13, salary2: 11.1}, {age2: 14, salary2: 15.1}]});
    test:assertEquals(toXml(check v), xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`);

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'seq_XsdSequenceArrayWithXmlValue2' occurs more than the max allowed times");
    toXmlresult = toXml(<XsdSequenceArrayWithXmlValue2>{seq_XsdSequenceArrayWithXmlValue2: [{age: 13, salary: 11.1}, {age: 13, salary: 11.1}, {age: 14, salary: 15.1}], seq_XsdSequenceArrayWithXmlValue2_2: [{age2: 13, salary2: 11.1}, {age2: 14, salary2: 15.1}]});
    test:assertTrue(toXmlresult is error);
    test:assertEquals((<Error>toXmlresult).message(), "'seq_XsdSequenceArrayWithXmlValue2' occurs more than the max allowed times");

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertEquals((<Error>v).message(), "'seq_XsdSequenceArrayWithXmlValue2_2' occurs more than the max allowed times");
    toXmlresult = toXml(<XsdSequenceArrayWithXmlValue2>{seq_XsdSequenceArrayWithXmlValue2: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}], seq_XsdSequenceArrayWithXmlValue2_2: [{age2: 13, salary2: 11.1}, {age2: 13, salary2: 11.1}, {age2: 14, salary2: 15.1}]});
    test:assertTrue(toXmlresult is error);
    test:assertEquals((<Error>toXmlresult).message(), "'seq_XsdSequenceArrayWithXmlValue2_2' occurs more than the max allowed times");
}

@Name {
    value: "Root"
}
type XSDSequenceArrayWithXmlValueRecord13 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 3
    }
    Seq_XSDSequenceArrayWithXmlValueRecord13_1[] seq_XSDSequenceArrayWithXmlValueRecord13_1;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 3
    }
    Seq_XSDSequenceArrayWithXmlValueRecord13_2[] seq_XSDSequenceArrayWithXmlValueRecord13_2;
};

type Seq_XSDSequenceArrayWithXmlValueRecord13_1 record {
    @SequenceOrder {value: 1}
    Seq_Array_A_3 field1;

    @SequenceOrder {value: 2}
    Seq_Array_B_3 field2;

    @SequenceOrder {value: 3}
    Seq_Array_C_3 field3;
};

type Seq_XSDSequenceArrayWithXmlValueRecord13_2 record {
    @SequenceOrder {value: 1}
    Seq_Array_D_3 field4;

    @SequenceOrder {value: 2}
    Seq_Array_E_3 field5;

    @SequenceOrder {value: 3}
    Seq__Array_F_3 field6;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXSDSequenceArrayWithXmlValueRecord4() returns error? {
    xml|Error toXmlresult;

    xml xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDSequenceArrayWithXmlValueRecord13|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}]});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`);

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}, {field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}, {field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}]});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`);

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}, {a: "1", b: "2", c: "3"}, {a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}, {d: "1", e: "2", f: "3"}, {d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}, {g: "1", h: "2", i: "3"}, {g: "1", h: "2", i: "3"}]}}]});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i></field6></Root>`);

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'seq_XSDSequenceArrayWithXmlValueRecord13_2' occurs more than the max allowed times");
    toXmlresult = toXml(<XSDSequenceArrayWithXmlValueRecord13>{seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}, {field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}, {field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}, {d: "1", e: "2", f: "3"}, {d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}, {g: "1", h: "2", i: "3"}, {g: "1", h: "2", i: "3"}]}}]});
    test:assertTrue(toXmlresult is error);
    test:assertEquals((<Error>toXmlresult).message(), "'seq_XSDSequenceArrayWithXmlValueRecord13_2' occurs more than the max allowed times");

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "'value3' occurs more than the max allowed times");
}

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXSDSequenceArrayWithXmlValueRecord4P2() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><g>1</g><h>2</h><i>3</i><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDSequenceArrayWithXmlValueRecord13|Error v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertEquals((<Error>v2).message(), "Element(s) 'field6' is not found in 'seq_XSDSequenceArrayWithXmlValueRecord13_2'");

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
    test:assertEquals((<Error>v2).message(), "Element 'field5' is not in the correct order in 'seq_XSDSequenceArrayWithXmlValueRecord13_2'");
}

type XsdSequenceArrayWithXmlValue5 record {|
    @Sequence {
        minOccurs: 2,
        maxOccurs: 3
    }
    Seq_XsdSequenceArrayWithXmlValue5[] seq_XsdSequenceArrayWithXmlValue5;
|};

type Seq_XsdSequenceArrayWithXmlValue5 record {|
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
function testXsdSequenceArrayWithXmlValue5() returns error? {
    xml xmlValue;
    XsdSequenceArrayWithXmlValue5|Error v;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XsdSequenceArrayWithXmlValue5: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}]});
    test:assertEquals(toXml(check v), xml `<XsdSequenceArrayWithXmlValue5><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary></XsdSequenceArrayWithXmlValue5>`);

    xmlValue = xml `<XsdSequenceArrayWithXmlValue5><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary></XsdSequenceArrayWithXmlValue5>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, <XsdSequenceArrayWithXmlValue5>{seq_XsdSequenceArrayWithXmlValue5: [{age: 13, salary: 11.1}, {age: 14, salary: 14.1}, {age: 15, salary: 15.1}]});
    test:assertEquals(toXml(check v), xml `<XsdSequenceArrayWithXmlValue5><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary></XsdSequenceArrayWithXmlValue5>`);

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'seq_XsdSequenceArrayWithXmlValue5' occurs more than the max allowed times");

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertEquals((<Error>v).message(), "'seq_XsdSequenceArrayWithXmlValue5' occurs less than the min required times");
    xml|Error toXmlresult = toXml(<XsdSequenceArrayWithXmlValue5>{seq_XsdSequenceArrayWithXmlValue5: [{age: 13, salary: 11.1}]});
    test:assertTrue(toXmlresult is error);
    test:assertEquals((<Error>toXmlresult).message(), "'seq_XsdSequenceArrayWithXmlValue5' occurs less than the min required times");
}

@Name {
    value: "Root"
}
type XSDSequenceArrayWithXmlValueRecord6 record {
    @Sequence {
        minOccurs: 2,
        maxOccurs: 3
    }
    Seq_XSDSequenceArrayWithXmlValueRecord6_1[] seq_XSDSequenceArrayWithXmlValueRecord6_1;

    @Sequence {
        minOccurs: 2,
        maxOccurs: 3
    }
    Seq_XSDSequenceArrayWithXmlValueRecord6_2[] seq_XSDSequenceArrayWithXmlValueRecord6_2;
};

type Seq_XSDSequenceArrayWithXmlValueRecord6_1 record {
    @SequenceOrder {value: 1}
    Seq_Array_A_6 field1;

    @SequenceOrder {value: 2}
    Seq_Array_B_6 field2;
};

type Seq_XSDSequenceArrayWithXmlValueRecord6_2 record {
    @SequenceOrder {value: 1}
    Seq_Array_D_6 field4;

    @SequenceOrder {value: 2}
    Seq_Array_E_6 field5;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXSDSequenceArrayWithXmlValueRecord6() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a><a>2</a></field1><field2><d>1</d><d>1</d></field2><field1><a>1</a><a>1</a></field1><field2><d>1</d><d>1</d></field2><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5></Root>`;
    XSDSequenceArrayWithXmlValueRecord6|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {"seq_XSDSequenceArrayWithXmlValueRecord6_1":[{"field1":{"value1":[{"a":"1"},{"a":"2"}]},"field2":{"value2":[{"d":"1"},{"d":"1"}]}},{"field1":{"value1":[{"a":"1"},{"a":"1"}]},"field2":{"value2":[{"d":"1"},{"d":"1"}]}}],"seq_XSDSequenceArrayWithXmlValueRecord6_2":[{"field4":{"value1":[{"a":"1"},{"a":"1"}]},"field5":{"value2":[{"d":"1"},{"d":"1"}]}},{"field4":{"value1":[{"a":"1"},{"a":"1"}]},"field5":{"value2":[{"d":"1"},{"d":"1"}]}}]});
    test:assertEquals(toXml(check v2), xml `<Root><field1><a>1</a><a>2</a></field1><field2><d>1</d><d>1</d></field2><field1><a>1</a><a>1</a></field1><field2><d>1</d><d>1</d></field2><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5></Root>`);
}
