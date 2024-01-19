import ballerina/http;
import ballerina/log;

isolated boolean availability = false;

listener http:Listener sentiment_ls = new (9000,
    secureSocket = {
        'key: {
            certFile: "resources/server_public.crt",
            keyFile: "resources/server_private.key"
        },
        mutualSsl: {
            cert: "resources/client_public.crt"
        }
    }
);

configurable string oauth2IntrospectionUrl = ?;

@http:ServiceConfig {
    auth: [
        {
            oauth2IntrospectionConfig: {
                url: oauth2IntrospectionUrl,
                clientConfig: {
                    customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
                    secureSocket: {
                        cert: "resources/sts_server_public.crt"
                    }
                }
            }
        }
    ]
}
@display {
    label: "Sentiment Analysis Service",
    id: "sentiment-analysis"
}
service /text\-processing on sentiment_ls {

    public function init() {
        log:printInfo("Sentiment analysis service started");
    }

    isolated resource function post api/sentiment(Post post) returns Sentiment|http:ServiceUnavailable {
        // Return a dummy response
        lock {
            if availability {
                availability = false;
                return {
                    probability: {
                        neg: 0.30135019761690551,
                        neutral: 0.27119050546800266,
                        pos: 0.69864980238309449
                    },
                    label: POSITIVE
                };
            }
            availability = true;
            return http:SERVICE_UNAVAILABLE;
        }
    }
}

type Probability record {
    decimal neg;
    decimal neutral;
    decimal pos;
};

enum SENTIMENT_LABEL {
    NEGATIVE = "neg",
    NEUTRAL = "neutral",
    POSITIVE = "pos"
};

type Sentiment record {
    Probability probability;
    SENTIMENT_LABEL label;
};

type Post record {
    string text;
};
