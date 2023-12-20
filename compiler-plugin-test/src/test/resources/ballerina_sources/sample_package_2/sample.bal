import ballerina/data.xmldata;

@xmldata:Name {
    value: "Data"
}
type Data record {|
    @xmldata:Namespace {
        prefix: "ns1",
        uri: "http://ballerina.com"
    }
    string A;
    @xmldata:Namespace {
        prefix: "ns1",
        uri: "http://ballerina.com"
    }
    @xmldata:Name {
        value: "A"
    }
    string B;
|};
