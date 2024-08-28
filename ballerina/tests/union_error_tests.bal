import ballerina/test;

xml xe1 = xml `<A>text</A>`;
xml xe2 = xml `<A><B>text</B></A>`;
xml xe3 = xml `<A><B>text</B><B>text</B></A>`;
xml xe4 = xml `<A>
                    <B><C>text</C><C>text</C><D>text</D></B>
                    <B><C>text</C><C>text</C><D>text</D></B>
                </A>`;
xml xe5 = xml `<ns1:A xmlns:ns1="http://example.com/ns1" xmlns:ns2="http://example.com/ns2" ns1:a1="outer">
                <ns1:B ns1:b1="middle">
                    <ns1:C ns1:c1="inner">Deep Value1</ns1:C>
                    <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
                </ns1:B>
                <ns2:B ns1:b1="middle">
                    <ns1:C ns1:c1="inner">Deep Value3</ns1:C>
                    <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
                </ns2:B>
              </ns1:A>`;

type E1 record {
    boolean|()|int|decimal|record {} \#content;
};

type E2 record {
    record {boolean|()|int|decimal|record {} \#content;} B;
};

type E22 record {
    record {boolean|()|int|decimal|record {} \#content;}|record {record {int \#content;} \#content;} B;
};

type E3 record {
    (record {int \#content;}|record {boolean \#content;})[] B;
};

type E32 record {
    record {int \#content;}[]|record {boolean \#content;}[] B;
};

type E4P1 record {boolean \#content;};
type E4P12 record {int \#content;}|E4P1;

type E4 record {
    record{E4P12[] C;}[] B;
};

type E4P2 record {boolean \#content;}[];
type E4P22 record {int \#content;}[]|E4P2;

type E42 record {
    record{E4P22 C;}[] B;
};

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type E5 record {
    string a1;
    (F111|F112)[] B;
};

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type F111 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string b1;
    (G111|G112)[] C;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns2"
}
type F112 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string b1;
    (G111|G112)[] C;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns1"
}
type G111 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string c1;
    string \#content;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns1"
}
type G112 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string c1;
    string \#content;
};

@test:Config
function testErrorUnion() {
    E1|error e1 = parseAsType(xe1);
    test:assertTrue(e1 is error);
    test:assertEquals((<error>e1).message(), "field '#content' cannot convert into the type '(boolean|int|decimal|data.xmldata:record {| anydata...; |})?'");

    E2|error e2 = parseAsType(xe2);
    test:assertTrue(e2 is error);
    test:assertEquals((<error>e2).message(), "field '#content' cannot convert into the type '(boolean|int|decimal|data.xmldata:record {| anydata...; |})?'");

    E22|error e22 = parseAsType(xe2);
    test:assertTrue(e22 is error);
    test:assertEquals((<error>e22).message(), "field 'B' cannot convert into the type '(data.xmldata:record {| (boolean|int|decimal|record {| anydata...; |})? #content; anydata...; |}|data.xmldata:record {| record {| int #content; anydata...; |} #content; anydata...; |})'");

    E3|error e3 = parseAsType(xe3);
    test:assertTrue(e3 is error);
    test:assertEquals((<error>e3).message(), "field 'B' cannot convert into the type '(data.xmldata:record {| int #content; anydata...; |}|data.xmldata:record {| boolean #content; anydata...; |})[]'");

    E32|error e32 = parseAsType(xe3);
    test:assertTrue(e32 is error);
    test:assertEquals((<error>e32).message(), "field 'B' cannot convert into the type '(data.xmldata:record {| int #content; anydata...; |}[]|data.xmldata:record {| boolean #content; anydata...; |}[])'");

    E4|error e4 = parseAsType(xe4);
    test:assertTrue(e4 is error);
    test:assertEquals((<error>e4).message(), "field 'C' cannot convert into the type 'data.xmldata:E4P12[]'");

    E42|error e42 = parseAsType(xe4);
    test:assertTrue(e42 is error);
    test:assertEquals((<error>e42).message(), "field 'C' cannot convert into the type 'ballerina/data.xmldata:1:E4P22'");

    E5|error e5 = parseAsType(xe5);
    test:assertTrue(e5 is error);
    test:assertEquals((<error>e5).message(), "field 'B' cannot convert into the type '(data.xmldata:F111|data.xmldata:F112)[]'");
}
