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
