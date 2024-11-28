// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

enum EnumA {
    A = "A",
    B,
    C = "C2"
}

type FiniteType true|"A"|1|2;

@test:Config
function testFiniteTypes() returns error? {
    record {| 
        EnumA a;
        "A"|"B"|"C" b;
        record {|
            "A"|"B"|"C" c;
            EnumA d;
        |} nested;
    |} r = check parseAsType(xml `<Root><a>A</a><b>B</b><nested><c>B</c><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: "A", b: "B", nested: {c: "B", d: "B"}});
}

@test:Config
function testFiniteTypesWithNestedRecords() returns error? {
    record {| 
        EnumA a;
        FiniteType b;
        record {|
            FiniteType c;
            FiniteType e;
            EnumA d;
        |} nested;
    |} r = check parseAsType(xml `<Root><a>C2</a><b>1</b><nested><c>2</c><d>A</d><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: "C2", b: 1, nested: {c: 2, d: "A", e: true}});
}

@test:Config
function testFiniteTypeArrays() returns error? {
    record {| 
        EnumA[] a;
        ("A"|"B"|"C")[] b;
        record {|
            ("A"|"B"|"C")[] c;
            EnumA[] d;
        |} nested;
    |} r = check parseAsType(xml `<Root><a>A</a><a>A</a><b>B</b><b>B</b><nested><c>B</c><c>B</c><d>B</d><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: ["A", "A"], b: ["B", "B"], nested: {c: ["B", "B"], d: ["B", "B"]}});
}

@test:Config
function testFiniteTypeArrays2() returns error? {
    record {| 
        EnumA[] a;
        FiniteType[] b;
        record {|
            FiniteType[] c;
            FiniteType[] e;
            EnumA[] d;
        |} nested;
    |} r = check parseAsType(xml `<Root><a>C2</a><a>C2</a><b>1</b><b>1</b><nested><c>2</c><c>2</c><d>A</d><d>A</d><e>true</e><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: ["C2", "C2"], b: [1, 1], nested: {c: [2, 2], d: ["A", "A"], e: [true, true]}});
}

@test:Config
function testFiniteTypesWithXmlString() returns error? {
    record {| 
        EnumA a;
        "A"|"B"|"C" b;
        record {|
            "A"|"B"|"C" c;
            EnumA d;
        |} nested;
    |} r = check parseString(string `<Root><a>A</a><b>B</b><nested><c>B</c><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: "A", b: "B", nested: {c: "B", d: "B"}});
}

@test:Config
function testFiniteTypesWithNestedRecordsWithXmlString() returns error? {
    record {| 
        EnumA a;
        FiniteType b;
        record {|
            FiniteType c;
            FiniteType e;
            EnumA d;
        |} nested;
    |} r = check parseString(string `<Root><a>C2</a><b>1</b><nested><c>2</c><d>A</d><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: "C2", b: 1, nested: {c: 2, d: "A", e: true}});
}

@test:Config
function testFiniteTypeArraysWithXmlString() returns error? {
    record {| 
        EnumA[] a;
        ("A"|"B"|"C")[] b;
        record {|
            ("A"|"B"|"C")[] c;
            EnumA[] d;
        |} nested;
    |} r = check parseString(string `<Root><a>A</a><a>A</a><b>B</b><b>B</b><nested><c>B</c><c>B</c><d>B</d><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: ["A", "A"], b: ["B", "B"], nested: {c: ["B", "B"], d: ["B", "B"]}});
}

@test:Config
function testFiniteTypeArraysWithXmlString2() returns error? {
    record {| 
        EnumA[] a;
        FiniteType[] b;
        record {|
            FiniteType[] c;
            FiniteType[] e;
            EnumA[] d;
        |} nested;
    |} r = check parseString(string `<Root><a>C2</a><a>C2</a><b>1</b><b>1</b><nested><c>2</c><c>2</c><d>A</d><d>A</d><e>true</e><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: ["C2", "C2"], b: [1, 1], nested: {c: [2, 2], d: ["A", "A"], e: [true, true]}});
}
type NestedRec record {|
    @Name {
        value: "c2"
    }
    FiniteType c;
    FiniteType e;
    @Name {
        value: "d2"
    }
    EnumA d;
|};

@test:Config
function testFiniteTypesWithNameAnnotations() returns error? {
    record {|
        EnumA a;
        FiniteType b;
        NestedRec nested;
    |} r = check parseAsType(xml `<Root><a>C2</a><b>1</b><nested><c2>2</c2><d2>A</d2><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: "C2", b: 1, nested: {c: 2, d: "A", e: true}});
}
