import ballerina/log;
import ballerinax/nats;

type RegisterEvent record {
    string email;
};

service "ballerina.forum.new.user" on new nats:Listener(nats:DEFAULT_URL) {
    public function init() returns error? {
        log:printInfo("NATS consumer service started");
    }

    remote function onMessage(RegisterEvent event) {
        log:printInfo("received a new user registration event", email = event.email);;
    }
}

