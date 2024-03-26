import ballerina/data.xmldata;

@xmldata:Name {
    value: "Data"
}
type Person record {|
    string name;
    record {|string street; string country;|}|map<string> address;
    record {|string street; string country;|}? company;
|};

public function main() returns error? {
    string xmlStr = string `<Person><name>Kevin</name><address></address></Person>`;
    Person _ = check xmldata:parseString(xmlStr);
}
