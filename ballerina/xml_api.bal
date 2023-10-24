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

import ballerina/jballerina.java;

# Defines the name of the XML element.
#
# + value - The name of the XML element
public type NameConfig record {|
    string value;
|};

# The annotation is used to specify the new name of the existing record name or field name according to the XML format.
# In the XML string-record conversion, this annotation can be used to override the default XML element name using the
# `xml:toXML` API and validate the overridden XML element name with record field using the `xml:fromXmlString` API.
public annotation NameConfig Name on type, record field;

# Defines the namespace of the XML element
#
# + prefix - The value of the prefix of the namespace
# + uri - The value of the URI of the namespace
public type NamespaceConfig record {|
    string prefix?;
    string uri;
|};

# The annotation is used to specify the namespace's prefix and URI of the XML element.
# In the XML string-record conversion, this annotation can be used to add XML namespace using the `xml:toXML` API and
# validate the the XML namespace with record in the `xml:fromXmlString` API.
public annotation NamespaceConfig Namespace on type, record field;

# The annotation is used to denote the field that is considered an attribute.
# In the XML string-record conversion, this annotation can be used to add XML attribute using the `xml:toXML` API and
# validate the XML attribute with record fields in the `xml:fromXmlString` API.
public annotation Attribute on record field;

# A Parse a xml value with projection
#
# + v - Source XML value 
# + options - Options to be used for filtering in the projection
# + t - Target type to be used for filtering in the projection
# + return - On success, returns the given target type value, else returns an `xml:Error` 
public isolated function fromXmlWithType(xml v, Options options = {}, typedesc<anydata> t = <>)
        returns t|ConversionError = @java:Method {'class: "io.ballerina.stdlib.data.xml.Native"} external;

# A Parser a xml string value with projection
#
# + s - Source XML string value 
# + options - Options to be used for filtering in the projection 
# + t - Target type to be used for filtering in the projection
# + return - On success, returns the given target type value, else returns an `xml:Error` 
public isolated function fromXmlStringWithType(string s, Options options = {}, typedesc<anydata> t = <>)
        returns t|ConversionError = @java:Method {'class: "io.ballerina.stdlib.data.xml.Native"} external;

# Parse a xml byte array with projection
#
# + v - Byte array of xml
# + options - Options to be used for filtering in the projection
# + t - Target type to be used for filtering in the projection
# + return - On success, returns the given target type value, else returns an `xml:Error` 
public isolated function fromXmlByteArrayWithType(byte[] v, Options options = {}, typedesc<anydata> t = <>)
        returns t|ConversionError = @java:Method {'class: "io.ballerina.stdlib.data.xml.Native"} external;

# Parse a xml byte stream with projection
#
# + v - Byte stream of json value
# + options - Options to be used for filtering in the projection
# + t - Target type to be used for filtering in the projection
# + return - On success, returns the given target type value, else returns an `xml:Error` 
public isolated function fromXmlByteStreamWithType(stream<byte[], error?> v, Options options = {}, typedesc<anydata> t = <>)
        returns t|ConversionError = @java:Method {'class: "io.ballerina.stdlib.data.xml.Native"} external;
