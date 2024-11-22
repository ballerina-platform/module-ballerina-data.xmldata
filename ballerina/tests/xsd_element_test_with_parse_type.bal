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
    xml xmlValue = xml `<Root><name>John</name><age>25</age></Root>`;
    ElementRecordWithXmlValue|Error rec = parseAsType(xmlValue);
    test:assertEquals(rec, {name: "John", age: 25});
    test:assertEquals(toXml(check rec), xmlValue);

    xmlValue = xml `<Root><name>John</name></Root>`;
    rec = parseAsType(xmlValue);
    test:assertEquals(rec, {name: "John"});
    test:assertEquals(toXml(check rec), xmlValue);
}

@Name {
    value: "Root"
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
    int[] age;
};

@test:Config{groups: ["xsd", "xsd_element"]}
function testXsdElementWithXmlValue2() returns error? {
    xml xmlValue;
    ElementRecordWithXmlValue2|Error rec;
    xml|Error toXmlResult;

    xmlValue = xml `<Root><name>John</name><age>25</age></Root>`;
    rec = parseAsType(xmlValue);
    test:assertEquals(rec, {name: ["John"], age: [25]});
    test:assertEquals(toXml(check rec), xmlValue);

    xmlValue = xml `<Root><name>John</name></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs less than the min required times");
    toXmlResult = toXml(<ElementRecordWithXmlValue2>{name: ["John"], age: []});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs less than the min required times");

    xmlValue = xml `<Root><age>25</age></Root>`;
    rec = parseAsType(xmlValue);
    test:assertEquals(rec, {age: [25]});
    test:assertEquals(toXml(check rec), xmlValue);

    xmlValue = xml `<Root><age>11</age><age>12</age><age>13</age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is Error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue2>{age: [11, 12, 13, 14, 15]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><age>11</age><name>Abc</name><age>12</age><age>13</age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue2>{name: ["Abc"], age: [11, 12, 13, 14, 15]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><age>11</age><age>12</age><age>13</age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue2>{name: ["Abc", "Abc", "Abc", "Abc", "Abc"], age: [11, 12, 13, 14, 15]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><age>11</age><name>Abc</name><name>Abc</name><age>12</age><name>Abc</name><age>13<name>Abc</name></age><age>14</age><age>15</age></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue2>{name: ["Abc", "Abc", "Abc", "Abc"], age: [11, 12, 13, 14, 15]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");
}

@Name {
    value: "Root"
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
        int[] age;

        @Element {
            maxOccurs: 3,
            minOccurs: 2
        }
        int[] id;
    } user;
    
    @Element {
        maxOccurs: 1,
        minOccurs: 1
    }
    int status;
};

@test:Config{groups: ["xsd", "xsd_element"]}
function testXsdElementWithXmlValue3() returns error? {
    xml xmlValue;
    ElementRecordWithXmlValue3|Error rec;
    xml|Error toXmlResult;

    xmlValue = xml `<Root><user><name>John</name><id>1</id><id>2</id><age>35</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertEquals(rec, {user: {name: ["John"], id: [1, 2], age: [35]}, status: 3});
    test:assertEquals(toXml(check rec), xml `<Root><user><name>John</name><age>35</age><id>1</id><id>2</id></user><status>3</status></Root>`);

    xmlValue = xml `<Root><user><name>John</name><id>1</id><id>2</id></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs less than the min required times");
    toXmlResult = toXml(<ElementRecordWithXmlValue3>{user: {name: ["John"], id: [1, 2], age: []}, status: 3});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs less than the min required times");

    xmlValue = xml `<Root><user><id>1</id><id>2</id><age>35</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertEquals(rec, {user: {id: [1, 2], age: [35]}, status: 3});
    test:assertEquals(toXml(check rec), xml `<Root><user><age>35</age><id>1</id><id>2</id></user><status>3</status></Root>`);

    xmlValue = xml `<Root><user><id>1</id><id>2</id><age>11</age><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue3>{user: {id: [1, 2], age: [11, 13, 13, 14, 15]}, status: 3});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><user><id>1</id><id>2</id><age>11</age><name>Abc</name><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue3>{user: {id: [1,2], age: [11, 13, 13, 14, 15], name: ["Abc"]}, status: 3});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><user><id>1</id><id>2</id><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><name>Abc</name><age>11</age><age>13</age><age>13</age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue3>{user: {id: [1,2], age: [11, 13, 13, 14, 15], name: ["Abc", "Abc", "Abc", "Abc"]}, status: 3});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");

    xmlValue = xml `<Root><user><id>1</id><id>2</id><age>11</age><name>Abc</name><name>Abc</name><age>13</age><name>Abc</name><age>13<name>Abc</name></age><age>14</age><age>15</age></user><status>3</status></Root>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'age' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue3>{user: {id: [1,2], age: [11, 13, 13, 14, 15], name: ["Abc", "Abc", "Abc", "Abc"]}, status: 3});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'age' occurs more than the max allowed times");
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
    xml|Error toXmlResult;

    xml xmlValue = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    ElementRecordWithXmlValue4|Error rec = parseAsType(xmlValue);
    test:assertEquals(rec, {name: [{firstName: ["John", "Jane", "Jim"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3], age: [20, 25, 30]});
    test:assertEquals(toXml(check rec), xmlValue);

    xmlValue = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlValue);
    test:assertEquals(rec, {name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});
    test:assertEquals(toXml(check rec), xmlValue);

    xmlValue = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'name' occurs less than the min required times");
    toXmlResult = toXml(<ElementRecordWithXmlValue4>{name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'name' occurs less than the min required times");

    xmlValue = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'name' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue4>{name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'name' occurs more than the max allowed times");

    xmlValue = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Anna</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><status>4</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'lastName' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue4>{name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown", "Brown", "Brown", "Brown", "Brown", "Brown", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'lastName' occurs more than the max allowed times");

    xmlValue = xml `<ElementRecordWithXmlValue4><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><name><firstName>John</firstName><firstName>Jane</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><firstName>Jim</firstName><lastName>Doe</lastName><lastName>Smith</lastName><lastName>Brown</lastName></name><status>1</status><status>2</status><status>3</status><age>20</age><age>25</age><age>30</age></ElementRecordWithXmlValue4>`;
    rec = parseAsType(xmlValue);
    test:assertTrue(rec is error);
    test:assertEquals((<Error>rec).message(), "'firstName' occurs more than the max allowed times");
    toXmlResult = toXml(<ElementRecordWithXmlValue4>{name: [{firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna"], lastName: ["Doe", "Smith", "Brown"]}, {firstName: ["John", "Jane", "Jim", "Anna", "John"], lastName: ["Doe", "Smith", "Brown"]}], status: [1, 2, 3, 4], age: [20, 25, 30]});
    test:assertTrue(toXmlResult is Error);
    test:assertEquals((<Error>toXmlResult).message(), "'firstName' occurs more than the max allowed times");
}
