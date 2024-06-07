import ballerina/data.xmldata as xd;

public function testFunc() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check xd:parseString(str);
}
