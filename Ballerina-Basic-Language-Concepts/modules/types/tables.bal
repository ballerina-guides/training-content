import ballerina/io;

type Doctor record {
    readonly record {
        string first;
        string last;
    } name;
    int age;
};

table<Doctor> key(name) t = table [
    {name: {first: "John", last: "Smith"}, age: 25},
    {name: {first: "Fred", last: "Bloggs"}, age: 35}
];

// Exercise 07
public function tableValues() {
    Doctor? e = t[{first: "Fred", last: "Bloggs"}];
    io:println(`Doctor: ${e}`);
    io:println(`Doctor Table: ${t}`);
}
