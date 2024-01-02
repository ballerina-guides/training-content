import ballerina/http;
import ballerina/sql;
import ballerina/test;
import ballerina/time;
import ballerina/uuid;
import ballerinax/mysql;
import ballerinax/nats;

string forumServiceUrl = "http://localhost:4000/api";

http:Client forumClient = check new (forumServiceUrl);

client class MockHttpClient {
    isolated resource function post [http:PathParamType... path](http:RequestMessage message, map<string|string[]>? headers = (), string?
            mediaType = (), http:TargetType targetType = http:Response, *http:QueryParams params)
            returns http:Response|anydata|http:ClientError {
        string label = message.toString().includes("Negative") ? "neg" : "pos";
        Sentiment sentiment = {
            probability: {
                neg: 0.1,
                neutral: 0.1,
                pos: 0.8
            },
            label
        };
        return sentiment;
    }
}

@test:Mock {
    functionName: "initDbClient"
}
function mockInitDbClient() returns mysql:Client|error {
    return test:mock(mysql:Client);
}

@test:Mock {
    functionName: "initSentimentClient"
}
function mockInitSentimentClient() returns http:Client|error {
    return test:mock(http:Client, new MockHttpClient());
}

@test:Mock {
    functionName: "initNatsClient"
}
function mockInitNatsClient() returns nats:Client|error {
    return test:mock(nats:Client);
}

@test:Config {groups: ["create-user"]}
function testCreateExistingUser() returns error? {
    string existingId = uuid:createType1AsString();
    test:prepare(forumDBClient).when("queryRow").thenReturn(existingId);
    http:Response response = check forumClient->/users.post(
        {name: "John Doe", email: "johndoe@gmail.com", password: "1234"}
    );
    test:assertEquals(response.statusCode, http:STATUS_CONFLICT, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "User already exists"}, "Response mismatched");
}

@test:Config {groups: ["create-user"]}
function testCreateNewUser() returns error? {
    sql:Error noUserError = error("No user found");
    test:prepare(forumDBClient).when("queryRow").thenReturn(noUserError);
    sql:ExecutionResult queryExecutionResult = {affectedRowCount: 1, lastInsertId: 1};
    test:prepare(forumDBClient).when("execute").thenReturn(queryExecutionResult);
    test:prepare(natsClient).when("publishMessage").doNothing();
    http:Response response = check forumClient->/users.post(
        {name: "John Doe", email: "johndoe@gmail.com", password: "1234"}
    );
    test:assertEquals(response.statusCode, http:STATUS_CREATED, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {message: "User created successfully"}, "Response mismatched");
}

@test:Config {groups: ["login"]}
function testLoginWithInvalidCredentials() returns error? {
    sql:Error noUserError = error("No user found");
    test:prepare(forumDBClient).when("queryRow").thenReturn(noUserError);
    http:Response response = check forumClient->/login.post({name: "John Doe", password: "1234"});
    test:assertEquals(response.statusCode, http:STATUS_UNAUTHORIZED, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "Invalid credentials"}, "Response mismatched");
}

@test:Config {groups: ["login"]}
function testLoginWithValidCredentials() returns error? {
    string id = uuid:createType1AsString();
    test:prepare(forumDBClient).when("queryRow").thenReturn(id);
    http:Response response = check forumClient->/login.post({name: "John Doe", password: "1234"});
    test:assertEquals(response.statusCode, http:STATUS_OK, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {id, message: "Login successful"}, "Response mismatched");
}

@test:Config {groups: ["post"]}
function testPostWithInvalidUser() returns error? {
    string userId = uuid:createType1AsString();
    sql:Error noUserError = error("No user found");
    test:prepare(forumDBClient).when("queryRow").thenReturn(noUserError);
    http:Response response = check forumClient->/users/[userId]/posts.post(
        {title: "Ballerina Websub", description: "Ballerina supports websub", timestamp: "2023-12-03T10:15:30.00Z"}
    );
    test:assertEquals(response.statusCode, http:STATUS_NOT_FOUND, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "User not found"}, "Response mismatched");
}

@test:Config {groups: ["post"]}
function testPostWithNegativeSentiment() returns error? {
    string userId = uuid:createType1AsString();
    test:prepare(forumDBClient).when("queryRow").thenReturn(userId);
    http:Response response = check forumClient->/users/[userId]/posts.post(
        {title: "Negative Post", description: "Foo bar", timestamp: "2023-12-03T10:15:30.00Z"}
    );
    test:assertEquals(response.statusCode, http:STATUS_FORBIDDEN, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(),
        {error_message: "Post is forbidden due to negative sentiment"}, "Response mismatched");
}

@test:Config {groups: ["post"]}
function testPostWithPositiveSentiment() returns error? {
    string userId = uuid:createType1AsString();
    test:prepare(forumDBClient).when("queryRow").thenReturn(userId);
    http:Response response = check forumClient->/users/[userId]/posts.post(
        {title: "Ballerina Websub", description: "Ballerina supports websub", timestamp: "2023-12-03T10:15:30.00Z"}
    );
    test:assertEquals(response.statusCode, http:STATUS_CREATED, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(),
        {message: "Post created successfully"}, "Response mismatched");
}

@test:Config {groups: ["post"]}
function testPostWithInvalidScheduleTime() returns error? {
    string userId = uuid:createType1AsString();
    test:prepare(forumDBClient).when("queryRow").thenReturn(userId);
    NewForumPost newPost = {
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        timestamp: "2023-12-03T10:15:30.00Z"
    };

    // invalid schedule time
    string schedule = "2023-12-03T10:15:30.00Z";
    http:Response response = check forumClient->/users/[userId]/posts.post(newPost, schedule = schedule);
    test:assertEquals(response.statusCode, http:STATUS_BAD_REQUEST, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(),
        {error_message: "Invalid schedule time"}, "Response mismatched");
}

@test:Config {groups: ["post"]}
function testPostWithValidScheduleTime() returns error? {
    string userId = uuid:createType1AsString();
    test:prepare(forumDBClient).when("queryRow").thenReturn(userId);
    NewForumPost newPost = {
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        timestamp: "2023-12-03T10:15:30.00Z"
    };
    string schedule = time:utcToString(time:utcAddSeconds(time:utcNow(), 100));
    http:Response response = check forumClient->/users/[userId]/posts.post(newPost, schedule = schedule);
    test:assertEquals(response.statusCode, http:STATUS_ACCEPTED, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(),
        {message: "Post scheduled successfully"}, "Response mismatched");
}

@test:Config {groups: ["like"]}
function testLikeNonExistingPost() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    sql:Error noPostError = error("No post found");
    test:prepare(forumDBClient).when("queryRow").thenReturn(noPostError);
    http:Response response = check forumClient->/posts/[postId]/likes.post({userId});
    test:assertEquals(response.statusCode, http:STATUS_NOT_FOUND, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "Post not found"}, "Response mismatched");
}

@test:Config {groups: ["like"]}
function testLikeFromAlreadyLikedUser() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    ForumPostInDB forumPost = {
        id: postId,
        user_id: userId,
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
        likes: [userId].toJsonString()
    };
    test:prepare(forumDBClient).when("queryRow").thenReturn(forumPost);
    http:Response response = check forumClient->/posts/[postId]/likes.post({userId});
    test:assertEquals(response.statusCode, http:STATUS_CONFLICT, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "Already liked"}, "Response mismatched");
}

@test:Config {groups: ["like"]}
function testLikePostFromNotYetLikedUser() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    ForumPostInDB forumPost = {
        id: postId,
        user_id: userId,
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
        likes: [].toJsonString()
    };
    test:prepare(forumDBClient).when("queryRow").thenReturn(forumPost);
    http:Response response = check forumClient->/posts/[postId]/likes.post({userId});
    test:assertEquals(response.statusCode, http:STATUS_OK, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {message: "Post liked successfully"}, "Response mismatched");
}

@test:Config {groups: ["comment"]}
function testCommentOnNonExistingPost() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    NewPostComment comment = {userId, comment: "This is a comment", timestamp: "2023-12-03T10:15:30.00Z"};
    sql:Error noPostError = error("No post found");
    test:prepare(forumDBClient).when("queryRow").thenReturn(noPostError);
    http:Response response = check forumClient->/posts/[postId]/comments.post(comment);
    test:assertEquals(response.statusCode, http:STATUS_NOT_FOUND, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "Post not found"}, "Response mismatched");
}

@test:Config {groups: ["comment"]}
function testCommentOnExistingPost() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    NewPostComment comment = {userId, comment: "This is a comment", timestamp: "2023-12-03T10:15:30.00Z"};
    ForumPostInDB forumPost = {
        id: postId,
        user_id: userId,
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
        likes: [].toJsonString()
    };
    test:prepare(forumDBClient).when("queryRow").thenReturn(forumPost);
    sql:ExecutionResult queryExecutionResult = {affectedRowCount: 1, lastInsertId: 1};
    test:prepare(forumDBClient).when("execute").thenReturn(queryExecutionResult);
    http:Response response = check forumClient->/posts/[postId]/comments.post(comment);
    test:assertEquals(response.statusCode, http:STATUS_OK, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {message: "Comment created successfully"}, "Response mismatched");
}

@test:Config {groups: ["get-post"]}
function testGetNonExistingPost() returns error? {
    string postId = uuid:createType1AsString();
    sql:Error noPostError = error("No post found");
    test:prepare(forumDBClient).when("queryRow").thenReturn(noPostError);
    http:Response response = check forumClient->/posts/[postId];
    test:assertEquals(response.statusCode, http:STATUS_NOT_FOUND, "Status code mismatched");
    test:assertEquals(response.getJsonPayload(), {error_message: "Post not found"}, "Response mismatched");
}

@test:Config {groups: ["get-post"]}
function testGetExistingPost() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    ForumPostInDB forumPost = {
        id: postId,
        user_id: userId,
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
        likes: [].toJsonString(),
        "name": "John Doe"
    };
    test:prepare(forumDBClient).when("queryRow").thenReturn(forumPost);
    string commentId = uuid:createType1AsString();
    PostCommentInDB[] comments = [
        {
            id: commentId,
            post_id: postId,
            user_id: uuid:createType1AsString(),
            comment: "This is a comment",
            posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
            "name": "Jane Doe"
        }
    ];
    stream<PostCommentInDB, error?> commentStream = comments.toStream();
    test:prepare(forumDBClient).when("query").thenReturn(commentStream);
    ForumPost actualPost = check forumClient->/posts/[postId];
    ForumPost expectedPost = {
        title: "Ballerina Websub",
        description: "Ballerina supports websub",
        username: "John Doe",
        id: postId,
        likes: [],
        comments: [
            {
                id: commentId,
                username: "Jane Doe",
                comment: "This is a comment",
                postedAt: {
                    timeAbbrev: "Z",
                    dayOfWeek: 0,
                    year: 2023,
                    month: 12,
                    day: 3,
                    hour: 10,
                    minute: 15,
                    second: 30.0
                }
            }
        ],
        postedAt: {
            timeAbbrev: "Z",
            dayOfWeek: 0,
            year: 2023,
            month: 12,
            day: 3,
            hour: 10,
            minute: 15,
            second: 30.0
        }
    };
    test:assertEquals(actualPost, expectedPost, "Response mismatched");
}

@test:Config {groups: ["get-post"]}
function testGetAllPosts() returns error? {
    string postId = uuid:createType1AsString();
    string userId = uuid:createType1AsString();
    ForumPostInDB[] forumPosts = [
        {
            id: postId,
            user_id: userId,
            title: "Ballerina Websub",
            description: "Ballerina supports websub",
            posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
            likes: [].toJsonString(),
            "name": "John Doe"
        }
    ];
    stream<ForumPostInDB, error?> postStream = forumPosts.toStream();
    string commentId = uuid:createType1AsString();
    PostCommentInDB[] comments = [
        {
            id: commentId,
            post_id: postId,
            user_id: uuid:createType1AsString(),
            comment: "This is a comment",
            posted_at: check time:civilFromString("2023-12-03T10:15:30.00Z"),
            "name": "Jane Doe"
        }
    ];
    stream<PostCommentInDB, error?> commentStream = comments.toStream();
    test:prepare(forumDBClient).when("query").thenReturnSequence(postStream, commentStream);
    ForumPost[] actualPosts = check forumClient->/posts;
    ForumPost[] expectedPosts = [
        {
            title: "Ballerina Websub",
            description: "Ballerina supports websub",
            username: "John Doe",
            id: postId,
            likes: [],
            comments: [
                {
                    id: commentId,
                    username: "Jane Doe",
                    comment: "This is a comment",
                    postedAt: {
                        timeAbbrev: "Z",
                        dayOfWeek: 0,
                        year: 2023,
                        month: 12,
                        day: 3,
                        hour: 10,
                        minute: 15,
                        second: 30.0
                    }
                }
            ],
            postedAt: {
                timeAbbrev: "Z",
                dayOfWeek: 0,
                year: 2023,
                month: 12,
                day: 3,
                hour: 10,
                minute: 15,
                second: 30.0
            }
        }
    ];
    test:assertEquals(actualPosts, expectedPosts, "Response mismatched");
}
