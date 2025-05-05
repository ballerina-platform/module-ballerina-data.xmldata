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
