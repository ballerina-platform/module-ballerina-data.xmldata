import ballerina/test;

type ElementRecord record {
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
function testXsdElement() returns error? {
    string xmlStr = "<Root><name>John</name><age>25</age></Root>";
    ElementRecord|Error rec = parseString(xmlStr);
    test:assertEquals(rec, {name: "John", age: 25});

    xmlStr = "<Root><name>John</name></Root>";
    rec = parseString(xmlStr);
    test:assertEquals(rec, {name: "John"});
}

type ElementRecord2 record {
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
function testXsdElement2() returns error? {
    string xmlStr = "<Root><name>John</name><age>25</age></Root>";
    ElementRecord2|Error rec = parseString(xmlStr);
    test:assertEquals(rec, {name: ["John"], age: [25]});

    xmlStr = "<Root><name>John</name></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs less than the min required times"));

    xmlStr = "<Root><age>25</age></Root>";
    rec = parseString(xmlStr);
    test:assertEquals(rec, {age: [25]});

    xmlStr = "<Root><age>11</age><age>12</age><age>13</age><age>14</age><age>15</age></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = "<Root><age>11</age><name>Abc</name><age>12</age><age>13</age><age>14</age><age>15</age></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = "<Root><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><age>11</age><age>12</age><age>13</age><age>14</age><age>15</age></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = "<Root><age>11</age><name>Abc</name><name>Abc</name><age>12</age><name>Abc</name><age>13<name>Abc</name></age><age>14</age><age>15</age></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));
}

type ElementRecord3 record {
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
function testXsdElement3() returns error? {
    string xmlStr;
    ElementRecord3|Error rec;

    xmlStr = "<Root><user><name>John</name><id>1</id><id>2</id><age>35</age></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertEquals(rec, {user: {name: ["John"], age: [35], id: [1, 2]}, status: 3});

    xmlStr = "<Root><user><name>John</name><id>1</id><id>2</id></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs less than the min required times"), (<Error>rec).message());

    xmlStr = "<Root><user><id>1</id><id>2</id><age>35</age></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertEquals(rec, {user: {age: [35], id: [1, 2]}, status: 3});

    xmlStr = "<Root><user><id>1</id><id>2</id><age>11</age><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"));

    xmlStr = "<Root><user><id>1</id><id>2</id><age>11</age><name>Abc</name><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"), (<Error>rec).message());

    xmlStr = "<Root><user><id>1</id><id>2</id><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><age>11</age><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"), (<Error>rec).message());

    xmlStr = "<Root><user><id>1</id><id>2</id><age>11</age><name>Abc</name><name>Abc</name><age>13</age><name>Abc</name><age>13<name>Abc</name></age><age>14</age><age>15</age></user><status>3</status></Root>";
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("age Element occurs more than the max allowed times"), (<Error>rec).message());
}

type ElementRecord4 record {
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
function testXsdElement4() returns error? {
    string xmlStr = string `<ElementRecord4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><age>20</age><age>25</age><age>30</age></ElementRecord4>`;
    ElementRecord4|Error rec = parseString(xmlStr);
    test:assertEquals(rec, {name: [{firstName: ["John", "Jane", "Jim"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3], age: [20, 25, 30]});

    xmlStr = string `<ElementRecord4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecord4>`;
    rec = parseString(xmlStr);
    test:assertEquals(rec, {name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});

    xmlStr = string `<ElementRecord4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecord4>`;
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("name Element occurs less than the min required times"));

    xmlStr = string `<ElementRecord4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecord4>`;
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("name Element occurs more than the max allowed times"));

    xmlStr = string `<ElementRecord4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecord4>`;
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("lastName Element occurs more than the max allowed times"));

    xmlStr = string `<ElementRecord4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><age>20</age><age>25</age><age>30</age></ElementRecord4>`;
    rec = parseString(xmlStr);
    test:assertTrue(rec is error);
    test:assertTrue((<Error>rec).message().includes("firstName Element occurs more than the max allowed times"), (<Error>rec).message());
}