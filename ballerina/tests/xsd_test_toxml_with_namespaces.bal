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

type EmptyRec record {};

@Name {
    value: "A"
}
type ToXmlWithNamespaces1 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    @Namespace {
        uri: "http://example.com",
        prefix: "ex"        
    }
    Seq_A_toXmlWithNamespaces seq_a;
};

type Seq_A_toXmlWithNamespaces record {
    @Order {
        value: 3
    }
    @Namespace {
        uri: "http://example2.com",
        prefix: "ex2"        
    }
    string c;

    @Namespace {
        uri: "http://example2.com",
        prefix: "ex2"        
    }
    @Order {
        value: 1
    }
    string a;

    @Order {
        value: 2
    }
    @Namespace {
        uri: "http://example2.com",
        prefix: "ex2"        
    }
    string b;
};

@Name {
    value: "A"
}
type ToXmlWithNamespaces2 record {
    Seq_A_toXmlWithNamespaces2 name;
};

type Seq_A_toXmlWithNamespaces2 record {

    @Namespace {
        uri: "http://example3.com",
        prefix: "c"        
    }
    @Order {
        value: 3
    }
    string c;

    @Order {
        value: 1
    }

    @Namespace {
        uri: "http://example1.com",
        prefix: "a"        
    }
    string a;

    @Namespace {
        uri: "http://example3.com",
        prefix: "b"        
    }
    @Order {
        value: 2
    }
    string b;
};

@test:Config {groups: ["xsd", "to_xml"]}
function testToXmlWithSimpleRecordWithNamespaces2() {
    ToXmlWithNamespaces2 a;
    xml|Error xmlResult;

    a = {name: {b: "B", a: "A", c: "C"}};
    xmlResult = toXml(a);
    test:assertEquals(xmlResult, xml `<A><name><c:c xmlns:c="http://example3.com">C</c:c><a:a xmlns:a="http://example1.com">A</a:a><b:b xmlns:b="http://example3.com">B</b:b></name></A>`);
}

@Name {
    value: "A"
}
type ToXmlWithNamespaces3 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXmlWithNamespaces3 name;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXmlWithNamespaces3_2 name2;
};

type Seq_A_toXmlWithNamespaces3 record {
    @Order {
        value: 3
    }
    @Namespace {
        uri: "http://example3.com",
        prefix: "c"        
    }
    string c;

    @Order {
        value: 1
    }
    string a;

    @Order {
        value: 3
    }
    @Namespace {
        uri: "http://example2.com",
        prefix: "b"        
    }
    string b?;
};

type Seq_A_toXmlWithNamespaces3_2 record {
    @Order {
        value: 3
    }
    string c2;

    @Namespace {
        uri: "http://example3.com",
        prefix: "a2"        
    }
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
type ToXmlWithNamespaces4 record {
    int n;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXmlWithNamespaces3 name;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_A_toXmlWithNamespaces3_2 name2;

    record{record{int n;} name;} name3;
};

@Name {
    value: "A"
}
type ToXmlWithNamespaces5 record {
    record {
        int n;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXmlWithNamespaces3 name;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXmlWithNamespaces3_2 name2;

        record{record{int n;} name;} name3;
    } a;

    string c;

    record {
        int n;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXmlWithNamespaces3 name;

        @Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_A_toXmlWithNamespaces3_2 name2;

        record{record{int n;} name;} name3;
    } b;
};

@Name {
    value: "Root"
}
type ToXmlWithNamespaces6 record {
    @Sequence {
        minOccurs: 0,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithNamespace13_1 seq_XSDSequenceRecord13_1?;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecordWithNamespace13_2 seq_XSDSequenceRecord13_2;
};

type Seq_XSDSequenceRecordWithNamespace13_1 record {
    @Order {value: 1}
    @Namespace {
        uri: "http://example1.com",
        prefix: "field1"
    }
    Seq_A_13 field1;

    @Order {value: 2}
    @Namespace {
        uri: "http://example2.com",
        prefix: "field2"
    }
    Seq_B_13 field2;

    @Namespace {
        uri: "http://example3.com",
        prefix: "field3"
    }
    @Order {value: 3}
    Seq_C_13 field3;
};

type Seq_XSDSequenceRecordWithNamespace13_2 record {
    @Order {value: 1}
    @Namespace {
        uri: "http://example4.com",
        prefix: "field4"
    }
    Seq_D_13 field4;

    @Order {value: 2}
    @Namespace {
        uri: "http://example5.com"
    }
    Seq_E_13 field5;

    @Namespace {
        uri: "http://example6.com",
        prefix: "field6"
    }
    @Order {value: 3}
    Seq_F_13 field6;
};

@Name {
    value: "A"
}
type ToXmlWithNamespaces7 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    @Namespace {
        uri: "http://example.com",
        prefix: "ex"        
    }
    Seq_A_toXmlWithNamespaces[] seq_a;
};

@Name {
    value: "A"
}
type ToXmlWithNamespaces8 record {
    @Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    @Namespace {
        uri: "http://example.com",
        prefix: "ex"        
    }
    Seq_A_toXmlWithNamespaces[] seq_a;

    @Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    @Namespace {
        uri: "http://example2.com",
        prefix: "ex2"        
    }
    Seq_A_toXmlWithNamespaces[] seq_a2;
};

@test:Config {groups: ["xsd", "to_xml"], dataProvider: testToXmlWithXsdProviderWithNamespaces}
function testToXmlWithXsdWithNamespaces(typedesc<record{}> recordType, record{} value, xml expected) returns error?{
    xml|Error xmlResult = toXml(check value.ensureType(recordType), {});
    test:assertEquals(xmlResult, expected);
}

function testToXmlWithXsdProviderWithNamespaces() returns [typedesc<record{}>, record{}, xml][] {
    return [[
            ToXmlWithNamespaces1,
            <ToXmlWithNamespaces1>{seq_a: {b: "B", a: "A", c: "C"}},
            xml `<A><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c></A>`
        ], 
        [
            ToXmlWithNamespaces2,
            <ToXmlWithNamespaces2>{name: {b: "B", a: "A", c: "C"}},
            xml `<A><name><c:c xmlns:c="http://example3.com">C</c:c><a:a xmlns:a="http://example1.com">A</a:a><b:b xmlns:b="http://example3.com">B</b:b></name></A>`
        ],
        [
            ToXmlWithNamespaces3,
            <ToXmlWithNamespaces3>{name: {b: "B", a: "A", c: "C"}, name2: {b2: "B", a2: "A", c2: "C"}},
            xml `<A><a>A</a><b:b xmlns:b="http://example2.com">B</b:b><c:c xmlns:c="http://example3.com">C</c:c><a2:a2 xmlns:a2="http://example3.com">A</a2:a2><b2>B</b2><c2>C</c2></A>`
        ],
        [
            ToXmlWithNamespaces4,
            <ToXmlWithNamespaces4>{name: {b: "B", a: "A", c: "C"}, name3: {name: {n: 1}}, name2: {b2: "B", a2: "A", c2: "C"}, n: 1},
            xml `<A><n>1</n><a>A</a><b:b xmlns:b="http://example2.com">B</b:b><c:c xmlns:c="http://example3.com">C</c:c><a2:a2 xmlns:a2="http://example3.com">A</a2:a2><b2>B</b2><c2>C</c2><name3><name><n>1</n></name></name3></A>`
        ],
        [
            ToXmlWithNamespaces5,
            <ToXmlWithNamespaces5>{a: {n: 1, name: {b: "B", a: "A", c: "C"}, name3: {name: {n: 1}}, name2: {b2: "B", a2: "A", c2: "C"}}, b: {n: 1, name: {b: "B", a: "A", c: "C"}, name3: {name: {n: 1}}, name2: {b2: "B", a2: "A", c2: "C"}}, c: "A"},
            xml `<A><a><n>1</n><a>A</a><b:b xmlns:b="http://example2.com">B</b:b><c:c xmlns:c="http://example3.com">C</c:c><a2:a2 xmlns:a2="http://example3.com">A</a2:a2><b2>B</b2><c2>C</c2><name3><name><n>1</n></name></name3></a><c>A</c><b><n>1</n><a>A</a><b:b xmlns:b="http://example2.com">B</b:b><c:c xmlns:c="http://example3.com">C</c:c><a2:a2 xmlns:a2="http://example3.com">A</a2:a2><b2>B</b2><c2>C</c2><name3><name><n>1</n></name></name3></b></A>`
        ],
        // TODO: Values are exact equals but assertion is failing. Need to check.
        // [
        //     ToXmlWithNamespaces6,
        //     <ToXmlWithNamespaces6>{seq_XSDSequenceRecord13_1: {field1: {value1: {a: "1", b: "2", c: "3"}}, field2: {value2: {d: "1", e: "2", f: "3"}}, field3: {value3: {g: "1", h: "2", i: "3"}}}, seq_XSDSequenceRecord13_2: {field4: {value1: {a: "1", b: "2", c: "3"}}, field5: {value2: {d: "1", e: "2", f: "3"}}, field6: {value3: {g: "1", h: "2", i: "3"}}}},
        //     xml `<Root><field1:field1 xmlns:field1="http://example1.com"><a>1</a><b>2</b><c>3</c></field1:field1><field2:field2 xmlns:field2="http://example2.com"><d>1</d><e>2</e><f>3</f></field2:field2><field3:field3 xmlns:field3="http://example3.com"><g>1</g><h>2</h><i>3</i></field3:field3><field4:field4 xmlns:field4="http://example4.com"><a>1</a><b>2</b><c>3</c></field4:field4><field5 xmlns="http://example5.com"><d>1</d><e>2</e><f>3</f></field5><field6:field6 xmlns:field6="http://example6.com"><g>1</g><h>2</h><i>3</i></field6:field6></Root>`
        // ],
        [
            EmptyRec,
            {},
            xml ``
        ],
        [
            ToXmlWithNamespaces7,
            <ToXmlWithNamespaces7>{seq_a: [{b: "B", a: "A", c: "C"}, {b: "B", a: "A", c: "C"}]},
            xml `<A><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c></A>`
        ],
        [
            ToXmlWithNamespaces8,
            <ToXmlWithNamespaces8>{seq_a: [{b: "B", a: "A", c: "C"}, {b: "B", a: "A", c: "C"}], seq_a2: [{b: "B", a: "A", c: "C"}, {b: "B", a: "A", c: "C"}]},
            xml `<A><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c><ex2:a xmlns:ex2="http://example2.com">A</ex2:a><ex2:b xmlns:ex2="http://example2.com">B</ex2:b><ex2:c xmlns:ex2="http://example2.com">C</ex2:c></A>`
        ]
    ];
}

@Name {
    value: "A"
}
type ToXmlChoiceWithNamespace1 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_A_toXmlWithNamespace choice_a;
};

type Choice_A_toXmlWithNamespace record {
    @Namespace {
        uri: "http://examplec.com",
        prefix: "c"        
    }
    string c?;

    @Namespace {
        uri: "http://examplea.com",
        prefix: "a"        
    }
    string a?;

    @Namespace {
        uri: "http://exampleb.com",
        prefix: "b"        
    }
    string b?;
};

@Name {
    value: "A"
}
type ToXmlChoiceWithNamespace2 record {
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_A_toXmlWithNamespace2 choice_a;

    @Choice {
        minOccurs: 1,
        maxOccurs: 3
    }
    Choice_A_toXmlWithNamespace3 choice_b;
};

type Choice_A_toXmlWithNamespace2 record {
    @Element {
        minOccurs: 2,
        maxOccurs: 3
    }
    @Namespace {
        uri: "http://examplea.com",
        prefix: "c"        
    }
    string c?;

    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    string a?;

    @Element {
        minOccurs: 1,
        maxOccurs: 5
    }
    @Namespace {
        uri: "http://examplea.com",
        prefix: "b"        
    }
    string b?;
};

type Choice_A_toXmlWithNamespace3 record {
    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    string c?;

    @Namespace {
        uri: "http://examplea.com",
        prefix: "a"        
    }
    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    string a?;

    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    string b?;
};

@Name {
    value: "A"
}
type ToXmlChoiceWithNamespace4 record {
    record {
        @Choice {
            minOccurs: 2,
            maxOccurs: 3
        }
        Choice_A_toXmlWithNamespace4 choice_a;
    } nestedName;

    record {
        @Choice {
            minOccurs: 2,
            maxOccurs: 2
        }
        Choice_A_toXmlWithNamespace3 choice_a;
    } nestedName2;
};

type Choice_A_toXmlWithNamespace4 record {
    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    @Namespace {
        uri: "http://examplec.com",
        prefix: "c"        
    }
    string c?;

    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    @Namespace {
        uri: "http://exampleb.com",
        prefix: "a"        
    }
    string a?;

    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    @Namespace {
        uri: "http://exampleb.com",
        prefix: "b"        
    }
    string b?;
};

type Choice_A_toXmlWithNamespace5 record {
    @Element {
        minOccurs: 1,
        maxOccurs: 1
    }
    @Namespace {
        uri: "http://examplea.com",
        prefix: "c"        
    }
    string c?;

    @Namespace {
        uri: "http://examplea.com",
        prefix: "a"        
    }
    @Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    string a?;

    @Element {
        minOccurs: 2,
        maxOccurs: 3
    }
    @Namespace {
        uri: "http://examplea.com",
        prefix: "b"        
    }
    string b?;
};

@test:Config {groups: ["xsd", "to_xml"], dataProvider: testToXmlDataProviderWithNamespaces2}
function testToXmlWithXsdWithNamespace(typedesc<record{}> recordType, record{} value, xml expected) returns error?{
    xml|Error xmlResult = toXml(check value.ensureType(recordType), {});
    test:assertEquals(xmlResult, expected);
}

function testToXmlDataProviderWithNamespaces2() returns [typedesc<record{}>, record{}, xml][] {
    return [[
            ToXmlChoiceWithNamespace1,
            <ToXmlChoiceWithNamespace1>{choice_a: {b: "B"}},
            xml `<A><b:b xmlns:b="http://exampleb.com">B</b:b></A>`
        ], 
        [
            ToXmlChoiceWithNamespace2,
            <ToXmlChoiceWithNamespace2>{choice_a: {c: "C"}, choice_b: {b: "B", a: "A", c: "C"}},
            xml `<A><c:c xmlns:c="http://examplea.com">C</c:c><c>C</c><a:a xmlns:a="http://examplea.com">A</a:a><b>B</b></A>`
        ],
        [
            ToXmlChoiceWithNamespace4,
            <ToXmlChoiceWithNamespace4>{nestedName: {choice_a: {b: "B", a: "A"}}, nestedName2: {choice_a: {b: "B", a: "A"}}},
            xml `<A><nestedName><a:a xmlns:a="http://exampleb.com">A</a:a><b:b xmlns:b="http://exampleb.com">B</b:b></nestedName><nestedName2><a:a xmlns:a="http://examplea.com">A</a:a><b>B</b></nestedName2></A>`
        ]
    ];
}
