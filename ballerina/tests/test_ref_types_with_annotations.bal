import ballerina/test;

@Name {
    value: "root"
}
@Namespace {
    uri: "http://ballerina.io",
    prefix: "a1"
}
type TypeRefType1 record {
    @Name {
        value: "nestedA"
    }
    NestedTypeRefType1 a;

    @Name {
        value: "nestedB"
    }
    NestedTypeRefType2 b;
};

@Namespace {
    uri: "http://nested-ballerina.io",
    prefix: "nestedA"
}
type NestedTypeRefType1 record {
    @Name {
        value: "A"
    }
    int a;

    @Name {
        value: "B"
    }
    int b;
};

type NestedTypeRefType2 record {
    @Name {
        value: "A"
    }
    int a;

    @Name {
        value: "B"
    }
    int b;
};

type TypeRefA1 TypeRefType1;

@Namespace {
    uri: "http://ballerina.io",
    prefix: "A1"
}
type TypeRefB1 TypeRefA1;

@Namespace {
    uri: "http://ballerina.io",
    prefix: "A1"
}
@Name {
    value: "r"
}
type TypeRefC1 TypeRefA1;

@test:Config
function testTypeRefAnnotations() returns error? {
    TypeRefType1 t = {
        a: {a: 1, b: 2},
        b: {a: 3, b: 4}
    };

    xml xmlResult = check toXml(t);
    test:assertTrue(xmlResult is xml:Element);
    test:assertEquals(xmlResult.toString(), string `<a1:root xmlns:a1="http://ballerina.io"><nestedA:nestedA xmlns:nestedA="http://nested-ballerina.io"><A>1</A><B>2</B></nestedA:nestedA><nestedB><A>3</A><B>4</B></nestedB></a1:root>`);

    TypeRefA1 ta = {
        a: {a: 1, b: 2},
        b: {a: 3, b: 4}
    };

    xmlResult = check toXml(ta);
    test:assertTrue(xmlResult is xml:Element);
    test:assertEquals(xmlResult.toString(), string `<a1:root xmlns:a1="http://ballerina.io"><nestedA:nestedA xmlns:nestedA="http://nested-ballerina.io"><A>1</A><B>2</B></nestedA:nestedA><nestedB><A>3</A><B>4</B></nestedB></a1:root>`);

    TypeRefB1 tb = {
        a: {a: 1, b: 2},
        b: {a: 3, b: 4}
    };

    xmlResult = check toXml(tb);
    test:assertTrue(xmlResult is xml:Element);
    test:assertEquals(xmlResult.toString(), string `<A1:root xmlns:A1="http://ballerina.io"><nestedA:nestedA xmlns:nestedA="http://nested-ballerina.io"><A>1</A><B>2</B></nestedA:nestedA><nestedB><A>3</A><B>4</B></nestedB></A1:root>`);

    TypeRefC1 tc = {
        a: {a: 1, b: 2},
        b: {a: 3, b: 4}
    };

    xmlResult = check toXml(tc);
    test:assertTrue(xmlResult is xml:Element);
    test:assertEquals(xmlResult.toString(), string `<A1:r xmlns:A1="http://ballerina.io"><nestedA:nestedA xmlns:nestedA="http://nested-ballerina.io"><A>1</A><B>2</B></nestedA:nestedA><nestedB><A>3</A><B>4</B></nestedB></A1:r>`);
}

@Namespace {
    uri: "http://ballerina.io",
    prefix: "a1"
}
@Name {
    value: "root"
}
type TypeRefType2 record {
    @Name {
        value: "nestedA"
    }
    NestedTypeRefType3 a;

    @Name {
        value: "nestedB"
    }
    NestedTypeRefType4 b;
};

@Namespace {
    uri: "http://nested-ballerina.io",
    prefix: "nestedA"
}
type NestedTypeRefType3 record {
    @Name {
        value: "A"
    }
    int a;

    @Name {
        value: "B"
    }
    int b;
};

@Namespace {
    uri: "http://nested-ballerina.io",
    prefix: "nestedB"
}
type NestedTypeRefType4 record {
    @Namespace {
        uri: "http://nested-ballerina.io/a",
        prefix: "a"
    }
    int a;

    @Name {
        value: "B"
    }
    int b;
};

@test:Config
function testTypeRefAnnotations2() returns error? {
    TypeRefType2 t = {
        a: {a: 1, b: 2},
        b: {a: 3, b: 4}
    };

    xml xmlResult = check toXml(t);
    test:assertTrue(xmlResult is xml:Element);
    test:assertEquals(xmlResult.toString(), string `<a1:root xmlns:a1="http://ballerina.io"><nestedA:nestedA xmlns:nestedA="http://nested-ballerina.io"><A>1</A><B>2</B></nestedA:nestedA><nestedB:nestedB xmlns:nestedB="http://nested-ballerina.io"><a:a xmlns:a="http://nested-ballerina.io/a">3</a:a><B>4</B></nestedB:nestedB></a1:root>`);
}
