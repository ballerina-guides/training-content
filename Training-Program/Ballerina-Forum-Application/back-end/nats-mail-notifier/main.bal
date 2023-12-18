import ballerina/io;
import ballerina/log;
import ballerinax/googleapis.gmail;
import ballerinax/nats;

type RegisterEvent record {
    string email;
};

configurable gmail:OAuth2RefreshTokenGrantConfig gmailAuthConfig = ?;

configurable string adminGmail = ?;

final gmail:Client gmailClient = check new ({auth: gmailAuthConfig});

const WELCOME_MAIL_SUBJECT = "Welcome to the Ballerina Language Forum!";

function sendGmailGreeting(RegisterEvent event) returns error? {
    do {
        gmail:MessageRequest request = {
            'from: adminGmail,
            to: [event.email],
            subject: WELCOME_MAIL_SUBJECT,
            bodyInHtml: check io:fileReadString("resources/welcome_mail.html")
        };
        _ = check gmailClient->/users/me/messages/send.post(request);
        log:printInfo("The email has been sent", recipient = event.email);
    } on fail error err {
        log:printError("Failed to send the email", receipient = event.email, 'error = err);
    }
}

@display {
    label: "NATS Notification Consumer",
    id: "nats-notifier"
}
service "ballerina.forum.new.user" on new nats:Listener(nats:DEFAULT_URL) {
    public function init() returns error? {
        log:printInfo("Mail notifier service started");
    }

    remote function onMessage(RegisterEvent event) returns error? {
        check sendGmailGreeting(event);
    }
}

