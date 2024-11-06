import ballerina/test;

type XSDSequenceRecord record {|
    @Sequence {
        minOccurs: 1,
        maxOccurs: 1
    }
    Seq_XSDSequenceRecord seq_XSDSequenceRecord;
|};

type Seq_XSDSequenceRecord record {|
    @Order {
        value: 1
    }
    int age;

    @Order {
        value: 2
    }
    float salary;
|};

@test:Config
function testXsdSequence() returns error? {
    string xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
    XSDSequenceRecord v = check parseString(xmlStr);
    test:assertEquals(v, {seq_XSDSequenceRecord: {age: 13, salary: 11.1}});
    test:assertEquals(v.seq_XSDSequenceRecord.age, 13);
    test:assertEquals(v.seq_XSDSequenceRecord.salary, 11.1);
}
