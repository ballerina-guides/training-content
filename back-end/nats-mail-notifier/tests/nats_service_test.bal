import ballerina/file;
import ballerina/io;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/test;
import ballerinax/googleapis.gmail;
import ballerinax/nats;

final nats:Client natsClient = check new (natsUrl);
final string logFilePath = check file:createTemp(".log", "test-");

public client class MockGmailClient {
    resource isolated function post users/[string userId]/messages/send(gmail:MessageRequest request,
            gmail:Xgafv? xgafv = (), string? access_token = (), gmail:Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ()) returns gmail:Message|error {
        string[]? to = request?.to;
        if to is () {
            return error("mail to: is empty");
        }
        if to.length() != 1 {
            return error("mail to: is empty");
        }
        if to.pop() == "fail@gmail.com" {
            return error("mail sending failed");
        }
        return {
            threadId: "TID00001",
            id: "001"
        };
    }
}

@test:Mock {functionName: "getGmailClient"}
function getMockGmailClient() returns gmail:Client|error {
    return test:mock(gmail:Client, new MockGmailClient());
}

@test:BeforeSuite
function setLogFilePath() returns error? {
    check log:setOutputFile(logFilePath, log:OVERWRITE);
}

@test:BeforeEach
function cleanLogs() returns error? {
    if check file:test(logFilePath, file:EXISTS) {
        check file:remove(logFilePath);
    }
    check file:create(logFilePath);
}

@test:Config {dataProvider: dataProvider}
function testNatsServiceWithGmailSuccess(string email, string expectedLogOutput) returns error? {
    RegisterEvent event = {email};
    check natsClient->publishMessage({content: event, subject: "ballerina.forum.new.user"});

    // wait for the NATS listener to recieve the message
    runtime:sleep(1);
    string actualLogOutput = check io:fileReadString(logFilePath);
    test:assertTrue(actualLogOutput.includes(expectedLogOutput));
}

function dataProvider() returns string[][] {
    return [
        ["fail@gmail.com", "Failed to send the email"],
        ["johndoe@gmail.com", "The email has been sent"]
    ];
}
