import ballerina/data.xmldata;

string xmlStr = string `<Data><A>1</A><B>2</B></Data>`;

record {|
    @xmldata:Name {
        value: "B"
    }
    string A;
    string B;
|}|map<int>|error rec1 = xmldata:fromXmlStringWithType(xmlStr);

record {|
    @xmldata:Name {
        value: "B"
    }
    string A;
    string B;
|}|map<int>|error rec2 = {A: "1", B: "2"};

public function main() {
    record {|
        @xmldata:Name {
            value: "B"
        }
        string A;
        string B;
    |}|map<int>|error rec3 = xmldata:fromXmlStringWithType(xmlStr);

    record {|
        @xmldata:Name {
            value: "B"
        }
        string A;
        string B;
    |}|map<int>|error rec4 = {A: "1", B: "2"};
}
