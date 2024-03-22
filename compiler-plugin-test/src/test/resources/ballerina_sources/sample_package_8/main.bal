import ballerina/data.xmldata;

string xmlStr = string `<Data><A>1</A><B>2</B></Data>`;

record {|
    @xmldata:Name {
        value: "A"
    }
    string a;
    @xmldata:Name {
        value: "A"
    }
    string b;
|} _ = check xmldata:parseString(xmlStr);

record {|
    @xmldata:Name {
        value: "A"
    }
    string a;
    @xmldata:Name {
        value: "A"
    }
    string b;
|} _ = {a: "1", b: "2"};

function testFunction() returns error? {
    record {|
        @xmldata:Name {
            value: "A"
        }
        string a;
        @xmldata:Name {
            value: "A"
        }
        string b;
    |} _ = check xmldata:parseString(xmlStr);

    record {|
        @xmldata:Name {
            value: "A"
        }
        string a;
        @xmldata:Name {
            value: "A"
        }
        string b;
    |} _ = {a: "1", b: "2"};
}
