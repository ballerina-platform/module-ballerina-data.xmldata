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

SourceOptions sOptions1 = {attributePrefix: "@"};

type Employee record {|
    string name;
    int \@age;
    Address address;
|};

type Address record {|
    string city;
    string country;
    string \@zip;
|};

@test:Config
function testAttributePrefixForFromXmlStringWithType() returns error? {
    string xmlStr1 = string `
        <Employee age="26">
            <name>Kanth</name>
            <address zip="12345">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
        </Employee>
    `;
    Employee e = check fromXmlStringWithType(xmlStr1, sOptions1);
    test:assertEquals(e.name, "Kanth");
    test:assertEquals(e.\@age, 26);
    test:assertEquals(e.address.city, "Colombo");
    test:assertEquals(e.address.country, "Sri Lanka");
    test:assertEquals(e.address.\@zip, "12345");
}

@test:Config
function testAttributePrefixForFromXmlWithType() returns error? {
    xml xmlVal = xml `
        <Employee age="26">
            <name>Kanth</name>
            <address zip="12345">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
        </Employee>
    `;
    Employee e = check fromXmlWithType(xmlVal, sOptions1);
    test:assertEquals(e.name, "Kanth");
    test:assertEquals(e.\@age, 26);
    test:assertEquals(e.address.city, "Colombo");
    test:assertEquals(e.address.country, "Sri Lanka");
    test:assertEquals(e.address.\@zip, "12345");
}

SourceOptions sOptions2 = {textFieldName: "value"};

type Book record {|
    record {|
        string value;
    |} title;
    int year;
    Author author;
|};

type Author record {|
    string value;
    @Attribute
    int age;
|};

@test:Config
function testTextFieldNameWithFromXmlStringWithtype() returns error? {
    string xmlStr = string `<Book>
            <title>Clean Code</title>
            <year>2008</year>
            <author age="55">Robert C. Martin</author>
        </Book>`;
    Book b = check fromXmlStringWithType(xmlStr, sOptions2);
    test:assertEquals(b.title.value, "Clean Code");
    test:assertEquals(b.year, 2008);
    test:assertEquals(b.author.value, "Robert C. Martin");
    test:assertEquals(b.author.age, 55);

    xml bXml = check toXml(b, {textFieldName: sOptions2.textFieldName});
    test:assertEquals(bXml, xml `<Book><title>Clean Code</title><year>2008</year><author age="55">Robert C. Martin</author></Book>`);

    // TODO: What shoulbe the behaviour here?
    // string xmlStr2 = string `<author value="55">Robert C. Martin</author>`;
    // record {|
    //     string value;
    // |} author = check fromXmlStringWithType(xmlStr2, option2);
    // test:assertEquals(author.value, "Robert C. Martin");
}

@test:Config
function testTextFieldNameWithFromXmlWithtype() returns error? {
    xml xmlVal = xml `<Book>
            <title>Clean Code</title>
            <year>2008</year>
            <author age="55">Robert C. Martin</author>
        </Book>`;
    Book b = check fromXmlWithType(xmlVal, sOptions2);
    test:assertEquals(b.title.value, "Clean Code");
    test:assertEquals(b.year, 2008);
    test:assertEquals(b.author.value, "Robert C. Martin");
    test:assertEquals(b.author.age, 55);

    xml bXml = check toXml(b, {textFieldName: sOptions2.textFieldName});
    test:assertEquals(bXml, xml `<Book><title>Clean Code</title><year>2008</year><author age="55">Robert C. Martin</author></Book>`);
}

SourceOptions sOptions3 = {allowDataProjection: false};
SourceOptions sOptions4 = {attributePrefix: "@", allowDataProjection: false};
SourceOptions sOptions5 = {textFieldName: "value", allowDataProjection: false};

@test:Config
function testDisableProjectionForFromXmlStringWithTypeNegative() returns error? {
    string xmlStr1 = string `
        <Employee age="26">
            <name>Kanth</name>
            <address zip="12345">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
            <title>Software Engineer</title>
        </Employee>
    `;
    Employee|error e = fromXmlStringWithType(xmlStr1, sOptions3);
    test:assertTrue(e is error);
    test:assertEquals((<error>e).message(), "undefined field 'age' in record 'data.xmldata:Employee'");

    Employee|error e2 = fromXmlStringWithType(xmlStr1, sOptions4);
    test:assertTrue(e2 is error);
    test:assertEquals((<error>e2).message(), "undefined field 'title' in record 'data.xmldata:Employee'");

    string xmlStr2 = string `
        <Employee age="26" title="SE">
            <name>Kanth</name>
            <address zip="12345">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
        </Employee>
    `;
    Employee|error e3 = fromXmlStringWithType(xmlStr2, sOptions4);
    test:assertTrue(e3 is error);
    test:assertEquals((<error>e3).message(), "undefined field '@title' in record 'data.xmldata:Employee'");

    string xmlStr3 = string `<author age="55">Robert C. Martin</author>`;
    record {|
        int age;
    |}|error e4 = fromXmlStringWithType(xmlStr3, sOptions5);
    test:assertTrue(e4 is error);
    test:assertEquals((<error>e4).message(), "undefined field 'value' in record 'data.xmldata:record {| int age; |}'");

    record {|
        int age;
    |}|error e5 = fromXmlStringWithType(xmlStr3, sOptions3);
    test:assertTrue(e5 is error);
    test:assertEquals((<error>e5).message(), "undefined field '#content' in record 'data.xmldata:record {| int age; |}'");
}

@test:Config
function testDisableProjectionForFromXmlWithTypeNegative() returns error? {
    xml xmlVal1 = xml `
        <Employee age="26">
            <name>Kanth</name>
            <address zip="12345">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
            <title>Software Engineer</title>
        </Employee>
    `;
    Employee|error e = fromXmlWithType(xmlVal1, sOptions3);
    test:assertTrue(e is error);
    test:assertEquals((<error>e).message(), "undefined field 'age' in record 'data.xmldata:Employee'");

    Employee|error e2 = fromXmlWithType(xmlVal1, sOptions4);
    test:assertTrue(e2 is error);
    test:assertEquals((<error>e2).message(), "undefined field 'title' in record 'data.xmldata:Employee'");

    xml xmlVal2 = xml `
        <Employee age="26" title="SE">
            <name>Kanth</name>
            <address zip="12345">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
        </Employee>
    `;
    Employee|error e3 = fromXmlWithType(xmlVal2, sOptions4);
    test:assertTrue(e3 is error);
    test:assertEquals((<error>e3).message(), "undefined field '@title' in record 'data.xmldata:Employee'");

    xml xmlVal3 = xml `<author age="55">Robert C. Martin</author>`;
    record {|
        int age;
    |}|error e4 = fromXmlWithType(xmlVal3, sOptions5);
    test:assertTrue(e4 is error);
    test:assertEquals((<error>e4).message(), "undefined field 'value' in record 'data.xmldata:record {| int age; |}'");

    record {|
        int age;
    |}|error e5 = fromXmlWithType(xmlVal3, sOptions3);
    test:assertTrue(e5 is error);
    test:assertEquals((<error>e5).message(), "undefined field '#content' in record 'data.xmldata:record {| int age; |}'");
}

SourceOptions sOptions6 = {attributePrefix: "@", allowDataProjection: false, textFieldName: "value"};

type Library record {|
    @Name {
        value: "Book"
    }
    Book1[] books;
    Employee librarian;
    Address address;
|};

type Book1 record {|
    record {|
        string value;
    |} title;
    int year;
    record {|
        string value;
        @Attribute
        int \@age;
    |} author;
|};

@test:Config
function testComplexOptionsForFromXmlStringWithType() returns error? {
    string xmlStr = string `
        <Library>
            <Book>
                <title>Clean Code</title>
                <year>2008</year>
                <author age="55">Robert C. Martin</author>
            </Book>
            <Book>
                <title>Refactoring</title>
                <year>1999</year>
                <author age="55">Martin Fowler</author>
            </Book>
            <librarian age="26">
                <name>Kanth</name>
                <address zip="12345">
                    <city>Colombo</city>
                    <country>Sri Lanka</country>
                </address>
            </librarian>
            <address zip="45142">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
        </Library>
    `;
    Library l = check fromXmlStringWithType(xmlStr, sOptions6);
    test:assertEquals(l.books[0].title.value, "Clean Code");
    test:assertEquals(l.books[0].year, 2008);
    test:assertEquals(l.books[0].author.value, "Robert C. Martin");
    test:assertEquals(l.books[0].author.\@age, 55);
    test:assertEquals(l.books[1].title.value, "Refactoring");
    test:assertEquals(l.books[1].year, 1999);
    test:assertEquals(l.books[1].author.value, "Martin Fowler");
    test:assertEquals(l.books[1].author.\@age, 55);
    test:assertEquals(l.librarian.name, "Kanth");
    test:assertEquals(l.librarian.\@age, 26);
    test:assertEquals(l.librarian.address.city, "Colombo");
    test:assertEquals(l.librarian.address.country, "Sri Lanka");
    test:assertEquals(l.librarian.address.\@zip, "12345");
    test:assertEquals(l.address.city, "Colombo");
    test:assertEquals(l.address.country, "Sri Lanka");
    test:assertEquals(l.address.\@zip, "45142");
}

@test:Config
function testComplexOptionsForFromXmlStringWithTypeNegative() returns error? {
    string xmlStr = string `
        <Library>
            <Book>
                <title>Clean Code</title>
                <year>2008</year>
                <author age="55">Robert C. Martin</author>
            </Book>
            <Book>
                <title>Refactoring</title>
                <year>1999</year>
                <author age="55">Martin Fowler</author>
            </Book>
            <librarian age="26">
                <name>Kanth</name>
                <address zip="12345">
                    <city>Colombo</city>
                    <country>Sri Lanka</country>
                    <street>23th lane</street>
                </address>
            </librarian>
            <address zip="45142">
                <city>Colombo</city>
                <country>Sri Lanka</country>
            </address>
        </Library>
    `;
    Library|error l = fromXmlStringWithType(xmlStr, sOptions6);
    test:assertTrue(l is error);
    test:assertEquals((<error>l).message(), "undefined field 'street' in record 'data.xmldata:Address'");
}
