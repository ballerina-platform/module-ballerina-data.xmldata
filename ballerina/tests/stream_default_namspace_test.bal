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

type ProductFull record {
    string description;
    PriceFull price;
    string category;
    @Attribute
    int id;
    @Attribute
    string name;
};

type PriceFull record {
    string \#content;
    @Attribute
    string currency;
};

type ProductsFull record {
    ProductFull[] product;
};

type AddressFull record {
    string street;
    string city;
    string state;
    int zip;
};

type CustomerFull record {
    string name;
    string email;
    string phone;
    AddressFull address;
    @Attribute
    string id;
};

type CustomersFull record {
    CustomerFull[] customer;
};

@Name {value: "invoice"}
type InvoiceFull record {
    ProductsFull products;
    CustomersFull customers;
};

@test:Config
function testDefaultNamespaceInvoice() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream("tests/resources/default_namespaced_invoice.xml");
    InvoiceFull invoice = check fromXmlStringWithType(dataStream);
    test:assertEquals(invoice.products.product[0].id, 1);
    test:assertEquals(invoice.products.product[0].name, "Product 1");
    test:assertEquals(invoice.products.product[0].description, string `This is the description for
                Product 1.`);
    test:assertEquals(invoice.products.product[0].price.\#content, 57.70d);
    test:assertEquals(invoice.products.product[0].price.currency, "USD");
    test:assertEquals(invoice.products.product[0].category, "Books");
}
