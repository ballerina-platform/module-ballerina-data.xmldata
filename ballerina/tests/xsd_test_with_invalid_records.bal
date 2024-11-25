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

import ballerina/test;

type XSDSequenceInvalidRecord record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    int a;
|};

type XSDSequenceInvalidRecord2 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    int[] a;
|};

type StringArr string[][];

type XSDSequenceInvalidRecord3 record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    StringArr a;
|};

@test:Config {groups: ["xsd", "xsd_sequence"]}
function testXsdSequenceWithInvalidRecord() returns error? {
    string xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceInvalidRecord|Error v = parseString(xmlStr);
    test:assertEquals((<Error>v).message(), "Cannot include Sequence annotation into 'a' of type 'int'");

    XSDSequenceInvalidRecord2|Error v2 = parseString(xmlStr);
    test:assertEquals((<Error>v2).message(), "Cannot include Sequence annotation into 'a' of type 'int[]'");

    XSDSequenceInvalidRecord3|Error v3 = parseString(xmlStr);
    test:assertEquals((<Error>v3).message(), "Cannot include Sequence annotation into 'a' of type 'string[][]'");
}

type XSDChoiceInvalidRecord record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    int a;
|};

type XSDChoiceInvalidRecord2 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    int[] a;
|};

type XSDChoiceInvalidRecord3 record {|
    @Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    StringArr a;
|};

@test:Config {groups: ["xsd", "xsd_choice"]}
function testXsdChoiceWithInvalidRecord() returns error? {
    string xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDChoiceInvalidRecord|Error v = parseString(xmlStr);
    test:assertEquals((<Error>v).message(), "Cannot include Choice annotation into 'a' of type 'int'");

    XSDChoiceInvalidRecord2|Error v2 = parseString(xmlStr);
    test:assertEquals((<Error>v2).message(), "Cannot include Choice annotation into 'a' of type 'int[]'");

    XSDChoiceInvalidRecord3|Error v3 = parseString(xmlStr);
    test:assertEquals((<Error>v3).message(), "Cannot include Choice annotation into 'a' of type 'string[][]'");

    xmlStr = string `<Root><a>13</a><a>11.1</a></Root>`;
    XSDChoiceInvalidRecord|Error v4 = parseString(xmlStr);
    test:assertEquals((<Error>v4).message(), "Cannot include Choice annotation into 'a' of type 'int'");
}
