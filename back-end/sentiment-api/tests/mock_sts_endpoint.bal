import ballerina/http;
import ballerina/log;
import ballerina/uuid;

// Default values of mock authorization server.
configurable int STS_SERVER_PORT = 9446;

// The mock authorization server.
listener http:Listener sts = new (STS_SERVER_PORT, {
    secureSocket: {
        key: {
            certFile: "resources/sts_server_public.crt",
            keyFile: "tests/resources/sts_server_private.key"
        }
    }
});

service /oauth2 on sts {

    function init() {
        log:printInfo("Mock STS endpoint started", host = "0.0.0.0", port = STS_SERVER_PORT, protocol = "HTTPS");
    }

    // This issues an access token with reference to the received grant type (client credentials, password and refresh token grant type).
    resource function post token(http:Request req) returns http:Ok|http:Unauthorized|http:BadRequest|http:InternalServerError {
        return prepareDummyTokenResponse();
    }

    resource function post introspect(http:Request req) returns http:Ok|http:Unauthorized|http:BadRequest|http:ClientError {
        var payload = req.getTextPayload();
        string:RegExp r = re `=`;
        string token = r.split(check payload)[1];
        return prepareIntrospectionResponse(token, "");
    }
}

function prepareDummyTokenResponse() returns http:Ok {
    string newAccessToken = uuid:createType4AsString();
    string newRefreshToken = uuid:createType4AsString();
    json response = {
        "access_token": newAccessToken,
        "refresh_token": newRefreshToken,
        "token_type": "example",
        "expires_in": 3600,
        "example_parameter": "example_value"
    };

    http:Ok ok = {body: response};
    return ok;
}

function prepareIntrospectionResponse(string accessToken, string tokenTypeHint) returns http:Ok {
    json response = {
        "active": true,
        "scope": "read write dolphin",
        "client_id": "l238j323ds-23ij4",
        "username": "jdoe",
        "token_type": "token_type",
        "exp": 3600,
        "iat": 1419350238,
        "nbf": 1419350238,
        "sub": "Z5O3upPC88QrAjx00dis",
        "aud": "https://protected.example.net/resource",
        "iss": "https://server.example.com/",
        "jti": "JlbmMiOiJBMTI4Q0JDLUhTMjU2In",
        "extension_field": "twenty-seven",
        "scp": "admin"
    };
    http:Ok ok = {body: response};
    return ok;
}
