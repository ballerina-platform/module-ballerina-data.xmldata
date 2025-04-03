import ballerina/jballerina.java;

type SupportedType xml|string|boolean|int|();

public isolated function transform(string query, xml value, typedesc<SupportedType> td = <>) returns td|Error = @java:Method {
    'class: "io.ballerina.lib.data.xmldata.xpath.XPath"
} external;
