import ballerina/test;

@test:Config
function testParseMapAnyData() {
    xml xmlValue = xml `<root> <foo>5</foo> <bar>10</bar> </root>`;
    map<anydata> mapValue = checkpanic parseAsType(xmlValue);
    // record {|anydata...;|} mapValue = checkpanic parseAsType(xmlValue);
    test:assertEquals({"foo": 5, "bar": 10}, mapValue, msg = "Parsed map value is not as expected");
    // TODO: also test type alias, union etc.
}
