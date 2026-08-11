// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

type ScaleLine record {|
    int lineNumber;
    decimal rate;
|};

type BatchRecord record {|
    string material;
    decimal amount;
    string currencyCode;
    ScaleLine[] scales;
|};

type BatchDocument record {|
    BatchRecord[] batchRecord;
|};

type TextFieldRecord record {|
    string attribute_id;
    string \#content;
|};

isolated function assertToXmlStringParity(map<anydata> value) returns error? {
    xml treeResult = check toXml(value);
    string stringResult = check toXmlString(value);
    test:assertEquals(stringResult, treeResult.toString(),
            msg = "toXmlString output differs from toXml(...).toString()");
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForSimpleRecord() returns error? {
    SimpleRecord data = {name: "Asha"};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForComplexRecord() returns error? {
    ComplexRecord data = {name: "Asha", count: 3, description: "first < second & \"third\""};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForNestedUnion() returns error? {
    RecordWithNestedUnion data = {id: "1", nested: <ComplexRecord>{name: "n", count: 2, description: "d"}};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForDeepUnion() returns error? {
    RecordWithDeepUnion data = {id: "9", deepField: <Level2Union>{l2Name: "b", inner: {l1Name: "a"}}};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForAnnotatedRecord() returns error? {
    Customer data = {name: "Asha", age: 10};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForMapValue() returns error? {
    map<string> data = {a: "1", b: "two", c: "three & four"};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForEmptyRecord() returns error? {
    record {||} data = {};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForEmptyArrayField() returns error? {
    RecordWithEmptyArray data = {id: "1", items: []};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForTextFieldAndAttribute() returns error? {
    TextFieldRecord data = {attribute_id: "id-1", \#content: "text < & > content"};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForBatchDocument() returns error? {
    BatchRecord[] batchRecords = [];
    foreach int i in 0 ..< 250 {
        batchRecords.push({
            material: string `MAT-${i}`,
            amount: <decimal>i + 0.09d,
            currencyCode: "USD",
            scales: [{lineNumber: 1, rate: 5.1d}, {lineNumber: 2, rate: 9.2d}]
        });
    }
    BatchDocument data = {batchRecord: batchRecords};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForRestFields() returns error? {
    record {|string name; anydata...;|} data = {name: "a", "extra": 42, "more": [1, 2, 3]};
    check assertToXmlStringParity(data);
}

// Nested namespaces: the child inherits the parent's prefix binding and the
// grandchild introduces a different default namespace. Asserts in-scope xmlns
// declarations are suppressed on descendants exactly like the tree serializer does.
@test:Config {
    groups: ["toXmlString"]
}
function testToXmlStringParityForNestedNamespaces() returns error? {
    NSRec3 data = {bar: {baz: "2"}};
    xml treeResult = check toXml(data);
    string stringResult = check toXmlString(data);
    test:assertEquals(stringResult, treeResult.toString(),
            msg = "toXmlString output differs from toXml(...).toString()");
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForRepeatedAnnotatedRecords() returns error? {
    map<Customer[]> data = {
        customer1: [{name: "Asha", age: 10}, {name: "Kalai", age: 10}],
        customer2: [{name: "Asha", age: 10}]
    };
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityWithCustomOptions() returns error? {
    TextFieldRecord data = {attribute_id: "id-1", \#content: "body"};
    Options options = {attributePrefix: "attribute_", textFieldName: "#content"};
    xml treeResult = check toXml(data, options);
    string stringResult = check toXmlString(data, options);
    test:assertEquals(stringResult, treeResult.toString(),
            msg = "toXmlString output differs from toXml(...).toString() with custom options");
}
