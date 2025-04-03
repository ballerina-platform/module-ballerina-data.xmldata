import ballerina/test;

@test:Config
function emptyQueryTest() {
    xml value = xml `<root></root>`;
    string query = "//b";
    () result = checkpanic transform(query, value);
    test:assertEquals(result, ());
}

@test:Config
function xmlValueTest() {
    xml value = xml `<data><person><firstName>John</firstName><lastName>Doe</lastName></person></data>`;
    string query = "/data/person";
    xml result = checkpanic transform(query, value);
    xmlEqual(result, xml `<person><firstName>John</firstName><lastName>Doe</lastName></person>`);
}

@test:Config
function stringValueTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    string result = checkpanic transform(query, value);
    test:assertEquals(result, "John");
}

@test:Config
function stringSingleTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    "John" result = checkpanic transform(query, value);
    test:assertEquals(result, "John");
}

@test:Config
function stringUnionSingleTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    "John"|"Jane" result = checkpanic transform(query, value);
    test:assertEquals(result, "John");
}

@test:Config
function stringSingleErrorTest() {
    xml value = xml `<root><name>John</name></root>`;
    string query = "/root/name";
    "Jane"|error result = transform(query, value);
    test:assertTrue(result is Error);
}

@test:Config
function stringIntUnionTest() {
    xml value = xml `<root><value>John</value></root>`;
    string query = "/root/value";
    string|int result = checkpanic transform(query, value);
    test:assertEquals(result, "John");
}

@test:Config
function booleanValueTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    boolean result = checkpanic transform(query, value);
    test:assertEquals(result, true);
}

@test:Config
function booleanSingleTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    true result = checkpanic transform(query, value);
    test:assertEquals(result, true);
}

@test:Config
function booleanUnionSingleTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    true|false result = checkpanic transform(query, value);
    test:assertEquals(result, true);
}

@test:Config
function booleanSingleErrorTest() {
    xml value = xml `<root><active>true</active></root>`;
    string query = "/root/active";
    false|error result = transform(query, value);
    test:assertTrue(result is Error);
}

@test:Config
function booleanStringUnionTest() {
    xml value = xml `<root><value>true</value></root>`;
    string query = "/root/value";
    boolean|string result = checkpanic transform(query, value);
    test:assertEquals(result, true);
}

@test:Config
function stringValueTest2() {
    xml value = xml `<root><value>25</value></root>`;
    string query = "/root/value";
    string|int result = checkpanic transform(query, value);
    test:assertEquals(result, 25);
}

@test:Config
function multiTypeUnionTest() {
    xml value = xml `<root><value>true</value></root>`;
    string query = "/root/value";
    boolean|string|int result = checkpanic transform(query, value);
    test:assertEquals(result, true);
}

@test:Config
function multiTypeUnionErrorTest() {
    xml value = xml `<root><value>invalid</value></root>`;
    string query = "/root/value";
    boolean|int|error result = transform(query, value);
    test:assertTrue(result is Error);
}

@test:Config
function stringBooleanIntUnionTest() {
    xml value = xml `<root><value>42</value></root>`;
    string query = "/root/value";
    string|boolean|int result = checkpanic transform(query, value);
    test:assertEquals(result, 42);
}

@test:Config
function intValueTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    int result = checkpanic transform(query, value);
    test:assertEquals(result, 25);
}

@test:Config
function intSingleTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    25 result = checkpanic transform(query, value);
    test:assertEquals(result, 25);
}

@test:Config
function intUnionSingleTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    25|30 result = checkpanic transform(query, value);
    test:assertEquals(result, 25);
}

@test:Config
function intSingleErrorTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    30|error result = transform(query, value);
    test:assertTrue(result is Error);
}

@test:Config
function intUnionSingleErrorTest() {
    xml value = xml `<root><age>25</age></root>`;
    string query = "/root/age";
    30|45|error result = transform(query, value);
    test:assertTrue(result is Error);
}

@test:Config
function xmlSequenceTest() {
    xml value = xml `<data>
        <person><name>John</name><age>25</age></person>
        <person><name>Jane</name><age>30</age></person>
    </data>`;
    string query = "//person";
    xml result = checkpanic transform(query, value);
    xmlEqual(result, xml `<person><name>John</name><age>25</age></person><person><name>Jane</name><age>30</age></person>`);
}

@test:Config
function stringSequenceErrorTest() {
    xml value = xml `<data>
        <person><name>John</name></person>
        <person><name>Jane</name></person>
    </data>`;
    string query = "//person/name";
    string|error result = transform(query, value);
    test:assertTrue(result is Error);
}

function xmlEqual(xml actual, xml expected) {
    var whitespace = re `\s+`;
    string actualString = whitespace.replaceAll(actual.toString(), "");
    string expectedString = whitespace.replaceAll(expected.toString(), "");
    test:assertEquals(actualString, expectedString);
}
