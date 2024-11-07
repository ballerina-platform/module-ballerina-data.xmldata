// import ballerina/test;

// type XSDChoiceRecord record {|
//     @Choice {
//         minOccurs: 1,
//         maxOccurs: 1
//     }
//     Seq_XSDChoiceRecord seq_XSDChoiceRecord;
// |};

// type Seq_XSDChoiceRecord record {|
//     int age?;
//     float salary?;
// |};

// @test:Config
// function testXsdChoice() returns error? {
//     string xmlStr = string `<Root><age>13</age></Root>`;
//     XSDChoiceRecord v = parseString(xmlStr);
//     test:assertEquals(v, {seq_XSDChoiceRecord: {age: 13}});

//     xmlStr = string `<Root><salary>13.5</salary></Root>`;
//     v = parseString(xmlStr);
//     test:assertEquals(v, {seq_XSDChoiceRecord: {salary: 13.5}});

//     xmlStr = string `<Root><age>13</age><salary>11.1</salary></Root>`;
//     v = parseString(xmlStr);
//     test:assertEquals(v, {seq_XSDChoiceRecord: {age: 13, salary: 11.1}});
// }