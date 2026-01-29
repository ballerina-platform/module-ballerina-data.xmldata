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
