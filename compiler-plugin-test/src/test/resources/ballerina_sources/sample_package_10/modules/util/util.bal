import ballerina/data.xmldata;

type Data record {|
    string A;
    @xmldata:Name {
        value: "A"
    }
    string B;
|};
