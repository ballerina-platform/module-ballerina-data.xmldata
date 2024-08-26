// import ballerina/data.xmldata;
// // import ballerina/io;
// import ballerina/test;

// xml x1 = xml `<A>42</A>`;

// type A11 record {
//     int[]|string \#content;
// };

// type A12 record {int[] \#content;}|record {int \#content;};

// type A13 record {|
//     int[]|string...;
// |};

// type A14 record {
//     boolean|int \#content;
// };

// function testUnionTypes1() {
//     // // bug #3
//     A11|error a11 = xmldata:parseAsType(x1);
//     test:assertEquals(a11, {"#content": "42"});

//     A12|error a12 = xmldata:parseAsType(x1);
//     test:assertEquals(a12, {"#content":42});

//     A13|error a13 = xmldata:parseAsType(x1);
//     test:assertEquals(a13, {"#content":"42"});

//     A14|error a14 = xmldata:parseAsType(x1);
//     test:assertEquals(a14, {"#content": 42});
// }

// xml x2 = xml `<A a1="2024" a2="3.14">Sample Text</A>`;

// type A21 record {
//     int[]|string \#content;
//     int|boolean|string a1;
// };

// type A22 record {int[] \#content;}|record {|int[]...;|}|record {int \#content; int a2;}|record {int \#content; int a1;};

// type A23 record{int \#content;}|record {string \#content; int|decimal a1;};

// // type A24 record {int[] \#content;}|record {|int[]...;|}|record {int \#content; int a2;}|record {|float|string|int...;|};

// type A25 record{int \#content;}|record {string \#content; int|decimal a1; int|decimal a2;};

// type A26 record {int[] \#content;}|record {|int[]...;|}|record {int \#content; int a2;}|record {|boolean?|string?...;|};

// function testUnionTypes2() {
//     A21|error a21 = xmldata:parseAsType(x2);
//     test:assertEquals(a21, {"#content":"Sample Text","a1":2024});

//     A22|error a22 = xmldata:parseAsType(x2);
//     test:assertTrue(a22 is xmldata:Error);
//     test:assertEquals((<error> a22).message(), "source value cannot convert into 'wso2/xml_data_dev:0:A22'");

//     // // bug #4
//     // A23|error a23 = xmldata:parseAsType(x2);
//     // test:assertEquals(a23, {"#content":"Sample Text","a1":2024, "a2": <decimal>3.14});

//     // // bug #5
//     // A24|error a24 = xmldata:parseAsType(x2);
//     // test:assertEquals(a24, {"a1":2024, "a2": <float>3.14});

//     A25|error a25 = xmldata:parseAsType(x2);
//     test:assertEquals(a25, {"#content":"Sample Text","a1":2024, "a2": <decimal>3.14});

//     A26|error a26 = xmldata:parseAsType(x2);
//     test:assertEquals(a26, {"#content":"Sample Text"});
// }

// xml x3 = xml `<A><B>100</B></A>`;

// type A31 record {
//     int[]|string B;
// };

// type A31P2 record {
//     @xmldata:Name {
//         value: "B"
//     }
//     string|int[] b;
// };

// type A32 record {
//     @xmldata:Name {
//         value: "B"
//     }
//     boolean|record{int \#content;}|int[] b;
// };

// type A33 record{string|int[] b1;}|record {|int|string B;|};

// type A34 record {
//     record{int \#content; int b1;}|record{int \#content;}[]|record{int \#content;} B;
// };

// type A35 record {|
//     record{|boolean|string...;|}...;
// |};

// function testUnionTypes3() {
//     A31|error a31 = xmldata:parseAsType(x3);
//     test:assertEquals(a31, {"B":[100]});

//     A31P2|error a31p2 = xmldata:parseAsType(x3);
//     test:assertEquals(a31p2, {"b":"100"});

//     A32|error a32 = xmldata:parseAsType(x3);
//     test:assertEquals(a32, {"b":{"#content":100}});

//     A33|error a33 = xmldata:parseAsType(x3);
//     test:assertEquals(a33, {"B":100});

//     A34|error a34 = xmldata:parseAsType(x3);
//     test:assertEquals(a34, {"B":[{"#content":100}]});

//     A35|error a35 = xmldata:parseAsType(x3);
//     test:assertEquals(a35, {"B":{"#content":"100"}});
// }

// xml x4 = xml `<A><B b1="99" b2="45.67" b3="1">Nested Content</B></A>`;

// type A41 record {|
//     int|record{|string \#content; int[]|int b1; record{}|boolean b2;|}|record{|string \#content; int[]|int b1; record{}|string b2;|}|record{} B;
// |};

// type A41P2 record {|
//     int|record{|boolean \#content; int[]|int b1; record{}|boolean b2;|}|record{|string \#content; int[]|int b1; record{}|string b2;|}|record{} B;
// |};

// type A42 record {|
//     int|record{|int...;|}|record{string \#content; int[]|int b1;}|record{} B;
// |};

// type A43P2 record {|int[]|record{|string \#content;|} B;|};
// type A43 record{|int[]|record{|int \#content; float|decimal|int...;|} B;|}|A43P2;

// function testUnionTypes4() {
//     // // bug #2
//     // A41|error a41 = xmldata:parseAsType(x4);
//     // test:assertEquals(a41, {"B":{"#content":"Nested Content","b1":99,"b2":"45.67"}});

//     A41P2|error a41p2 = xmldata:parseAsType(x4);
//     test:assertEquals(a41p2, {"B":{"#content":"Nested Content","b1":99,"b2":"45.67"}});

//     A42|error a42 = xmldata:parseAsType(x4);
//     test:assertEquals(a42, {"B":{"#content":"Nested Content","b1":99}});

//     A43|error a43 = xmldata:parseAsType(x4);
//     test:assertEquals(a43, {"B":{"#content":"Nested Content"}});
// }

// xml x5 = xml `<A><B id="1" id2="2">123</B><B id="11" id2="22">456</B></A>`;

// type Ref record {|int...;|};
// type RefArr Ref[];

// type A51 record {RefArr|int[] B;};
// type A52 record {int[]|RefArr B;};
// type A53 record {Ref|int[] B;};
// type A54 record {|Ref|int[]...;|};
// type A55 record {|Ref[]|int[]...;|};
// type A56 record {|(Ref|int)[]...;|};
// type A57 record {|(Ref|int)[] B;|};
// type A58 record {|(int|Ref)[]...;|};

// function testUnionTypes5() {
//     // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A51|error a51 = xmldata:parseAsType(x5);
//     // test:assertEquals(a51, {"B":[{"#content":123},{"#content":456}]});

//     A52|error a52 = xmldata:parseAsType(x5);
//     test:assertEquals(a52, {"B":[123,456]});

//     // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A53|error a53 = xmldata:parseAsType(x5);
//     // test:assertEquals(a53, {);

//     // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A54|error a54 = xmldata:parseAsType(x5);
//     // test:assertEquals(a54, {});

//     // // bug #6
//     // A55|error a55 = xmldata:parseAsType(x5);
//     // test:assertEquals(a55, {"B":[123,456]});

//     A56|error a56 = xmldata:parseAsType(x5);
//     test:assertEquals(a56, {"B":[{"#content":123},{"#content":456}]});

//     A57|error a57 = xmldata:parseAsType(x5);
//     test:assertEquals(a57, {"B":[{"#content":123},{"#content":456}]});

//     // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A58|error a58 = xmldata:parseAsType(x5);
//     // test:assertEquals(a58, {"B":[{"#content":123},{"#content":456}]});
// }

// xml x6 = xml `<A><B b1="car" b2="red">Toyota</B><C c1="bike" c2="blue">Yamaha</C></A>`;

// type A61 record {string C; record {|string \#content;|}[]|string B;};
// type A62 record {record {|boolean|record{(record{}|int[])[]|string \#content;}|string \#content;|}|string B; string C;};
// type A63 record {|record {|string \#content;|}[]|record {|string \#content;|}...;|};
// type A64 record {|record {|boolean|record{}|record{}[]|string \#content;|}[]|string B;|};

// function testUnionTypes6() {
//     A61|error a61 = xmldata:parseAsType(x6);
//     test:assertEquals(a61, {"C":"Yamaha","B":[{"#content":"Toyota"}]});

//     A62|error a62 = xmldata:parseAsType(x6);
//     test:assertEquals(a62, {"B":"Toyota","C":"Yamaha"});

//     A63|error a63 = xmldata:parseAsType(x6);
//     test:assertEquals(a63, {"B":[{"#content":"Toyota"}],"C":[{"#content":"Yamaha"}]});

//     A64|error a64 = xmldata:parseAsType(x6);
//     test:assertEquals(a64, {"B":[{"#content":"Toyota"}]});
// }

// xml x7 = xml `<A><B b1="solid" b2="red">Brick</B><B b1="liquid" b2="blue">Water</B><C c1="gas" c2="transparent">Air</C></A>`;

// type A71 record {record {|string...;|}[]|string[] B;};
// type A72 record {string[]|record {|string...;|}[] B;};
// type A73 record {record {|string \@content;|}|string[] B;};
// type A74 record {|record {|string...;|}|string[]...;|};
// type A75 record {|record {|string...;|}[]|string[]...;|};
// type A76 record {|(record {|string...;|}|string)[]...;|};
// type A77 record {|(record {|string...;|}|string)[] B;|};
// type A78 record {|(string|record {|string...;|})[]...;|};

// function testUnionTypes7() {
//     // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A71|error a71 = xmldata:parseAsType(x7);
//     // test:assertEquals(a71, {"B":[{"#content":"Brick"},{"#content":"Water"}],"C":{"c1":"gas","c2":"transparent","#content":"Air"}});

//     A72|error a72 = xmldata:parseAsType(x7);
//     test:assertEquals(a72, {"B":["Brick","Water"],"C":{"c1":"gas","c2":"transparent","#content":"Air"}});

//     A73|error a73 = xmldata:parseAsType(x7);
//     test:assertTrue(a73 is xmldata:Error);
//     test:assertEquals((<error>a73).message(), "unsupported input type");

//     // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A74|error a74 = xmldata:parseAsType(x7);
//     // test:assertEquals(a74, {"B":{"#content":"Water"},"C":{"#content":"Air"});

//     // // bug #6
//     // A75|error a75 = xmldata:parseAsType(x7);
//     // test:assertEquals(a75, {"B":[{"#content":"Brick"},{"#content":"Water"}],"C":[{"#content":"Air"}]});

//     // // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A76|error a76 = xmldata:parseAsType(x7);
//     // test:assertEquals(a76, {"B":[{"#content":"Brick"},{"#content":"Water"}],"C":[{"#content":"Air"}]});

//     // // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A77|error a77 = xmldata:parseAsType(x7);
//     // test:assertEquals(a77, {"B":[{"#content":"Brick"},{"#content":"Water"}]});

//     // // //bug https://github.com/ballerina-platform/ballerina-library/issues/6907
//     // A78|error a78 = xmldata:parseAsType(x7);
//     // test:assertEquals(a78, {"B":{"#content":"Water"},"C":{"#content":"Air"}});
// }

// xml x8 = xml `<A a1="level1" a2="parent">
//                 <B b1="level2-1" b2="middle">
//                     <C c1="inner1" c2="value">First</C>
//                 </B>
//                 <B b1="level2-2" b2="middle">
//                     <C c1="inner2" c2="value">Second</C>
//                     <C c1="inner3" c2="value">Third</C>
//                 </B>
//                 <B b1="level2-3" b2="middle">
//                     <D d1="inner4" d2="value">Fourth</D>
//                     <E e1="inner5" e2="value">Fifth</E>
//                 </B>
//               </A>`;

// type A81P2 record{string \#content;}[];
// type A81P1 record{string \#content;};
// type A81 record {record{|(A81P1|A81P2)[] C?;|}[] B;};
// type A81Part2 record {record{(A81P1|A81P2)[] C?;}[] B;};
// type A82P2 record{string \#content;}[][];
// type A82P1 record{string \#content;}[];
// type A82 record {record{|A82P1|A82P2 C?;|}[] B;};
// type A82Part2 record {record{A82P1|A82P2 C?;}[] B;};
// type A83P2 record{string \#content;}[];
// type A83P1 record{string \#content;};
// type A83 record {|record{|(A83P1|A83P2)[] C?;|}...;|};
// type A84P2 record{string \#content;}[];
// type A84P1 record{string \#content;};
// type A84 record {|record{|(A84P1|A84P2)[] C?;|}[]...;|};
// type A85 record{|record{}...;|}|record{|record{}[]...;|};
// type A86 record{|record{}[]...;|}|record{|record{}...;|};

// function testUnionTypes8() {
//     A81|error a81 = xmldata:parseAsType(x8);
//     test:assertEquals(a81, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},{}]});

//     A81Part2|error a81p2 = xmldata:parseAsType(x8);
//     test:assertEquals(a81p2, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},
//                             {"D":{"d1":"inner4","d2":"value","#content":"Fourth"},"E":{"e1":"inner5","e2":"value","#content":"Fifth"}}]});

//     A82|error a82 = xmldata:parseAsType(x8);
//     test:assertEquals(a82, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},{}]});

//     A82Part2|error a82p2 = xmldata:parseAsType(x8);
//     test:assertEquals(a82p2, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},
//                             {"D":{"d1":"inner4","d2":"value","#content":"Fourth"},"E":{"e1":"inner5","e2":"value","#content":"Fifth"}}]});

//     A83|error a83 = xmldata:parseAsType(x8);
//     test:assertEquals(a83, {B: {}});

//     A84|error a84 = xmldata:parseAsType(x8);
//     test:assertEquals(a84, {"B":[{"C":[{"#content":"First"}]},{"C":[{"#content":"Second"},{"#content":"Third"}]},{}]});

//     A85|error a85 = xmldata:parseAsType(x8);
//     test:assertEquals(a85, {"B":{"D":{"d1":"inner4","d2":"value","#content":"Fourth"},"E":{"e1":"inner5","e2":"value","#content":"Fifth"}}});

//     A86|error a86 = xmldata:parseAsType(x8);
//     test:assertEquals(a86, {"B":[{"C":{"c1":"inner1","c2":"value","#content":"First"}},{"C":[{"c1":"inner2","c2":"value","#content":"Second"},
//                             {"c1":"inner3","c2":"value","#content":"Third"}]},{"D":{"d1":"inner4","d2":"value","#content":"Fourth"},
//                             "E":{"e1":"inner5","e2":"value","#content":"Fifth"}}]});
// }
              
// xml x9 = xml `<A a1="level1" a2="root">
//                 <B b1="level2-1" b2="child">
//                     <C c1="level3-1" c2="leaf">100</C>
//                     <C c1="level3-2" c2="leaf">200</C>
//                     <C c1="level3-3" c2="leaf">300</C>
//                 </B>
//                 <B b1="level2-2" b2="child">
//                     <C c1="level3-4" c2="leaf">400</C>
//                     <C c1="level3-5" c2="leaf">500</C>
//                     <C c1="level3-6" c2="leaf">600</C>
//                 </B>
//               </A>`;

// type A91P1 record{string[]|record{string \#content;}[] C;};
// type A91 record {A91P1[] B;};
// type A92P1 record{(string|record{string \#content;})[] C;};
// type A92 record {A92P1[] B;};
// type A93P1 record{record{string \#content;}[]|string[] C;};
// type A93 record {A93P1[] B;};
// type A94P1 record{|(record{string \#content;}|string)[]...;|};
// type A94 record {A94P1[] B;};

// function testUnionTypes9() {
//     A91|error a91 = xmldata:parseAsType(x9);
//     test:assertEquals(a91, {"B":[{"C":["100","200","300"]},{"C":["400","500","600"]}]});

//     A92|error a92 = xmldata:parseAsType(x9);
//     test:assertEquals(a92, {"B":[{"C":["100","200","300"]},{"C":["400","500","600"]}]});

//     A93|error a93 = xmldata:parseAsType(x9);
//     test:assertEquals(a93, {"B":[{"C":[{"#content":"100"},
//                             {"#content":"200"},{"#content":"300"}]},
//                             {"C":[{"#content":"400"},{"#content":"500"},
//                             {"#content":"600"}]}]});

//     A94|error a94 = xmldata:parseAsType(x9);
//     test:assertEquals(a94, {"B":[{"C":[{"#content":"100"},
//                             {"#content":"200"},{"#content":"300"}]},
//                             {"C":[{"#content":"400"},{"#content":"500"},
//                             {"#content":"600"}]}]});
// }

// xml x10 = xml `<A xmlns:ns1="http://example.com/ns1" ns1:a1="outer">
//                 <ns1:B ns1:b1="middle">
//                     <ns1:C ns1:c1="inner">Deep Value1</ns1:C>
//                     <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
//                 </ns1:B>
//                 <ns1:B ns1:b1="middle">
//                     <ns1:C ns1:c1="inner">Deep Value3</ns1:C>
//                     <ns1:C ns1:c1="inner">Deep Value4</ns1:C>
//                 </ns1:B>
//               </A>`;

// type A101P1 record{string[]|record{string \#content;}[] C;};
// type A101 record {A101P1[] B;};
// type A102P1 record{(string|record{string \#content;})[] C;};
// type A102 record {A102P1[] B;};
// type A103P1 record{record{string \#content;}[]|string[] C;};
// type A103 record {A103P1[] B;};
// type A104P1 record{(record{string \#content;}|string)[] C;};
// type A104 record {A104P1[] B;};

// function testUnionTypes10() {
//     A101|error a101 = xmldata:parseAsType(x10);
//     test:assertEquals(a101, {"B":[{"C":["Deep Value1","Deep Value2"]},{"C":["Deep Value3","Deep Value4"]}]});

//     A102|error a102 = xmldata:parseAsType(x10);
//     test:assertEquals(a102, {"B":[{"C":["Deep Value1","Deep Value2"]},{"C":["Deep Value3","Deep Value4"]}]});

//     A103|error a103 = xmldata:parseAsType(x10);
//     test:assertEquals(a103, {"B":[{"C":[{"#content":"Deep Value1"},{"#content":"Deep Value2"}]},
//                                 {"C":[{"#content":"Deep Value3"},{"#content":"Deep Value4"}]}]});

//     A104|error a104 = xmldata:parseAsType(x10);
//     test:assertEquals(a104, {"B":[{"C":[{"#content":"Deep Value1"},{"#content":"Deep Value2"}]},
//                                 {"C":[{"#content":"Deep Value3"},{"#content":"Deep Value4"}]}]});
// }

// xml x11 = xml `<ns1:A xmlns:ns1="http://example.com/ns1" xmlns:ns2="http://example.com/ns2" ns1:a1="outer">
//                 <ns1:B ns1:b1="middle">
//                     <ns1:C ns1:c1="inner">Deep Value1</ns1:C>
//                     <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
//                 </ns1:B>
//                 <ns2:B ns1:b1="middle">
//                     <ns1:C ns1:c1="inner">Deep Value3</ns1:C>
//                     <ns1:C ns1:c1="inner">Deep Value2</ns1:C>
//                 </ns2:B>
//               </ns1:A>`;

// @xmldata:Namespace {
//     prefix: "ns1",
//     uri: "http://example.com/ns1"
// }
// type A111 record {
//     string a1;
//     (B111|B112)[] B;
// };

// @xmldata:Namespace {
//     prefix: "ns1",
//     uri: "http://example.com/ns1"
// }
// type A112 record {|
//     string a1;
//     (B111|B112)[]...;
// |};

// @xmldata:Namespace {
//     prefix: "ns1",
//     uri: "http://example.com/ns1"
// }
// type B111 record {
//     @xmldata:Namespace {
//         prefix: "ns1",
//         uri: "http://example.com/ns1"
//     }
//     string b1;
//     (C111|C112)[] C;
// };

// @xmldata:Namespace {
//     prefix: "ns2",
//     uri: "http://example.com/ns2"
// }
// type B112 record {
//     @xmldata:Namespace {
//         prefix: "ns1",
//         uri: "http://example.com/ns1"
//     }
//     string b1;
//     (C111|C112)[] C;
// };

// @xmldata:Namespace {
//     prefix: "ns1",
//     uri: "http://example.com/ns1"
// }
// type C111 record {
//     @xmldata:Namespace {
//         prefix: "ns1",
//         uri: "http://example.com/ns1"
//     }
//     string c1;
//     string \#content;
// };

// @xmldata:Namespace {
//     prefix: "ns1",
//     uri: "http://example.com/ns1"
// }
// type C112 record {
//     @xmldata:Namespace {
//         prefix: "ns1",
//         uri: "http://example.com/ns1"
//     }
//     string c1;
//     string \#content;
// };

// function testUnionTypes11() {
//     A111|error a111 = xmldata:parseAsType(x11);
//     test:assertEquals(a111, {"a1":"outer","B":[{"b1":"middle","C":[{"c1":"inner","#content":"Deep Value1"},
//                             {"c1":"inner","#content":"Deep Value2"}]},
//                             {"b1":"middle","C":[{"c1":"inner","#content":"Deep Value3"},
//                             {"c1":"inner","#content":"Deep Value2"}]}]});

//     A112|error a112 = xmldata:parseAsType(x11);
//     test:assertEquals(a112, {"a1":"outer","B":[{"b1":"middle","C":[{"c1":"inner","#content":"Deep Value1"},
//                             {"c1":"inner","#content":"Deep Value2"}]},
//                             {"b1":"middle","C":[{"c1":"inner","#content":"Deep Value3"},
//                             {"c1":"inner","#content":"Deep Value2"}]}]});
// }

// xml x12 = xml `<ns1:A xmlns:ns1="http://example.com/ns1" xmlns:ns2="http://example.com/ns2" ns1:a1="outer">
//                 <ns2:B ns2:b1="middle">
//                     <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value1</ns3:C>
//                     <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value2</ns3:C>
//                 </ns2:B>
//                 <ns2:B ns2:b1="middle">
//                     <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value3</ns3:C>
//                     <ns3:C xmlns:ns3="http://example.com/ns3" ns3:c1="inner">Deep Value4</ns3:C>
//                 </ns2:B>
//               </ns1:A>`;

// @xmldata:Namespace {
//     prefix: "ns1",
//     uri: "http://example.com/ns1"
// }
// type A121 record {
//     string a1;
//     (B121|B122)[] B;
// };

// type A122 record {|
//     string a1;
//     (B121|B122)[]...;
// |};

// @xmldata:Namespace {
//     prefix: "ns2",
//     uri: "http://example.com/ns2"
// }
// type B121 record {
//     string b1;
//     C121[] C;
// };

// @xmldata:Namespace {
//     prefix: "ns2",
//     uri: "http://example.com/ns2"
// }
// type B122 record {
//     string b1;
//     C121[] C;
// };

// @xmldata:Namespace {
//     prefix: "ns3",
//     uri: "http://example.com/ns3"
// }
// type C121 record {
//     string c1;
//     string \#content;
// };

// function testUnionTypes12() {
//     A121|error a121 = xmldata:parseAsType(x12);
//     test:assertEquals(a121, {"a1":"outer","B":[{"b1":"middle", "C":[{"c1":"inner","#content":"Deep Value1"},
//                             {"c1":"inner","#content":"Deep Value2"}]},{"b1":"middle",
//                             "C":[{"c1":"inner","#content":"Deep Value3"},{"c1":"inner","#content":"Deep Value4"}]}]});
//     A122|error a122 = xmldata:parseAsType(x12);
//     test:assertEquals(a122, {"a1":"outer","B":[{"b1":"middle", "C":[{"c1":"inner","#content":"Deep Value1"},
//                             {"c1":"inner","#content":"Deep Value2"}]},{"b1":"middle",
//                             "C":[{"c1":"inner","#content":"Deep Value3"},{"c1":"inner","#content":"Deep Value4"}]}]});
// }

// public function main() {
//     testUnionTypes1();
//     testUnionTypes2();
//     testUnionTypes3();
//     testUnionTypes4();
//     testUnionTypes5();
//     testUnionTypes6();
//     testUnionTypes7();
//     testUnionTypes8();
//     testUnionTypes9();
//     testUnionTypes10();
//     testUnionTypes11();
//     testUnionTypes12();
// }
