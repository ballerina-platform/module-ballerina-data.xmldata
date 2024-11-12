import ballerina/test;

type ElementRecordWithXmlValue record {
    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    string name?;

    @Element {
        maxOccurs: 1,
        minOccurs: 0
    }
    int age?;
};

@test:Config{groups: ["xsd", "xsd_element"]}
function testXsdElementWithXmlValue() returns error? {
    xml xmlStr = xml `<Root><name>John</name><age>25</age></Root>`;
    ElementRecordWithXmlValue|Error rec = parseAsType(xmlStr);
    test:assertEquals(rec, {name: "John", age: 25});

    xmlStr = xml `<Root><name>John</name></Root>`;
    rec = parseAsType(xmlStr);
    test:assertEquals(rec, {name: "John"});
}

type ElementRecordWithXmlValue2 record {
    @Element {
        maxOccurs: 10,
        minOccurs: 0
    }
    string[] name?;

    @Element {
        maxOccurs: 3,
        minOccurs: 1
    }
    int[] age?;
};

@test:Config{groups: ["xsd", "xsd_element"]}
function testXsdElementWithXmlValue2() returns error? {
    xml xmlStr = xml `<Root><name>John</name><age>25</age></Root>`;
    ElementRecordWithXmlValue2|Error rec = parseAsType(xmlStr);
    test:assertEquals(rec, {name: ["John"], age: [25]});

    xmlStr = xml `<Root><name>John</name></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs less than the min required times"));

    xmlStr = xml `<Root><age>25</age></Root>`;
    rec = parseAsType(xmlStr);
    test:assertEquals(rec, {age: [25]});

    xmlStr = xml `<Root><age>11</age><age>12</age><age>13</age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = xml `<Root><age>11</age><name>Abc</name><age>12</age><age>13</age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = xml `<Root><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><age>11</age><age>12</age><age>13</age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = xml `<Root><age>11</age><name>Abc</name><name>Abc</name><age>12</age><name>Abc</name><age>13<name>Abc</name></age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));
}

type ElementRecordWithXmlValue3 record {
    record {
        @Element {
            maxOccurs: 10,
            minOccurs: 0
        }
        string[] name?;

        @Element {
            maxOccurs: 3,
            minOccurs: 1
        }
        int[] age?;

        @Element {
            maxOccurs: 3,
            minOccurs: 2
        }
        int[] id?;
    } user;
    
    @Element {
        maxOccurs: 1,
        minOccurs: 1
    }
    int status;
};

@test:Config{groups: ["xsd", "xsd_element"]}
function testXsdElementWithXmlValue3() returns error? {
    xml xmlStr;
    ElementRecordWithXmlValue3|Error rec;

    xmlStr = xml `<Root><user><name>John</name><id>1</id><id>2</id><age>35</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertEquals(rec, {user: {name: ["John"], age: [35], id: [1, 2]}, status: 3});

    xmlStr = xml `<Root><user><name>John</name><id>1</id><id>2</id></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs less than the min required times"), (<Error>rec).message());

    xmlStr = xml `<Root><user><id>1</id><id>2</id><age>35</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertEquals(rec, {user: {age: [35], id: [1, 2]}, status: 3});

    xmlStr = xml `<Root><user><id>1</id><id>2</id><age>11</age><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = xml `<Root><user><id>1</id><id>2</id><age>11</age><name>Abc</name><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"), (<Error>rec).message());

    xmlStr = xml `<Root><user><id>1</id><id>2</id><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><age>11</age><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"), (<Error>rec).message());

    xmlStr = xml `<Root><user><id>1</id><id>2</id><age>11</age><name>Abc</name><name>Abc</name><age>13</age><name>Abc</name><age>13<name>Abc</name></age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"), (<Error>rec).message());
}

type ElementRecordWithXmlValue4 record {
    @Element {
        maxOccurs: 3,
        minOccurs: 2
    }
    record {
        @Element {
            maxOccurs: 4,
            minOccurs: 3
        }
        string[] firstName;

        @Element {
            maxOccurs: 3,
            minOccurs: 3
        }
        string[] lastName;
    }[] name;
    
    @Element {
        maxOccurs: 4,
        minOccurs: 3
    }
    int[] status;

    @Element {
        maxOccurs: 3,
        minOccurs: 3
    }
    int[] age;
};

@test:Config{groups: ["xsd", "xsd_element"]}
function testXsdElementWithXmlValue4() returns error? {
    xml xmlStr = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    ElementRecordWithXmlValue4|Error rec = parseAsType(xmlStr);
    test:assertEquals(rec, {name: [{firstName: ["John", "Jane", "Jim"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3], age: [20, 25, 30]});

    xmlStr = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlStr);
    test:assertEquals(rec, {name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});

    xmlStr = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("name Element occurs less than the min required times"));

    xmlStr = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("name Element occurs more than the max allowed times"));

    xmlStr = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("lastName Element occurs more than the max allowed times"));

    xmlStr = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("firstName Element occurs more than the max allowed times"), (<Error>rec).message());
}