// Exercise 12
import ballerina/io;

type TotalMark record {
    readonly string id;
    int total;
};

table<TotalMark> key(id) totalMarks = table [];

public function queryActions() {
    from Result result in results
    do {
        if (totalMarks.hasKey(result.id)) {
            TotalMark totalMark = totalMarks.get(result.id);
            totalMark.total = totalMark.total + result.score;
            totalMarks.put(totalMark);
        } else {
            TotalMark totalMark = {id: result.id, total: result.score};
            totalMarks.add(totalMark);
        }
        io:println(`Query Expression Result: ${result}`);
    };
}
