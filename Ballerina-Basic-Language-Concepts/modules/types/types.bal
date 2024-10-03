import ballerina/io;

// Exercise 03
public function simpleTypes() {
    float j = 100.10 - 0.01;
    io:println(j);

    decimal d = 100.10 - 0.01;
    io:println(d);
}
