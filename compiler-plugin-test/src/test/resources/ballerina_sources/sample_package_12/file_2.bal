import ballerina/data.xmldata as xd2;

public function testFunc2() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check xd2:parseString(str);
}
