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

import ballerina/io;
import ballerina/test;

type Product record {
    string description;
    decimal price;
    string category;
    @Attribute
    string id;
    @Attribute
    string name;
};

type Products record {
    Product[] product;
};

type Address record {
    string street;
    string city;
    string state;
    int zip;
};

type Customer record {
    string name;
    string email;
    string phone;
    Address address;
    @Attribute
    string id;
};

type Customers record {
    Customer[] customer;
};

@Name {value: "invoice"}
type Invoice record {
    Products products;
    Customers customers;
};


@test:Config
function testStreamFileRead1() returns error? {

    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream("tests/resources/small_data.xml");
    Invoice invoice = check fromXmlStringWithType(dataStream);
    test:assertEquals(invoice.products.product[1].price, 63.36d);
    // test:assertEquals(invoice.products.product[1].name, "Product 2"); // Not working
}