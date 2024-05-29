import ballerina/data.xmldata as xd;

type UnionType record {|int a;|}|record {|string b;|};

public function main() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check xd:parseString(str);
}
