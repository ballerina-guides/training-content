// Exercise 01
import ballerina/io;

const INVALID_USERNAME = "InvalidUsername";

type InvalidUsernameError distinct error<record { string message; }>;

public function distinctErrors() {
    error? res = validateUsername({username1: "wa"});
    if res is error {
        if res is InvalidUsernameError {
            io:println("username validation failed: " + res.message());
        } else {
            io:println("invalid payload" + res.message());
        }
    }
}

function validateUsername(json registration) returns error? {
    string username = check registration.username;

    if username.length() < 6 {
        return error InvalidUsernameError(INVALID_USERNAME, 
        message = "invalid length");
    }

    if username.indexOf(" ") !is () {
        return error InvalidUsernameError(INVALID_USERNAME, 
                 message = "contains spaces");
    }
}

