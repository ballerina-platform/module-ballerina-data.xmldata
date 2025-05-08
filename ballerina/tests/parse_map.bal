import ballerina/test;

type M map<anydata>;

type R record {|
    anydata...;
|};

@test:Config
function testParseMapAnyData() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>10</bar> </root>`;
    map<anydata> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": 5, "bar": 10}, mapValue);
    M mapValue2 = checkpanic parseAsType(xmlValue);
    test:assertEquals(mapValue, mapValue2);
    R recordValue = checkpanic parseAsType(xmlValue);
    test:assertEquals(mapValue, recordValue);
}

@test:Config
function testParseUnion() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>foo</bar> </root>`;
    map<int>|map<string>|map<anydata> mapValue = checkpanic parseAsType(xmlValue);
    test:assertTrue(mapValue is map<string>);
    test:assertEquals({"foo": "5", "bar": "foo"}, mapValue);
}

@test:Config
function testParseUnion2() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>foo</bar> </root>`;
    map<int|string> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": 5, "bar": "foo"}, mapValue);
}

@test:Config
function testParseUnion3() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>true</bar> </root>`;
    map<int>|map<boolean>|map<string> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": "5", "bar": "true"}, mapValue);
}

@test:Config
function testParseBooleanMap() {
    xml xmlValue = xml `<root> <foo>true</foo> <bar>false</bar> </root>`;
    map<boolean> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": true, "bar": false}, mapValue);
}

@test:Config
function testParseIntMap() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>10</bar> </root>`;
    map<int> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": 5, "bar": 10}, mapValue);
}

// https://github.com/ballerina-platform/ballerina-library/issues/7896
@test:Config {enable: false}
function testParseNullableIntMap() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>10</bar> <baz></baz> </root>`;
    map<int?> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": 5, "bar": 10, "baz": ()}, mapValue);
}

// https://github.com/ballerina-platform/ballerina-library/issues/7896
@test:Config {enable: false}
function testParseNullableIntMapWithNullValues() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar></bar> <baz>15</baz> </root>`;
    map<int?> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({foo: 5, bar: (), baz: 15}, mapValue);
}

// https://github.com/ballerina-platform/ballerina-library/issues/7896
@test:Config {enable: false}
function testParseNullableIntMapWithAttributes() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></bar> <baz>15</baz> </root>`;
    map<int?> mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": 5, "bar": (), "baz": 15}, mapValue);
}

// https://github.com/ballerina-platform/ballerina-library/issues/7896
@test:Config {enable: false}
function testParseUnionWithNullable() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar></bar> <baz>15</baz> </root>`;
    map<int?>|map<string?> mapValue = checkpanic parseAsType(xmlValue);
    test:assertTrue(mapValue is map<int?>);
    test:assertEquals({"foo": 5, "bar": (), "baz": 15}, mapValue);
}

type R2 record {|
    R1...;
|};

type R1 record {|
    int foo;
    string bar;
|};

// https://github.com/ballerina-platform/ballerina-library/issues/7897
@test:Config {enable: false}
function testNestedRecord() {
    xml xmlValue1 = xml `<root><v1> <foo>5</foo> <bar>10</bar> </v1></root>`;
    R2 mapValue2 = checkpanic parseAsType(xmlValue1);
    test:assertEquals({"v1": {foo: 5, bar: "10"}}, mapValue2);
}
