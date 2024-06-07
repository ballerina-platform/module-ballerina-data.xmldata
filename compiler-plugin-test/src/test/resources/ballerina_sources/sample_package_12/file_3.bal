import ballerina/data.xmldata;

public function testFunc3() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check xmldata:parseString(str);
}
