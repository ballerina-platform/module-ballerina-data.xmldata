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

@test:Config {
    groups: ["toXml"]
}
function testToXmlBasic1() returns error? {
    xml xmlVal = xml `<Data><A><B>1</B><B>2</B><C>6</C></A><A><B>3</B><B>4</B><C>5</C></A><D>5</D></Data>`;
    Data rec1 = check parseAsType(xmlVal);
    xml result1 = check toXml(rec1);
    test:assertTrue(result1 == xmlVal);
}

@test:Config {
    groups: ["toXml"]
}
function testToXmlBasic2() returns error? {
    xml xmlVal1 = xml `<Data1><A>1</A></Data1>`;
    Data1 rec1 = check parseAsType(xmlVal1);
    xml result1 = check toXml(rec1);
    test:assertTrue(result1 == xmlVal1);

    xml xmlVal2 = xml `<Data2><A>1</A></Data2>`;
    Data2 rec2 = check parseAsType(xmlVal2);
    xml result2 = check toXml(rec2);
    test:assertTrue(result2 == xmlVal2);
}

@test:Config {
    groups: ["toXml"]
}
function testToXmlBasic3() returns error? {
    // xml xmlval1 = xml `<Data3><A>1</A><B>2</B></Data3>`;
    // Data3 rec1 = check parseAsType(xmlval1);
    // xml result1 = check toXml(rec1);
    // test:assertTrue(result1 == xmlval1);

    // xml xmlVal2 = xml `<Data3><A>1</A><B>2</B></Data3>`;
    // Data4 rec2 = check parseAsType(xmlVal2);
    // xml result2 = check toXml(rec2);
    // test:assertTrue(result2 == xmlVal2);

    xml xmlVal3 = xml `<Data5><A><B>1</B></A><A><B>2</B></A><A><B>3</B></A></Data5>`;
    Data5 rec3 = check parseAsType(xmlVal3);
    xml result3 = check toXml(rec3);
    test:assertEquals(result3, xmlVal3);
}

@test:Config {
    groups: ["toXml"]
}
function testToXmlBasic4() returns error? {
    xml xmlVal1 = xml `<Data6><A><D><C><D>1</D><D>2</D></C><C><D>3</D><D>4</D></C></D></A></Data6>`;
    Data6 rec1 = check parseAsType(xmlVal1);
    xml result = check toXml(rec1);
    test:assertTrue(result == xmlVal1);
}

@test:Config {
    groups: ["toXml"]
}
function testToXmlBasic5() returns error? {
    xml xmlVal1 = xml `<Data>
        <A>
            <C>1</C>
        </A>
        <A>
            <C>2</C>
        </A>
    </Data>`;
    Data7 rec1 = check parseAsType(xmlVal1);
    xml result = check toXml(rec1);
    test:assertEquals(result, xml `<Data7><A><C>1</C></A><A><C>2</C></A></Data7>`);
}

@test:Config {
    groups: ["toXml"]
}
function testToXmlWithNameAnnotation() returns error? {
    xml xmlVal1 = xml `<Data8><A><D><C><D>1</D><D>2</D></C><C><D>3</D><D>4</D></C></D></A></Data8>`;
    Rec2 rec1 = check parseAsType(xmlVal1);
    xml result = check toXml(rec1);
    test:assertEquals(result, xmlVal1);
}

@test:Config {
    groups: ["toXml"]
}
function testToXmlWithNameSpaceAnnotation1() returns error? {
    NSRec1 rec = {\#content: "1"};
    xml result = check toXml(rec);
    test:assertEquals(result, xml `<x:foo xmlns:x="example.com">1</x:foo>`);
}

@test:Config {
    groups: ["toXml"]
}

function testToXmlWithNameSpaceAnnotation2() returns error? {
    NSRec3 rec = {bar: {baz: "2"}};
    xml result = check toXml(rec);
    test:assertEquals(result.toString(),
        string `<x:foo xmlns:x="example.com"><x:bar><baz xmlns="example2.com">2</baz></x:bar></x:foo>`);
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapJsonToXml1() returns error? {
    map<json> data = {id: 30, customer: {name: "Asha", age: 10}};
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><id>30</id><customer><name>Asha</name><age>10</age></customer></root>`,
                    msg = "testMapJsonToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testDefaultRecordToXml1() returns error? {
    record {int id;} data = {id: 30};
    xml result = check toXml(data);
    test:assertEquals(result, xml `<id>30</id>`, msg = "testDefaultRecordToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testDefaultRecordToXml2() returns error? {
    record {int id; string name;} data = {id: 30, name: "Asha"};
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><id>30</id><name>Asha</name></root>`,
                    msg = "testDefaultRecordToXml2 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapStringToXml1() returns error? {
    map<string> data = {"id": "30"};
    xml result = check toXml(data);
    test:assertEquals(result, xml `<id>30</id>`, msg = "testMapStringToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapStringToXml2() returns error? {
    map<string> data = {"id": "30", "name": "Asha"};
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><id>30</id><name>Asha</name></root>`,
                    msg = "testMapStringToXml2 result incorrect");
}

@Name {
    value: "Customers"
}
@Namespace {
    prefix: "ns",
    uri: "http://sdf.com"
}
type Customer record {

    @Name {
        value: "employeeName"
    }
    @Namespace {
        prefix: "ns",
        uri: "http://sdf.com"
    }
    @Attribute
    string name;

    int age;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithAnnotationToXml1() returns error? {
    Customer data = {name: "Asha", age: 10};
    xml result = check toXml(data);
    test:assertEquals(result,
                    xml `<ns:Customers xmlns:ns="http://sdf.com" ns:employeeName="Asha"><age>10</age></ns:Customers>`,
                    msg = "testRecordWithAnnotationToXml1 result incorrect");
}

@Namespace {
    prefix: "ns",
    uri: "http://sdf.com"
}
@Name {
    value: "Customers"
}
type Customer2 record {

    @Name {
        value: "employeeName"
    }
    @Namespace {
        prefix: "ns",
        uri: "http://sdf.com"
    }
    @Attribute
    string name;

    int age;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithAnnotationToXml2() returns error? {
    Customer2 data = {name: "Asha", age: 10};
    xml result = check toXml(data);
    test:assertEquals(result,
                    xml `<ns:Customers xmlns:ns="http://sdf.com" ns:employeeName="Asha"><age>10</age></ns:Customers>`,
                    msg = "testRecordWithAnnotationToXml2 result incorrect");
}

@Namespace {
    prefix: "ns",
    uri: "http://sdf.com"
}
@Name {
    value: "Customers"
}
type Customer3 record {

    @Namespace {
        prefix: "ns",
        uri: "http://sdf.com"
    }
    @Attribute
    @Name {
        value: "employeeName"
    }
    string name;

    int age;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithAnnotationToXml3() returns error? {
    Customer3 data = {name: "Asha", age: 10};
    xml result = check toXml(data);
    test:assertEquals(result,
                    xml `<ns:Customers xmlns:ns="http://sdf.com" ns:employeeName="Asha"><age>10</age></ns:Customers>`,
                    msg = "testRecordWithAnnotationToXml3 result incorrect");
}

@Namespace {
    prefix: "ns",
    uri: "http://sdf.com"
}
@Name {
    value: "Customers"
}
type Customer4 record {

    @Attribute
    @Namespace {
        prefix: "ns",
        uri: "http://sdf.com"
    }
    @Name {
        value: "employeeName"
    }
    string name;

    int age;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithAnnotationToXml4() returns error? {
    Customer4 data = {name: "Asha", age: 10};
    xml result = check toXml(data);
    test:assertEquals(result,
                    xml `<ns:Customers xmlns:ns="http://sdf.com" ns:employeeName="Asha"><age>10</age></ns:Customers>`,
                    msg = "testRecordWithAnnotationToXml4 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapXmlToXml() returns error? {
    map<xml> data = {
        "value": xml `<text>1</text>`,
        "value1": xml `<text>2</text>`
    };
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><value><text>1</text></value><value1><text>2</text></value1></root>`,
    msg = "testMapXmLToXml result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapStringToXml3() returns error? {
    map<string> data = {
        "series": "Dark",
        genre: "Sci-Fi",
        language: "German",
        seasons: "3",
        "id": "3296"
    };
    string expected = "<root>" +
                        "<series>Dark</series>" +
                        "<genre>Sci-Fi</genre>" +
                        "<language>German</language>" +
                        "<seasons>3</seasons>" +
                        "<id>3296</id>" +
                    "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapStrinToXml3 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapBooleanToXml1() returns error? {
    map<boolean> data = {
        boolean1: true,
        boolean2: false
    };
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><boolean1>true</boolean1><boolean2>false</boolean2></root>`,
                    msg = "testMapBooleanToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapIntToXml() returns error? {
    map<int> data = {
        value: 5,
        value1: 6
    };
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><value>5</value><value1>6</value1></root>`,
                    msg = "testFromJSON result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapDecimalToXml() returns error? {
    map<decimal> data = {
        value: 5.0,
        value1: 6.2
    };
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><value>5.0</value><value1>6.2</value1></root>`,
                    msg = "testFromJSON result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapFloatToXml() returns error? {
    map<float> data = {
        value: 5.0,
        value1: 6.4
    };
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><value>5.0</value><value1>6.4</value1></root>`,
                    msg = "testFromJSON result incorrect");
}

type NewEmployee record {
    readonly string name;
    int salary;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testMapTableToXml() returns error? {
    table<map<string>> tableValue = table [{key: "value"}];
    map<table<map<string>>> data = {
        data: tableValue
    };
    xml result = check toXml(data);
    test:assertEquals(result, xml `<root><data><key>value</key></data></root>`, msg = "testFromJSON result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapStringArrayToXml() returns error? {
    map<string[]> data = {
        key1: ["value1", "value2"],
        key2: ["value1", "value2"]
    };
    xml result = check toXml(data);
    test:assertEquals(result,
                    xml `<root><key1>value1</key1><key1>value2</key1><key2>value1</key2><key2>value2</key2></root>`,
                    msg = "testMapStringArrayToXml result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapIntArrayToXml() returns error? {
    map<int[]> data = {
        key1: [1, 2],
        key2: [1, 2],
        key3: [1, 2]
    };
    string expected = "<root>" +
                            "<key1>1</key1>" +
                            "<key1>2</key1>" +
                            "<key2>1</key2>" +
                            "<key2>2</key2>" +
                            "<key3>1</key3>" +
                            "<key3>2</key3>" +
                        "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapIntArrayToXml result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapDecimalArrayToXml() returns error? {
    map<decimal[]> data = {
        key1: [1.0, 2.0],
        key2: [1.0, 2.0],
        key3: [1.0, 2.0]
    };
    string expected = "<root>" +
                        "<key1>1.0</key1>" +
                        "<key1>2.0</key1>" +
                        "<key2>1.0</key2>" +
                        "<key2>2.0</key2>" +
                        "<key3>1.0</key3>" +
                        "<key3>2.0</key3>" +
                    "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapDecimalArrayToXml result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapFloatArrayToXml() returns error? {
    map<float[]> data = {
        key1: [1.0, 2.0],
        key2: [1.0, 2.0],
        key3: [1.0, 2.0]
    };
    string expected = "<root>" +
                            "<key1>1.0</key1>" +
                            "<key1>2.0</key1>" +
                            "<key2>1.0</key2>" +
                            "<key2>2.0</key2>" +
                            "<key3>1.0</key3>" +
                            "<key3>2.0</key3>" +
                        "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapFloatArrayToXml result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapJsonArrayToXml1() returns error? {
    map<json[]> data = {customer: [{name: "Asha", age: 10}, {name: "Kalai", age: 12}]};
    string expected = "<root>" +
                        "<customer>" +
                            "<name>Asha</name>" +
                            "<age>10</age>" +
                        "</customer>" +
                        "<customer>" +
                            "<name>Kalai</name>" +
                            "<age>12</age>" +
                        "</customer>" +
                    "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapJsonToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapXmlArrayToXml1() returns error? {
    map<xml[]> data = {
        customer:
        [
            xml `<name>Asha</name><age>10</age>`,
            xml `<name>Kalai</name><age>13</age>`
        ],
        employee:
        [
            xml `<name>Asha</name><age>10</age>`,
            xml `<name>Kalai</name><age>13</age>`
        ]
    };
    string expected = "<root>" +
                        "<customer>" +
                            "<name>Asha</name>" +
                            "<age>10</age>" +
                        "</customer>" +
                        "<customer>" +
                            "<name>Kalai</name>" +
                            "<age>13</age>" +
                        "</customer>" +
                        "<employee>" +
                            "<name>Asha</name>" +
                            "<age>10</age>" +
                        "</employee>" +
                        "<employee>" +
                            "<name>Kalai</name>" +
                            "<age>13</age>" +
                        "</employee>" +
                    "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapXmlArrayToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
function testMapXmlArrayToXml2() returns error? {
    map<xml[]> m2 = {
        emplyee: [xml `Kanth`, xml `Kevin`]
    };
    xml x2 = check toXml(m2);
    test:assertEquals(x2, xml `<root><emplyee>Kanth</emplyee><emplyee>Kevin</emplyee></root>`,
                    msg = "testMapXmlArrayToXml2 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordArrayToXml1() returns error? {
    Customer[] customers = [{name: "Asha", age: 10}, {name: "Kalai", age: 10}];
    map<Customer[]> data = {customers: customers};
    string expected = "<root>" +
                        "<customers xmlns:ns=\"http://sdf.com\" ns:employeeName=\"Asha\">" +
                            "<age>10</age>" +
                        "</customers>" +
                        "<customers xmlns:ns=\"http://sdf.com\" ns:employeeName=\"Kalai\">" +
                            "<age>10</age>" +
                        "</customers>" +
                    "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testRecordToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordArrayToXml2() returns error? {
    Customer[] customers = [{name: "Asha", age: 10}, {name: "Kalai", age: 10}];
    map<Customer[]> data = {customer1: customers, customer2: customers};
    string expected = "<root>" +
                        "<customer1 xmlns:ns=\"http://sdf.com\" ns:employeeName=\"Asha\">" +
                            "<age>10</age>" +
                        "</customer1>" +
                        "<customer1 xmlns:ns=\"http://sdf.com\" ns:employeeName=\"Kalai\">" +
                            "<age>10</age>" +
                        "</customer1>" +
                        "<customer2 xmlns:ns=\"http://sdf.com\" ns:employeeName=\"Asha\">" +
                            "<age>10</age>" +
                        "</customer2>" +
                        "<customer2 xmlns:ns=\"http://sdf.com\" ns:employeeName=\"Kalai\">" +
                            "<age>10</age>" +
                        "</customer2>" +
                    "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testRecordToXml1 result incorrect");
}

@test:Config {
    groups: ["toXml"]
}
isolated function testMapTableToXml1() returns error? {
    table<map<string>> tableValue = table [
        {key: "value", key1: "value1"},
        {key2: "value2", key3: "value3"}
    ];
    map<table<map<string>>> data = {
        data: tableValue
    };
    string expected = "<root>" +
                        "<data>" +
                            "<key>value</key>" +
                            "<key1>value1</key1>" +
                        "</data>" +
                        "<data>" +
                            "<key2>value2</key2>" +
                            "<key3>value3</key3>" +
                        "</data>" +
                        "</root>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testMapTableToXml1 result incorrect");
}

@Namespace {
    prefix: "nso",
    uri: "http://www.w3.org/"
}
type Root record {
    string name;

    @Attribute
    string xmlns\:asd = "http://www.w3.org1/";
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordToXml2() returns error? {
    Root data = {name: "Asha"};
    xml result = check toXml(data);
    string expected = "<nso:Root xmlns:nso=\"http://www.w3.org/\" xmlns:asd=\"http://www.w3.org1/\">" +
                        "<name>Asha</name>" +
                    "</nso:Root>";
    test:assertEquals(result.toString(), expected, msg = "testRecordToXml1 result incorrect");
}

type Root31 record {
    string name;

    @Attribute
    string xmlns\:nso = "http://www.w3.org1/";
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordToXml3() returns error? {
    Root31 data = {name: "Asha"};
    xml result = check toXml(data);
    string expected = "<Root31 xmlns:nso=\"http://www.w3.org1/\"><name>Asha</name></Root31>";
    test:assertEquals(result.toString(), expected, msg = "testRecordToXml3 result incorrect");
}

type Commercial6 record {
    BookStore6 bookstore;
};

type BookStore6 record {
    string storeName;
    int postalCode;
    boolean isOpen;
    @Name {
        value: "address"
    }
    Address6 add;
    @Name {
        value: "codes"
    }
    Codes6 codeValues;
    @Attribute
    string status;
    @Attribute
    string 'xmlns\:ns0;
};

type Address6 record {
    string street;
    string city;
    string country;
};

type Codes6 record {
    @Name {
        value: "item"
    }
    int[] items;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testComplexRecordToXml() returns error? {
    Commercial6 data = {
        bookstore: {
            storeName: "foo",
            postalCode: 94,
            isOpen: true,
            add: {
                street: "Galle Road",
                city: "Colombo",
                country: "Sri Lanka"
            },
            codeValues: {
                items: [4, 8, 9]
            },
            'xmlns\:ns0: "http://sample.com/test",
            status: "online"
        }
    };
    string expected = "<Commercial6>" +
                        "<bookstore xmlns:ns0=\"http://sample.com/test\" status=\"online\">" +
                            "<storeName>foo</storeName>" +
                            "<postalCode>94</postalCode>" +
                            "<isOpen>true</isOpen>" +
                            "<address>" +
                                "<street>Galle Road</street>" +
                                "<city>Colombo</city>" +
                                "<country>Sri Lanka</country>" +
                            "</address>" +
                            "<codes>" +
                                "<item>4</item>" +
                                "<item>8</item>" +
                                "<item>9</item>" +
                            "</codes>" +
                        "</bookstore>" +
                    "</Commercial6>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testComplexRecordToXml result incorrect");
}

@Namespace {
    uri: "example.com"
}
type Purchased_Bill record {
    Purchased_Items PurchasedItems;
    Purchased_Address Address;
    @Attribute
    @Namespace {
        prefix: "ns",
        uri: "ns.com"
    }
    string attr?;
};

type Purchased_Items record {
    Purchased_Purchase[] PLine;
};

type Purchased_Purchase record {
    string|Purchased_ItemCode ItemCode;
    int Count;
};

type Purchased_ItemCode record {
    @Attribute
    string discount;
    string \#content?;
};

@Namespace {
    uri: ""
}
type Purchased_Address record {
    string StreetAddress;
    string City;
    int Zip;
    string Country;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithNamespaceAnnotationToXml() returns error? {
    Purchased_Bill input = {
        PurchasedItems: {
            PLine: [
                {ItemCode: "223345", Count: 10},
                {ItemCode: "223300", Count: 7},
                {
                    ItemCode: {discount: "22%", \#content: "200777"},
                    Count: 7
                }
            ]
        },
        Address: {
            StreetAddress: "20, Palm grove, Colombo 3",
            City: "Colombo",
            Zip: 300,
            Country: "LK"
        },
        attr: "attr-val"
    };
    string expected =
        "<Purchased_Bill xmlns=\"example.com\" xmlns:ns=\"ns.com\" ns:attr=\"attr-val\">" +
            "<PurchasedItems>" +
                "<PLine>" +
                    "<ItemCode>223345</ItemCode>" +
                    "<Count>10</Count>" +
                "</PLine>" +
                "<PLine>" +
                    "<ItemCode>223300</ItemCode>" +
                    "<Count>7</Count>" +
                "</PLine>" +
                "<PLine>" +
                    "<ItemCode discount=\"22%\">200777</ItemCode>" +
                    "<Count>7</Count>" +
                "</PLine>" +
            "</PurchasedItems>" +
            "<Address xmlns=\"\">" +
                "<StreetAddress>20, Palm grove, Colombo 3</StreetAddress>" +
                "<City>Colombo</City>" +
                "<Zip>300</Zip>" +
                "<Country>LK</Country>" +
            "</Address>" +
        "</Purchased_Bill>";
    xml result = check toXml(input);
    test:assertEquals(result.toString(), expected, msg = "testComplexRecordToXml result incorrect");
}

@Namespace {
    uri: "example.com"
}
type Purchased_Bill1 record {
    @Name {
        value: "PurchasedItems"
    }
    Purchased_Items1 PurchasedItem;
    @Attribute
    @Namespace {
        prefix: "ns",
        uri: "ns.com"
    }
    string attr?;
};

@Namespace {
    prefix: "ns0",
    uri: "example.com"
}
type Purchased_Items1 record {
    Purchased_Purchase1[] PLine;
};

type Purchased_Purchase1 record {
    string|Purchased_ItemCode1 ItemCode;
    int Count;
};

@Namespace {
    prefix: "ns2",
    uri: "example1.com"
}
type Purchased_ItemCode1 record {
    @Attribute
    string discount;
    string \#content?;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithNamaspaceAnnotationToXml1() returns error? {
    Purchased_Bill1 input = {
        PurchasedItem: {
            PLine: [
                {ItemCode: "223345", Count: 10},
                {ItemCode: "223300", Count: 7},
                {
                    ItemCode: {discount: "22%", \#content: "200777"},
                    Count: 7
                }
            ]
        },
        attr: "attr-val"
    };
    string expected =
        "<Purchased_Bill1 xmlns=\"example.com\" xmlns:ns=\"ns.com\" ns:attr=\"attr-val\">" +
            "<ns0:PurchasedItems xmlns:ns0=\"example.com\">" +
                "<PLine>" +
                    "<ItemCode>223345</ItemCode>" +
                    "<Count>10</Count>" +
                "</PLine>" +
                "<PLine>" +
                    "<ItemCode>223300</ItemCode>" +
                    "<Count>7</Count>" +
                "</PLine>" +
                "<PLine>" +
                    "<ns2:ItemCode xmlns:ns2=\"example1.com\" discount=\"22%\">200777</ns2:ItemCode>" +
                    "<Count>7</Count>" +
                "</PLine>" +
            "</ns0:PurchasedItems>" +
        "</Purchased_Bill1>";
    xml result = check toXml(input);
    test:assertEquals(result.toString(), expected, msg = "testRecordWithNamaspaceAnnotationToXml1 result incorrect");
}

@Namespace {
    prefix: "ns0",
    uri: "example.com"
}
type Purchased_Bill2 record {
    Purchased_Items2 PurchasedItems;
    @Attribute
    @Namespace {
        prefix: "ns",
        uri: "ns.com"
    }
    string attr?;
};

@Namespace {
    prefix: "ns1",
    uri: "example1.com"
}
type Purchased_Items2 record {
    Purchased_Purchase2[] pLine;
};

@Namespace {
    prefix: "ns2",
    uri: "example2.com"
}
type Purchased_Purchase2 record {
    string|Purchased_ItemCode2 itemCode;
    int count;
};

@Namespace {
    uri: "example1.com"
}
type Purchased_ItemCode2 record {
    @Attribute
    string discount;
    string \#content?;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithNamaspaceAnnotationToXml2() returns error? {
    Purchased_Bill2 input = {
        PurchasedItems: {
            pLine: [
                {itemCode: "223345", count: 10},
                {itemCode: "223300", count: 7},
                {
                    itemCode: {discount: "22%", \#content: "200777"},
                    count: 7
                }
            ]
        },
        attr: "attr-val"
    };
    string expected =
        "<ns0:Purchased_Bill2 xmlns:ns0=\"example.com\" xmlns:ns=\"ns.com\" ns:attr=\"attr-val\">" +
            "<ns1:PurchasedItems xmlns:ns1=\"example1.com\">" +
                "<ns2:pLine xmlns:ns2=\"example2.com\">" +
                    "<itemCode>223345</itemCode>" +
                    "<count>10</count>" +
                "</ns2:pLine>" +
                "<ns2:pLine xmlns:ns2=\"example2.com\">" +
                    "<itemCode>223300</itemCode>" +
                    "<count>7</count>" +
                "</ns2:pLine>" +
                "<ns2:pLine xmlns:ns2=\"example2.com\">" +
                    "<itemCode xmlns=\"example1.com\" discount=\"22%\">200777</itemCode>" +
                    "<count>7</count>" +
                "</ns2:pLine>" +
            "</ns1:PurchasedItems>" +
        "</ns0:Purchased_Bill2>";
    xml result = check toXml(input);
    test:assertEquals(result.toString(), expected, msg = "testRecordWithNamaspaceAnnotationToXml2 result incorrect");
}

@Namespace {
    prefix: "ns",
    uri: "http://sdf.com"
}
type Invoices record {
    int id;
    string PurchasedItem;
    @Namespace {
        uri: "example2.com"
    }
    @Attribute
    string attr?;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithAnnotationToXml6() returns error? {
    Invoices data = {
        id: 1,
        PurchasedItem: "soap",
        attr: "attr-val"
    };
    string expected =
        "<ns:Invoices xmlns=\"example2.com\" xmlns:ns=\"http://sdf.com\" attr=\"attr-val\">" +
            "<id>1</id>" +
            "<PurchasedItem>soap</PurchasedItem>" +
        "</ns:Invoices>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testRecordWithAnnotationToXml6 result incorrect");
}

@Namespace {
    prefix: "ns",
    uri: "http://sdf.com"
}
type Invoices1 record {
    Items[] items;
    int id;
    @Namespace {
        uri: "example2.com"
    }
    @Attribute
    string attr?;
};

type Items record {
    string itemCode;
    int count;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithAnnotationToXml7() returns error? {
    Invoices1 data = {
        items: [
            {itemCode: "223345", count: 1},
            {itemCode: "223300", count: 7}
        ],
        id: 1,
        attr: "attr-val"
    };
    string expected =
        "<ns:Invoices1 xmlns=\"example2.com\" xmlns:ns=\"http://sdf.com\" attr=\"attr-val\">" +
            "<items>" +
                "<itemCode>223345</itemCode>" +
                "<count>1</count>" +
            "</items>" +
            "<items>" +
                "<itemCode>223300</itemCode>" +
                "<count>7</count>" +
            "</items>" +
            "<id>1</id>" +
        "</ns:Invoices1>";
    xml result = check toXml(data);
    test:assertEquals(result.toString(), expected, msg = "testRecordWithAnnotationToXml6 result incorrect");
}

@Namespace {
    prefix: "nso",
    uri: "example.com"
}
@Name {
    value: "PurchasedBill"
}
type Example record {
    PurchasedItems PurchasedItems;
    PurchasedAddress Address;
    @Namespace {
        prefix: "ns",
        uri: "ns.com"
    }
    @Attribute
    string attr?;
};

@Namespace {
    prefix: "ns1",
    uri: "example1.com"
}
@Name {
    value: "PurchasedPurchase"
}
type PurchasedItems record {
    Example1[] PLine;
};

@Namespace {
    prefix: "ns2",
    uri: "example1.com"
}
type Example1 record {
    string|PurchasedItemCode ItemCode;
    int Count;
    @Attribute
    string attr?;
};

@Namespace {
    prefix: "ns3",
    uri: "example1.com"
}
type PurchasedItemCode record {
    @Attribute
    string discount;
    string \#content?;
};

@Namespace {
    uri: "example3.com"
}
type PurchasedAddress record {
    string StreetAddress;
    string City;
    int Zip;
    string Country;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordWithNamespaceAnnotationToXml1() returns error? {
    Example input = {
        PurchasedItems: {
            PLine: [
                {ItemCode: "223345", Count: 10, attr: "1"},
                {ItemCode: "223300", Count: 7},
                {
                    ItemCode: {discount: "22%", \#content: "200777"},
                    Count: 7
                }
            ]
        },
        Address: {
            StreetAddress: "20, Palm grove, Colombo 3",
            City: "Colombo",
            Zip: 300,
            Country: "LK"
        },
        attr: "attr-val"
    };
    string expected =
        "<nso:PurchasedBill xmlns:nso=\"example.com\" xmlns:ns=\"ns.com\" ns:attr=\"attr-val\">" +
        "<ns1:PurchasedPurchase xmlns:ns1=\"example1.com\">" +
            "<ns1:PLine xmlns:ns2=\"example1.com\" attr=\"1\">" +
            "<ItemCode>223345</ItemCode>" +
            "<Count>10</Count>" +
            "</ns1:PLine>" +
            "<ns1:PLine xmlns:ns2=\"example1.com\">" +
            "<ItemCode>223300</ItemCode>" +
            "<Count>7</Count>" +
            "</ns1:PLine>" +
            "<ns1:PLine xmlns:ns2=\"example1.com\">" +
            "<ns1:ItemCode xmlns:ns3=\"example1.com\" discount=\"22%\">200777</ns1:ItemCode>" +
            "<Count>7</Count>" +
            "</ns1:PLine>" +
            "</ns1:PurchasedPurchase>" +
            "<Address xmlns=\"example3.com\">" +
            "<StreetAddress>20, Palm grove, Colombo 3</StreetAddress>" +
            "<City>Colombo</City>" +
            "<Zip>300</Zip>" +
            "<Country>LK</Country>" +
            "</Address>" +
        "</nso:PurchasedBill>";
    xml result = check toXml(input);
    test:assertEquals(result.toString(), expected, msg = "testComplexRecordToXml result incorrect");
}

type AddressR1 record {|
    string city;
    int code; 
|};

type Wsa_ReplyTo1 record {
    @Namespace {prefix: "wsa", uri: "example1.com"}
    AddressR1 Address;
};

type Htng_ReplyTo1 record {
    @Namespace {prefix: "wsa", uri: "example1.com"}
    AddressR1 Address;
};

@Name {value: "soap"}
type Soap1 record {
    @Name {value: "ReplyTo"}
    @Namespace {prefix: "wsa", uri: "example1.com"}
    Wsa_ReplyTo1 wsaReplyTo;
    @Name {value: "ReplyTo"}
    @Namespace {prefix: "htng", uri: "example2.com"}
    Htng_ReplyTo1 htngReplyTo;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testXmlToRecordWithNamespaceAttachedToFields() returns error? {
    Soap1 val = {
        htngReplyTo: {
            Address: {
                code: 40000,
                city: "Colombo"
            }
        }, 
        wsaReplyTo: {
            Address: {
                code: 10000,
                city: "Kandy"
            }
        }
    };
    
    xml xmlVal = check toXml(val);
    string expected = "<soap>" +
    "<wsa:ReplyTo xmlns:wsa=\"example1.com\">" +
    "<wsa:Address><city>Kandy</city><code>10000</code></wsa:Address>" +
    "</wsa:ReplyTo><htng:ReplyTo xmlns:htng=\"example2.com\">" +
    "<wsa:Address xmlns:wsa=\"example1.com\"><city>Colombo</city><code>40000</code>" +
    "</wsa:Address></htng:ReplyTo></soap>";
    test:assertEquals(xmlVal.toString(), expected);
}

@Namespace {prefix: "wsa", uri: "example1.com"}
type AddressR2 record {|
    string city;
    int code; 
|};

@Namespace {prefix: "wsa", uri: "example1.com"}
type Wsa_ReplyTo2 record {
    @Namespace {prefix: "wsa", uri: "example1.com"}
    AddressR2 Address;
};

@Namespace {prefix: "htng", uri: "example2.com"}
type Htng_ReplyTo2 record {
    @Namespace {prefix: "wsa", uri: "example1.com"}
    AddressR2 Address;
};

@Name {value: "soap"}
type Soap2 record {
    @Name {value: "ReplyTo"}
    @Namespace {prefix: "wsa", uri: "example1.com"}
    Wsa_ReplyTo2 wsaReplyTo;
    @Name {value: "ReplyTo"}
    @Namespace {prefix: "htng", uri: "example2.com"}
    Htng_ReplyTo2 htngReplyTo;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testXmlToRecordWithNamespaceAttachedToFieldsAndTypes() returns error? {
    Soap2 val = {
        htngReplyTo: {
            Address: {
                code: 40000,
                city: "Colombo"
            }
        }, 
        wsaReplyTo: {
            Address: {
                code: 10000,
                city: "Kandy"
            }
        }
    };
    
    xml xmlVal = check toXml(val);
    string expected = "<soap>" +
    "<wsa:ReplyTo xmlns:wsa=\"example1.com\">" +
    "<wsa:Address><city>Kandy</city><code>10000</code></wsa:Address>" +
    "</wsa:ReplyTo><htng:ReplyTo xmlns:htng=\"example2.com\">" +
    "<wsa:Address xmlns:wsa=\"example1.com\"><city>Colombo</city><code>40000</code>" +
    "</wsa:Address></htng:ReplyTo></soap>";
    test:assertEquals(xmlVal.toString(), expected); 
}

type RequestorID record {
    @Attribute
    string ID;
    @Attribute
    string ID_Context;
    @Attribute
    string Type;
};

type Source record {
    RequestorID RequestorID;
};

@test:Config {
    groups: ["toXml"]
}
isolated function testUnderscoreInTheFieldName() returns error? {
    Source s = {
    RequestorID: {
        ID: "1", 
        ID_Context: "2", 
        Type: "3"}};
    xml xmlVal = check toXml(s);
    test:assertEquals(xmlVal.toString(), "<Source><RequestorID ID=\"1\" ID_Context=\"2\" Type=\"3\"/></Source>");
}

@Namespace {
    uri: "example.com"
}
type File record {|
    @Namespace {
        uri: "example.com"
    }
    string fileName;
    @Namespace {
        uri: "example.com"
    }
    string fileNamespace;
|};

@test:Config {
    groups: ["toXml"]
}
isolated function testToRecordFieldNameEndsWithNameOrNamespace() returns error? {
    File file = {
        fileName: "test.bal",
        fileNamespace: "wso2.com"
    };

    xml result = check toXml(file);
    string expected = "<File xmlns=\"example.com\"><fileName>test.bal</fileName><fileNamespace>wso2.com</fileNamespace></File>";
    test:assertEquals(result.toString(), expected);
}

type String string;

type VersionType String;

@Name {
    value: "Payload"
}
type Payload1 record {
    @Attribute
    string 'version?;
    VersionType 'type?;
};

type Map map<json>;

@Name {
    value: "Payload"
}
type Payload2 record {|
    @Attribute
    string 'version?;
    Map value;
|};

@test:Config {
    groups: ["toXml"]
}
isolated function testRecordFieldTypeAsReferenceTypeForToXml() returns error? {
    Payload1 payload1 = {'version: "1.0", 'type: "example"};
    xml result = check toXml(payload1); 
    test:assertEquals(result.toString(), "<Payload version=\"1.0\"><type>example</type></Payload>");
    
    Payload2 payload2 = {'version: "1.0", value: {id: "243", name: "Kanth"}};
    xml result2 = check toXml(payload2);
    test:assertEquals(result2.toString(), "<Payload version=\"1.0\"><value><id>243</id><name>Kanth</name></value></Payload>");
}

@test:Config {
    groups: ["toXml"]
}
function testMapXmltoXmlNegative() {
    map<xml|int> data = {
        "value": xml `<text>1</text>`,
        "value1": 2
    };
    xml|Error result = toXml(data);
    test:assertEquals((<Error>result).message(), "unsupported input type");
}
