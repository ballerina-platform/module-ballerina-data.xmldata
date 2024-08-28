import ballerina/test;

string s1 = "<A>42</A>";

type S11 record {
    int[]|string \#content;
};

type S12 record {int[] \#content;}|record {int \#content;};

type S13 record {|
    int[]|int...;
|};

type S14 record {
    boolean|int \#content;
};

@test:Config
function testParseStringUnionTypes1() {
    S11|error a11 = parseString(s1);
    test:assertEquals(a11, {"#content": "42"});

    S12|error a12 = parseString(s1);
    test:assertEquals(a12, {"#content":42});

    // // bug #9
    // S13|error a13 = parseString(s1);
    // test:assertEquals(a13, {"#content":42});

    S14|error a14 = parseString(s1);
    test:assertEquals(a14, {"#content": 42});
}

string s2 = string `<A a1="2024" a2="3.14">Sample Text</A>`;

type S21 record {
    int[]|string \#content;
    int|boolean|string a1;
};

type S22 record {int[] \#content;}|record {|int[]...;|}|record {int \#content; int a2;}|record {int \#content; int a1;};

type S23 record{int \#content;}|record {string \#content; int|decimal a1;};

// type S24 record {int[] \#content;}|record {|int[]...;|}|record {int \#content; int a2;}|record {|float|string|int...;|};

type S25 record{int \#content;}|record {string \#content; int|decimal a1; int|decimal a2;};

type S26 record {int[] \#content;}|record {|int[]...;|}|record {int \#content; int a2;}|record {|boolean?|string?...;|};

@test:Config
function testParseStringUnionTypes2() {
    S21|error a21 = parseString(s2);
    test:assertEquals(a21, {"#content":"Sample Text","a1":2024});

    S22|error a22 = parseString(s2);
    test:assertTrue(a22 is Error);
    test:assertEquals((<error> a22).message(), "source value cannot convert into 'ballerina/data.xmldata:1:S22'");

    // https://github.com/ballerina-platform/ballerina-library/issues/6925
    // S23|error a23 = parseString(s2);
    // test:assertEquals(a23, {"#content":"Sample Text","a1":2024, "a2": <decimal>3.14});

    // https://github.com/ballerina-platform/ballerina-library/issues/6925
    // S24|error a24 = parseString(s2);
    // test:assertEquals(a24, {"a1":2024, "a2": <float>3.14});

    S25|error a25 = parseString(s2);
    test:assertEquals(a25, {"#content":"Sample Text","a1":2024, "a2": <decimal>3.14});

    S26|error a26 = parseString(s2);
    test:assertEquals(a26, {"#content":"Sample Text"});
}

string s3 = string `<A><B>100</B></A>`;

type S31 record {
    int[]|string B;
};

type S31P2 record {
    @Name {
        value: "B"
    }
    string|int[] b;
};

type S32 record {
    @Name {
        value: "B"
    }
    boolean|record{int \#content;}|int[] b;
};

type S33 record{string|int[] b1;}|record {|int|string B;|};

type S34 record {
    record{int \#content; int b1;}|record{int \#content;}[]|record{int \#content;} B;
};

type S35 record {|
    record{|string...;|}...;
|};

@test:Config
function testParseStringUnionTypes3() {
    S31|error a31 = parseString(s3);
    test:assertEquals(a31, {"B":"100"});

    S31P2|error a31p2 = parseString(s3);
    test:assertEquals(a31p2, {"b":"100"});

    S32|error a32 = parseString(s3);
    test:assertEquals(a32, {"b":{"#content":100}});

    S33|error a33 = parseString(s3);
    test:assertEquals(a33, {"B":100});

    S34|error a34 = parseString(s3);
    test:assertEquals(a34, {"B":[{"#content":100}]});

    // https://github.com/ballerina-platform/ballerina-library/issues/6929
    // S35|error a35 = parseString(s3);
    // test:assertEquals(a35, {"B":{"#content":"100"}});
}

string s4 = string `<A><B b1="99" b2="45.67" b3="1">Nested Content</B></A>`;

type S41 record {|
    int|record{|string \#content; int[]|int b1; record{}|boolean b2;|}|record{|string \#content; int[]|int b1; record{}|string b2;|}|record{} B;
|};

type S41P2 record {|
    int|record{|boolean \#content; int[]|int b1; record{}|boolean b2;|}|record{|string \#content; int[]|int b1; record{}|string b2;|}|record{} B;
|};

type S42 record {|
    int|record{|int...;|}|record{string \#content; int[]|int b1;}|record{} B;
|};

type S43P2 record {|int[]|record{|string \#content;|} B;|};
type S43 record{|int[]|record{|int \#content; float|decimal|int...;|} B;|}|S43P2;

@test:Config
function testParseStringUnionTypes4() {
    // https://github.com/ballerina-platform/ballerina-library/issues?q=is%3Aopen+is%3Aissue+author%3ASasinduDilshara+label%3Amodule%2Fdata.xmldata
    // S41|error a41 = parseString(s4);
    // test:assertEquals(a41, {"B":{"#content":"Nested Content","b1":99,"b2":"45.67"}});

    S41P2|error a41p2 = parseString(s4);
    test:assertEquals(a41p2, {"B":{"#content":"Nested Content","b1":99,"b2":"45.67"}});

    S42|error a42 = parseString(s4);
    test:assertEquals(a42, {"B":{"#content":"Nested Content","b1":99}});

    S43|error a43 = parseString(s4);
    test:assertEquals(a43, {"B":{"#content":"Nested Content"}});
}

string s5 = string `<A><B id="1" id2="2">123</B><B id="11" id2="22">456</B></A>`;

type Ref record {|int...;|};
type RefArr Ref[];

type S51 record {RefArr|int[] B;};
type S52 record {int[]|RefArr B;};
type S53 record {Ref|int[] B;};
type S54 record {|Ref|int[]...;|};
type S55 record {|Ref[]|int[]...;|};
type S56 record {|(Ref|int)[]...;|};
type S57 record {|(Ref|int)[] B;|};
type S58 record {|(int|Ref)[]...;|};

@test:Config
function testParseStringUnionTypes5() {
    // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S51|error a51 = parseString(s5);
    // test:assertEquals(a51, {"B":[{"#content":123},{"#content":456}]});

    S52|error a52 = parseString(s5);
    test:assertEquals(a52, {"B":[123,456]});

    // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S53|error a53 = parseString(s5);
    // test:assertEquals(a53, {);

    // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S54|error a54 = parseString(s5);
    // test:assertEquals(a54, {});

    // https://github.com/ballerina-platform/ballerina-library/issues?q=is%3Aopen+is%3Aissue+author%3ASasinduDilshara+label%3Amodule%2Fdata.xmldata
    // S55|error a55 = parseString(s5);
    // test:assertEquals(a55, {"B":[123,456]});

    S56|error a56 = parseString(s5);
    test:assertEquals(a56, {"B":[{"#content":123},{"#content":456}]});

    S57|error a57 = parseString(s5);
    test:assertEquals(a57, {"B":[{"#content":123},{"#content":456}]});

    // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S58|error a58 = parseString(s5);
    // test:assertEquals(a58, {"B":[{"#content":123},{"#content":456}]});
}

string s6 = string `<A><B b1="car" b2="red">Toyota</B><C c1="bike" c2="blue">Yamaha</C></A>`;

type S61 record {string C; record {|string \#content;|}[]|string B;};
type S62 record {record {|boolean|record{(record{}|int[])[]|string \#content;}|string \#content;|}|string B; string C;};
type S63 record {|record {|string \#content;|}[]|record {|string \#content;|}...;|};
type S64 record {|record {|boolean|record{}|record{}[]|string \#content;|}[]|string B;|};

@test:Config
function testParseStringUnionTypes6() {
    S61|error a61 = parseString(s6);
    test:assertEquals(a61, {"C":"Yamaha","B":[{"#content":"Toyota"}]});

    S62|error a62 = parseString(s6);
    test:assertEquals(a62, {"B":"Toyota","C":"Yamaha"});

    S63|error a63 = parseString(s6);
    test:assertEquals(a63, {"B":[{"#content":"Toyota"}],"C":[{"#content":"Yamaha"}]});

    S64|error a64 = parseString(s6);
    test:assertEquals(a64, {"B":[{"#content":"Toyota"}]});
}

string s7 = string `<A><B b1="solid" b2="red">Brick</B><B b1="liquid" b2="blue">Water</B><C c1="gas" c2="transparent">Air</C></A>`;

type S71 record {record{[int, int] a;}|record {|string...;|}[]|string[] B;};
type S72 record {string[]|record {|string...;|}[] B;};
type S73 record {record {|string \@content;|}|string[] B;};
type S74 record {|record {|string...;|}|string[]...;|};
type S75 record {|record {|string...;|}[]|string[]...;|};
type S76 record {|(record {|string...;|}|string)[]...;|};
type S77 record {|(record {|string...;|}|string)[] B;|};
type S78 record {|(string|record {|string...;|})[]...;|};

@test:Config
function testParseStringUnionTypes7() {
    // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S71|error a71 = parseString(s7);
    // test:assertEquals(a71, {"B":[{"#content":"Brick"},{"#content":"Water"}],"C":{"c1":"gas","c2":"transparent","#content":"Air"}});

    S72|error a72 = parseString(s7);
    test:assertEquals(a72, {"B":["Brick","Water"],"C":{"c1":"gas","c2":"transparent","#content":"Air"}});

    S73|error a73 = parseString(s7);
    test:assertTrue(a73 is Error);
    test:assertEquals((<error>a73).message(), "field 'B' cannot convert into the type '(data.xmldata:record {| string @content; |}|string[])'");

    // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S74|error a74 = parseString(s7);
    // test:assertEquals(a74, {"B":{"#content":"Water"},"C":{"#content":"Air"});

    // https://github.com/ballerina-platform/ballerina-library/issues?q=is%3Aopen+is%3Aissue+author%3ASasinduDilshara+label%3Amodule%2Fdata.xmldata
    // S75|error a75 = parseString(s7);
    // test:assertEquals(a75, {"B":[{"#content":"Brick"},{"#content":"Water"}],"C":[{"#content":"Air"}]});

    // // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S76|error a76 = parseString(s7);
    // test:assertEquals(a76, {"B":[{"#content":"Brick"},{"#content":"Water"}],"C":[{"#content":"Air"}]});

    // // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S77|error a77 = parseString(s7);
    // test:assertEquals(a77, {"B":[{"#content":"Brick"},{"#content":"Water"}]});

    // // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
    // S78|error a78 = parseString(s7);
    // test:assertEquals(a78, {"B":{"#content":"Water"},"C":{"#content":"Air"}});
}

string s8 = string `<A a1="level1" a2="parent">
                <B b1="level2-1" b2="middle">
                    <C c1="inner1" c2="value">First</C>
                </B>
                <B b1="level2-2" b2="middle">
                    <C c1="inner2" c2="value">Second</C>
                    <C c1="inner3" c2="value">Third</C>
                </B>
                <B b1="level2-3" b2="middle">
                    <D d1="inner4" d2="value">Fourth</D>
                    <E e1="inner5" e2="value">Fifth</E>
                </B>
              </A>`;

type S81P2 record{string \#content;}[];
type S81P1 record{string \#content;};
type S81 record {record{|(S81P1|S81P2)[] C?;|}[] B;};
type S81Part2 record {record{(S81P1|S81P2)[] C?;}[] B;};
type S82P2 record{string \#content;}[][];
type S82P1 record{string \#content;}[];
type S82 record {record{|S82P1|S82P2 C?;|}[] B;};
type S82Part2 record {record{S82P1|S82P2 C?;}[] B;};
type S83P2 record{string \#content;}[];
type S83P1 record{string \#content;};
type S83 record {|record{|(S83P1|S83P2)[] C?;|}...;|};
type S84P2 record{string \#content;}[];
type S84P1 record{string \#content;};
type S84 record {|record{|(S84P1|S84P2)[] C?;|}[]...;|};
type S85 record{|record{}...;|}|record{|record{}[]...;|};
type S86 record{|record{}[]...;|}|record{|record{}...;|};

@test:Config
function testParseStringUnionTypes8() {
    S81|error a81 = parseString(s8);
    test:assertEquals(a81, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},{}]});

    S81Part2|error a81p2 = parseString(s8);
    test:assertEquals(a81p2, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},
                            {"D":{"d1":"inner4","d2":"value","#content":"Fourth"},"E":{"e1":"inner5","e2":"value","#content":"Fifth"}}]});

    S82|error a82 = parseString(s8);
    test:assertEquals(a82, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},{}]});

    S82Part2|error a82p2 = parseString(s8);
    test:assertEquals(a82p2, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},
                            {"D":{"d1":"inner4","d2":"value","#content":"Fourth"},"E":{"e1":"inner5","e2":"value","#content":"Fifth"}}]});

    S83|error a83 = parseString(s8);
    test:assertEquals(a83, {B: {}});

    S84|error a84 = parseString(s8);
    test:assertEquals(a84, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},{}]});

    S85|error a85 = parseString(s8);
    test:assertEquals(a85, {"B":{"D":{"d1":"inner4","d2":"value","#content":"Fourth"},"E":{"e1":"inner5","e2":"value","#content":"Fifth"}}});

    S86|error a86 = parseString(s8);
    test:assertEquals(a86, {"B":[{"C":{"c1":"inner1","c2":"value","#content":"First"}},{"C":[{"c1":"inner2","c2":"value","#content":"Second"},
                            {"c1":"inner3","c2":"value","#content":"Third"}]},{"D":{"d1":"inner4","d2":"value","#content":"Fourth"},
                            "E":{"e1":"inner5","e2":"value","#content":"Fifth"}}]});
}
              
string s9 = string `<A a1="level1" a2="root">
                <B b1="level2-1" b2="child">
                    <C c1="level3-1" c2="leaf">100</C>
                    <C c1="level3-2" c2="leaf">200</C>
                    <C c1="level3-3" c2="leaf">300</C>
                </B>
                <B b1="level2-2" b2="child">
                    <C c1="level3-4" c2="leaf">400</C>
                    <C c1="level3-5" c2="leaf">500</C>
                    <C c1="level3-6" c2="leaf">600</C>
                </B>
              </A>`;

type S91P1 record{string[]|record{string \#content;}[] C;};
type S91 record {S91P1[] B;};
type S92P1 record{(string|record{string \#content;})[] C;};
type S92 record {S92P1[] B;};
type S93P1 record{record{string \#content;}[]|string[] C;};
type S93 record {S93P1[] B;};
type S94P1 record{|(record{string \#content;}|string)[]...;|};
type S94 record {S94P1[] B;};

@test:Config
function testParseStringUnionTypes9() {
    S91|error a91 = parseString(s9);
    test:assertEquals(a91, {"B":[{"C":["100","200","300"]},{"C":["400","500","600"]}]});

    S92|error a92 = parseString(s9);
    test:assertEquals(a92, {"B":[{"C":["100","200","300"]},{"C":["400","500","600"]}]});

    S93|error a93 = parseString(s9);
    test:assertEquals(a93, {"B":[{"C":[{"#content":"100"},
                            {"#content":"200"},{"#content":"300"}]},
                            {"C":[{"#content":"400"},{"#content":"500"},
                            {"#content":"600"}]}]});

    S94|error a94 = parseString(s9);
    test:assertEquals(a94, {"B":[{"C":[{"#content":"100"},
                            {"#content":"200"},{"#content":"300"}]},
                            {"C":[{"#content":"400"},{"#content":"500"},
                            {"#content":"600"}]}]});
}

string s10 = string `<A xmlns:ns1="http://example.com/ns1" ns1:a1="outer">
                <ns1:B ns1:b1="middle">
                    <ns1:C ns1:c1="inner">Deep Value1</ns1:C>
                    <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
                </ns1:B>
                <ns1:B ns1:b1="middle">
                    <ns1:C ns1:c1="inner">Deep Value3</ns1:C>
                    <ns1:C ns1:c1="inner">Deep Value4</ns1:C>
                </ns1:B>
              </A>`;

type S101P1 record{string[]|record{string \#content;}[] C;};
type S101 record {S101P1[] B;};
type S102P1 record{(string|record{string \#content;})[] C;};
type S102 record {S102P1[] B;};
type S103P1 record{record{string \#content;}[]|string[] C;};
type S103 record {S103P1[] B;};
type S104P1 record{(record{string \#content;}|string)[] C;};
type S104 record {S104P1[] B;};

@test:Config
function testParseStringUnionTypes10() {
    S101|error a101 = parseString(s10);
    test:assertEquals(a101, {"B":[{"C":["Deep Value1","Deep Value2"]},{"C":["Deep Value3","Deep Value4"]}]});

    S102|error a102 = parseString(s10);
    test:assertEquals(a102, {"B":[{"C":["Deep Value1","Deep Value2"]},{"C":["Deep Value3","Deep Value4"]}]});

    S103|error a103 = parseString(s10);
    test:assertEquals(a103, {"B":[{"C":[{"#content":"Deep Value1"},{"#content":"Deep Value2"}]},
                                {"C":[{"#content":"Deep Value3"},{"#content":"Deep Value4"}]}]});

    S104|error a104 = parseString(s10);
    test:assertEquals(a104, {"B":[{"C":[{"#content":"Deep Value1"},{"#content":"Deep Value2"}]},
                                {"C":[{"#content":"Deep Value3"},{"#content":"Deep Value4"}]}]});
}

string s11 = string `<ns1:A xmlns:ns1="http://example.com/ns1" xmlns:ns2="http://example.com/ns2" ns1:a1="outer">
                <ns1:B ns1:b1="middle">
                    <ns1:C ns1:c1="inner">Deep Value1</ns1:C>
                    <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
                </ns1:B>
                <ns2:B ns1:b1="middle">
                    <ns1:C ns1:c1="inner">Deep Value3</ns1:C>
                    <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
                </ns2:B>
              </ns1:A>`;

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type S111 record {
    string a1;
    (T111|T112)[] B;
};

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type S112 record {|
    string a1;
    (T111|T112)[]...;
|};

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type T111 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string b1;
    (U111|U112)[] C;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns2"
}
type T112 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string b1;
    (U111|U112)[] C;
};

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type U111 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string c1;
    string \#content;
};

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type U112 record {
    @Namespace {
        prefix: "ns1",
        uri: "http://example.com/ns1"
    }
    string c1;
    string \#content;
};

@test:Config
function testParseStringUnionTypes11() {
    S111|error a111 = parseString(s11);
    test:assertEquals(a111, {"a1":"outer","B":[{"b1":"middle","C":[{"c1":"inner","#content":"Deep Value1"},
                            {"c1":"inner","#content":"Deep Value2"}]},
                            {"b1":"middle","C":[{"c1":"inner","#content":"Deep Value3"},
                            {"c1":"inner","#content":"Deep Value2"}]}]});

    S112|error a112 = parseString(s11);
    test:assertEquals(a112, {"a1":"outer","B":[{"b1":"middle","C":[{"c1":"inner","#content":"Deep Value1"},
                            {"c1":"inner","#content":"Deep Value2"}]},
                            {"b1":"middle","C":[{"c1":"inner","#content":"Deep Value3"},
                            {"c1":"inner","#content":"Deep Value2"}]}]});
}

string s12 = string `<ns1:A xmlns:ns1="http://example.com/ns1" xmlns:ns2="http://example.com/ns2" ns1:a1="outer">
                <ns2:B ns2:b1="middle">
                    <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value1</ns3:C>
                    <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value2</ns3:C>
                </ns2:B>
                <ns2:B ns2:b1="middle">
                    <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value3</ns3:C>
                    <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value4</ns3:C>
                </ns2:B>
              </ns1:A>`;

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type S121 record {
    string a1;
    (T121|T122)[] B;
};

type S122 record {|
    string a1;
    (T121|T122)[]...;
|};

@Namespace {
    prefix: "ns222",
    uri: "http://example.com/ns2"
}
type T121 record {
    string b1;
    U121[] C;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns2"
}
type T122 record {
    string b1;
    U121[] C;
};

@Namespace {
    prefix: "ns3",
    uri: "http://example.com/ns3"
}
type U121 record {
    string c1;
    string \#content;
};

@test:Config
function testParseStringUnionTypes12() {
    S121|error a121 = parseString(s12);
    test:assertEquals(a121, {"a1":"outer","B":[{"b1":"middle", "C":[{"c1":"inner","#content":"Deep Value1"},
                            {"c1":"inner","#content":"Deep Value2"}]},{"b1":"middle",
                            "C":[{"c1":"inner","#content":"Deep Value3"},{"c1":"inner","#content":"Deep Value4"}]}]});
    S122|error a122 = parseString(s12);
    test:assertEquals(a122, {"a1":"outer","B":[{"b1":"middle", "C":[{"c1":"inner","#content":"Deep Value1"},
                            {"c1":"inner","#content":"Deep Value2"}]},{"b1":"middle",
                            "C":[{"c1":"inner","#content":"Deep Value3"},{"c1":"inner","#content":"Deep Value4"}]}]});
}
