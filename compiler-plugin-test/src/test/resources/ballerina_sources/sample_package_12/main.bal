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
import ballerina/data.xmldata;

type XSDSequenceInvalidRecord record {|
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    int a;
|};

type XSDSequenceInvalidRecord2 record {|
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    int[] a;
|};

type StringArr string[][];

type XSDSequenceInvalidRecord3 record {|
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    StringArr a;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithInvalidRecord() returns xmldata:Error? {
    string xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceInvalidRecord _ = check xmldata:parseString(xmlStr);
}

type XSDChoiceInvalidRecord record {|
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    int a;
|};

type XSDChoiceInvalidRecord2 record {|
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    int[] a;
|};

type XSDChoiceInvalidRecord3 record {|
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    StringArr a;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceWithInvalidRecord() returns xmldata:Error? {
    string xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDChoiceInvalidRecord _ = check xmldata:parseString(xmlStr);
}
