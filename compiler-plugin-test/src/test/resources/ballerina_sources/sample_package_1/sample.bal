import ballerina/data.xmldata;

@xmldata:Name {
    value: "Data"
}
type Data record {|
    @xmldata:Name {
        value: "A"
    }
    string a;
    @xmldata:Name {
        value: "A"
    }
    string b;
|};
