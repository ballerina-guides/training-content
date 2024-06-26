import ballerina/io;

// Exercise 05
public function tupleValues() {
    [string, int...] t = ["waruna", 12, 45];
    t = ["waruna", 12];
    io:println(`Tuple values: ${t}`);
}
