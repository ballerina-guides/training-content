// Exercise 02
import ballerina/io;

const INVALID_USERNAME = "InvalidUsername";

type InvalidUsernameLengthError InvalidUsernameError & error<record {int length;}>;

function validateUsernameWithErrorIntersection(json registration) returns error? {
    string username = check registration.username;
    if username.length() < 6 {
        return error InvalidUsernameLengthError(INVALID_USERNAME,
        message = "invalid length", length = username.length());
    }
    if username.indexOf(" ") !is () {
        return error InvalidUsernameError(INVALID_USERNAME,
        message = "contains spaces");
    }
}

public function errorIntersection() {
    error? res = validateUsernameWithErrorIntersection({username1: "wa"});
    if res is error {
        if res is InvalidUsernameLengthError {
            int length = res.detail().length;
            io:println(string `username validation failed due to invalid length: ${length}`);

        } else if res is InvalidUsernameError {
            io:println("username validation failed");

        } else {
            io:println("invalid payload");
        }
    }
}

