import ballerina/http;
import ballerina/uuid;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on new http:Listener(4000) {
    resource function post users(UserRegistration newUser) returns UserCreated|UserAlreadyExist|error {
        string|error id = forumDBClient->queryRow(`SELECT id FROM users WHERE name = ${newUser.name}`);

        if id is string {
            return {
                body: {
                    error_message: "User already exists"
                }
            };
        }

        string userId = uuid:createType1AsString();
        _ = check forumDBClient->execute(`INSERT INTO users VALUES (${userId}, ${newUser.name}, ${newUser.email}, ${newUser.password})`);

        return {
            body: {
                message: "User created successfully"
            }
        };
    }

    resource function post login(UserCredentials credentials) returns LoginSuccess|LoginFailure {
        string|error id = forumDBClient->queryRow(`SELECT id FROM users WHERE name = ${credentials.name} AND password = ${credentials.password}`);

        if id is string {
            return {
                body: {
                    id: id,
                    message: "Login successful"
                }
            };
        }

        return {
            body: {
                error_message: "Invalid credentials"
            }
        };
    }
}

type UserAlreadyExist record {|
    *http:Conflict;
    FailureResponse body;
|};

type UserCreated record {|
    *http:Created;
    SuccessResponse body;
|};

type LoginFailure record {|
    *http:Unauthorized;
    FailureResponse body;
|};

type LoginSuccess record {|
    *http:Ok;
    UserLogin body;
|};
