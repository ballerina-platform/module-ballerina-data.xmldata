// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

type PersonInfo record {
    int age;
    string country;
};

@Namespace {
    prefix: "emp",
    uri: "http://example.com/employee"
}
type PersonWithNS record {|
    @Namespace {
        prefix: "emp",
        uri: "http://example.com/employee"
    }
    int age;
    @Namespace {
        prefix: "emp",
        uri: "http://example.com/employee"
    }
    string country;
|};

type AddressInfo record {
    string city;
    string zip;
};

type EmployeeWithAny record {|
    string name;
    @Any
    PersonInfo|AddressInfo anyElement;
|};

type Department record {
    string deptName;
    int deptId;
};

type Company record {
    string companyName;
    @Any
    Department|PersonInfo nestedElement;
};

type MultiAnyRecord record {|
    string id;
    @Any
    PersonInfo|AddressInfo firstElement;
    @Any
    Department|PersonInfo secondElement;
|};

@Name {
    value: "Person"
}
type NamedPersonInfo record {
    int age;
    string country;
};

type EmployeeWithNamedAny record {
    string name;
    @Any
    NamedPersonInfo anyElement;
};

@Name {
    value: "Location"
}
type NamedAddressInfo record {
    string city;
    string zip;
};

type EmployeeWithNamedAnyUnion record {
    string name;
    @Any
    NamedPersonInfo|NamedAddressInfo anyElement;
};

type EmployeeWithSingleRecordAny record {|
    string name;
    @Any
    PersonInfo anyElement;
|};

type EmployeeWithAnyBase record {
    string name;
    @Any
    PersonInfo|AddressInfo anyElement;
};

type EmployeeWithAnyTypeRef EmployeeWithAnyBase;

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type NamespacedPersonInfo record {
    int age;
    string country;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns2"
}
type NamespacedAddressInfo record {
    string city;
    string zip;
};

type EmployeeWithNamespacedAny record {
    string name;
    @Any
    NamespacedPersonInfo|NamespacedAddressInfo anyElement;
};

@Namespace {
    prefix: "emp",
    uri: "http://example.com/employee"
}
type NamespacedEmployeeWithAny record {
    @Namespace {
        prefix: "emp",
        uri: "http://example.com/employee"
    }
    string name;
    @Any
    @Namespace {
        prefix: "emp",
        uri: "http://example.com/employee"
    }
    PersonWithNS|AddressInfo anyElement;
};

type PersonData record {
    string name;
};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
type ObjectWithAnydataAndMultipleAttrs record {|
    @Sequence {minOccurs: 0}
    SequenceGroupWithAnydataAndMultipleAttrs[] sequenceGroup;
    @Attribute
    string Id?;
    @Attribute
    string MimeType?;
    @Attribute
    string Encoding?;
|};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
type SequenceGroupWithAnydataAndMultipleAttrs record {|
    @Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
    @SequenceOrder {value: 1}
    @Any
    PersonData anyElement;
|};

type Project record {
    string projectName;
    int projectId;
};

type Task record {
    string taskName;
    string status;
};

type ChoiceWithAnyRecord record {|
    string id;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_ChoiceWithAnyRecord choice;
|};

type Choice_ChoiceWithAnyRecord record {|
    @Any
    PersonInfo|AddressInfo option1?;
    @Any
    Project|Task option2?;
|};

@Name {
    value: "InnerChoice"
}
type InnerChoiceRecordWithAny record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_InnerChoiceWithAny innerChoice;
|};

type Choice_InnerChoiceWithAny record {|
    @Any
    AddressInfo|Project deepOption1?;
    @Any
    Task|PersonInfo deepOption2?;
|};

type NestedChoiceWithAnyRecord record {|
    string name;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_NestedChoiceWithAny outerChoice;
|};

type Choice_NestedChoiceWithAny record {|
    InnerChoiceRecordWithAny innerOption1?;
    @Any
    PersonInfo|Department innerOption2?;
|};

type MultipleChoicesWithAnyRecord record {|
    string recordId;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_MultiChoiceAny1 firstChoice;
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    Choice_MultiChoiceAny2 secondChoice;
|};

type Choice_MultiChoiceAny1 record {|
    @Any
    PersonInfo|AddressInfo option1?;
    string simpleOption?;
|};

type Choice_MultiChoiceAny2 record {|
    @Any
    Project|Task option2?;
    int numericOption?;
|};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
type PersonData2 record {
    string name;
};

@Name {value: "Object"}
@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type Object1 record {|
    @Sequence {minOccurs: 0}
    SequenceGroup621[] sequenceGroup62;
    @Attribute
    string Id?;
    @Attribute
    string MimeType?;
    @Attribute
    string Encoding?;
|};

@Name {value: "Object"}
@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type Object2 record {|
    @Sequence {minOccurs: 0}
    SequenceGroup622[] sequenceGroup62;
    @Attribute
    string Id?;
    @Attribute
    string MimeType?;
    @Attribute
    string Encoding?;
|};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type SequenceGroup621 record {|
    @Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
    @SequenceOrder {value: 1}
    @Any
    anydata anyElement;
|};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type SequenceGroup622 record {|
    @Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
    @SequenceOrder {value: 1}
    @Any
    anydata[]? anyElement;
|};

@Namespace {uri: "http://example.com/seq"}
type SequenceWithOptionalAny record {|
    @Sequence {minOccurs: 0}
    OptionalAnyGroup[] groups;
|};

@Namespace {uri: "http://example.com/seq"}
type OptionalAnyGroup record {|
    @SequenceOrder {value: 1}
    string requiredField;
    @SequenceOrder {value: 2}
    @Any
    PersonData? optionalAnyField;
|};

type RecordWithOptionalAny record {|
    string id;
    @Any
    PersonInfo? optionalPerson;
|};

type RecordWithMultipleOptionalAny record {|
    string name;
    @Any
    PersonInfo? person;
    @Any
    AddressInfo? address;
    @Any
    Department? dept;
|};

@Namespace {uri: "http://example.com/empty"}
type SequenceWithEmptyGroups record {|
    @Sequence {minOccurs: 0}
    EmptyAnyGroup[] groups;
|};

@Namespace {uri: "http://example.com/empty"}
type EmptyAnyGroup record {|
    @SequenceOrder {value: 1}
    @Any
    PersonData? anyField;
|};

type InnerRecordWithOptionalAny record {|
    string innerName;
    @Any
    PersonInfo? innerPerson;
|};

type OuterRecordWithNestedOptionalAny record {|
    string outerName;
    InnerRecordWithOptionalAny inner;
|};

type RecordWithOptionalAnyUnion record {|
    string id;
    @Any
    (PersonInfo|AddressInfo)? optionalUnion;
|};

type Level3Record record {|
    @Any
    PersonInfo? level3Person;
|};

type Level2Record record {|
    string level2Name;
    Level3Record? level3;
|};

type Level1Record record {|
    string level1Name;
    @Any
    Level2Record? level2;
|};

type ChoiceWithOptionalAny record {|
    string recordId;
    @Choice {
        minOccurs: 0,
        maxOccurs: 1
    }
    Choice_OptionalAny? optionalChoice;
|};

type Choice_OptionalAny record {|
    @Any
    PersonInfo? personOption;
    @Any
    AddressInfo? addressOption;
|};

type RecordWithOptionalAnyArray record {|
    string id;
    @Any
    PersonInfo[]? people;
|};

@Namespace {
    prefix: "ns",
    uri: "http://example.com/optional"
}
type NamespacedRecordWithOptionalAny record {|
    @Namespace {
        prefix: "ns",
        uri: "http://example.com/optional"
    }
    string id;
    @Any
    @Namespace {
        prefix: "ns",
        uri: "http://example.com/optional"
    }
    PersonInfo? optionalPerson;
|};

type RecordWithOptionalAnydataAny record {|
    string id;
    @Any
    anydata? optionalAnydata;
|};

@Namespace {uri: "http://example.com/singleany"}
type SequenceWithSingleOptionalAny record {|
    @Sequence {minOccurs: 0}
    SingleOptionalAnyGroup[] groups;
|};

@Namespace {uri: "http://example.com/singleany"}
type SingleOptionalAnyGroup record {|
    @SequenceOrder {value: 1}
    string groupId;
    @SequenceOrder {value: 2}
    @Any
    PersonData? optionalAny;
|};

public type PersonRecord1 record {
    string name;
};

type Person345 record {
    string name;
};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type Sign record {|
    @Sequence {minOccurs: 1, maxOccurs: 1}
    SequenceGroup52 sequenceGroup52;
    @Attribute
    string data;
|};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type SequenceGroup52 record {|
    @Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
    @SequenceOrder {value: 1}
    int outputLength?;
    @Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
    @SequenceOrder {value: 2}
    @Any
    anydata[]? anyElement;
|};

@Name {value: "Object"}
@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type Object123 record {|
    @Sequence {minOccurs: 0}
    SequenceGroup123[] sequenceGroup62;
    @Attribute
    string Id?;
    @Attribute
    string MimeType?;
    @Attribute
    string Encoding?;
|};

@Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
public type SequenceGroup123 record {|
    @Namespace {uri: "http://www.w3.org/2000/09/xmldsig#"}
    @SequenceOrder {value: 1}
    @Any
    anydata anyElement;
|};

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationRecordType() returns error? {
    PersonInfo person = {
        age: 30,
        country: "Sri Lanka"
    };
    EmployeeWithAny employee = {
        name: "John",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithAny><name>John</name><PersonInfo><age>30</age><country>Sri Lanka</country></PersonInfo></EmployeeWithAny>`;
    test:assertEquals(result, expected);

    EmployeeWithAny parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    AddressInfo address = {
        city: "New York",
        zip: "10001"
    };
    employee = {
        name: "Alice",
        anyElement: address
    };
    result = check toXml(employee);
    expected = xml `<EmployeeWithAny><name>Alice</name><AddressInfo><city>New York</city><zip>10001</zip></AddressInfo></EmployeeWithAny>`;
    test:assertEquals(result, expected);

    EmployeeWithAny newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationDifferentRecordType() returns error? {
    AddressInfo address = {
        city: "Colombo",
        zip: "12345"
    };
    EmployeeWithAny employee = {
        name: "Jane",
        anyElement: address
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithAny><name>Jane</name><AddressInfo><city>Colombo</city><zip>12345</zip></AddressInfo></EmployeeWithAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationNestedRecord() returns error? {
    Department dept = {
        deptName: "Engineering",
        deptId: 101
    };
    Company company = {
        companyName: "TechCorp",
        nestedElement: dept
    };
    xml result = check toXml(company);
    xml expected = xml `<Company><companyName>TechCorp</companyName><Department><deptName>Engineering</deptName><deptId>101</deptId></Department></Company>`;
    test:assertEquals(result, expected, msg = "testToXmlWithAnyAnnotationNestedRecord result incorrect");
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithMultipleAnyAnnotations() returns error? {
    PersonInfo person = {
        age: 25,
        country: "India"
    };
    Department dept = {
        deptName: "Sales",
        deptId: 202
    };
    MultiAnyRecord rec = {
        id: "001",
        firstElement: person,
        secondElement: dept
    };
    xml result = check toXml(rec);
    xml expected = xml `<MultiAnyRecord><id>001</id><PersonInfo><age>25</age><country>India</country></PersonInfo><Department><deptName>Sales</deptName><deptId>202</deptId></Department></MultiAnyRecord>`;
    test:assertEquals(result, expected, msg = "testToXmlWithMultipleAnyAnnotations result incorrect");
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationSingleRecordType() returns error? {
    PersonInfo person = {
        age: 45,
        country: "France"
    };
    EmployeeWithSingleRecordAny employee = {
        name: "Pierre",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithSingleRecordAny><name>Pierre</name><PersonInfo><age>45</age><country>France</country></PersonInfo></EmployeeWithSingleRecordAny>`;
    test:assertEquals(result, expected);

    EmployeeWithSingleRecordAny parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAndNameAnnotation() returns error? {
    EmployeeWithNamedAny employee = {
        name: "Mike",
        anyElement: {
            age: 35,
            country: "Australia"
        }
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithNamedAny><name>Mike</name><Person><age>35</age><country>Australia</country></Person></EmployeeWithNamedAny>`;
    test:assertEquals(result, expected, msg = "testToXmlWithAnyAndNameAnnotation result incorrect");

    EmployeeWithNamedAny newEmployee = check parseAsType(expected);
    test:assertEquals(employee, newEmployee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationParentTypeReference() returns error? {
    PersonInfo person = {
        age: 28,
        country: "Canada"
    };
    EmployeeWithAnyTypeRef employee = {
        name: "Sarah",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithAnyTypeRef><name>Sarah</name><PersonInfo><age>28</age><country>Canada</country></PersonInfo></EmployeeWithAnyTypeRef>`;
    test:assertEquals(result, expected);

    EmployeeWithAnyTypeRef parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    AddressInfo address = {
        city: "Toronto",
        zip: "M5V"
    };
    employee = {
        name: "David",
        anyElement: address
    };
    result = check toXml(employee);
    expected = xml `<EmployeeWithAnyTypeRef><name>David</name><AddressInfo><city>Toronto</city><zip>M5V</zip></AddressInfo></EmployeeWithAnyTypeRef>`;
    test:assertEquals(result, expected);

    EmployeeWithAnyTypeRef newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAndNamespaceAnnotation() returns error? {
    NamespacedPersonInfo person = {
        age: 40,
        country: "Germany"
    };
    EmployeeWithNamespacedAny employee = {
        name: "Hans",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithNamespacedAny><name>Hans</name><ns1:NamespacedPersonInfo xmlns:ns1="http://example.com/ns1"><age>40</age><country>Germany</country></ns1:NamespacedPersonInfo></EmployeeWithNamespacedAny>`;
    test:assertEquals(result.toString(), expected.toString());

    EmployeeWithNamespacedAny parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    NamespacedAddressInfo address = {
        city: "Berlin",
        zip: "10115"
    };
    employee = {
        name: "Eva",
        anyElement: address
    };
    result = check toXml(employee);
    expected = xml `<EmployeeWithNamespacedAny><name>Eva</name><ns2:NamespacedAddressInfo xmlns:ns2="http://example.com/ns2"><city>Berlin</city><zip>10115</zip></ns2:NamespacedAddressInfo></EmployeeWithNamespacedAny>`;
    test:assertEquals(result.toString(), expected.toString());

    EmployeeWithNamespacedAny newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNamespaceAnnotationAndAnyField() returns error? {
    PersonWithNS person = {
        age: 32,
        country: "Japan"
    };
    NamespacedEmployeeWithAny employee = {
        name: "Yuki",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<emp:NamespacedEmployeeWithAny xmlns:emp="http://example.com/employee"><emp:name>Yuki</emp:name><emp:PersonWithNS><emp:age>32</emp:age><emp:country>Japan</emp:country></emp:PersonWithNS></emp:NamespacedEmployeeWithAny>`;
    test:assertEquals(result.toString(), expected.toString());

    NamespacedEmployeeWithAny parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    AddressInfo address = {
        city: "Tokyo",
        zip: "100-0001"
    };
    employee = {
        name: "Endo",
        anyElement: address
    };
    result = check toXml(employee);
    expected = xml `<emp:NamespacedEmployeeWithAny xmlns:emp="http://example.com/employee"><emp:name>Endo</emp:name><emp:AddressInfo><city>Tokyo</city><zip>100-0001</zip></emp:AddressInfo></emp:NamespacedEmployeeWithAny>`;
    test:assertEquals(result.toString(), expected.toString());

    NamespacedEmployeeWithAny newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAndNameAnnotationInUnion() returns error? {
    NamedPersonInfo person = {
        age: 28,
        country: "UK"
    };
    EmployeeWithNamedAnyUnion employee = {
        name: "James",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithNamedAnyUnion><name>James</name><Person><age>28</age><country>UK</country></Person></EmployeeWithNamedAnyUnion>`;
    test:assertEquals(result, expected);

    EmployeeWithNamedAnyUnion parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    NamedAddressInfo address = {
        city: "London",
        zip: "SW1A"
    };
    employee = {
        name: "Emma",
        anyElement: address
    };
    result = check toXml(employee);
    expected = xml `<EmployeeWithNamedAnyUnion><name>Emma</name><Location><city>London</city><zip>SW1A</zip></Location></EmployeeWithNamedAnyUnion>`;
    test:assertEquals(result, expected);

    EmployeeWithNamedAnyUnion newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

type EmployeeBaseWithoutAny record {
    string name;
    PersonInfo|AddressInfo details;
};

type EmployeeTypeRefWithAny record {
    *EmployeeBaseWithoutAny;
    @Any
    PersonInfo|AddressInfo details;
};

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationOnTypeRefField() returns error? {
    PersonInfo person = {
        age: 33,
        country: "Brazil"
    };
    EmployeeTypeRefWithAny employee = {
        name: "Carlos",
        details: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeTypeRefWithAny><PersonInfo><age>33</age><country>Brazil</country></PersonInfo><name>Carlos</name></EmployeeTypeRefWithAny>`;
    test:assertEquals(result, expected);

    EmployeeTypeRefWithAny parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    AddressInfo address = {
        city: "Sao Paulo",
        zip: "01310"
    };
    employee = {
        name: "Ana",
        details: address
    };
    result = check toXml(employee);
    expected = xml `<EmployeeTypeRefWithAny><AddressInfo><city>Sao Paulo</city><zip>01310</zip></AddressInfo><name>Ana</name></EmployeeTypeRefWithAny>`;
    test:assertEquals(result, expected);

    EmployeeTypeRefWithAny newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

@Namespace {
    prefix: "ns1",
    uri: "http://example.com/ns1"
}
type PersonNS1 record {
    int age;
    string country;
};

@Namespace {
    prefix: "ns2",
    uri: "http://example.com/ns2"
}
@Name {
    value: "PersonNS1"
}
type PersonNS2 record {
    int age;
    string country;
};

type EmployeeWithSameNameDifferentNS record {
    string name;
    @Any
    PersonNS1|PersonNS2 anyElement;
};

type NestedAddress record {
    string street;
    string city;
};

type Country record {
    string country;
};

type PersonWithNestedRecord record {
    string name;
    int age;
    @Any
    NestedAddress|Country address;
};

type EmployeeWithNestedAny record {
    string empId;
    @Any
    PersonWithNestedRecord|AddressInfo anyElement;
};

type EmployeeWithAnyOnNonRecordType record {
    string name;
    @Any
    string description;
};

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationOnNonRecordType() returns error? {
    EmployeeWithAnyOnNonRecordType employee = {
        name: "John",
        description: "Software Engineer"
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithAnyOnNonRecordType><name>John</name><description>Software Engineer</description></EmployeeWithAnyOnNonRecordType>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithSameTypeNameDifferentNamespaces() returns error? {
    PersonNS1 person1 = {
        age: 30,
        country: "USA"
    };
    EmployeeWithSameNameDifferentNS employee = {
        name: "John",
        anyElement: person1
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithSameNameDifferentNS><name>John</name><ns1:PersonNS1 xmlns:ns1="http://example.com/ns1"><age>30</age><country>USA</country></ns1:PersonNS1></EmployeeWithSameNameDifferentNS>`;
    test:assertEquals(result.toString(), expected.toString());

    EmployeeWithSameNameDifferentNS parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);

    PersonNS2 person2 = {
        age: 25,
        country: "UK"
    };
    employee = {
        name: "Jane",
        anyElement: person2
    };
    result = check toXml(employee);
    expected = xml `<EmployeeWithSameNameDifferentNS><name>Jane</name><ns2:PersonNS1 xmlns:ns2="http://example.com/ns2"><age>25</age><country>UK</country></ns2:PersonNS1></EmployeeWithSameNameDifferentNS>`;
    test:assertEquals(result.toString(), expected.toString());

    EmployeeWithSameNameDifferentNS newEmployee = check parseAsType(expected);
    test:assertEquals(newEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnnotationHavingNestedRecord() returns error? {
    PersonWithNestedRecord person = {
        name: "John",
        age: 30,
        address: {
            street: "123 Main St",
            city: "New York"
        }
    };
    EmployeeWithNestedAny employee = {
        empId: "EMP001",
        anyElement: person
    };
    xml result = check toXml(employee);
    xml expected = xml `<EmployeeWithNestedAny><empId>EMP001</empId><PersonWithNestedRecord><name>John</name><age>30</age><NestedAddress><street>123 Main St</street><city>New York</city></NestedAddress></PersonWithNestedRecord></EmployeeWithNestedAny>`;
    test:assertEquals(result, expected);

    EmployeeWithNestedAny parsedEmployee = check parseAsType(expected);
    test:assertEquals(parsedEmployee, employee);
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithAnyAnnotationOnAnydataFieldWithMultipleAttributes() returns error? {
    PersonData person = {
        name: "john"
    };
    ObjectWithAnydataAndMultipleAttrs data = {
        sequenceGroup: [
            {
                anyElement: person
            }
        ],
        Id: "id123",
        MimeType: "application/xml",
        Encoding: "UTF-8"
    };
    xml result = check toXml(data);
    xml expected = xml `<ObjectWithAnydataAndMultipleAttrs xmlns="http://www.w3.org/2000/09/xmldsig#" Id="id123" MimeType="application/xml" Encoding="UTF-8"><PersonData><name>john</name></PersonData></ObjectWithAnydataAndMultipleAttrs>`;
    test:assertEquals(result.toString(), expected.toString());

    ObjectWithAnydataAndMultipleAttrs parsedData = check parseAsType(result);
    test:assertEquals(parsedData, data);
    result = check toXml(parsedData);
    test:assertEquals(result.toString(), expected.toString());

    parsedData = check parseAsType(expected);
    test:assertEquals(parsedData, data);
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithAnyAndChoiceAnnotations() returns error? {
    PersonInfo person = {
        age: 28,
        country: "Australia"
    };
    ChoiceWithAnyRecord rec = {
        id: "REC001",
        choice: {
            option1: person
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<ChoiceWithAnyRecord><id>REC001</id><PersonInfo><age>28</age><country>Australia</country></PersonInfo></ChoiceWithAnyRecord>`;
    test:assertEquals(result, expected);

    AddressInfo address = {
        city: "Sydney",
        zip: "2000"
    };
    rec = {
        id: "REC002",
        choice: {
            option1: address
        }
    };
    result = check toXml(rec);
    expected = xml `<ChoiceWithAnyRecord><id>REC002</id><AddressInfo><city>Sydney</city><zip>2000</zip></AddressInfo></ChoiceWithAnyRecord>`;
    test:assertEquals(result, expected);

    Project project = {
        projectName: "Alpha",
        projectId: 101
    };
    rec = {
        id: "REC003",
        choice: {
            option2: project
        }
    };
    result = check toXml(rec);
    expected = xml `<ChoiceWithAnyRecord><id>REC003</id><Project><projectName>Alpha</projectName><projectId>101</projectId></Project></ChoiceWithAnyRecord>`;
    test:assertEquals(result, expected);

    Task task = {
        taskName: "Design",
        status: "In Progress"
    };
    rec = {
        id: "REC004",
        choice: {
            option2: task
        }
    };
    result = check toXml(rec);
    expected = xml `<ChoiceWithAnyRecord><id>REC004</id><Task><taskName>Design</taskName><status>In Progress</status></Task></ChoiceWithAnyRecord>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithNestedChoiceAndAnyAnnotations() returns error? {
    AddressInfo address = {
        city: "Melbourne",
        zip: "3000"
    };
    NestedChoiceWithAnyRecord rec = {
        name: "TestRecord",
        outerChoice: {
            innerOption1: {
                innerChoice: {
                    deepOption1: address
                }
            }
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<NestedChoiceWithAnyRecord><name>TestRecord</name><InnerChoice><AddressInfo><city>Melbourne</city><zip>3000</zip></AddressInfo></InnerChoice></NestedChoiceWithAnyRecord>`;
    test:assertEquals(result, expected);

    Department dept = {
        deptName: "Engineering",
        deptId: 42
    };
    rec = {
        name: "TestRecord2",
        outerChoice: {
            innerOption2: dept
        }
    };
    result = check toXml(rec);
    expected = xml `<NestedChoiceWithAnyRecord><name>TestRecord2</name><Department><deptName>Engineering</deptName><deptId>42</deptId></Department></NestedChoiceWithAnyRecord>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithMultipleChoicesAndAnyAnnotations() returns error? {
    PersonInfo person = {
        age: 35,
        country: "Canada"
    };
    MultipleChoicesWithAnyRecord rec = {
        recordId: "MULTI001",
        firstChoice: {
            option1: person
        },
        secondChoice: {
            numericOption: 42
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<MultipleChoicesWithAnyRecord><recordId>MULTI001</recordId><PersonInfo><age>35</age><country>Canada</country></PersonInfo><numericOption>42</numericOption></MultipleChoicesWithAnyRecord>`;
    test:assertEquals(result, expected);

    Task task = {
        taskName: "Review",
        status: "Pending"
    };
    rec = {
        recordId: "MULTI002",
        firstChoice: {
            simpleOption: "Hello"
        },
        secondChoice: {
            option2: task
        }
    };
    result = check toXml(rec);
    expected = xml `<MultipleChoicesWithAnyRecord><recordId>MULTI002</recordId><simpleOption>Hello</simpleOption><Task><taskName>Review</taskName><status>Pending</status></Task></MultipleChoicesWithAnyRecord>`;
    test:assertEquals(result, expected);

    AddressInfo address = {
        city: "Toronto",
        zip: "M5V"
    };
    Project project = {
        projectName: "Beta",
        projectId: 202
    };
    rec = {
        recordId: "MULTI003",
        firstChoice: {
            option1: address
        },
        secondChoice: {
            option2: project
        }
    };
    result = check toXml(rec);
    expected = xml `<MultipleChoicesWithAnyRecord><recordId>MULTI003</recordId><AddressInfo><city>Toronto</city><zip>M5V</zip></AddressInfo><Project><projectName>Beta</projectName><projectId>202</projectId></Project></MultipleChoicesWithAnyRecord>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "sequence", "ara"]
}
function testAnyAnnotationWithAnydataFieldAndSequence() returns error? {
    PersonData2 person = {
        name: "john"
    };
    Object1 data = {
        sequenceGroup62: [
            {
                anyElement: person
            }
        ]
    };
    xml parsedValue = check toXml(data);
    xml expected = xml `<Object xmlns="http://www.w3.org/2000/09/xmldsig#"><PersonData2><name>john</name></PersonData2></Object>`;
    test:assertEquals(parsedValue.toString(), expected.toString());
    Object1 parsedBack = check parseAsType(parsedValue);
    test:assertEquals(parsedBack, data);   
}

@test:Config {
    groups: ["toXml", "any", "sequence", "opt"]
}
function testSequenceWithOptionalAnyField() returns error? {
    SequenceWithOptionalAny rec = {
        groups: [
            {
                requiredField: "required",
                optionalAnyField: {name: "John"}
            }
        ]
    };
    xml result = check toXml(rec);
    xml expected = xml `<SequenceWithOptionalAny xmlns="http://example.com/seq"><requiredField>required</requiredField><PersonData><name>John</name></PersonData></SequenceWithOptionalAny>`;
    test:assertEquals(result.toString(), expected.toString());

    SequenceWithOptionalAny parsedRec = check parseAsType(result);
    test:assertEquals(parsedRec, rec);

    SequenceWithOptionalAny rec2 = {
        groups: [
            {
                requiredField: "only required",
                optionalAnyField: ()
            }
        ]
    };
    xml result2 = check toXml(rec2);
    xml expected2 = xml `<SequenceWithOptionalAny xmlns="http://example.com/seq"><requiredField>only required</requiredField></SequenceWithOptionalAny>`;
    test:assertEquals(result2.toString(), expected2.toString());
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyFieldAsNil() returns error? {
    RecordWithOptionalAny rec = {
        id: "001",
        optionalPerson: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAny><id>001</id></RecordWithOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyFieldWithValue() returns error? {
    RecordWithOptionalAny rec = {
        id: "002",
        optionalPerson: {age: 25, country: "USA"}
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAny><id>002</id><PersonInfo><age>25</age><country>USA</country></PersonInfo></RecordWithOptionalAny>`;
    test:assertEquals(result, expected);

    RecordWithOptionalAny parsedRec = check parseAsType(result);
    test:assertEquals(parsedRec, rec);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithMultipleOptionalAnyFieldsAllNil() returns error? {
    RecordWithMultipleOptionalAny rec = {
        name: "Test",
        person: (),
        address: (),
        dept: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithMultipleOptionalAny><name>Test</name></RecordWithMultipleOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithMultipleOptionalAnyFieldsSomeNil() returns error? {
    RecordWithMultipleOptionalAny rec = {
        name: "PartialTest",
        person: {age: 30, country: "UK"},
        address: (),
        dept: {deptName: "HR", deptId: 101}
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithMultipleOptionalAny><name>PartialTest</name><PersonInfo><age>30</age><country>UK</country></PersonInfo><Department><deptName>HR</deptName><deptId>101</deptId></Department></RecordWithMultipleOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyUnionAsNil() returns error? {
    RecordWithOptionalAnyUnion rec = {
        id: "UNION001",
        optionalUnion: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnyUnion><id>UNION001</id></RecordWithOptionalAnyUnion>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyUnionWithPersonInfo() returns error? {
    RecordWithOptionalAnyUnion rec = {
        id: "UNION002",
        optionalUnion: <PersonInfo>{age: 28, country: "Canada"}
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnyUnion><id>UNION002</id><PersonInfo><age>28</age><country>Canada</country></PersonInfo></RecordWithOptionalAnyUnion>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyUnionWithAddressInfo() returns error? {
    RecordWithOptionalAnyUnion rec = {
        id: "UNION003",
        optionalUnion: <AddressInfo>{city: "Vancouver", zip: "V6B"}
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnyUnion><id>UNION003</id><AddressInfo><city>Vancouver</city><zip>V6B</zip></AddressInfo></RecordWithOptionalAnyUnion>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNestedOptionalAnyFieldAsNil() returns error? {
    OuterRecordWithNestedOptionalAny rec = {
        outerName: "Outer",
        inner: {
            innerName: "Inner",
            innerPerson: ()
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<OuterRecordWithNestedOptionalAny><outerName>Outer</outerName><inner><innerName>Inner</innerName></inner></OuterRecordWithNestedOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNestedOptionalAnyFieldWithValue() returns error? {
    OuterRecordWithNestedOptionalAny rec = {
        outerName: "Outer",
        inner: {
            innerName: "Inner",
            innerPerson: {age: 22, country: "Australia"}
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<OuterRecordWithNestedOptionalAny><outerName>Outer</outerName><inner><innerName>Inner</innerName><PersonInfo><age>22</age><country>Australia</country></PersonInfo></inner></OuterRecordWithNestedOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithEmptySequenceGroups() returns error? {
    SequenceWithEmptyGroups rec = {
        groups: []
    };
    xml result = check toXml(rec);
    xml expected = xml `<SequenceWithEmptyGroups xmlns="http://example.com/empty"/>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithSequenceGroupsContainingNilAny() returns error? {
    SequenceWithEmptyGroups rec = {
        groups: [
            {anyField: ()}
        ]
    };
    xml result = check toXml(rec);
    xml expected = xml `<SequenceWithEmptyGroups xmlns="http://example.com/empty"/>`;
    test:assertEquals(result.toString(), expected.toString());

    SequenceWithEmptyGroups rec2 = {
        groups: [
            {
                anyField: {
                    name: "John"
                }
            }
        ]
    };
    xml result2 = check toXml(rec2);
    xml expected2 = xml `<SequenceWithEmptyGroups xmlns="http://example.com/empty"><PersonData><name>John</name></PersonData></SequenceWithEmptyGroups>`;
    test:assertEquals(result2.toString(), expected2.toString());
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithOptionalChoiceAsNil() returns error? {
    ChoiceWithOptionalAny rec = {
        recordId: "CHOICE001",
        optionalChoice: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<ChoiceWithOptionalAny><recordId>CHOICE001</recordId></ChoiceWithOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithChoiceAnyFieldsAllNil() returns error? {
    ChoiceWithOptionalAny rec = {
        recordId: "CHOICE002",
        optionalChoice: {
            personOption: (),
            addressOption: ()
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<ChoiceWithOptionalAny><recordId>CHOICE002</recordId></ChoiceWithOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithChoiceOneAnyFieldNil() returns error? {
    ChoiceWithOptionalAny rec = {
        recordId: "CHOICE003",
        optionalChoice: {
            personOption: {age: 35, country: "Germany"},
            addressOption: ()
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<ChoiceWithOptionalAny><recordId>CHOICE003</recordId><PersonInfo><age>35</age><country>Germany</country></PersonInfo></ChoiceWithOptionalAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithDeeplyNestedOptionalAnyAllNil() returns error? {
    Level1Record rec = {
        level1Name: "L1",
        level2: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<Level1Record><level1Name>L1</level1Name></Level1Record>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithDeeplyNestedOptionalAnyPartialNil() returns error? {
    Level1Record rec = {
        level1Name: "L1",
        level2: {
            level2Name: "L2",
            level3: {
                level3Person: ()
            }
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<Level1Record><level1Name>L1</level1Name><Level2Record><level2Name>L2</level2Name><level3/></Level2Record></Level1Record>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithDeeplyNestedOptionalAnyWithValues() returns error? {
    Level1Record rec = {
        level1Name: "L1",
        level2: {
            level2Name: "L2",
            level3: {
                level3Person: {age: 40, country: "France"}
            }
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<Level1Record><level1Name>L1</level1Name><Level2Record><level2Name>L2</level2Name><level3><PersonInfo><age>40</age><country>France</country></PersonInfo></level3></Level2Record></Level1Record>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyArrayAsNil() returns error? {
    RecordWithOptionalAnyArray rec = {
        id: "ARRAY001",
        people: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnyArray><id>ARRAY001</id></RecordWithOptionalAnyArray>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyArrayEmpty() returns error? {
    RecordWithOptionalAnyArray rec = {
        id: "ARRAY002",
        people: []
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnyArray><id>ARRAY002</id></RecordWithOptionalAnyArray>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnyArrayWithValues() returns error? {
    RecordWithOptionalAnyArray rec = {
        id: "ARRAY003",
        people: [
            {age: 25, country: "USA"},
            {age: 30, country: "UK"}
        ]
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnyArray><id>ARRAY003</id><people><age>25</age><country>USA</country></people><people><age>30</age><country>UK</country></people></RecordWithOptionalAnyArray>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNamespacedOptionalAnyAsNil() returns error? {
    NamespacedRecordWithOptionalAny rec = {
        id: "NS001",
        optionalPerson: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<ns:NamespacedRecordWithOptionalAny xmlns:ns="http://example.com/optional"><ns:id>NS001</ns:id></ns:NamespacedRecordWithOptionalAny>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNamespacedOptionalAnyWithValue() returns error? {
    NamespacedRecordWithOptionalAny rec = {
        id: "NS002",
        optionalPerson: {age: 45, country: "Japan"}
    };
    xml result = check toXml(rec);
    xml expected = xml `<ns:NamespacedRecordWithOptionalAny xmlns:ns="http://example.com/optional"><ns:id>NS002</ns:id><ns:PersonInfo><age>45</age><country>Japan</country></ns:PersonInfo></ns:NamespacedRecordWithOptionalAny>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnydataAnyAsNil() returns error? {
    RecordWithOptionalAnydataAny rec = {
        id: "ANYDATA001",
        optionalAnydata: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnydataAny><id>ANYDATA001</id></RecordWithOptionalAnydataAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithOptionalAnydataAnyWithRecordValue() returns error? {
    RecordWithOptionalAnydataAny rec = {
        id: "ANYDATA002",
        optionalAnydata: "test string value"
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithOptionalAnydataAny><id>ANYDATA002</id><optionalAnydata>test string value</optionalAnydata></RecordWithOptionalAnydataAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithSequenceSingleOptionalAnyNil() returns error? {
    SequenceWithSingleOptionalAny rec = {
        groups: [
            {
                groupId: "G1",
                optionalAny: ()
            }
        ]
    };
    xml result = check toXml(rec);
    xml expected = xml `<SequenceWithSingleOptionalAny xmlns="http://example.com/singleany"><groupId>G1</groupId></SequenceWithSingleOptionalAny>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithSequenceSingleOptionalAnyWithValue() returns error? {
    SequenceWithSingleOptionalAny rec = {
        groups: [
            {
                groupId: "G2",
                optionalAny: {name: "Alice"}
            }
        ]
    };
    xml result = check toXml(rec);
    xml expected = xml `<SequenceWithSingleOptionalAny xmlns="http://example.com/singleany"><groupId>G2</groupId><PersonData><name>Alice</name></PersonData></SequenceWithSingleOptionalAny>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any", "sequence", "arrr"]
}
function testAnyAnnotationWithAnydataFieldAndSequence2() returns error? {
    PersonData2 person = {
        name: "john"
    };
    Object2 data = {
        sequenceGroup62: [
            {
                anyElement: [person]
            }
        ]
    };
    xml parsedValue = check toXml(data);
    xml expected = xml `<Object xmlns="http://www.w3.org/2000/09/xmldsig#"><PersonData2><name>john</name></PersonData2></Object>`;
    test:assertEquals(parsedValue.toString(), expected.toString());
    Object2 parsedBack = check parseAsType(parsedValue);
    test:assertEquals(parsedBack, data);
}

type EmptyPersonInfo record {|
|};

type RecordWithAnyEmptyRecord record {|
    string id;
    @Any
    EmptyPersonInfo? emptyRecord;
|};

type RecordWithMixedAnyFields record {|
    @Any
    PersonInfo? first;
    @Any
    AddressInfo? second;
    @Any
    Department? third;
|};

type InnerAnyRecord record {|
    @Any
    PersonInfo? innerAny;
|};

type OuterWithInnerAny record {|
    string name;
    InnerAnyRecord? inner;
|};

type RecordWithAnyUnionAllNil record {|
    string id;
    @Any
    (PersonInfo|AddressInfo|Department)? anyUnion;
|};

type RecordWithAnyAnydataNil record {|
    string name;
    @Any
    anydata? anyField;
|};

type RecordWithAnyArrayNilElements record {|
    string id;
    @Any
    PersonInfo?[]? people;
|};

type Level3Any record {|
    @Any
    PersonInfo? l3Any;
|};

type Level2Any record {|
    @Any
    Level3Any? l2Any;
|};

type Level1Any record {|
    string name;
    @Any
    Level2Any? l1Any;
|};

@Namespace {uri: "http://example.com/seqnpe"}
type SequenceWithAnyTest record {|
    @Sequence {minOccurs: 0, maxOccurs: 10}
    SequenceAnyGroup[] groups;
|};

@Namespace {uri: "http://example.com/seqnpe"}
type SequenceAnyGroup record {|
    @SequenceOrder {value: 1}
    string groupName;
    @SequenceOrder {value: 2}
    @Any
    PersonData? anyInSequence;
|};

type ChoiceAnyTest record {|
    string id;
    @Choice {minOccurs: 0, maxOccurs: 1}
    ChoiceAnyOptions? options;
|};

type ChoiceAnyOptions record {|
    @Any
    PersonInfo? personOpt;
    @Any
    AddressInfo? addressOpt;
|};

@Namespace {prefix: "xs", uri: "http://example.com/npe"}
type NamespacedRecordAnyNil record {|
    @Namespace {prefix: "xs", uri: "http://example.com/npe"}
    string id;
    @Any
    @Namespace {prefix: "xs", uri: "http://example.com/npe"}
    PersonInfo? anyWithNS;
|};

type PersonInfoRef PersonInfo?;

type RecordWithAnyTypeRef record {|
    string name;
    @Any
    PersonInfoRef anyRef;
|};

type RecordWithAnyJsonNil record {|
    string name;
    @Any
    json? jsonField;
|};

type RecordWithEmptyAnyArray record {|
    string id;
    @Any
    PersonInfo[] people?;
|};

type RecordWithAnyUnionWithNilType record {|
    string id;
    @Any
    PersonInfo|()? fieldWithNilInUnion;
|};

type RecordWithMixedAnydataArray record {|
    string name;
    @Any
    anydata[] mixedArray;
|};

type AllOptionalAnyRecord record {|
    @Any
    PersonInfo? a;
    @Any
    AddressInfo? b;
    @Any
    Department? c;
    @Any
    Project? d;
|};

@Namespace {uri: "http://example.com/altseq"}
type AlternatingAnySequence record {|
    @Sequence {minOccurs: 0, maxOccurs: 10}
    AlternatingAnyGroup[] groups;
|};

@Namespace {uri: "http://example.com/altseq"}
type AlternatingAnyGroup record {|
    @SequenceOrder {value: 1}
    string id;
    @SequenceOrder {value: 2}
    @Any
    PersonData? anyField;
|};

type RecordWithTrulyOptionalMultipleAny record {
    string name;
    @Any
    PersonInfo? person?;
    @Any
    AddressInfo? address?;
    @Any
    Department? dept?;
};

type RecordWithTrulyOptionalAny record {|
    string id;
    @Any
    PersonInfo? optionalPerson?;
|};

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyFieldContainingEmptyRecord() returns error? {
    RecordWithAnyEmptyRecord rec = {
        id: "test",
        emptyRecord: {}
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyEmptyRecord><id>test</id><EmptyPersonInfo/></RecordWithAnyEmptyRecord>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithMixedAnyFieldsFirstNil() returns error? {
    RecordWithMixedAnyFields rec = {
        first: (),
        second: {city: "NYC", zip: "10001"},
        third: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithMixedAnyFields><AddressInfo><city>NYC</city><zip>10001</zip></AddressInfo></RecordWithMixedAnyFields>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithMixedAnyFieldsLastNil() returns error? {
    RecordWithMixedAnyFields rec = {
        first: {age: 25, country: "USA"},
        second: (),
        third: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithMixedAnyFields><PersonInfo><age>25</age><country>USA</country></PersonInfo></RecordWithMixedAnyFields>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNestedAnyFieldInnerRecordNil() returns error? {
    OuterWithInnerAny rec = {
        name: "test",
        inner: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<OuterWithInnerAny><name>test</name></OuterWithInnerAny>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNestedAnyFieldInnerAnyNil() returns error? {
    OuterWithInnerAny rec = {
        name: "test",
        inner: {
            innerAny: ()
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<OuterWithInnerAny><name>test</name><inner/></OuterWithInnerAny>`;
    test:assertEquals(result.toString(), expected.toString());
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyUnionFieldNil() returns error? {
    RecordWithAnyUnionAllNil rec = {
        id: "union-nil",
        anyUnion: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyUnionAllNil><id>union-nil</id></RecordWithAnyUnionAllNil>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyArrayContainingNilElements() returns error? {
    RecordWithAnyArrayNilElements rec = {
        id: "array-nil",
        people: [(), {age: 30, country: "UK"}, ()]
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString().includes("UK"));
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyArrayFieldNil() returns error? {
    RecordWithAnyArrayNilElements rec = {
        id: "array-field-nil",
        people: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyArrayNilElements><id>array-field-nil</id></RecordWithAnyArrayNilElements>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyAnydataFieldNil() returns error? {
    RecordWithAnyAnydataNil rec = {
        name: "test",
        anyField: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyAnydataNil><name>test</name></RecordWithAnyAnydataNil>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithDeeplyNestedAnyAllNil() returns error? {
    Level1Any rec = {
        name: "deep",
        l1Any: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<Level1Any><name>deep</name></Level1Any>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithDeeplyNestedAnyPartialNil() returns error? {
    Level1Any rec = {
        name: "deep",
        l1Any: {
            l2Any: {
                l3Any: ()
            }
        }
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString().includes("Level1Any"));
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithSequenceAnyFieldNil() returns error? {
    SequenceWithAnyTest rec = {
        groups: [
            {groupName: "G1", anyInSequence: ()},
            {groupName: "G2", anyInSequence: {name: "John"}}
        ]
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString().includes("G1"));
    test:assertTrue(result.toString().includes("John"));
}

@test:Config {
    groups: ["toXml", "any", "choice"]
}
function testToXmlWithChoiceAnyBothNil() returns error? {
    ChoiceAnyTest rec = {
        id: "choice-nil",
        options: {
            personOpt: (),
            addressOpt: ()
        }
    };
    xml result = check toXml(rec);
    xml expected = xml `<ChoiceAnyTest><id>choice-nil</id></ChoiceAnyTest>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithNamespacedAnyFieldNil() returns error? {
    NamespacedRecordAnyNil rec = {
        id: "ns-nil",
        anyWithNS: ()
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString().includes("ns-nil"));
    test:assertFalse(result.toString().includes("PersonInfo"));
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyTypeRefNil() returns error? {
    RecordWithAnyTypeRef rec = {
        name: "ref-nil",
        anyRef: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyTypeRef><name>ref-nil</name></RecordWithAnyTypeRef>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testXmlWithAnyArray() returns error? {
    PersonInfo person = {
        age: 29,
        country: "India"
    };
    RecordWithEmptyAnyArray rec = {
        id: "empty-array",
        people: [person]
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithEmptyAnyArray><id>empty-array</id><PersonInfo><age>29</age><country>India</country></PersonInfo></RecordWithEmptyAnyArray>`;
    test:assertEquals(result, expected);
    RecordWithEmptyAnyArray parsedRec = check parseAsType(result);
    test:assertEquals(parsedRec, rec);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testXmlWithAnyArray2() returns error? {
    Object123 rec = {
        sequenceGroup62: []
    };
    xml result = check toXml(rec);
    xml expected = xml `<Object xmlns="http://www.w3.org/2000/09/xmldsig#"/>`;
    test:assertEquals(result.toString(), expected.toString());
    Object123 parsedRec = check parseAsType(result);
    test:assertEquals(parsedRec, rec);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyJsonFieldNil() returns error? {
    RecordWithAnyJsonNil rec = {
        name: "json-nil",
        jsonField: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyJsonNil><name>json-nil</name></RecordWithAnyJsonNil>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAnyUnionContainingNilType() returns error? {
    RecordWithAnyUnionWithNilType rec = {
        id: "nil-in-union",
        fieldWithNilInUnion: ()
    };
    xml result = check toXml(rec);
    xml expected = xml `<RecordWithAnyUnionWithNilType><id>nil-in-union</id></RecordWithAnyUnionWithNilType>`;
    test:assertEquals(result, expected);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithAllOptionalAnyFieldsNil() returns error? {
    AllOptionalAnyRecord rec = {
        a: (),
        b: (),
        c: (),
        d: ()
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString() == "" || result.toString() == "<AllOptionalAnyRecord/>");
}

@test:Config {
    groups: ["toXml", "any", "sequence"]
}
function testToXmlWithAlternatingNilAnyInSequence() returns error? {
    AlternatingAnySequence rec = {
        groups: [
            {id: "1", anyField: ()},
            {id: "2", anyField: {name: "Alice"}},
            {id: "3", anyField: ()},
            {id: "4", anyField: {name: "Bob"}}
        ]
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString().includes("Alice"));
    test:assertTrue(result.toString().includes("Bob"));
}

@test:Config {
    groups: ["toXml", "any"]
}
function testToXmlWithMixedAnydataArray() returns error? {
    RecordWithMixedAnydataArray rec = {
        name: "mixed",
        mixedArray: [(), "value1", (), 123, ()]
    };
    xml result = check toXml(rec);
    test:assertTrue(result.toString().includes("mixed"));
}

@test:Config {
    groups: ["toXml", "any"]
}
function testParseXmlToRecordWithMissingAnyField() returns error? {
    xml input = xml `<RecordWithTrulyOptionalAny><id>parse-test</id></RecordWithTrulyOptionalAny>`;
    RecordWithTrulyOptionalAny result = check parseAsType(input);
    test:assertEquals(result.id, "parse-test");
    test:assertEquals(result?.optionalPerson, ());
}

@test:Config {
    groups: ["toXml", "any"]
}
function testRoundTripWithNilAnyFields() returns error? {
    RecordWithTrulyOptionalMultipleAny original = {
        name: "RoundTrip",
        person: (),
        address: {city: "Seattle", zip: "98101"},
        dept: ()
    };

    xml xmlResult = check toXml(original);
    RecordWithTrulyOptionalMultipleAny parsed = check parseAsType(xmlResult);

    test:assertEquals(parsed.name, original.name);
    test:assertEquals(parsed?.address, original?.address);
}

@test:Config {
    groups: ["toXml", "any"]
}
function testEmptyValuesForAnyElements() returns error? {
    Sign sigMethod = {
        data: "", 
        sequenceGroup52: {
            outputLength: 5,
            anyElement: []
        }
    };
    xml parsedValue = check toXml(sigMethod);
    Sign parsedBack = check parseAsType(parsedValue);
    test:assertEquals(parsedBack, sigMethod);
}
