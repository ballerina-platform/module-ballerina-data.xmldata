import ballerina/test;

@Name {
    value: "A"
}
type ToXml1 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXml seq_a;
};

type Seq_A_toXml record {
    @Order {
        value: 3
    }
    string c;

    @Order {
        value: 1
    }
    string a;

    @Order {
        value: 2
    }
    string b;
};

@Name {
    value: "A"
}
type ToXml2 record {
    Seq_A_toXml2 name;
};

type Seq_A_toXml2 record {
    @Order {
        value: 3
    }
    string c;

    @Order {
        value: 1
    }
    string a;

    @Order {
        value: 2
    }
    string b;
};

@test:Config {groups: ["xsd", "to_xml"]}
function testToXmlWithSimpleRecord2() {
    ToXml2 a;
    xml|Error xmlResult;

    a = {name: {b: "B", a: "A", c: "C"}};
    xmlResult = toXml(a);
    test:assertEquals(xmlResult, xml `<A><name><c>C</c><a>A</a><b>B</b></name></A>`);
}

@Name {
    value: "A"
}
type ToXml3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXml3 name;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXml3_2 name2;
};

type Seq_A_toXml3 record {
    @Order {
        value: 3
    }
    string c;

    @Order {
        value: 1
    }
    string a;

    @Order {
        value: 3
    }
    string b?;
};

type Seq_A_toXml3_2 record {
    @Order {
        value: 3
    }
    string c2;

    @Order {
        value: 1
    }
    string a2;

    @Order {
        value: 3
    }
    string b2;
};

@Name {
    value: "A"
}
type ToXml4 record {
    int n;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXml3 name;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXml3_2 name2;

    record{record{int n;} name;} name3;
};

@Name {
    value: "A"
}
type ToXml5 record {
    record {
        int n;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXml3 name;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXml3_2 name2;

        record{record{int n;} name;} name3;
    } a;

    string c;

    record {
        int n;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXml3 name;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXml3_2 name2;

        record{record{int n;} name;} name3;
    } b;
};

@Name {
    value: "Root"
}
type ToXml6 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord13_1 seq_XSDSequenceRecord13_1?;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord13_2 seq_XSDSequenceRecord13_2;
};

@test:Config {groups: ["xsd", "to_xml"], dataProvider: testToXmlWithXsdProvider}
function testToXmlWithXsd(typedesc<record{}> recordType, record{} value, xml expected) returns error?{
    xml|Error xmlResult = toXml(check value.ensureType(recordType), {});
    test:assertEquals(xmlResult, expected);
}

function testToXmlWithXsdProvider() returns [typedesc<record{}>, record{}, xml][] {
    return [[
            ToXml1,
            <ToXml1>{seq_a: {b: "B", a: "A", c: "C"}},
            xml `<A><a>A</a><b>B</b><c>C</c></A>`
        ], 
        [
            ToXml2,
            <ToXml2>{name: {b: "B", a: "A", c: "C"}},
            xml `<A><name><c>C</c><a>A</a><b>B</b></name></A>`
        ],
        [
            ToXml3,
            <ToXml3>{name: {b: "B", a: "A", c: "C"}, name2: {b2: "B", a2: "A", c2: "C"}},
            xml `<A><a>A</a><b>B</b><c>C</c><a2>A</a2><b2>B</b2><c2>C</c2></A>`
        ],
        [
            ToXml4,
            <ToXml4>{name: {b: "B", a: "A", c: "C"}, name3: {name: {n: 1}}, name2: {b2: "B", a2: "A", c2: "C"}, n: 1},
            xml `<A><n>1</n><a>A</a><b>B</b><c>C</c><a2>A</a2><b2>B</b2><c2>C</c2><name3><name><n>1</n></name></name3></A>`
        ],
        [
            ToXml5,
            <ToXml5>{a: {n: 1, name: {b: "B", a: "A", c: "C"}, name3: {name: {n: 1}}, name2: {b2: "B", a2: "A", c2: "C"}}, b: {n: 1, name: {b: "B", a: "A", c: "C"}, name3: {name: {n: 1}}, name2: {b2: "B", a2: "A", c2: "C"}}, c: "A"},
            xml `<A><a><n>1</n><a>A</a><b>B</b><c>C</c><a2>A</a2><b2>B</b2><c2>C</c2><name3><name><n>1</n></name></name3></a><c>A</c><b><n>1</n><a>A</a><b>B</b><c>C</c><a2>A</a2><b2>B</b2><c2>C</c2><name3><name><n>1</n></name></name3></b></A>`
        ],
        [
            ToXml6,
            <ToXml6>{seq_XSDSequenceRecord13_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {d: "1", e: "2", f: "3"}}, field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XSDSequenceRecord13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}},
            xml `<Root><field1><a>1</a><b>2</b><c>3</c></field1><field2><d>1</d><e>2</e><f>3</f></field2><field3><g>1</g><h>2</h><i>3</i></field3><field4><a>1</a><b>2</b><c>3</c></field4><field5><d>1</d><e>2</e><f>3</f></field5><field6><g>1</g><h>2</h><i>3</i></field6></Root>`
        ]
    ];
}