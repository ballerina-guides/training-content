import ballerina/io;

// Exercise 04
public function arrayValues() {
    int[] v = [1, 2, 3];
    int[] w = [4, 5, 6];
    int[] x = [...v, ...w];
    io:println(`Combined Array = ${x}`);
}
