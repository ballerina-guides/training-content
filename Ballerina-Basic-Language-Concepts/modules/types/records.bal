import ballerina/io;

type Person record {
    string name;
    Address address?;
    int? salary;
};

type Address record {
    string city;
};

// Exercise 06
public function recordValues() {
    Person p1 = {name: "John", salary: ()};
    string? city = p1.address?.city;
    io:println(`P1 city: ${city}`);
}
