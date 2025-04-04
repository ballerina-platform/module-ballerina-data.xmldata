// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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

@test:Config
function emptyQueryTest() {
    xml value = xml `<root></root>`;
    string query = "//b";
    () result = checkpanic transform(value, query);
    test:assertEquals(result, ());
}

@test:Config
function xmlValueTest() {
    xml value = xml `<data><person><firstName>John</firstName><lastName>Doe</lastName></person></data>`;
    string query = "/data/person";
    xml result = checkpanic transform(value, query);
    xmlEqual(result, xml `<person><firstName>John</firstName><lastName>Doe</lastName></person>`);
}

@test:Config
function stringValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    string result = checkpanic transform(value, query);
    test:assertEquals(result, "John");

    query = "/root/name/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, "John");
}

@test:Config
function stringSingleTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    "John" result = checkpanic transform(value, query);
    test:assertEquals(result, "John");

    query = "/root/name/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, "John");
}

@test:Config
function stringUnionSingleTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    "John"|"Jane" result = checkpanic transform(value, query);
    test:assertEquals(result, "John");

    query = "/root/name/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, "John");
}

@test:Config
function stringSingleErrorTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    "Jane"|error result = transform(value, query);
    test:assertTrue(result is Error);

    query = "/root/name/text()";
    result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function stringIntUnionTest() {
    xml value = xml `<root><value>John</value></root>`;
    string query = "/root/value";
    string|int result = checkpanic transform(value, query);
    test:assertEquals(result, "John");

    query = "/root/value/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, "John");
}

@test:Config
function booleanValueTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    boolean result = checkpanic transform(value, query);
    test:assertEquals(result, true);
}

@test:Config
function booleanSingleTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    true result = checkpanic transform(value, query);
    test:assertEquals(result, true);
}

@test:Config
function booleanUnionSingleTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    true|false result = checkpanic transform(value, query);
    test:assertEquals(result, true);
}

@test:Config
function booleanSingleErrorTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    false|error result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function booleanStringUnionTest() {
    xml value = xml `<root><value>true</value></root>`;
    string query = "/root/value";
    boolean|string result = checkpanic transform(value, query);
    test:assertEquals(result, true);
}

@test:Config
function stringValueTest2() {
    xml value = xml `<root><value>25</value></root>`;
    string query = "/root/value";
    string|int result = checkpanic transform(value, query);
    test:assertEquals(result, 25);

    query = "/root/value/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, 25);
}

@test:Config
function multiTypeUnionTest() {
    xml value = xml `<root><value>true</value></root>`;
    string query = "/root/value";
    boolean|string|int result = checkpanic transform(value, query);
    test:assertEquals(result, true);

    query = "/root/value/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, true);
}

@test:Config
function multiTypeUnionErrorTest() {
    xml value = xml `<root><value>invalid</value></root>`;
    string query = "/root/value";
    boolean|int|error result = transform(value, query);
    test:assertTrue(result is Error);

    query = "/root/value/text()";
    result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function stringBooleanIntUnionTest() {
    xml value = xml `<root><value>42</value></root>`;
    string query = "/root/value";
    string|boolean|int result = checkpanic transform(value, query);
    test:assertEquals(result, 42);

    query = "/root/value/text()";
    result = checkpanic transform(value, query);
    test:assertEquals(result, 42);
}

@test:Config
function intValueTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    int result = checkpanic transform(value, query);
    test:assertEquals(result, 25);
}

@test:Config
function intSingleTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    25 result = checkpanic transform(value, query);
    test:assertEquals(result, 25);
}

@test:Config
function intUnionSingleTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    25|30 result = checkpanic transform(value, query);
    test:assertEquals(result, 25);
}

@test:Config
function intSingleErrorTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    30|error result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function intUnionSingleErrorTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    30|45|error result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function xmlSequenceTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
    </data>`;
    string query = "//person";
    xml result = checkpanic transform(value, query);
    xmlEqual(result, xml `<person><name>John</name><age>25</age></person><person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function stringSequenceErrorTest() {
    xml value = xml `<data>
        <person><name>John</name></person>
        <person><name>Jane</name></person>
    </data>`;
    string query = "//person/name";
    string|error result = transform(value, query);
    test:assertTrue(result is Error);

    query = "//person/name/text()";
    result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function invalidXPathQueryTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "//invalid[";
    error|xml result = transform(value, query);
    test:assertTrue(result is Error);
}

@test:Config
function noMatchingValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "//nonexistent";
    () result = checkpanic transform(value, query);
    test:assertEquals(result, ());
}

@test:Config
function positionPredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
        <person><name>Bob</name><age>35</age></person>
    </data>`;
    string query = "//person[2]";
    xml result = checkpanic transform(value, query);
    xmlEqual(result, xml `<person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function attributePredicateTest() {
    xml value = xml `<data>
        <person id="1"><name>John</name></person>
        <person id="2"><name>Jane</name></person>
    </data>`;
    string query = "//person[@id='2']";
    xml result = checkpanic transform(value, query);
    xmlEqual(result, xml `<person id="2"><name>Jane</name></person>`);
}

@test:Config
function valuePredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
    </data>`;
    string query = "//person[age > 25]";
    xml result = checkpanic transform(value, query);
    xmlEqual(result, xml `<person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function complexPredicateTest() {
    xml value = xml `<data>
        <person id="1"><name>John</name><age>25</age><active>true</active></person>
        <person id="2"><name>Jane</name><age>30</age><active>false</active></person>
        <person id="3"><name>Bob</name><age>35</age><active>true</active></person>
    </data>`;
    string query = "//person[age > 25 and active = 'true']";
    xml result = checkpanic transform(value, query);
    xmlEqual(result, xml `<person id="3"><name>Bob</name><age>35</age><active>true</active></person>`);
}

@test:Config
function noMatchExpectedValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/nonexistent";
    string|error result = transform(value, query);
    test:assertTrue(result is Error);
}

function xmlEqual(xml actual, xml expected) {
    var whitespace = re `\s+`;
    string actualString = whitespace.replaceAll(actual.toString(), "");
    string expectedString = whitespace.replaceAll(expected.toString(), "");
    test:assertEquals(actualString, expectedString);
}
