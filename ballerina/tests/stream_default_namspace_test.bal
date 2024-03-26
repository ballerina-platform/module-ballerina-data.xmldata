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
    uri: "http://www.example.com/products"
}
type ProductFull record {
    @Namespace {
        uri: "http://www.example.com/products"
    }
    string description;
    @Namespace {
        uri: "http://www.example.com/products"
    }
    PriceFull price;
    @Namespace {
        uri: "http://www.example.com/products"
    }
    string category;
    @Attribute
    int id;
    @Attribute
    string name;
};

@Namespace {
    uri: "http://www.example.com/products"
}
type PriceFull record {
    decimal \#content;
    @Attribute
    string currency;
};

@Namespace {
    uri: "http://www.example.com/products"
}
type ProductsFull record {
    ProductFull[] product;
};

@Namespace {
    uri: "http://www.example.com/customer"
}
type AddressFull record {
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    string street;
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    string city;
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    string state;
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    int zip;
};

@Namespace {
    uri: "http://www.example.com/customer"
}
type CustomerFull record {
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    string name;
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    string email;
    @Namespace {
        uri: "http://www.example.com/customer"
    }
    string phone;
    AddressFull address;
    @Attribute
    string id;
};

@Namespace {
    uri: "http://www.example.com/customer"
}
type CustomersFull record {
    CustomerFull[] customer;
};

@Name {value: "invoice"}
type InvoiceFull record {
    ProductsFull products;
    CustomersFull customers;
};

# Test default namespace with a record including all fields using annotations. 
#
# + return - return error on failure, otherwise nil.
@test:Config
function testDefaultNamespaceInvoiceFull() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream("tests/resources/default_namespaced_invoice.xml");
    InvoiceFull invoice = check parseStream(dataStream);

    test:assertEquals(invoice.length(), 2, "Invoice count mismatched");
    test:assertEquals(invoice.products.length(), 1, "Products count mismatched");
    test:assertEquals(invoice.products.product.length(), 2, "Products/product count mismatched");
    test:assertEquals(invoice.customers.length(), 1, "Customers count mismatched");
    test:assertEquals(invoice.customers.customer.length(), 2, "Customers/customer count mismatched");

    test:assertEquals(invoice.products.product[0].length(), 5, "Product 1 field count mismatched");
    test:assertEquals(invoice.products.product[0].id, 1);
    test:assertEquals(invoice.products.product[0].name, "Product 1");
    test:assertEquals(invoice.products.product[0].description, "This is the description for Product 1.");
    test:assertEquals(invoice.products.product[0].price.length(), 2, "Price 1 price field count mismatched");
    test:assertEquals(invoice.products.product[0].price.\#content, 57.70d);
    test:assertEquals(invoice.products.product[0].price.currency, "USD");
    test:assertEquals(invoice.products.product[0].category, "Home and Garden");

    test:assertEquals(invoice.products.product[1].length(), 5, "Product 2 field count mismatched");
    test:assertEquals(invoice.products.product[1].id, 2);
    test:assertEquals(invoice.products.product[1].name, "Product 2");
    test:assertEquals(invoice.products.product[1].description, "This is the description for Product 2.");
    test:assertEquals(invoice.products.product[0].price.length(), 2, "Price 1 price field count mismatched");
    test:assertEquals(invoice.products.product[1].price.\#content, 6312.36d);
    test:assertEquals(invoice.products.product[1].price.currency, "LKR");
    test:assertEquals(invoice.products.product[1].category, "Books");

    test:assertEquals(invoice.customers.customer[0].length(), 5, "Customer 1 field count mismatched");
    test:assertEquals(invoice.customers.customer[0].id, "C001");
    test:assertEquals(invoice.customers.customer[0].name, "John Doe");
    test:assertEquals(invoice.customers.customer[0].email, "john@example.com");
    test:assertEquals(invoice.customers.customer[0].phone, "569-5052");
    test:assertEquals(invoice.customers.customer[0].address.length(), 4, "Customer 1 address field count mismatched");
    test:assertEquals(invoice.customers.customer[0].address.street, "MZ738SI4DV St.");
    test:assertEquals(invoice.customers.customer[0].address.city, "Newport");
    test:assertEquals(invoice.customers.customer[0].address.state, "NY");
    test:assertEquals(invoice.customers.customer[0].address.zip, 19140);

    test:assertEquals(invoice.customers.customer[1].length(), 5, "Customer 2 field count mismatched");
    test:assertEquals(invoice.customers.customer[1].id, "C002");
    test:assertEquals(invoice.customers.customer[1].name, "Jane Doe");
    test:assertEquals(invoice.customers.customer[1].email, "jane@example.com");
    test:assertEquals(invoice.customers.customer[1].phone, "674-2864");
    test:assertEquals(invoice.customers.customer[1].address.length(), 4, "Customer 2 address field count mismatched");
    test:assertEquals(invoice.customers.customer[1].address.street, "ZI0TGK3BKG St.");
    test:assertEquals(invoice.customers.customer[1].address.city, "Otherville");
    test:assertEquals(invoice.customers.customer[1].address.state, "CA");
    test:assertEquals(invoice.customers.customer[1].address.zip, 77855);
}

type ProductFullPlain record {
    string description;
    PriceFullPlain price;
    string category;
    int id;
    string name;
};

type PriceFullPlain record {
    decimal \#content;
    string currency;
};

type ProductsFullPlain record {
    ProductFullPlain[] product;
};

type AddressFullPlain record {
    string street;
    string city;
    string state;
    int zip;
};

type CustomerFullPlain record {
    string name;
    string email;
    string phone;
    AddressFullPlain address;
    string id;
};

type CustomersFullPlain record {
    CustomerFullPlain[] customer;
};

type InvoiceFullPlain record {
    ProductsFullPlain products;
    CustomersFullPlain customers;
};

# Test default namespace with a record including all fields without using any annotations. 
#
# + return - return error on failure, otherwise nil.
@test:Config
function testDefaultNamespaceInvoiceFullPlain() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream("tests/resources/default_namespaced_invoice.xml");
    InvoiceFullPlain invoice = check parseStream(dataStream);

    test:assertEquals(invoice.length(), 2, "Invoice count mismatched");
    test:assertEquals(invoice.products.length(), 1, "Products count mismatched");
    test:assertEquals(invoice.products.product.length(), 2, "Products/product count mismatched");
    test:assertEquals(invoice.customers.length(), 1, "Customers count mismatched");
    test:assertEquals(invoice.customers.customer.length(), 2, "Customers/customer count mismatched");

    test:assertEquals(invoice.products.product[0].length(), 5, "Product 1 field count mismatched");
    test:assertEquals(invoice.products.product[0].id, 1);
    test:assertEquals(invoice.products.product[0].name, "Product 1");
    test:assertEquals(invoice.products.product[0].description, "This is the description for Product 1.");
    test:assertEquals(invoice.products.product[0].price.length(), 2, "Price 1 price field count mismatched");
    test:assertEquals(invoice.products.product[0].price.\#content, 57.70d);
    test:assertEquals(invoice.products.product[0].price.currency, "USD");
    test:assertEquals(invoice.products.product[0].category, "Home and Garden");

    test:assertEquals(invoice.products.product[1].length(), 5, "Product 2 field count mismatched");
    test:assertEquals(invoice.products.product[1].id, 2);
    test:assertEquals(invoice.products.product[1].name, "Product 2");
    test:assertEquals(invoice.products.product[1].description, "This is the description for Product 2.");
    test:assertEquals(invoice.products.product[0].price.length(), 2, "Price 1 price field count mismatched");
    test:assertEquals(invoice.products.product[1].price.\#content, 6312.36d);
    test:assertEquals(invoice.products.product[1].price.currency, "LKR");
    test:assertEquals(invoice.products.product[1].category, "Books");

    test:assertEquals(invoice.customers.customer[0].length(), 5, "Customer 1 field count mismatched");
    test:assertEquals(invoice.customers.customer[0].id, "C001");
    test:assertEquals(invoice.customers.customer[0].name, "John Doe");
    test:assertEquals(invoice.customers.customer[0].email, "john@example.com");
    test:assertEquals(invoice.customers.customer[0].phone, "569-5052");
    test:assertEquals(invoice.customers.customer[0].address.length(), 4, "Customer 1 address field count mismatched");
    test:assertEquals(invoice.customers.customer[0].address.street, "MZ738SI4DV St.");
    test:assertEquals(invoice.customers.customer[0].address.city, "Newport");
    test:assertEquals(invoice.customers.customer[0].address.state, "NY");
    test:assertEquals(invoice.customers.customer[0].address.zip, 19140);

    test:assertEquals(invoice.customers.customer[1].length(), 5, "Customer 2 field count mismatched");
    test:assertEquals(invoice.customers.customer[1].id, "C002");
    test:assertEquals(invoice.customers.customer[1].name, "Jane Doe");
    test:assertEquals(invoice.customers.customer[1].email, "jane@example.com");
    test:assertEquals(invoice.customers.customer[1].phone, "674-2864");
    test:assertEquals(invoice.customers.customer[1].address.length(), 4, "Customer 2 address field count mismatched");
    test:assertEquals(invoice.customers.customer[1].address.street, "ZI0TGK3BKG St.");
    test:assertEquals(invoice.customers.customer[1].address.city, "Otherville");
    test:assertEquals(invoice.customers.customer[1].address.state, "CA");
    test:assertEquals(invoice.customers.customer[1].address.zip, 77855);
}
