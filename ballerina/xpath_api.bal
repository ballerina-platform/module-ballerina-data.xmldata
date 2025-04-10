// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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
import ballerina/lang.'object as obj;

public type XPathRawTemplate object {
    *obj:RawTemplate;
    public string[] & readonly strings;
    public anydata[] insertions;
};

# Valid types to which the result of the XPath query can be projected. This will be used by the compiler plugin to
# validate usages of `transform` function. Since compiler plugin don't fully cover all possible cases, we need to
# validate at runtime as well.
type SupportedType ()|boolean|int|float|decimal|string|xml;

# Transforms the XML value using the XPath query and projects the result to the specified type.
#
# + 'xml - The XML value to be transformed
# + query - The XPath query to be used for transformation
# + td - The type to which the result of the XPath query should be projected
# + return - On success, returns the projected value, if either query is invalid or result of query can't be projected
# to the specified type, returns an `Error` value
public isolated function transform(xml xmlValue, XPathRawTemplate query, typedesc<anydata> td = <>) returns td|Error = @java:Method {
    'class: "io.ballerina.lib.data.xmldata.xpath.XPath"
} external;
