import ballerina/http;
import ballerina/test;

configurable SentimentClientConfig sentimentClientConfig = ?;

type SentimentClientConfig record {|
    string clientUrl;
    string refreshUrl;
    string refreshToken;
    string clientId;
    string clientSecret;
|};

http:Client? sentimentClient = ();
int|string x = 1;

@test:BeforeSuite
function initializeSentimentClient() returns error? {
    sentimentClient = check new (sentimentClientConfig.clientUrl,
        secureSocket = {
            cert: "resources/server_public.crt",
            'key: {
                certFile: "resources/client_public.crt",
                keyFile: "tests/resources/client_private.key"
            }
        },
        auth = {
            refreshUrl: sentimentClientConfig.refreshUrl,
            refreshToken: sentimentClientConfig.refreshToken,
            clientId: sentimentClientConfig.clientId,
            clientSecret: sentimentClientConfig.clientSecret,
            clientConfig: {
                secureSocket: {
                    cert: "resources/sts_server_public.crt"
                }
            }
        }
    );
}

@test:Config {}
function testSentimentApiWhenUnavailable() returns error? {
    Sentiment|http:Error sentiment = (<http:Client>sentimentClient)->/api/sentiment.post({text: "I am happy!"});
    if sentiment is Sentiment {
        test:assertFail("sentiment response is not an error");
    }
    test:assertEquals(sentiment.message(), "Service Unavailable");
}

@test:Config {dependsOn: [testSentimentApiWhenUnavailable]}
function testSentimentApiWhenAvailable() {
    Sentiment|http:Error sentiment = (<http:Client>sentimentClient)->/api/sentiment.post({text: "I am happy!"});
    if sentiment is http:Error {
        test:assertFail("sentiment response is an error");
    }
    Sentiment expectedSentiment = {
        probability: {
            neg: 0.30135019761690551,
            neutral: 0.27119050546800266,
            pos: 0.69864980238309449
        },
        label: POSITIVE
    };
    test:assertEquals(sentiment, expectedSentiment, "sentiment response is not as expected");
}
