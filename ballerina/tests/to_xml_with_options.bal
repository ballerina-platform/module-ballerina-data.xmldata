// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

type Person record {|
    string \#content;
    @Attribute
    int age;
|};

@test:Config
function testTextFieldNameForToXml() returns error? {
    Options options1 = {textFieldName: "value"};
    Book book = {
        title: {
            value: "Clean Code"
        },
        year: 2008,
        author: {
            value: "Robert C. Martin",
            age: 55
        }
    };
    xml xmlBook = check toXml(book, options1);
    test:assertEquals(xmlBook, xml`<Book><title>Clean Code</title><year>2008</year><author age="55">Robert C. Martin</author></Book>`);

    Person person = {
        \#content: "Kanth",
        age: 26
    };
    xml xmlPerson = check toXml(person);
    test:assertEquals(xmlPerson, xml`<Person age="26">Kanth</Person>`);
}

type EmployeeNew record {|
    string name;
    @Attribute
    int \@age;
    record {|
        string city;
        @Attribute
        string \@zip;
    |} address;
|};

@test:Config
function testAttributePrefixForToXml() returns error? {
    Options options2 = {attributePrefix: "@"};
    Employee employee1 = {
        name: "Kanth",
        \@age: 26,
        address: {
            city: "Colombo",
            country: "Sri Lanka",
            \@zip: "10280"
        }    
    };
    xml xmlEmployee1 = check toXml(employee1, options2);
    test:assertEquals(xmlEmployee1, xml `<Employee><name>Kanth</name><age>26</age><address><city>Colombo</city><country>Sri Lanka</country><zip>10280</zip></address></Employee>`);

    EmployeeNew employee2 = {
        name: "Kanth",
        \@age: 26,
        address: {
            city: "Colombo",
            \@zip: "10280"
        }    
    };
    xml xmlEmployee2 = check toXml(employee2, options2);
    test:assertEquals(xmlEmployee2, xml `<EmployeeNew age="26"><name>Kanth</name><address zip="10280"><city>Colombo</city></address></EmployeeNew>`);
}

type City record {|
    string \@name;
    string \@country;
    Place[] place; 
|};

type Place record {|
    string value;
    @Attribute
    @Name {
        value: "@popularity-score"
    }
    int popularity;
|};

@test:Config
function testComplexOptionsForToXml() returns error? {
    Options options3 = {textFieldName: "value", attributePrefix: "@"};
    City city = {
        \@name: "Colombo",
        \@country: "Sri Lanka",
        place: [
            {
                value: "Galle Face Green",
                popularity: 8
            },
            {
                value: "Viharamahadevi Park",
                popularity: 7
            }
        ]
    };
    xml xmlCity = check toXml(city, options3);
    test:assertEquals(xmlCity, xml `<City><name>Colombo</name><country>Sri Lanka</country><place popularity-score="8">Galle Face Green</place><place popularity-score="7">Viharamahadevi Park</place></City>`);
}
