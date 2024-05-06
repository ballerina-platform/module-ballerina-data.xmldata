import ballerina/data.xmldata;

@xmldata:Name {
    value: "Data"
}
type Data3 record {|
    Data4 a;
|};

@xmldata:Name {
    value: "A"
}
type Data4 record {|
    string b;
|};
