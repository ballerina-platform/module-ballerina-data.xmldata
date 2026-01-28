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

type AddressInfo record {
    string city;
    string zip;
};

type EmployeeWithAny record {
    string name;
    @Any
    PersonInfo|AddressInfo|int|decimal anyElement;
};

type Department record {
    string deptName;
    int deptId;
};

type Company record {
    string companyName;
    @Any
    Department|PersonInfo nestedElement;
};

type MultiAnyRecord record {
    string id;
    @Any
    PersonInfo|AddressInfo firstElement;
    @Any
    Department|PersonInfo secondElement;
};

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

    employee = {
        name: "Alice",
        anyElement: 1001
    };
    result = check toXml(employee);
    expected = xml `<EmployeeWithAny><name>Alice</name><anyElement>1001</anyElement></EmployeeWithAny>`;
    test:assertEquals(result, expected);
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
    test:assertEquals(result, expected, msg = "testToXmlWithAnyAnnotationDifferentRecordType result incorrect");
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
}
