import ballerina/io;

xmlns "http://www.example.com/orders" as ns;

xml xmlOrders = xml `<orders xmlns="http://www.example.com/orders">
    <order id="1">
        <customer>
            <name>John Smith</name>
            <email>john@example.com</email>
        </customer>
        <items>
            <item id="1">
                <name>Product 1</name>
                <quantity>2</quantity>
                <price>19.99</price>
            </item>
            <item id="2">
                <name>Product 2</name>
                <quantity>1</quantity>
                <price>29.99</price>
            </item>
            <item id="3">
                <name>Product 3</name>
                <quantity>3</quantity>
                <price>9.99</price>
            </item>
        </items>
        <total currency="USD">99.95</total>
    </order>
    <order id="2">
        <customer>
            <name>Jane Doe</name>
            <email>jane@example.com</email>
        </customer>
        <items>
            <item id="1">
                <name>Product 1</name>
                <quantity>5</quantity>
                <price>19.99</price>
            </item>
            <item id="4">
                <name>Product 4</name>
                <quantity>2</quantity>
                <price>49.99</price>
            </item>
        </items>
        <total currency="USD">149.93</total>
    </order>
</orders>`;

xml:Element details = xml `<details><language>English</language></details>`;
xml:Element x1 = xml `<name>Sherlock Holmes</name>`;
xml x2 = xml `<author>Sir Arthur Conan Doyle</author><language>English</language>`;

// Exercise 08
public function xmlValues() {
    xml x3 = x1 + x2;
    details.setChildren(xml `<language>French</language>`);
    string firstCustomer = (xmlOrders/<ns:'order>[0]/<ns:customer>/<ns:name>).data();
    xml allCustomers = xmlOrders/**/<ns:customer>;
    xml customers = xml `<customers>${allCustomers}</customers>`;
    io:println(`Xml values x3: ${x3} ${"\n"} Xml values details: ${details} ${"\n"} 
        Xml values firstCustomer: ${firstCustomer} ${"\n"} Xml values customers: ${customers}`);
}

