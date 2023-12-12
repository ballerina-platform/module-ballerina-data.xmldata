import ballerina/data.xmldata;

public function main() returns error? {
    string xmlStr = string `<name>John</name>`;
    int _ = check xmldata:fromXmlStringWithType(xmlStr);
    map<string> _ = check xmldata:fromXmlStringWithType(xmlStr);
    xml _ = check xmldata:fromXmlStringWithType(xmlStr);
    record {|
        string name;
    |}[] val4 = check xmldata:fromXmlStringWithType(xmlStr);
}
