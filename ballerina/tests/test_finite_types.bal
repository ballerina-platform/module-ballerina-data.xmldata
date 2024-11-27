import ballerina/test;

enum EnumA {
    A = "A",
    B,
    C = "C2"
}

type FiniteType true|"A"|1|2;

@test:Config
function testFiniteTypes() returns error? {
    record { 
        EnumA a;
        "A"|"B"|"C" b;
        record {
            "A"|"B"|"C" c;
            EnumA d;
        } nested;
    } r = check parseAsType(xml `<Root><a>A</a><b>B</b><nested><c>B</c><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: "A", b: "B", nested: {c: "B", d: "B"}});
}

@test:Config
function testFiniteTypes2() returns error? {
    record { 
        EnumA a;
        FiniteType b;
        record {
            FiniteType c;
            FiniteType e;
            EnumA d;
        } nested;
    } r = check parseAsType(xml `<Root><a>C2</a><b>1</b><nested><c>2</c><d>A</d><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: "C2", b: 1, nested: {c: 2, d: "A", e: true}});
}

@test:Config
function testFiniteTypes3() returns error? {
    record { 
        EnumA[] a;
        ("A"|"B"|"C")[] b;
        record {
            ("A"|"B"|"C")[] c;
            EnumA[] d;
        } nested;
    } r = check parseAsType(xml `<Root><a>A</a><a>A</a><b>B</b><b>B</b><nested><c>B</c><c>B</c><d>B</d><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: ["A", "A"], b: ["B", "B"], nested: {c: ["B", "B"], d: ["B", "B"]}});
}

@test:Config
function testFiniteTypes4() returns error? {
    record { 
        EnumA[] a;
        FiniteType[] b;
        record {
            FiniteType[] c;
            FiniteType[] e;
            EnumA[] d;
        } nested;
    } r = check parseAsType(xml `<Root><a>C2</a><a>C2</a><b>1</b><b>1</b><nested><c>2</c><c>2</c><d>A</d><d>A</d><e>true</e><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: ["C2", "C2"], b: [1, 1], nested: {c: [2, 2], d: ["A", "A"], e: [true, true]}});
}

@test:Config
function testFiniteTypesWithXmlString() returns error? {
    record { 
        EnumA a;
        "A"|"B"|"C" b;
        record {
            "A"|"B"|"C" c;
            EnumA d;
        } nested;
    } r = check parseString(string `<Root><a>A</a><b>B</b><nested><c>B</c><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: "A", b: "B", nested: {c: "B", d: "B"}});
}

@test:Config
function testFiniteTypesWithXmlString2() returns error? {
    record { 
        EnumA a;
        FiniteType b;
        record {
            FiniteType c;
            FiniteType e;
            EnumA d;
        } nested;
    } r = check parseString(string `<Root><a>C2</a><b>1</b><nested><c>2</c><d>A</d><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: "C2", b: 1, nested: {c: 2, d: "A", e: true}});
}

@test:Config
function testFiniteTypesWithXmlString3() returns error? {
    record { 
        EnumA[] a;
        ("A"|"B"|"C")[] b;
        record {
            ("A"|"B"|"C")[] c;
            EnumA[] d;
        } nested;
    } r = check parseString(string `<Root><a>A</a><a>A</a><b>B</b><b>B</b><nested><c>B</c><c>B</c><d>B</d><d>B</d></nested></Root>`);
    test:assertEquals(r, {a: ["A", "A"], b: ["B", "B"], nested: {c: ["B", "B"], d: ["B", "B"]}});
}

@test:Config
function testFiniteTypesWithXmlString4() returns error? {
    record { 
        EnumA[] a;
        FiniteType[] b;
        record {
            FiniteType[] c;
            FiniteType[] e;
            EnumA[] d;
        } nested;
    } r = check parseString(string `<Root><a>C2</a><a>C2</a><b>1</b><b>1</b><nested><c>2</c><c>2</c><d>A</d><d>A</d><e>true</e><e>true</e></nested></Root>`);
    test:assertEquals(r, {a: ["C2", "C2"], b: [1, 1], nested: {c: [2, 2], d: ["A", "A"], e: [true, true]}});
}
