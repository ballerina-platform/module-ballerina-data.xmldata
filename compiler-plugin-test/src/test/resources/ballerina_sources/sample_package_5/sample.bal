import ballerina/data.xmldata;

@xmldata:Name {
    value: "Data"
}
type Data record {|
    string? A;
    () B;
    ()[] C;
    record {||}?[] D;
|};

function testFunction() returns error? {
    string xmlStr = string `<Data><A>1</A><B>2</B></Data>`;
    Data _ = check xmldata:fromXmlStringWithType(xmlStr);
}
