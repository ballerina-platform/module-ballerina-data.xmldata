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

    xmlStr = string `<Root><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord: {age: 13}});

    xmlStr = string `<Root><salary>13.5</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord: {salary: 13.5}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecord Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><salary>11.1</salary><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecord Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecord Element occurs less than the min required times"), (<Error>v).message());
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

    xmlStr = string `<Root><age>13</age></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceP1Record: {age: 13}});

    xmlStr = string `<Root><salary>13.5</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceP1Record: {salary: 13.5}});

    xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceP1Record Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><salary>11.1</salary><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceP1Record Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {});
}

@test:Config {groups: ["xsd", "xsd_Choice"]}
function testXsdChoiceP2() returns error? {
    string xmlStr = string `<Root><age>13</age></Root>`;
    XSDChoiceRecordP2|Error v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecordP2: {age: [13]}});

    xmlStr = string `<Root><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecordP2: {name: ["ABC"]}});

    xmlStr = string `<Root><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecordP2: {salary: 11.1}});

    xmlStr = string `<Root><age>13</age><age>13</age><age>13</age><salary>11.1</salary><name>ABC</name></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecordP2 Element occurs more than the max allowed times"), msg = (<Error>v).message());

    xmlStr = string `<Root><age>13</age><name>ABC</name><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecordP2 Element occurs more than the max allowed times"), msg = (<Error>v).message());
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
    string xmlStr = string `<Root><num>3</num><age>13</age></Root>`;
    XSDChoiceRecord2|Error v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord2: {age: 13}, num: 3});
    test:assertEquals((check v).choice_XSDChoiceRecord2.age, 13);
    test:assertEquals((check v).num, 3);

    xmlStr = string `<Root><salary>11.1</salary><num>3</num></Root>`;
    v = parseString(xmlStr);
    test:assertEquals(v, {choice_XSDChoiceRecord2: {salary: 11.1}, num: 3});
    test:assertEquals((check v).choice_XSDChoiceRecord2.salary, 11.1);
    test:assertEquals((check v).num, 3);

    xmlStr = string `<Root><salary>11.1</salary><age>13</age><num>3</num></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecord2 Element occurs more than the max allowed times"), (<Error>v).message());

    xmlStr = string `<Root><age>13</age><num>3</num><salary>11.1</salary></Root>`;
    v = parseString(xmlStr);
    test:assertTrue(v is Error);
    test:assertTrue((<Error>v).message().includes("choice_XSDChoiceRecord2 Element occurs more than the max allowed times"), (<Error>v).message());
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
    string xmlStr = string `<Root><num><n>3</n></num><age>13</age></Root>`;
    XSDChoiceRecord3|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord3: {age: 13}, num: {n: 3}});
    test:assertEquals((check v2).choice_XSDChoiceRecord3.age, 13);
    test:assertEquals((check v2).num, {n: 3});

    xmlStr = string `<Root><salary>11.1</salary><num><n>3</n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord3: {salary: 11.1}, num: {n: 3}});

    xmlStr = string `<Root><age>13</age><num><n>3</n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceRecord3 Element occurs more than the max allowed times"));

    xmlStr = string `<Root><num><n>3</n></num><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceRecord3 Element occurs more than the max allowed times"));
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
    string xmlStr = string `<Root><num><n><n>3</n></n></num><age>13</age></Root>`;
    XSDChoiceRecord4|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord4: {age: 13}, num: {n: {n: 3}}});
    test:assertEquals((check v2).choice_XSDChoiceRecord4.age, 13);
    test:assertEquals((check v2).num, {n: {n: 3}});

    xmlStr = string `<Root><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord4: {salary: 11.1}, num: {n: {n: 3}}});

    xmlStr = string `<Root><age>13</age><num><n><n>3</n></n></num><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceRecord4 Element occurs more than the max allowed times"));

    xmlStr = string `<Root><num><n><n>3</n></n></num><age>13</age><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceRecord4 Element occurs more than the max allowed times"));
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
    string xmlStr = string `<Root><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><age>13</age></Root>`;
    XSDChoiceRecord5|Error v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord5: {age: 13}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlStr = string `<Root><num2><n><n>3</n></n></num2><salary>11.1</salary><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord5: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlStr = string `<Root><salary>11.1</salary><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2></Root>`;
    v2 = parseString(xmlStr);
    test:assertEquals(v2, {choice_XSDChoiceRecord5: {salary: 11.1}, num: {n: {n: 3}}, num2: {n: {n: 3}}});

    xmlStr = string `<Root><age>13</age><num><n><n>3</n></n></num><num2><n><n>3</n></n></num2><salary>11.1</salary></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceRecord5 Element occurs more than the max allowed times"), (<Error>v2).message());

    xmlStr = string `<Root><num2><num><n><n>3</n></n></num2><num><n><n>3</n></n></num></Root>`;
    v2 = parseString(xmlStr);
    test:assertTrue(v2 is Error);
    test:assertTrue((<Error>v2).message().includes("choice_XSDChoiceRecord5 Element occurs less than the min required times"), (<Error>v2).message());
}
