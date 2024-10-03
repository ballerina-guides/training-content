// Exercise 14
import ballerina/io;
import ballerina/xmldata;

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

type Customer record {
    string name;
    string email;
};

type Item record {
    string name;
    int quantity;
    decimal price;
    @xmldata:Attribute
    string id;
};

type Items record {
    Item[] item;
};

type Order record {
    Customer customer;
    Items items;
    decimal total;
    @xmldata:Attribute
    string id;
};

@xmldata:Name {value: "orders"}
type Orders record {
    Order[] 'order;
    @xmldata:Attribute
    string 'xmlns;
};

type OrderSummary record {
   		 readonly Customer customer;
    		 decimal total;
};

public function convertXML() {
    Orders orders = checkpanic xmldata:fromXml(xmlOrders);
    json jsonOrders = orders.toJson();
    Customer[] customers = from xml customer in xmlOrders/<ns:'order>/<ns:customer>
        select {name: (customer/<ns:name>).data(), email: (customer/<ns:email>).data()};
    xml xmlCustomers = from Customer c in customers
        select xml `<customer><name>${c.name}</name><email>${c.email}</email></customer>`;
    xml customerSummary = xml `<customerSummary>${xmlCustomers}</customerSummary>`;
    OrderSummary[]|error orderSummary = getOrderSummary();
    io:println(`Xml to Json Orders: ${jsonOrders}  customerSummary: ${customerSummary}   orderSummary: ${orderSummary}`);

}

function getOrderSummary() returns OrderSummary[]|error {
    OrderSummary[] orderSummary = from xml 'order in xmlOrders/<ns:'order>
        let xml customer = 'order/<ns:customer>
        let decimal total = check getTotal('order/<ns:items>)
        select {
            customer: {name: (customer/<ns:name>).data(), email: (customer/<ns:email>).data()},
            total: total
        };
    return orderSummary;
}

function getTotal(xml items) returns decimal|error {
    decimal total = 0;
    from xml item in items/<ns:item>
    let int quantity = check int:fromString((item/<ns:quantity>).data())
    let decimal price = check decimal:fromString((item/<ns:price>).data())
    do {
        total += quantity * price;
    };
    return total;
}

