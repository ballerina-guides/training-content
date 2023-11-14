import ballerina/http;
import ballerina/log;
import ballerina/task;
import ballerinax/googleapis.gmail;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/nats;

# Database related configurations
type DatabaseConfig record {|
    # The database host
    string host;
    # The database user
    string user;
    # The database user password
    string password;
    # The database name
    string database;
    # The database port
    int port;
|};

configurable DatabaseConfig dbConfig = ?;

final mysql:Client forumDbClient = check new (...dbConfig);

# Sentiment endpoint related configurations
type SentimentEndpointConfig record {|
    # The endpoint URL
    string endpointUrl;
    # The retry interval
    decimal retryInterval;
    # The authentication configuration
    record {|
        # The refresh URL
        string refreshUrl;
        # The client ID
        string clientId;
        # The client secret
        string clientSecret;
        # The refresh token
        string refreshToken;
    |} authConfig;
|};

configurable SentimentEndpointConfig sentimentEpConfig = ?;

final http:Client sentimentClient = check new (sentimentEpConfig.endpointUrl,
    config = {
        retryConfig: {
            interval: sentimentEpConfig.retryInterval
        },
        auth: {
            ...sentimentEpConfig.authConfig,
            clientConfig: {
                secureSocket: {
                    cert: "./resources/public.crt"
                }
            }
        },
        secureSocket: {
            cert: "./resources/public.crt"
        }
    }
);

final nats:Client natsClient = check new (url = nats:DEFAULT_URL);

# Gmail related configurations
type GmailAuthConfig record {|
    # The refresh URL
    string refreshUrl = gmail:REFRESH_URL;
    # The refresh token
    string refreshToken;
    # The client ID
    string clientId;
    # The client secret
    string clientSecret;
|};

configurable GmailAuthConfig gmailAuthConfig = ?;

configurable string adminGmail = ?;

final gmail:Client gmailClient = check new ({auth: gmailAuthConfig});

const WELCOME_MAIL_SUBJECT = "Welcome to Ballerina Forum";

class EmailSenderTask {
    *task:Job;
    private final string recipientName;
    private final string recipientEmail;

    function init(string recipientName, string recipientEmail) {
        self.recipientName = recipientName;
        self.recipientEmail = recipientEmail;
    }

    public function execute() {
        gmail:MessageRequest request = {
            recipient: self.recipientEmail,
            sender: adminGmail,
            subject: WELCOME_MAIL_SUBJECT,
            messageBody: buildMessage(self.recipientName),
            contentType: gmail:TEXT_PLAIN
        };
        gmail:Message|error sendMessage = gmailClient->sendMessage(request);
        if sendMessage is error {
            log:printError("Failed to send the email", 'error = sendMessage, receipient = self.recipientEmail);
        } else {
            log:printInfo("The email has been sent", recipient = self.recipientEmail);
        }
    }
}

function buildMessage(string recipientName) returns string =>
string `Hi ${recipientName},  

Welcome to Ballerina Forum. We are glad to have you on board.  

Regards,  
Ballerina Forum Team`;
