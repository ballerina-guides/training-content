// Exercise 11
import ballerina/io;

type Student record {|
    string id;
    string name;
|};

type Result record {|
    string id;
    string subject;
    int score;
|};

Student[] students = [
    {id: "1", name: "Alice"},
    {id: "2", name: "Bob"},
    {id: "3", name: "Charlie"},
    {id: "4", name: "David"}
];
Result[] results = [
    {id: "1", subject: "Mathematics", score: 85},
    {id: "2", subject: "Mathematics", score: 75},
    {id: "1", subject: "Science", score: 35},
    {id: "2", subject: "Science", score: 65}
];

public function queryExpressions() {
    var result = from Result result in results
        where result.score > 25
        let var grade = getGrade(result.score)
        join var student in students on result.id equals student.id
        order by result.score descending
        limit 2
        select {name: student.name, subject: result.subject, score: result.score, grade: grade};
    io:println(`Query Expression Result: ${result}`);
}

function getGrade(int score) returns string {
    if (score > 50) {
        return "A";
    } else if (score > 40) {
        return "B";
    } else {
        return "C";
    }
}
