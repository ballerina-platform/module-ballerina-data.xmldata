# Ballerina XML Data Library 

The Ballerina XML Data Library is a comprehensive toolkit designed to facilitate the handling and manipulation of XML data within Ballerina applications. It streamlines the process of converting XML data to native Ballerina data types, enabling developers to work with XML content seamlessly and efficiently.

This library is the refined successor of the `ballerina/xmldata` module, incorporating enhanced functionalities and improved performance.

## Features

- **Versatile XML Data Input**: Accept XML data as a xml, a string, byte array, or a stream and convert it into a Record value.
- **XML to Record Value Conversion**: Transform XML data into Ballerina records with ease in compliance with OpenAPI 3 standards.
- **Projection Support**: Perform selective conversion of XML data subsets into Record values through projection.

## Usage

### Converting an XML value to a Record value

To convert an XML value to a Record value, you can utilize the `fromXmlWithType` function provided by the library. The example below showcases the transformation of an XML value into a Record value.

```ballerina
import ballerina/data.xmldata;
import ballerina/io;

public function main() returns error? {
    xml data = xml `<book>
        <id>0</id>
        <title>string</title>
        <author>string</author>
    </book>`;

    Book book = check xmldata:fromXmlWithType(data);
    io:println(book);
}

type Book record {
    int id;
    string title;
    string author;
};
```

### Converting an external XML document to a Record value

For transforming XML content from an external source into a Record value, the `fromXmlStringWithType` function can be used. This external source can be in the form of a string or a byte array/byte stream that houses the XML data. This is commonly extracted from files or network sockets. The example below demonstrates the conversion of an XML value from an external source into a Record value.

```ballerina
import ballerina/data.xmldata;
import ballerina/io;

public function main() returns error? {
    string xmlContent = check io:fileReadString("path/to/file.xml");
    Book book = check xmldata:fromXmlStringWithType(xmlContent);
    io:println(book);
}

type Book record {
    int id;
    string title;
    string author;
};
```

Make sure to handle possible errors that may arise during the file reading or XML to record conversion process. The `check` keyword is utilized to handle these errors, but more sophisticated error handling can be implemented as per your requirements.

## XML to Record Canonical Representation

The translation of XML to a Record representation is a fundamental feature of the library. It facilitates a structured and type-safe approach to handling XML data within Ballerina applications.

Take for instance the following XML snippet:

```xml
<book>
    <id>0</id>
    <title>string</title>
    <author>string</author>
</book>
```

XML data is inherently hierarchical, forming a tree structure. In the given example, the root element is `book`, which encompasses three child elements: `id`, `title`, and `author`. The `id` element harbors a numeric value `0`, whereas both the `title` and `author` elements contain string values.

A straightforward record representation of the above XML data is:

```ballerina
type Book record {
    int id;
    string title;
    string author;
};
```

In this representation, the XML data is efficiently translated into a record value. The `book` element is mapped to a record of type `Book`, and the child elements `id`, `title`, and `author` are converted into record fields of types `int` and `string` correspondingly.

This record type definition can be further refined through annotations. Moreover, utilizing open and closed records grants control over the translation process, which is elaborated in subsequent sections.

### XML Element Names

The name of the XML element serves as the name of the record field, altered to fit a valid Ballerina identifier. Notably, the record field name corresponds to the local name of the XML element, with any namespace prefixes being disregarded.

Consider the XML snippet:

```xml
<book>
    <id>0</id>
    <title-name>string</title-name>
    <author-name>string</author-name>
</book>
```

The canonical representation of the above XML as a Ballerina record is:

```ballerina
type Book record {
    int id;
    string title\-name;
    string author\-name;
};
```

Observe how the XML element names `title-name` and `author-name` are represented using delimited identifiers in Ballerina; the `-` characters in the XML element names are escaped using the `\ ` character.

Moreover, the `@Name` annotation can be utilized to explicitly specify the name of the record field, providing control over the translation process:

```ballerina
import ballerina/data.xmldata;

type Book record {
    int id;
    @xmldata:Name { value: "title-name" }
    string title;
    @xmldata:Name { value: "author-name" }
    string author;
};
```

### XML Attributes

Similarly to XML elements, XML attributes are also represented into record fields within the corresponding parent Record type. The name of the XML attribute is converted into the name of the record field, ensuring it is a valid Ballerina identifier. It is crucial to emphasize that the record field name aligns with the local name of the XML attribute, and any namespace prefixes are ignored.

Consider the following XML snippet:

```xml
<book lang="en" price="10.5">
    <id>0</id>
    <title>string</title>
    <author>string</author>
</book>
```

The canonical representation of the above XML as a Ballerina record is:

```ballerina
type Book record {
    string lang;
    decimal price;
    int id;
    string title;
    string author;
};
```

Additionally, the `@Attribute` annotation can be used to explicitly specify the field as an attribute providing control over the translation process. When element and attribute have same name in the same scope the priority is given to the element unless the expected record field has the `@Attribute` annotation. 

### Child Elements

Child elements are mapped to record fields, with the type reflecting that of the corresponding child element. 

Examine the XML snippet below:

```xml
<book>
    <id>0</id>
    <title>string</title>
    <author>
        <name>string</name>
        <country>string</country>
    </author>
</book>
```

The canonical representation of the above XML as a Ballerina record is:

```ballerina
type Book record {
    int id;
    string title;
    Author author;
};

type Author record {
    string name;
    string country;
};
```

In this transformation, child elements, like the `author` element containing its own sub-elements, are converted into nested records. This maintains the hierarchical structure of the XML data within the Ballerina type system, enabling intuitive and type-safe data manipulation.

Alternatively, inline type definitions offer a compact method for representing child elements as records within their parent record. This approach is particularly beneficial when the child record does not require reuse elsewhere and is unique to its parent record. 

Consider the subsequent Ballerina record definition, which employs inline type definition for the `author` field:

```ballerina
type Book record {
    int id;
    string title;
    record {
        string name;
        string country;
    } author;
};
```

### XML Text Content

The transformation of XML text content into record fields typically involves types like `string`, `boolean`, `int`, `float`, or `decimal`, depending on the textual content. For numeric values where type information is not explicitly defined, the default conversion type is `decimal`. Conversely, for non-numeric content, the default type is `string`.

Consider the XML snippet below:

```xml
<book>
    <id>0</id>
    <title>string</title>
    <author>string</author>
    <available>true</available>
    <price>10.5</price>
</book>
```

The translation into a Ballerina record would be as follows:

```ballerina
type Book record {
    int id;
    string title;
    string author;
    boolean available;
    decimal price;
};
```

In scenarios where the parent XML element of text content also includes attributes, the XML text content can be represented by a `string` type field named `#content` within a record type, with the attributes being mapped to their respective fields.

For instance, examine this XML:

```xml
<book>
    <id>0</id>
    <title lang="en">string</title>
    <price>10.5</price>
</book>
```

The canonical translation of XML to a Ballerina record is as such:

```ballerina
type Book record {
    int id;
    Title title;
    decimal price;
};

type Title record {
    string \#content;
    string lang;
};
```

### XML Namespaces

XML namespaces are accommodated by the library, supporting the translation of XML data that contains namespace prefixes. However, the presence of XML namespaces is not mandatory, and the library is capable of processing XML data without namespaces. Should namespaces be present, they will be utilized to resolve the names of XML elements and attributes.

It's important to note that, unlike in the `xmldata` module, the namespace prefixes do not reflect in the record field names, as the record field names align with the local names of the XML elements.

Examine the XML snippet below with default namespaces:

```xml
<book xmlns="http://example.com/book">
    <id>0</id>
    <title>string</title>
    <author>string</author>
</book>
```

The translation into a Ballerina record would be:

```ballerina
type Book record {
    int id;
    string title;
    string author;
};
```

Incorporating namespace validation yields:

```ballerina
import ballerina/data.xmldata;

@xmldata:Namespace {
    uri: "http://example.com/book"
}
type Book record {
    int id;
    string title;
    string author;
};
```

Here is the same XML snippet with a namespace prefix:

```xml
<bk:book xmlns:bk="http://example.com/book">
    <bk:id>0</bk:id>
    <bk:title>string</bk:title>
    <bk:author>string</bk:author>
</bk:book>
```

The translation into a Ballerina record would be:

```ballerina
import ballerina/data.xmldata;

@xmldata:Namespace {
    uri: "http://example.com/book"
}
type Book record {|
    @xmldata:Namespace {
        uri: "http://example.com/book"
    }
    int id;
    @xmldata:Namespace {
        uri: "http://example.com/book"
    }
    string title;
    @xmldata:Namespace {
        uri: "http://example.com/book"
    }
    string author;
|};
```

Here is the same XML snippet with a namespace prefix:

```xml
<bk:book xmlns:bk="http://example.com/book" xmlns:au="http://example.com/author">
    <bk:id>0</bk:id>
    <bk:title>string</bk:title>
    <au:author>string</au:author>
</bk:book>
```

The translation into a Ballerina record would be:

```ballerina
import ballerina/data.xmldata;

@xmldata:Namespace {
    uri: "http://example.com/book",
    prefix: "bk"
}
type Book record {|
    @xmldata:Namespace {
        uri: "http://example.com/book",
        prefix: "bk"
    }
    int id;
    @xmldata:Namespace {
        uri: "http://example.com/book",
        prefix: "bk"
    }
    string title;
    @xmldata:Namespace {
        uri: "http://example.com/author",
        prefix: "au"
    }
    string author;
|};
```

In these examples, the XML namespaces are appropriately acknowledged, ensuring the integrity of the XML structure within the Ballerina records.

### Working with Arrays

The library is equipped to handle the transformation of XML data containing arrays into Ballerina records. 

Take the following XML snippet as an example:

```xml
<book>
    <id>0</id>
    <title>string</title>
    <author>string</author>
    <author>string</author>
    <author>string</author>
</book>
```

The canonical representation of this XML as a Ballerina record is:

```ballerina
type Book record {
    int id;
    string title;
    string[] author;
};
```

### Controlling Which Elements to Convert

The library allows for selective conversion of XML elements into records through the use of rest fields. This is beneficial when the XML data contains elements that are not necessary to be transformed into record fields.

Take this XML snippet as an example:

```xml
<book lang="en">
    <id>0</id>
    <title lang="en">string</title>
    <author>string</author>
    <price>10.5</price>
</book>
```

Suppose that only the book `id`, and `title` elements are needed for conversion into record fields. This can be achieved by defining only the required fields in the record type and omitting the rest field:

```ballerina
type Book record {|
    int id;
    string title;
|};
```

However, if the rest field is utilized (or if the record type is defined as an open record), all elements in the XML data will be transformed into record fields:

```ballerina
type Book record {
    int id;
    string title;
};
```

In this instance, all other elements in the XML data, such as `author` and `price` along with their attributes, will be transformed into `string` type fields with the corresponding element name as the key.

This behavior extends to arrays as well. 

The process of projecting XML data into a record supports various use cases, including the filtering out of unnecessary elements. This functionality is anticipated to be enhanced in the future to accommodate more complex scenarios, such as filtering values based on regular expressions, among others.

## Issues and projects

Issues and Projects tabs are disabled for this repository as this is part of the Ballerina standard library. To report bugs, request new features, start new discussions, view project boards, etc. please visit Ballerina standard library [parent repository](https://github.com/ballerina-platform/ballerina-standard-library).

This repository only contains the source code for the package.

## Building from the source

### Set up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 17 (from one of the following locations).
   * [Oracle](https://www.oracle.com/java/technologies/downloads/)
   * [OpenJDK](https://adoptium.net/)

2. Export your GitHub personal access token with the read package permissions as follows.

        export packageUser=<Username>
        export packagePAT=<Personal access token>

### Building the source

Execute the commands below to build from source.

1. To build the library:

        ./gradlew clean build

2. Publish ZIP artifact to the local `.m2` repository:

        ./gradlew clean build publishToMavenLocal

3. Publish the generated artifacts to the local Ballerina central repository:

        ./gradlew clean build -PpublishToLocalCentral=true

4. Publish the generated artifacts to the Ballerina central repository:

        ./gradlew clean build -PpublishToCentral=true

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina code of conduct](https://ballerina.io/code-of-conduct).

## Useful links

[//]: # (* For more information go to the [`xmldata` library]&#40;https://lib.ballerina.io/ballerina/data.xmldata/latest&#41;.)
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.