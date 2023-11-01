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

@Namespace {
    uri: "http://www.example.com/invoice",
    prefix: "inv"
}
@Name {
    value: "invoice"
}
type SimpleInvoiceNS record {|
    @Namespace {
        uri: "http://www.example.com/invoice",
        prefix: "inv"
    }
    SimpleCustomersNS customers;
|};

type SimpleCustomersNS record {|
    @Namespace {
        uri: "http://www.example.com/customers",
        prefix: "customers"
    }
    @Name {
        value: "customer"
    }
    SimpleCustomerNS[10] cust;
|};

type SimpleCustomerNS record {|
    int id;
    string name;
    @Namespace {
        uri: "http://www.example.com/customers",
        prefix: "customers"
    }
    string city;
|};

const LARGE_XML_FILE = "build//resources//large_data.xml";

# Test reading large xml file with namespaces.
# + return - return error on failure, else nil.
@test:Config {
    enable: false
}
function testLargeFileStreamWithNamespace() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream(LARGE_XML_FILE);
    SimpleInvoiceNS invoice = check fromXmlStringWithType(dataStream);

    test:assertEquals(invoice.customers.length(), 1, "Invalid number of customers fields");
    test:assertEquals(invoice.customers.cust.length(), 10, "Invalid customers/customer length");
    test:assertEquals(invoice.customers.cust[0].length(), 3, "Invalid customers/customer/[0] fields");

    test:assertEquals(invoice.customers.cust[0].id, 0, "Invalid customers/customer/[0]/id");
    test:assertEquals(invoice.customers.cust[0].name, "Customer0", "Invalid customers/customer/[0]/name");
    test:assertEquals(invoice.customers.cust[0].city, "City0", "Invalid customers/customer/[0]/city");

    test:assertEquals(invoice.customers.cust[9].id, 9, "Invalid customers/customer/[9]/id");
    test:assertEquals(invoice.customers.cust[9].name, "Customer9", "Invalid customers/customer/[9]/name");
    test:assertEquals(invoice.customers.cust[9].city, "City9", "Invalid customers/customer/[9]/city");
}

type SimpleInvoice record {|
    SimpleCustomers customers;
|};

type SimpleCustomers record {|
    SimpleCustomer[] customer;
|};

type SimpleCustomer record {|
    int id;
    string name;
    string city;
|};

# Test reading large xml file without considering namespaces.
# + return - return error on failure, else nil.
@test:Config {
    enable: false
}
function testLargeFileStream() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream(LARGE_XML_FILE);
    SimpleInvoice invoice = check fromXmlStringWithType(dataStream);

    test:assertEquals(invoice.customers.length(), 1, "Invalid number of customers fields");
    test:assertEquals(invoice.customers.customer.length(), 100000, "Invalid customers/customer length");
    test:assertEquals(invoice.customers.customer[0].length(), 3, "Invalid customers/customer/[0] fields");

    test:assertEquals(invoice.customers.customer[0].id, 0, "Invalid customers/customer/[0]/id");
    test:assertEquals(invoice.customers.customer[0].name, "Customer0", "Invalid customers/customer/[0]/name");
    test:assertEquals(invoice.customers.customer[0].city, "City0", "Invalid customers/customer/[0]/city");

    test:assertEquals(invoice.customers.customer[9].id, 9, "Invalid customers/customer/[9]/id");
    test:assertEquals(invoice.customers.customer[9].name, "Customer9", "Invalid customers/customer/[9]/name");
    test:assertEquals(invoice.customers.customer[9].city, "City9", "Invalid customers/customer/[9]/city");
}

@test:BeforeSuite
function createLargeFile() returns error? {

    io:WritableByteChannel wbc = check io:openWritableFile(LARGE_XML_FILE);
    _ = check wbc.write(string `<inv:invoice xmlns:inv="http://www.example.com/invoice">`.toBytes(), 0);
    _ = check wbc.write("<inv:products>\n".toBytes(), 0);
    foreach int i in 0 ... 100000 {
        _ = check wbc.write(createProduct(i).toString().toBytes(), 0);
    }
    _ = check wbc.write("</inv:products>\n".toBytes(), 0);
    _ = check wbc.write("<inv:customers>\n".toBytes(), 0);
    foreach int i in 0 ... 100000 {
        _ = check wbc.write(createCustomer(i).toString().toBytes(), 0);
    }
    _ = check wbc.write("</inv:customers>\n".toBytes(), 0);
    _ = check wbc.write("</inv:invoice>\n".toBytes(), 0);
}

xmlns "http://www.example.com/products" as pro;
xmlns "http://www.example.com/customers" as customers;

function createProduct(int id) returns xml {
    string name = "Product" + id.toString();
    string description = "This is a " + name;
    int price = 100 + id;
    string category = "category" + id.toString();
    xml product = xml `<pro:product id="${id}" name="${name}">
        <pro:description>${description}</pro:description>
        <pro:price currency="USD">${price}</pro:price>
        <pro:category>${category}</pro:category>
    </pro:product>`;
    return product;
}

function createCustomer(int id) returns xml {
    string name = "Customer" + id.toString();
    string address = "Address" + id.toString();
    string city = "City" + id.toString();
    string country = "Country" + id.toString();
    xml customer = xml `<customers:customer id="${id}" name="${name}">
        <customers:address>${address}</customers:address>
        <customers:email>${name}@example.com</customers:email>
        <customers:city>${city}</customers:city>
        <customers:country>${country}</customers:country>
    </customers:customer>`;
    return customer;
}
