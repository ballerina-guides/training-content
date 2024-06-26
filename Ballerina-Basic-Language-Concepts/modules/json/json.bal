// Exercise 15
import ballerina/io;

json j = {
    "order": [
        {
            "id": "order1",
            "customer": {
                "name": "John Smith",
                "email": "john@gmail.com"
            },
            "items": {
                "item": [
                    {
                        "id": "item1",
                        "name": "Item 1",
                        "quantity": 1,
                        "price": 1.00
                    },
                    {
                        "id": "item2",
                        "name": "Item 2",
                        "quantity": 2,
                        "price": 2.00
                    }
                ]
            }
        },
        {
            "id": "order2",
            "customer": {
                "name": "Alex Scooper",
                "email": "alex@gmail.com"
            },
            "items": {
                "item": [
                    {
                        "id": "item1",
                        "name": "Item 3",
                        "quantity": 3,
                        "price": 3.00
                    },
                    {
                        "id": "item2",
                        "name": "Item 4",
                        "quantity": 4,
                        "price": 4.00
                    }
                ]
            }
        }
    ]
};

type Customer record {
    string name;
    string email;
};

type ItemItem record {
    string id;
    string name;
    int quantity;
    decimal price;
};

type Items record {
    ItemItem[] item;
};

type OrderItem record {
    string id;
    Customer customer;
    Items items;
};

type OrderItemSummary record {
    OrderItem[] 'order;
};

public function convertJson() returns error? {
    OrderItemSummary orderItemSummary = check j.cloneWithType();
    json j = orderItemSummary.toJson();
    io:println(`Json to Record: ${j}`);
}

