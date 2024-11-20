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

import ballerina/data.xmldata;

type XSDSequenceRecord record {|
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord seq_XSDSequenceRecord;
|};

type Seq_XSDSequenceRecord record {|
    @xmldata:Order {
        value: 1
    }
    int age;

    @xmldata:Order {
        value: 2
    }
    float salary;
|};

type XSDSequenceRecord2 record {|
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord2 seq_XSDSequenceRecord2;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord3 seq_XSDSequenceRecord3;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord4 seq_XSDSequenceRecord4;
|};

type Seq_XSDSequenceRecord2 record {|
    @xmldata:Order {
        value: 1
    }
    int age;

    @xmldata:Order {
        value: 2
    }
    float salary;

    @xmldata:Element {
        minOccurs: 2
    }
    string name;
|};

type Seq_XSDSequenceRecord3 record {
    @xmldata:Order {
        value: 1
    }
    int age;
    string name;

    @xmldata:Order {
        value: 2
    }
    float salary;
};

type XSDSequenceRecord4 record {|
    record {
        @xmldata:Sequence {
            minOccurs: 1,
            maxOccurs: 1
        }
        Seq_XSDSequenceRecord4 seq_XSDSequenceRecord;
    } nested;
|};

type Seq_XSDSequenceRecord4 record {
    int age;
    @xmldata:Order {
        value: 1
    }
    int age2;

    @xmldata:Element {
        minOccurs: 2
    }
    @xmldata:Order {
        value: 2
    }
    float salary;

    @xmldata:Element {
        minOccurs: 2
    }
    string address;
};

type ChoiceRecord record {
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    record {} age;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    int salary;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 1
    }
    ChoiceRec1 choiceRec1;
};

type ChoiceRec1 record {
    record {} age?;
    int salary?;
    string name?;
};
