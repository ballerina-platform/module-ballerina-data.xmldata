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
    () result = checkpanic transform(value, `//b`);
    test:assertEquals(result, ());
}

@test:Config
function xmlValueTest() {
    xml value = xml `<data><person><firstName>John</firstName><lastName>Doe</lastName></person></data>`;
    xml result = checkpanic transform(value, `/data/person`);
    xmlEqual(result, xml `<person><firstName>John</firstName><lastName>Doe</lastName></person>`);
}

@test:Config
function stringValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    string result = checkpanic transform(value, `/root/name`);
    test:assertEquals(result, "John");

    result = checkpanic transform(value, `/root/name/text()`);
    test:assertEquals(result, "John");
}

@test:Config
function stringSingleTest() {
    xml value = xml `<root><name>John</name></root>`;
    "John" result = checkpanic transform(value, `/root/name`);
    test:assertEquals(result, "John");

    result = checkpanic transform(value, `/root/name/text()`);
    test:assertEquals(result, "John");
}

@test:Config
function stringUnionSingleTest() {
    xml value = xml `<root><name>John</name></root>`;
    "John"|"Jane" result = checkpanic transform(value, `/root/name`);
    test:assertEquals(result, "John");

    result = checkpanic transform(value, `/root/name/text()`);
    test:assertEquals(result, "John");
}

@test:Config
function stringSingleErrorTest() {
    xml value = xml `<root><name>John</name></root>`;
    "Jane"|error result = transform(value, `/root/name`);
    test:assertTrue(result is Error);

    result = transform(value, `/root/name/text()`);
    test:assertTrue(result is Error);
}

@test:Config
function stringIntUnionTest() {
    xml value = xml `<root><value>John</value></root>`;
    string|int result = checkpanic transform(value, `/root/value`);
    test:assertEquals(result, "John");

    result = checkpanic transform(value, `/root/value/text()`);
    test:assertEquals(result, "John");
}

@test:Config
function booleanValueTest() {
    xml value = xml `<root><active>true</active></root>`;
    boolean result = checkpanic transform(value, `/root/active`);
    test:assertEquals(result, true);
}

@test:Config
function booleanSingleTest() {
    xml value = xml `<root><active>true</active></root>`;
    true result = checkpanic transform(value, `/root/active`);
    test:assertEquals(result, true);
}

@test:Config
function booleanUnionSingleTest() {
    xml value = xml `<root><active>true</active></root>`;
    true|false result = checkpanic transform(value, `/root/active`);
    test:assertEquals(result, true);
}

@test:Config
function booleanSingleErrorTest() {
    xml value = xml `<root><active>true</active></root>`;
    false|error result = transform(value, `/root/active`);
    test:assertTrue(result is Error);
}

@test:Config
function booleanStringUnionTest() {
    xml value = xml `<root><value>true</value></root>`;
    boolean|string result = checkpanic transform(value, `/root/value`);
    test:assertEquals(result, true);
}

@test:Config
function stringValueTest2() {
    xml value = xml `<root><value>25</value></root>`;
    string|int result = checkpanic transform(value, `/root/value`);
    test:assertEquals(result, "25");

    result = checkpanic transform(value, `/root/value/text()`);
    test:assertEquals(result, "25");
}

@test:Config
function multiTypeUnionTest() {
    xml value = xml `<root><value>true</value></root>`;
    boolean|string|int result = checkpanic transform(value, `/root/value`);
    test:assertEquals(result, true);

    result = checkpanic transform(value, `/root/value/text()`);
    test:assertEquals(result, true);
}

@test:Config
function multiTypeUnionErrorTest() {
    xml value = xml `<root><value>invalid</value></root>`;
    boolean|int|error result = transform(value, `/root/value`);
    test:assertTrue(result is Error);

    result = transform(value, `/root/value/text()`);
    test:assertTrue(result is Error);
}

@test:Config
function stringBooleanIntUnionTest() {
    xml value = xml `<root><value>42</value></root>`;
    string|boolean|int result = checkpanic transform(value, `/root/value`);
    test:assertEquals(result, "42");

    result = checkpanic transform(value, `/root/value/text()`);
    test:assertEquals(result, "42");
}

@test:Config
function intValueTest() {
    xml value = xml `<root><age>25</age></root>`;
    int result = checkpanic transform(value, `/root/age`);
    test:assertEquals(result, 25);
}

@test:Config
function intSingleTest() {
    xml value = xml `<root><age>25</age></root>`;
    25 result = checkpanic transform(value, `/root/age`);
    test:assertEquals(result, 25);
}

@test:Config
function intUnionSingleTest() {
    xml value = xml `<root><age>25</age></root>`;
    25|30 result = checkpanic transform(value, `/root/age`);
    test:assertEquals(result, 25);
}

@test:Config
function intSingleErrorTest() {
    xml value = xml `<root><age>25</age></root>`;
    30|error result = transform(value, `/root/age`);
    test:assertTrue(result is Error);
}

@test:Config
function intUnionSingleErrorTest() {
    xml value = xml `<root><age>25</age></root>`;
    30|45|error result = transform(value, `/root/age`);
    test:assertTrue(result is Error);
}

@test:Config
function xmlSequenceTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
    </data>`;
    xml result = checkpanic transform(value, `//person`);
    xmlEqual(result, xml `<person><name>John</name><age>25</age></person><person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function stringSequenceErrorTest() {
    xml value = xml `<data>
        <person><name>John</name></person>
        <person><name>Jane</name></person>
    </data>`;
    string|error result = transform(value, `//person/name`);
    test:assertTrue(result is Error);

    result = transform(value, `//person/name/text()`);
    test:assertTrue(result is Error);
}

@test:Config
function invalidXPathQueryTest() {
    xml value = xml `<root><name>John</name></root>`;
    error|xml result = transform(value, `//invalid[`);
    test:assertTrue(result is Error);
}

@test:Config
function noMatchingValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    () result = checkpanic transform(value, `//nonexistent`);
    test:assertEquals(result, ());
}

@test:Config
function positionPredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
        <person><name>Bob</name><age>35</age></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[2]`);
    xmlEqual(result, xml `<person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function attributePredicateTest() {
    xml value = xml `<data>
        <person id="1"><name>John</name></person>
        <person id="2"><name>Jane</name></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[@id='2']`);
    xmlEqual(result, xml `<person id="2"><name>Jane</name></person>`);
}

@test:Config
function valuePredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[age > 25]`);
    xmlEqual(result, xml `<person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function complexPredicateTest() {
    xml value = xml `<data>
        <person id="1"><name>John</name><age>25</age><active>true</active></person>
        <person id="2"><name>Jane</name><age>30</age><active>false</active></person>
        <person id="3"><name>Bob</name><age>35</age><active>true</active></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[age > 25 and active = 'true']`);
    xmlEqual(result, xml `<person id="3"><name>Bob</name><age>35</age><active>true</active></person>`);
}

@test:Config
function noMatchExpectedValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    string|error result = transform(value, `/root/nonexistent`);
    test:assertTrue(result is Error);
}

@test:Config
function containsPredicateTest() {
    xml value = xml `<data>
        <person><name>John Smith</name></person>
        <person><name>Jane Doe</name></person>
        <person><name>Bob Wilson</name></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[contains(name, 'Smith')]`);
    xmlEqual(result, xml `<person><name>John Smith</name></person>`);
}

@test:Config
function binaryAndPredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age><city>London</city></person>
        <person><name>Jane</name><age>30</age><city>Paris</city></person>
        <person><name>Bob</name><age>35</age><city>London</city></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[age > 30 and city = 'London']`);
    xmlEqual(result, xml `<person><name>Bob</name><age>35</age><city>London</city></person>`);
}

@test:Config
function binaryOrPredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age><city>London</city></person>
        <person><name>Jane</name><age>30</age><city>Paris</city></person>
        <person><name>Bob</name><age>35</age><city>London</city></person>
    </data>`;
    xml result = checkpanic transform(value, `//person[city = 'Paris' or age > 30]`);
    xmlEqual(result, xml `<person><name>Jane</name><age>30</age><city>Paris</city></person><person><name>Bob</name><age>35</age><city>London</city></person>`);
}

@test:Config
function variableNumericPredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age><active>true</active></person>
        <person><name>Jane</name><age>30</age><active>true</active></person>
        <person><name>Bob</name><age>35</age><active>true</active></person>
    </data>`;
    int minAge = 30;
    xml result = checkpanic transform(value, `//person[age > ${minAge} and active = 'true']`);
    xmlEqual(result, xml `<person><name>Bob</name><age>35</age><active>true</active></person>`);
}

@test:Config
function variableStringPredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><city>London</city></person>
        <person><name>Jane</name><city>Paris</city></person>
        <person><name>Bob</name><city>London</city></person>
    </data>`;
    string targetCity = "London";
    xml result = checkpanic transform(value, `//person[city = '${targetCity}']`);
    xmlEqual(result, xml `<person><name>John</name><city>London</city></person><person><name>Bob</name><city>London</city></person>`);
}

@test:Config
function multipleVariablePredicateTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age><city>London</city><active>false</active></person>
        <person><name>Jane</name><age>30</age><city>Paris</city><active>true</active></person>
        <person><name>Bob</name><age>35</age><city>London</city><active>true</active></person>
    </data>`;
    int minAge = 25;
    string targetCity = "London";
    boolean isActive = true;
    xml result = checkpanic transform(value, `//person[age > ${minAge} and city = '${targetCity}' and active = '${isActive}']`);
    xmlEqual(result, xml `<person><name>Bob</name><age>35</age><city>London</city><active>true</active></person>`);
}

@test:Config
function intFloatUnionOrderTest() {
    xml value = xml `<root><value>42</value></root>`;
    int|float result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is int);
    test:assertEquals(result, 42);

    value = xml `<root><value>42.5</value></root>`;
    result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is float);
    test:assertEquals(result, 42.5);
}

@test:Config
function floatIntUnionOrderTest() {
    xml value = xml `<root><value>42</value></root>`;
    float|int result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is float);
    test:assertEquals(result, 42.0);

    value = xml `<root><value>42.5</value></root>`;
    result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is float);
    test:assertEquals(result, 42.5);
}

@test:Config
function stringIntUnionOrderTest() {
    xml value = xml `<root><value>42</value></root>`;
    string|int result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is string);
    test:assertEquals(result, "42");

    value = xml `<root><value>42.5</value></root>`;
    result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is string);
    test:assertEquals(result, "42.5");
}

@test:Config
function intStringUnionOrderTest() {
    xml value = xml `<root><value>42</value></root>`;
    int|string result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is int);
    test:assertEquals(result, 42);

    value = xml `<root><value>42.5</value></root>`;
    result = checkpanic transform(value, `/root/value`);
    test:assertTrue(result is string);
    test:assertEquals(result, "42.5");
}

enum Status {
    ACTIVE,
    INACTIVE,
    PENDING
}

@test:Config
function enumValueTest() {

    xml value = xml `<root><status>ACTIVE</status></root>`;
    Status result = checkpanic transform(value, `/root/status`);
    test:assertEquals(result, ACTIVE);

    value = xml `<root><status>INACTIVE</status></root>`;
    result = checkpanic transform(value, `/root/status`);
    test:assertEquals(result, INACTIVE);

    value = xml `<root><status>PENDING</status></root>`;
    result = checkpanic transform(value, `/root/status`);
    test:assertEquals(result, PENDING);
}

@test:Config
function testRuntimeValidation() {
    error? e = trap contextuallyExpectedTypeFromParameter();
    test:assertTrue(e is Error);
}

function contextuallyExpectedTypeFromParameter() {
    xml value = xml `<root></root>`;
    foo(checkpanic transform(value, `//b`));
}

function foo(map<anydata> m) {
}

function xmlEqual(xml actual, xml expected) {
    var whitespace = re `\s+`;
    string actualString = whitespace.replaceAll(actual.toString(), "");
    string expectedString = whitespace.replaceAll(expected.toString(), "");
    test:assertEquals(actualString, expectedString);
}
