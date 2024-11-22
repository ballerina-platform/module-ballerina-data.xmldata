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

type StringArr string[];
type recordArr record{}[];
type Str string;

type A record {
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    int aSeq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    int[] a2Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    int|string[] a3Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    int|record{}[] a4Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    record{}[] a5Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    record{} a6Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    StringArr a7Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    recordArr a8Seq;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    Str a9Seq;
};

type A2 record {
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    int aChoice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    int[] a2Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    int|string[] a3Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    int|record{}[] a4Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    record{}[] a5Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    record{} a6Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    StringArr a7Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    recordArr a8Choice;

    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    Str a9Choice;
};

type A4 record {|
    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    Seq_XsdSequenceArray[] seq_XsdSequenceArray;

    @xmldata:Sequence {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    Seq_XsdSequenceArray[] seq_XsdSequenceArray2;

    @xmldata:Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    Seq_XsdSequenceArray[] seq_XsdSequenceArray3;

    @xmldata:Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Attribute
    Seq_XsdSequenceArray[] seq_XsdSequenceArray4;

    @xmldata:Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Attribute
    Choice_XsdSequenceArray[] Choice_XsdSequenceArray5;

    @xmldata:Element {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Choice {
        minOccurs: 1,
        maxOccurs: 2
    }
    @xmldata:Attribute
    Choice_XsdSequenceArray2[] Choice_XsdSequenceArray6;
|};

type Seq_XsdSequenceArray record {|
    @xmldata:SequenceOrder {
        value: 1
    }
    int age;

    @xmldata:SequenceOrder {
        value: 2
    }
    float salary;
|};

type Choice_XsdSequenceArray record {
    int? age;
};

type Choice_XsdSequenceArray2 record {|
    int? age;
|};
