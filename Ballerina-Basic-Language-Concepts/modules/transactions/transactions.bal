// Exercise 04
import ballerina/io;
import ballerina/random;

public function callTrxFunction() returns error? {
    retry<RetryMgr>(5) transaction {
        check reserveRooms();
        check makePayment();
        check commit;
    }
    return;
}

transactional function reserveRooms() returns error? {
    io:println("rooms reserved");
    transaction:onCommit(sendEmail);
    transaction:onRollback(releaseRooms);
}

function makePayment() returns error? {
    transaction {
        int|random:Error randomNumber = random:createIntInRange(0, 5);
        if randomNumber is random:Error  || randomNumber < 3 {
            io:println(`payment failed due to random number ${randomNumber}`);
            rollback;
            return error("payment failed");
        } else {
            check commit;
            io:println(`payment sucessfull with random number ${randomNumber}`);
        }
    }
}


isolated function sendEmail('transaction:Info info) {
    io:println("Email sent.");
}

isolated function releaseRooms(transaction:Info info, error? cause, boolean willRetry) {
    io:println("reserved rooms are reverted");
}

class RetryMgr {
    private int count;
    private int currentCount = 0;
    public function init(int count = 3) {
        self.count = count;
    }
    public function shouldRetry(error? e) returns boolean {
        self.currentCount = self.currentCount + 1;
        return self.count > self.currentCount;
    }
}
