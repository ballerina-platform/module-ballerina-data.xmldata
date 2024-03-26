import ballerina/data.xmldata;

string xmlStr = string `<Data><A>1</A><B>2</B></Data>`;
record {|
    string? A;
    () B;
    ()[] C;
    record {||}?[] D;
|} _ = check xmldata:parseString(xmlStr);

function testFunction() returns error? {
    record {|
        string? A;
        () B;
        ()[] C;
        record {||}?[] D;
    |} _ = check xmldata:parseString(xmlStr);
}
