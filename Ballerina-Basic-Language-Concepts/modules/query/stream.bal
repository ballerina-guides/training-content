// Exercise 13
import ballerina/io;

type Member record {|
    int id;
    string name;
|};

public function streamValues() returns error? {
    stream<Member, io:Error?> fileReadCsvAsStream = check io:fileReadCsvAsStream("modules/query/resources/employees.csv");
    check from Member e in fileReadCsvAsStream
        do {
            io:println(`CSV results: ${e.id}, ${e.name}`);
        };
}

