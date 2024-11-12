import ballerina/test;

type XsdSequenceArrayWithXmlValue record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    Seq_XsdSequenceArrayWithXmlValue[] seq_XsdSequenceArrayWithXmlValue;
|};

type Seq_XsdSequenceArrayWithXmlValue record {|
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
function testXsdSequenceArrayWithXmlValue() returns error? {
    xml xmlValue;
    XsdSequenceArrayWithXmlValue|Error v;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XsdSequenceArrayWithXmlValue: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}]});

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertTrue((<Error>v).message().includes("seq_XsdSequenceArrayWithXmlValue Element occurs more than the max allowed times"));
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
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

type Seq_XsdSequenceArrayWithXmlValue2_2 record {|
    @Order {
        value: 1
    }
    int age2;

    @Order {
        value: 2
    }
    float salary2;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceArrayWithXmlValue2() returns error? {
    xml xmlValue;
    XsdSequenceArrayWithXmlValue2|Error v;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XsdSequenceArrayWithXmlValue2: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}], seq_XsdSequenceArrayWithXmlValue2_2: [{age2: 13, salary2: 11.1}, {age2: 14, salary2: 15.1}]});

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertTrue((<Error>v).message().includes("seq_XsdSequenceArrayWithXmlValue2 Element occurs more than the max allowed times"));

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary><age2>13</age2><salary2>11.1</salary2><age2>13</age2><salary2>11.1</salary2><age2>14</age2><salary2>15.1</salary2></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is error);
    test:assertTrue((<Error>v).message().includes("seq_XsdSequenceArrayWithXmlValue2_2 Element occurs more than the max allowed times"));
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
    @Order {value: 1}
    Seq_Array_A_3 field1;

    @Order {value: 2}
    Seq_Array_B_3 field2;

    @Order {value: 3}
    Seq_Array_C_3 field3;
};

type Seq_XSDSequenceArrayWithXmlValueRecord13_2 record {
    @Order {value: 1}
    Seq_Array_D_3 field4;

    @Order {value: 2}
    Seq_Array_E_3 field5;

    @Order {value: 3}
    Seq__Array_F_3 field6;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXSDSequenceArrayWithXmlValueRecord4() returns error? {
    xml xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    XSDSequenceArrayWithXmlValueRecord13|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}]});

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}, {field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}, {field1: {value1: [{a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}, {field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}]}}]});

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {seq_XSDSequenceArrayWithXmlValueRecord13_1: [{field1: {value1: [{a: "1", b: "2", c: "3"}, {a: "1", b: "2", c: "3"}, {a: "1", b: "2", c: "3"}]}, field2: {value2: [{d: "1", e: "2", f: "3"}]}, field3: {value3: [{g: "1", h: "2", i: "3"}]}}], seq_XSDSequenceArrayWithXmlValueRecord13_2: [{field4: {value1: [{a: "1", b: "2", c: "3"}]}, field5: {value2: [{d: "1", e: "2", f: "3"}, {d: "1", e: "2", f: "3"}, {d: "1", e: "2", f: "3"}]}, field6: {value3: [{g: "1", h: "2", i: "3"}, {g: "1", h: "2", i: "3"}, {g: "1", h: "2", i: "3"}]}}]});

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("seq_XSDSequenceArrayWithXmlValueRecord13_2 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("value3 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><g>1</g><h>2</h><i>3</i><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element field6 not found in"), (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><g>1</g><h>2</h><i>3</i><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element f not found in"), (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><i>3</i><h>2</h></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element i is not in the correct order in"), msg = (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a><c>3</c><b>2</b></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element c is not in the correct order in"), msg = (<Error>v2).message());

    xmlValue = xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field5><d>1</d><e>2</e><f>3</f></field5><field4><a>1</a><b>2</b><c>3</c></field4><field6><g>1</g><h>2</h><i>3</i></field6></Root>`;
    v2 = parseAsType(xmlValue);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("Element field5 is not in the correct order in"), msg = (<Error>v2).message());
}

type XsdSequenceArrayWithXmlValue5 record {|
    @Sequence {
        minOccurs: 2,
        maxOccurs: 3
    }
    Seq_XsdSequenceArrayWithXmlValue5[] seq_XsdSequenceArrayWithXmlValue5;
|};

type Seq_XsdSequenceArrayWithXmlValue5 record {|
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
function testXsdSequenceArrayWithXmlValue5() returns error? {
    xml xmlValue;
    XsdSequenceArrayWithXmlValue5|Error v;

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, {seq_XsdSequenceArrayWithXmlValue5: [{age: 13, salary: 11.1}, {age: 14, salary: 15.1}]});

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertEquals(v, <XsdSequenceArrayWithXmlValue5>{seq_XsdSequenceArrayWithXmlValue5: [{age: 13, salary: 11.1}, {age: 14, salary: 14.1}, {age: 15, salary: 15.1}]});

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary><age>14</age><salary>14.1</salary><age>15</age><salary>15.1</salary><age>15</age><salary>15.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("seq_XsdSequenceArrayWithXmlValue5 Element occurs more than the max allowed times"), msg = (<Error>v).message());

    xmlValue = xml `<Root><age>13</age><salary>11.1</salary></Root>`;
    v = parseAsType(xmlValue);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("seq_XsdSequenceArrayWithXmlValue5 Element occurs less than the min required times"), msg = (<Error>v).message());
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
    @Order {value: 1}
    Seq_Array_A_6 field1;

    @Order {value: 2}
    Seq_Array_B_6 field2;
};

type Seq_XSDSequenceArrayWithXmlValueRecord6_2 record {
    @Order {value: 1}
    Seq_Array_D_6 field4;

    @Order {value: 2}
    Seq_Array_E_6 field5;
};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXSDSequenceArrayWithXmlValueRecord6() returns error? {
    // TODO: Refactor sequence elements into a array
    xml xmlValue = xml `<Root><field1><a>1</a><a>1</a></field1><field2><d>1</d><d>1</d></field2><field1><a>1</a><a>1</a></field1><field2><d>1</d><d>1</d></field2><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5><field4><a>1</a><a>1</a></field4><field5><d>1</d><d>1</d></field5></Root>`;
    XSDSequenceArrayWithXmlValueRecord6|Error v2 = parseAsType(xmlValue);
    test:assertEquals(v2, {"seq_XSDSequenceArrayWithXmlValueRecord6_1":[{"field1":{"value1":[{"a":"1"},{"a":"1"}]},"field2":{"value2":[{"d":"1"},{"d":"1"}]}},{"field1":{"value1":[{"a":"1"},{"a":"1"}]},"field2":{"value2":[{"d":"1"},{"d":"1"}]}}],"seq_XSDSequenceArrayWithXmlValueRecord6_2":[{"field4":{"value1":[{"a":"1"},{"a":"1"}]},"field5":{"value2":[{"d":"1"},{"d":"1"}]}},{"field4":{"value1":[{"a":"1"},{"a":"1"}]},"field5":{"value2":[{"d":"1"},{"d":"1"}]}}]});
}
