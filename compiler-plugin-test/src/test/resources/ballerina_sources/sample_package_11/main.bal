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
|};

type Seq_XsdSequenceArray record {|
    @xmldata:Order {
        value: 1
    }
    int age;

    @xmldata:Order {
        value: 2
    }
    float salary;
|};

