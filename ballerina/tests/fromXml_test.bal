// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

type Data record {|
    record {|
        int[] B;
        string C;
    |}[] A;
    string D;
|};

@test:Config{}
function testXmlStringToRecord1() returns error? {
    string xmlStr = "<Data><A><B>1</B><B>2</B><C>6</C></A><D>5</D><A><B>3</B><B>4</B><C>5</C></A></Data>";
    Data rec1 = check fromXmlStringWithType(xmlStr);

    test:assertEquals(rec1.A.length(), 2);
    test:assertEquals(rec1.A[0].B.length(), 2);
    test:assertEquals(rec1.A[0].B[0], 1);
    test:assertEquals(rec1.A[0].B[1], 2);
    test:assertEquals(rec1.A[0].C, "6");

    test:assertEquals(rec1.A[1].B.length(), 2);
    test:assertEquals(rec1.A[1].B[0], 3);
    test:assertEquals(rec1.A[1].B[1], 4);
    test:assertEquals(rec1.A[1].C, "5");

    test:assertEquals(rec1.D, "5");
}

@test:Config{}
function testXmlToRecord1() returns error? {
    xml xmlVal = xml `<Data><A><B>1</B><B>2</B><C>6</C></A><D>5</D><A><B>3</B><B>4</B><C>5</C></A></Data>`;
    Data rec1 = check fromXmlWithType(xmlVal);

    test:assertEquals(rec1.A.length(), 2);
    test:assertEquals(rec1.A[0].B.length(), 2);
    test:assertEquals(rec1.A[0].B[0], 1);
    test:assertEquals(rec1.A[0].B[1], 2);
    test:assertEquals(rec1.A[0].C, "6");

    test:assertEquals(rec1.A[1].B.length(), 2);
    test:assertEquals(rec1.A[1].B[0], 3);
    test:assertEquals(rec1.A[1].B[1], 4);
    test:assertEquals(rec1.A[1].C, "5");

    test:assertEquals(rec1.D, "5");
}

type Data1 record {|
    record {|
        string \#content;
    |} A;
|};

type Data2 record {|
    string A;
|};

@test:Config{}
function testXmlStringToRecord2() returns error? {
    string xmlStr1 = "<Data1><A>1</A></Data1>";
    Data1 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.\#content, "1");

    string xmlStr2 = "<Data2><A>1</A></Data2>";
    Data2 rec2 = check fromXmlStringWithType(xmlStr2);
    test:assertEquals(rec2.A, "1");
}

@test:Config{}
function testXmlToRecord2() returns error? {
    xml xmlVal1 = xml `<Data1><A>1</A></Data1>`;
    Data1 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.\#content, "1");

    xml xmlVal2 = xml `<Data2><A>1</A></Data2>`;
    Data2 rec2 = check fromXmlWithType(xmlVal2);
    test:assertEquals(rec2.A, "1");
}

type Data3 record {|
    record {|
        string \#content;
    |} A;
    record {|
        int \#content;
    |} B;
|};

@Name {
    value: "Data3"
}
type Data4 record {|
    string A;
    int B;
|};

type Data5 record {|
    record {|
        record {} B;
    |}[] A;
|};

@test:Config{}
function testXmlStringToRecord3() returns error? {
    string xmlStr1 = "<Data3><A>1</A><B>2</B></Data3>";
    Data3 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.\#content, "1");
    test:assertEquals(rec1.B.\#content, 2);

    string xmlStr2 = "<Data3><A>1</A><B>2</B></Data3>";
    Data4 rec2 = check fromXmlStringWithType(xmlStr2);
    test:assertEquals(rec2.A, "1");
    test:assertEquals(rec2.B, 2);

    string xmlStr3 = "<Data5><A><B>1</B></A><A><B>2</B></A><A><B>3</B></A></Data5>";
    Data5 rec3 = check fromXmlStringWithType(xmlStr3);
    test:assertEquals(rec3.A.length(), 3);
    test:assertEquals(rec3.A[0].B.get("#content"), "1");
    test:assertEquals(rec3.A[1].B.get("#content"), "2");
    test:assertEquals(rec3.A[2].B.get("#content"), "3");
}

@test:Config{}
function testXmlToRecord3() returns error? {
    xml xmlval1 = xml `<Data3><A>1</A><B>2</B></Data3>`;
    Data3 rec1 = check fromXmlWithType(xmlval1);
    test:assertEquals(rec1.A.\#content, "1");
    test:assertEquals(rec1.B.\#content, 2);

    xml xmlVal2 = xml `<Data3><A>1</A><B>2</B></Data3>`;
    Data4 rec2 = check fromXmlWithType(xmlVal2);
    test:assertEquals(rec2.A, "1");
    test:assertEquals(rec2.B, 2);

    xml xmlVal3 = xml `<Data5><A><B>1</B></A><A><B>2</B></A><A><B>3</B></A></Data5>`;
    Data5 rec3 = check fromXmlWithType(xmlVal3);
    test:assertEquals(rec3.A.length(), 3);
    test:assertEquals(rec3.A[0].B.get("#content"), "1");
    test:assertEquals(rec3.A[1].B.get("#content"), "2");
    test:assertEquals(rec3.A[2].B.get("#content"), "3");
}

type Data6 record {|
    record {|
        record {|
            record {|
                int[] D;
            |}[] C;
        |} D;
    |} A;
|};

@test:Config{}
function testXmlStringToRecord4() returns error? {
    string xmlStr1 = "<Data6><A><D><C><D>1</D><D>2</D></C><C><D>3</D><D>4</D></C></D></A></Data6>";
    Data6 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.D.C.length(), 2);
    test:assertEquals(rec1.A.D.C[0].D.length(), 2);
    test:assertEquals(rec1.A.D.C[0].D[0], 1);
    test:assertEquals(rec1.A.D.C[0].D[1], 2);
    test:assertEquals(rec1.A.D.C[1].D.length(), 2);
    test:assertEquals(rec1.A.D.C[1].D[0], 3);
    test:assertEquals(rec1.A.D.C[1].D[1], 4);
}

@test:Config{}
function testXmlToRecord4() returns error? {
    xml xmlVal1 = xml `<Data6><A><D><C><D>1</D><D>2</D></C><C><D>3</D><D>4</D></C></D></A></Data6>`;
    Data6 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.D.C.length(), 2);
    test:assertEquals(rec1.A.D.C[0].D.length(), 2);
    test:assertEquals(rec1.A.D.C[0].D[0], 1);
    test:assertEquals(rec1.A.D.C[0].D[1], 2);
    test:assertEquals(rec1.A.D.C[1].D.length(), 2);
    test:assertEquals(rec1.A.D.C[1].D[0], 3);
    test:assertEquals(rec1.A.D.C[1].D[1], 4);
}

type Data7 record {|
    record {|
        string C;
    |}[] A;
|};

@test:Config{}
function testXmlStringToRecord5() returns error? {
    string xmlStr1 = string `
    <Data>
        <A>
            <C>1</C>
        </A>
        <A>
            <C>2</C>
        </A>
    </Data>`;
    Data7 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.length(), 2);
    test:assertEquals(rec1.A[0].C, "1");
    test:assertEquals(rec1.A[1].C, "2");
}

@test:Config{}
function testXmlToRecord5() returns error? {
    xml xmlVal1 = xml `<Data>
        <A>
            <C>1</C>
        </A>
        <A>
            <C>2</C>
        </A>
    </Data>`;
    Data7 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.length(), 2);
    test:assertEquals(rec1.A[0].C, "1");
    test:assertEquals(rec1.A[1].C, "2");
}

// test for name annotations

@Name {
    value: "Data7"
}
type Rec1 record {|
    record {
    } A;
    record {
        float \#content;
    }[] B;
|};

@test:Config{}
function testXmlStringToRecord6() returns error? {
    string xmlStr1 = string `<Data7>
        <A>1</A>
        <B>1.0</B>
        <B>2.0</B>
    </Data7>`;
    Rec1 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.get("#content"), "1");
    test:assertEquals(rec1.B.length(), 2);
    test:assertEquals(rec1.B[0].get("#content"), 1.0);
    test:assertEquals(rec1.B[1].get("#content"), 2.0);
}

@test:Config{}
function testXmlToRecord6() returns error? {
    xml xmlVal1 = xml `<Data7>
        <A>1</A>
        <B>1.0</B>
        <B>2.0</B>
    </Data7>`;
    Rec1 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.get("#content"), "1");
    test:assertEquals(rec1.B.length(), 2);
    test:assertEquals(rec1.B[0].get("#content"), 1.0);
    test:assertEquals(rec1.B[1].get("#content"), 2.0);
}

@Name {
    value: "Data8"
}
type Rec2 record {|
    @Name {
        value: "A"
    }
    record {|
        @Name {
            value: "D"
        }
        record {|
            @Name {
                value: "C"
            }
            record {|
                @Name {
                    value: "D"
                }
                int[] d;
            |}[] c;
        |} d;
    |} a;
|};

@test:Config{}
function testXmlStringToRecord7() returns error? {
    string xmlStr1 = "<Data8><A><D><C><D>1</D><D>2</D></C><C><D>3</D><D>4</D></C></D></A></Data8>";
    Rec2 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.a.d.c.length(), 2);
    test:assertEquals(rec1.a.d.c[0].d.length(), 2);
    test:assertEquals(rec1.a.d.c[0].d[0], 1);
    test:assertEquals(rec1.a.d.c[0].d[1], 2);
    test:assertEquals(rec1.a.d.c[1].d.length(), 2);
    test:assertEquals(rec1.a.d.c[1].d[0], 3);
    test:assertEquals(rec1.a.d.c[1].d[1], 4);
}

@test:Config{}
function testXmlToRecord7() returns error? {
    xml xmlVal1 = xml `<Data8><A><D><C><D>1</D><D>2</D></C><C><D>3</D><D>4</D></C></D></A></Data8>`;
    Rec2 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.a.d.c.length(), 2);
    test:assertEquals(rec1.a.d.c[0].d.length(), 2);
    test:assertEquals(rec1.a.d.c[0].d[0], 1);
    test:assertEquals(rec1.a.d.c[0].d[1], 2);
    test:assertEquals(rec1.a.d.c[1].d.length(), 2);
    test:assertEquals(rec1.a.d.c[1].d[0], 3);
    test:assertEquals(rec1.a.d.c[1].d[1], 4);
}

// Rest field tests

type RecRest1 record {|
    record {
        int C;
    } A;
    int B;
|};

@test:Config{}
function testXmlStringToRecord21() returns error? {
    string xmlStr1 = "<RecRest1><A><C>1</C><D>3</D></A><B>2</B></RecRest1>";
    RecRest1 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.C, 1);
    test:assertEquals(rec1.A.get("D"), "3");
    test:assertEquals(rec1.B, 2);
}

@test:Config{}
function testXmlToRecord21() returns error? {
    xml xmlVal1 = xml `<RecRest1><A><C>1</C><D>3</D></A><B>2</B></RecRest1>`;
    RecRest1 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.C, 1);
    test:assertEquals(rec1.A.get("D"), "3");
    test:assertEquals(rec1.B, 2);
}

type RecRest2 record {|
    record {
        int C;
        record {
            int E;
        } D;
    } A;
    int B;
|};

@test:Config{}
function testXmlStringToRecord22() returns error? {
    string xmlStr1 = "<RecRest2><A><C>1</C><D><E>3</E><F>4</F></D></A><B>2</B></RecRest2>";
    RecRest2 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.C, 1);
    test:assertEquals(rec1.A.D.E, 3);
    test:assertEquals(rec1.A.D.get("F"), "4");
    test:assertEquals(rec1.B, 2);
}

@test:Config{}
function testXmlToRecord22() returns error? {
    xml xmlVal1 = xml `<RecRest2><A><C>1</C><D><E>3</E><F>4</F></D></A><B>2</B></RecRest2>`;
    RecRest2 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.C, 1);
    test:assertEquals(rec1.A.D.E, 3);
    test:assertEquals(rec1.A.D.get("F"), "4");
    test:assertEquals(rec1.B, 2);
}

type RecRest3 record {|
    record {
        int C;
        record {
            int E;
        }[] D;
    } A;
    int B;
|};

@test:Config{}
function testXmlStringToRecord23() returns error? {
    string xmlStr1 = "<RecRest3><A><C>1</C><D><E>3</E><F>4</F></D><D><E>5</E><F>6</F></D></A><B>2</B></RecRest3>";
    RecRest3 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.C, 1);
    test:assertEquals(rec1.A.D.length(), 2);
    test:assertEquals(rec1.A.D[0].E, 3);
    test:assertEquals(rec1.A.D[0].get("F"), "4");
    test:assertEquals(rec1.A.D[1].E, 5);
    test:assertEquals(rec1.A.D[1].get("F"), "6");
    test:assertEquals(rec1.B, 2);
}

@test:Config{}
function testXmlToRecord23() returns error? {
    xml xmlVal1 = xml `<RecRest3><A><C>1</C><D><E>3</E><F>4</F></D><D><E>5</E><F>6</F></D></A><B>2</B></RecRest3>`;
    RecRest3 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.A.C, 1);
    test:assertEquals(rec1.A.D.length(), 2);
    test:assertEquals(rec1.A.D[0].E, 3);
    test:assertEquals(rec1.A.D[0].get("F"), "4");
    test:assertEquals(rec1.A.D[1].E, 5);
    test:assertEquals(rec1.A.D[1].get("F"), "6");
    test:assertEquals(rec1.B, 2);
}

type RecRest4 record {|
    record {record {|
        string name;
    |} D;}[]...;
|};

@test:Config{}
function testXmlStringToRecord24() returns error? {
    string xmlStr1 = "<RecRest4><b><D><name>James</name></D></b><b><D><name>Clark</name></D></b></RecRest4>";
    RecRest4 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.get("b")[0].D.name, "James");
    test:assertEquals(rec1.get("b")[1].D.name, "Clark");
}

@test:Config{}
function testXmlToRecord24() returns error? {
    xml xmlVal1 = xml `<RecRest4><b><D><name>James</name></D></b><b><D><name>Clark</name></D></b></RecRest4>`;
    RecRest4 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.get("b")[0].D.name, "James");
    test:assertEquals(rec1.get("b")[1].D.name, "Clark");
}

type RecRest5 record {|
    record {record {|
        string name;
    |} D;}...;
|};

@test:Config{}
function testXmlStringToRecord25() returns error? {
    string xmlStr1 = "<Data><b><D><name>James</name></D></b><c><D><name>Clark</name></D></c></Data>";
    RecRest5 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.get("b").D.name, "James");
    test:assertEquals(rec1.get("c").D.name, "Clark");
}

@test:Config{}
function testXmlToRecord25() returns error? {
    xml xmlVal1 = xml `<Data><b><D><name>James</name></D></b><c><D><name>Clark</name></D></c></Data>`;
    RecRest5 rec1 = check fromXmlWithType(xmlVal1);
    test:assertEquals(rec1.get("b").D.name, "James");
    test:assertEquals(rec1.get("c").D.name, "Clark");
}

type RecRest6 record {|
    int A;
    int[]...;
|};

public function testXmlStringToRecord26() returns error? {
    string xmlStr = string `
    <Data>
        <A>1</A>
        <B>2</B>
        <B>3</B>
    </Data>`;
    RecRest6 rec = check fromXmlStringWithType(xmlStr);
    test:assertEquals(rec.A, 1);
    test:assertEquals((<int[]>rec.get("B"))[0], 2);
    test:assertEquals((<int[]>rec.get("B"))[1], 3);
}

public function testXmlToRecord26() returns error? {
    xml xmlVal = xml `<Data>
        <A>1</A>
        <B>2</B>
        <B>3</B>
    </Data>`;
    RecRest6 rec = check fromXmlWithType(xmlVal);
    test:assertEquals(rec.A, 1);
    test:assertEquals((<int[]>rec.get("B"))[0], 2);
    test:assertEquals((<int[]>rec.get("B"))[1], 3);
}

// test namespace and attributes annotations

type RecAtt1 record {|
    record {|
        @Attribute
        int c;
        int \#content;
    |}[] A;
    int B;
|};

@test:Config{}
function testXmlStringToRecord30() returns error? {
    string xmlStr1 = "<RecAtt1><A c=\"3\">1</A><A c=\"5\">6</A><B>2</B></RecAtt1>";
    RecAtt1 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.A.length(), 2);
    test:assertEquals(rec1.A[0].c, 3);
    test:assertEquals(rec1.A[0].get("#content"), 1);
    test:assertEquals(rec1.A[1].c, 5);
    test:assertEquals(rec1.A[1].get("#content"), 6);
    test:assertEquals(rec1.B, 2);
}

type RecAtt2 record {|
    RecNs1[] A;
|};

type RecNs1 record {|
    @Attribute
    string ns1\:data;
|};

@test:Config{}
function testXmlStringToRecord31() returns error? {
    string xmlStr = "<RecAtt2><A xmlns:ns1=\"NS1\" ns1:data=\"ns1\"></A><A xmlns:ns1=\"NS1\" ns1:data=\"ns1\"></A></RecAtt2>";
    RecAtt2 rec = check fromXmlStringWithType(xmlStr);
    test:assertEquals(rec.A.length(), 2);
    test:assertEquals(rec.A[0].get("ns1:data"), "ns1");
    test:assertEquals(rec.A[1].get("ns1:data"), "ns1");
}

type Rec record {|
    string element1;
    string element2;
|};

@test:Config{}
function testXmlStringToRecord32() returns error? {
    string xmlStr1 = string `
    <root xmlns:example="http://www.example.com">
        <example:element1>Value 1</example:element1>
        <element2>Value 2</element2>
    </root>`;

    Rec rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.element1, "Value 1");
    test:assertEquals(rec1.element2, "Value 2");
}

@Namespace {
    prefix: "x",
    uri: "example.com"
}
type NSRec1 record {|
    string \#content;
|};

@test:Config{}
function testXmlStringToRecord33() returns error? {
    string xmlStr1 = string `<x:foo xmlns:x="example.com">1</x:foo>`;
    NSRec1 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.get("#content"), "1");
}

@Namespace {
    prefix: "x",
    uri: "example.com"
}
type NSRec2 record {|
    @Namespace {
        prefix: "x",
        uri: "example.com"
    }
    string bar;
|};

@test:Config{}
function testXmlStringToRecord34() returns error? {
    string xmlStr1 = string `<x:foo xmlns:x="example.com"><x:bar>1</x:bar></x:foo>`;
    NSRec2 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.bar, "1");
}

@Namespace {
    prefix: "x",
    uri: "example.com"
}
type NSRec3 record {|
    @Namespace {
        prefix: "x",
        uri: "example.com"
    }
    record {|
        @Namespace {
            uri: "example2.com"
        }
        string baz;
    |} bar;
|};

@test:Config{}
function testXmlStringToRecord35() returns error? {
    string xmlStr1 = string `<x:foo xmlns:x="example.com" xmlns="example2.com"><x:bar><baz>2</baz></x:bar></x:foo>`;
    NSRec3 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.bar.baz, "2");
}

@Namespace {
    uri: "example.com"
}
type NSRec4 record {|
    @Namespace {
        uri: "example.com"
    }
    string bar;
|};

@test:Config{}
function testXmlStringToRecord36() returns error? {
    string xmlStr1 = string `<foo xmlns="example.com"><bar>1</bar></foo>`;
    NSRec4 rec1 = check fromXmlStringWithType(xmlStr1);
    test:assertEquals(rec1.bar, "1");
}

// Test projection with fixed array size.

type DataProj record {|
    record {|
        int B;
    |}[1] A;
|};

type DataProj2 record {|
    int[] A;
|};

@test:Config
function testXmlStringToRecord40() returns error? {
    string xmlStr = string `<DataProj>
        <A><B>1</B></A>
        <A><B>2</B></A>
        <A><B>3</B></A>
    </DataProj>`;
    DataProj rec = check fromXmlStringWithType(xmlStr);
    test:assertEquals(rec.A.length(), 1);
    test:assertEquals(rec.A[0].B, 1);

    string xmlStr2 = string `<DataProj2>
        <A>1</A>
        <A>2</A>
        <A>3</A>
    </DataProj2>`;

    DataProj2 rec2 = check fromXmlStringWithType(xmlStr2);
    test:assertEquals(rec2.A.length(), 3);
    test:assertEquals(rec2.A[0], 1);
    test:assertEquals(rec2.A[1], 2);
    test:assertEquals(rec2.A[2], 3);
}

type DataProj3 record {|
    record {|
        int B;
    |}[2] A;
|};

type DataProj4 record {|
    int[2] A;
|};

@test:Config
function testXmlStringToRecord41() returns error? {
    string xmlStr = string `<DataProj3>
        <A><B>1</B></A>
        <A><B>2</B></A>
        <A><B>3</B></A>
    </DataProj3>`;
    DataProj3 rec = check fromXmlStringWithType(xmlStr);
    test:assertEquals(rec.A.length(), 2);
    test:assertEquals(rec.A[0].B, 1);
    test:assertEquals(rec.A[1].B, 2);

    string xmlStr2 = string `<DataProj4>
        <A>1</A>
        <A>2</A>
        <A>3</A>
    </DataProj4>`;

    DataProj4 rec2 = check fromXmlStringWithType(xmlStr2);
    test:assertEquals(rec2.A.length(), 2);
    test:assertEquals(rec2.A[0], 1);
    test:assertEquals(rec2.A[1], 2);
}

@Namespace {
    uri: "http://www.example.com/invoice",
    prefix: "inv"
}
@Name {
    value: "invoice"
}
type DataProj5 record {|
    DataProjField customers;
|};

type DataProjField record {|
    @Name {
        value: "customer"
    }
    string[2] cust;
|};

@test:Config
function testXmlStringToRecord42() returns error? {
string xmlStr = string `<inv:invoice xmlns:inv="http://www.example.com/invoice">
    <customers>
        <customer>KLLBCQVN0Y</customer>
        <customer>T8VQU3X0QH</customer>
        <customer>DAWQU3X0QH</customer>
    </customers>
    </inv:invoice>`;

    DataProj5 invoice = check fromXmlStringWithType(xmlStr);
    test:assertEquals(invoice.customers.cust.length(), 2);
    test:assertEquals(invoice.customers.cust[0], "KLLBCQVN0Y");
    test:assertEquals(invoice.customers.cust[1], "T8VQU3X0QH");
}

// Negative cases
type DataN1 record {|
    int A;
|};


@test:Config{}
function testXmlStringToRecordNegative1() {
    string xmlStr1 = "<Data><B></B></Data>";
    DataN1|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "Required field A not present in XML");
}

@test:Config{}
function testXmlStringToRecordNegative2() {
    string xmlStr1 = "<Data><A>1.0</A></Data>";
    DataN1|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "'string' value '1.0' cannot be converted to 'int'");
}

type DataN2 int;

@test:Config{}
function testXmlStringToRecordNegative3() {
    string xmlStr1 = "<Data><A>1.0</A></Data>";
    DataN2|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "unsupported type expected record type but found 'DataN2'");
}

@test:Config{}
function testXmlStringToRecordNegative4() {
    string xmlStr1 = "<Data><A>1</A><A>2</A></Data>";
    DataN1|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "Incompatible type expected 'array' type but found 'int' for field 'A'");
}

type DataN3 record {|
    int[4] A;
|};

@test:Config{}
function testXmlStringToRecordNegative5() {
    string xmlStr1 = "<Data><A>1</A><A>2</A><A>3</A></Data>";
    DataN3|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "Array size is not compatible with the expected size");
}

type DataN4 record {|
    string...;
|};

@test:Config{}
function testXmlStringToRecordNegative6() {
    string xmlStr1 = "<Data><A>1</A><A>2</A><A>3</A></Data>";
    DataN4|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "Expected an 'string' type for the field 'A' found 'array' value");
}

@Name {
    value: "Space"
}
type DataN5 record {|
    string A;
|};

@test:Config{}
function testXmlStringToRecordNegative7() {
    string xmlStr1 = "<Data><A>1</A></Data>";
    DataN5|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "the record type name `Space` mismatch with given XML name `Data`");
}

@Namespace {
    uri: "www.example.com"
}
type DataN6 record {|
    string A;
|};

@test:Config{}
function testXmlStringToRecordNegative8() {
    string xmlStr1 = string `<Data xmlns="www.test.com"><A>1</A></Data>`;
    DataN6|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "namespace mismatched for the type: DataN6");
}

type DataN7 record {|
    @Namespace {
        uri: "www.example.com"
    }
    string A;
|};

@test:Config{}
function testXmlStringToRecordNegative9() {
    string xmlStr1 = string `<Data xmlns:ns1="www.test.com"><ns1:A>1</ns1:A></Data>`;
    DataN7|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "namespace mismatched for the field: A");
}

@Namespace {
    prefix: "x",
    uri: "example.com"
}
type DataN8 record {|
    @Namespace {
        uri: "example.com"
    }
    string bar;
|};

@test:Config{}
function testXmlStringToRecordNegative10() {
    string xmlStr1 = string `<x:foo xmlns:x="example.com"><x:bar>1</x:bar></x:foo>`;
    DataN8|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "namespace mismatched for the field: bar");
}

@Namespace {
    prefix: "x",
    uri: "example.com"
}
type DataN9 record {|
    @Namespace {
        prefix: "x",
        uri: "example.com"
    }
    record {|
        @Namespace {
            uri: "example.com"
        }
        string baz;
    |} bar;
|};

@test:Config{}
function testXmlStringToRecordNegative11() {
    string xmlStr1 = string `<x:foo xmlns:x="example.com" xmlns="example2.com"><x:bar><baz>2</baz></x:bar></x:foo>`;
    DataN9|error rec1 = fromXmlStringWithType(xmlStr1);
    test:assertEquals((<error>rec1).message(), "namespace mismatched for the field: baz");
}
