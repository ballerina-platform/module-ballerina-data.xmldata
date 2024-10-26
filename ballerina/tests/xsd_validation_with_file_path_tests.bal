import ballerina/test;
import ballerina/io;

function readXmlFile(string path) returns xml|error {
    return io:fileReadXml(path);
}

@test:Config {groups: ["xsd"]}
function testValidateSchema1() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_1.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_1_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_1_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    boolean isValid = validate(xsdPath, validXml);
    test:assertTrue(isValid, msg = "Valid XML should pass validation");

    boolean isInvalid = validate(xsdPath, invalidXml);
    test:assertFalse(isInvalid, msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema2() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_2.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_2_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_2_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    boolean isValid = validate(xsdPath, validXml);
    test:assertTrue(isValid, msg = "Valid XML should pass validation");

    boolean isInvalid = validate(xsdPath, invalidXml);
    test:assertFalse(isInvalid, msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema3() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_3.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_3_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_3_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    boolean isValid = validate(xsdPath, validXml);
    test:assertTrue(isValid, msg = "Valid XML should pass validation");

    boolean isInvalid = validate(xsdPath, invalidXml);
    test:assertFalse(isInvalid, msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema4() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_4.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_4_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_4_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    boolean isValid = validate(xsdPath, validXml);
    test:assertTrue(isValid, msg = "Valid XML should pass validation");

    boolean isInvalid = validate(xsdPath, invalidXml);
    test:assertFalse(isInvalid, msg = "Invalid XML should fail validation");
}

@test:Config {groups: ["xsd"]}
function testValidateSchema5() returns error? {
    string xsdPath = "tests/resources/xsd_tests/schemas/schema_5.xsd";
    string validXmlPath = "tests/resources/xsd_tests/xml_values/schema_5_valid_xml.xml";
    string invalidXmlPath = "tests/resources/xsd_tests/xml_values/schema_5_invalid_xml.xml";

    xml validXml = check readXmlFile(validXmlPath);
    xml invalidXml = check readXmlFile(invalidXmlPath);

    boolean isValid = validate(xsdPath, validXml);
    test:assertTrue(isValid, msg = "Valid XML should pass validation");

    boolean isInvalid = validate(xsdPath, invalidXml);
    test:assertFalse(isInvalid, msg = "Invalid XML should fail validation");
}
