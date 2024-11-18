import ballerina/test;

@test:Config {groups: ["xsd", "to_xml"], dataProvider: fromJsonDataProvider}
function testFromJson(json value, xml expected) returns error?{
    xml|Error xmlResult = fromJson(value);
    test:assertEquals(xmlResult, expected);
}

function fromJsonDataProvider() returns [json, xml][] {
    return [
        [{a: {b: 2, c: 3}}, xml `<a><b>2</b><c>3</c></a>`],
        [{a: {a: 1}}, xml `<a><a>1</a></a>`],
        [{a: {d: 4, e: {f: 5, g: "text"}}}, xml `<a><d>4</d><e><f>5</f><g>text</g></e></a>`],
        [{root: {nested: {value1: "example", value2: 10}}}, xml `<root><nested><value1>example</value1><value2>10</value2></nested></root>`],
        [{book: {title: "XML Guide", author: "John Doe", year: 2024}}, xml `<book><title>XML Guide</title><author>John Doe</author><year>2024</year></book>`],
        [{library: {section: {book1: "Book A", book2: "Book B"}}}, xml `<library><section><book1>Book A</book1><book2>Book B</book2></section></library>`],
        [{person: {name: "Alice", details: {age: 30, city: "Wonderland"}}}, xml `<person><name>Alice</name><details><age>30</age><city>Wonderland</city></details></person>`],
        [{catalog: {item: [{id: 1, name: "Item 1"}, {id: 2, name: "Item 2"}]}}, xml `<catalog><item><id>1</id><name>Item 1</name></item><item><id>2</id><name>Item 2</name></item></catalog>`],
        [{company: {employee: {id: 1001, name: "Bob", department: "Engineering"}}}, xml `<company><employee><id>1001</id><name>Bob</name><department>Engineering</department></employee></company>`],
        [{'order: {orderId: 5001, items: {item1: "Widget", item2: "Gadget"}}}, xml `<order><orderId>5001</orderId><items><item1>Widget</item1><item2>Gadget</item2></items></order>`],
        [{menu: {dish: [{name: "Pasta", price: 12.5}, {name: "Salad", price: 8.0}]}}, xml `<menu><dish><name>Pasta</name><price>12.5</price></dish><dish><name>Salad</name><price>8.0</price></dish></menu>`],
        [{report: {entries: [{date: "2024-10-01", detail: "Entry 1"}, {date: "2024-10-02", detail: "Entry 2"}]}}, xml `<report><entries><date>2024-10-01</date><detail>Entry 1</detail></entries><entries><date>2024-10-02</date><detail>Entry 2</detail></entries></report>`],
        [{shoppingList: {items: [{item: "Apples", quantity: 5}, {item: "Bananas", quantity: 3}]}}, xml `<shoppingList><items><item>Apples</item><quantity>5</quantity></items><items><item>Bananas</item><quantity>3</quantity></items></shoppingList>`],
        [{conference: {session: [{topic: "AI Trends", speaker: "Dr. Smith"}, {topic: "Web 3.0", speaker: "Jane Doe"}]}}, xml `<conference><session><topic>AI Trends</topic><speaker>Dr. Smith</speaker></session><session><topic>Web 3.0</topic><speaker>Jane Doe</speaker></session></conference>`]
    ];
}
