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

# Asserts that `toXmlString` produces exactly the text `toXml(...).toString()` produces
# for the given value.
#
# + value - The value to convert through both APIs
# + return - An error if either conversion fails or the outputs differ
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

type ContentOnlyRecord record {|
    string \#content;
|};

type RecordWithEmptyNested record {|
    record {||} inner;
    string name;
|};

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForRootTextContent() returns error? {
    ContentOnlyRecord data = {\#content: "only text"};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForMapOfXml() returns error? {
    map<xml> data = {"value": xml `<text>1</text>`, "value1": xml `<text>2</text>`};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForAnyAnnotatedField() returns error? {
    EmployeeWithAny data = {name: "n1", anyElement: <PersonInfo>{age: 3, country: "LK"}};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForXsdSequenceArray() returns error? {
    XsdSequenceArrayWithXmlValue5 data = {
        seq_XsdSequenceArrayWithXmlValue5: [{age: 1, salary: 1.0}, {age: 2, salary: 2.0}]
    };
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringErrorParityForXsdSequenceArray() returns error? {
    XsdSequenceArrayWithXmlValue5 data = {
        seq_XsdSequenceArrayWithXmlValue5: [{age: 1, salary: 1.0}]
    };
    xml|Error treeResult = toXml(data);
    string|Error stringResult = toXmlString(data);
    if treeResult is Error && stringResult is Error {
        test:assertEquals(stringResult.message(), treeResult.message(),
                msg = "error messages differ between toXml and toXmlString");
        return;
    }
    test:assertFail("both APIs were expected to return an occurrence-violation error");
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForNonPlainKeyNames() returns error? {
    map<string> data = {"item.one": "1", "item-two": "2", "_three": "3"};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForArrayWithNilElements() returns error? {
    record {|string name; (int|())[] values;|} data = {name: "n", values: [1, (), 3]};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForDefaultNamespaceReset() returns error? {
    Purchased_Bill data = {
        PurchasedItems: {
            PLine: [
                {ItemCode: "223345", Count: 10},
                {ItemCode: {"discount": "22%", "#content": "200777"}, Count: 7}
            ]
        },
        Address: {StreetAddress: "20, Palm grove, Colombo 3", City: "Colombo", Zip: 300, Country: "LK"},
        attr: "attr-val"
    };
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForNestedPrefixedNamespaces() returns error? {
    Purchased_Bill2 data = {
        PurchasedItems: {
            pLine: [
                {itemCode: "223345", count: 10},
                {itemCode: {discount: "22%", \#content: "200777"}, count: 7}
            ]
        },
        attr: "attr-val"
    };
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForEmptyMap() returns error? {
    map<string> data = {};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForTextOnlyMap() returns error? {
    map<string> data = {"#content": "top level text"};
    check assertToXmlStringParity(data);
    map<string> emptyText = {"#content": ""};
    check assertToXmlStringParity(emptyText);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForEmptyNestedRecordAndEmptyText() returns error? {
    RecordWithEmptyNested data = {inner: {}, name: ""};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForXsdChoice() returns error? {
    XSDChoiceWithXmlValueRecord data = {choice_XSDChoiceWithXmlValueRecord: {age: 3}};
    check assertToXmlStringParity(data);
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForAnyAnnotatedArray() returns error? {
    RecordWithOptionalAnyArray data = {
        id: "1",
        people: [{age: 1, country: "LK"}, {age: 2, country: "LK"}]
    };
    check assertToXmlStringParity(data);
}

# Asserts that both APIs produce the same outcome — equal text on success, or the
# same error message on failure — for inputs that may not be convertible.
#
# + value - The value to convert through both APIs
# + return - An error if the outcomes differ
isolated function assertToXmlStringOutcomeParity(map<anydata> value) returns error? {
    xml|Error treeResult = toXml(value);
    string|Error stringResult = toXmlString(value);
    if treeResult is xml && stringResult is string {
        test:assertEquals(stringResult, treeResult.toString());
        return;
    }
    if treeResult is Error && stringResult is Error {
        test:assertEquals(stringResult.message(), treeResult.message());
        return;
    }
    test:assertFail("one API succeeded while the other returned an error");
}

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringOutcomeParityForUnusualKeyNames() returns error? {
    check assertToXmlStringOutcomeParity({"1number": "v"});
    check assertToXmlStringOutcomeParity({"with space": "v"});
    check assertToXmlStringOutcomeParity({"with\"quote": "v"});
}

type RecordWithAnydataAnyArray record {|
    string id;
    @Any
    anydata[] anyElement;
|};

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringParityForAnydataAnyArray() returns error? {
    RecordWithAnydataAnyArray data = {
        id: "1",
        anyElement: [<PersonInfo>{age: 1, country: "LK"}, <AddressInfo>{city: "c", zip: "z"}]
    };
    check assertToXmlStringParity(data);
}

type RecordWithElementOccurrence record {|
    @Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    int[] counts;
|};

@test:Config {
    groups: ["toXmlString"]
}
isolated function testToXmlStringErrorParityForElementOccurrence() returns error? {
    check assertToXmlStringOutcomeParity(<RecordWithElementOccurrence>{counts: [1, 2, 3]});
    check assertToXmlStringOutcomeParity(<RecordWithElementOccurrence>{counts: []});
    check assertToXmlStringOutcomeParity(<RecordWithElementOccurrence>{counts: [1]});
}
