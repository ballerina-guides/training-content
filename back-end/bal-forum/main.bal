import ballerina/http;
import ballerina/uuid;
import ballerina/log;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on new http:Listener(4000) {

    public function init() {
        log:printInfo("Ballina Forum Service started");
    }

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
        _ = check forumDBClient->execute(`
            INSERT INTO users 
            VALUES (${userId}, ${newUser.name}, ${newUser.email}, ${newUser.password})
        `);

        return {
            body: {
                message: "User created successfully"
            }
        };
    }

    resource function post login(UserCredentials credentials) returns LoginSuccess|LoginFailure {
        string|error id = forumDBClient->queryRow(`
            SELECT id FROM users 
            WHERE name = ${credentials.name} AND password = ${credentials.password}
        `);

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

    resource function post users/[string id]/posts(NewForumPost newPost) returns PostCreated|UserNotFound|PostForbidden|error {
        string|error userId = forumDBClient->queryRow(`SELECT id FROM users WHERE id = ${id}`);

        if userId is error {
            return <UserNotFound>{
                body: {
                    error_message: "User not found"
                }
            };
        }

        Sentiment sentiment = check sentimentClient->/api/sentiment.post({text: newPost.title + " " + newPost.description});
        if sentiment.label != "pos" {
            return <PostForbidden>{
                body: {
                    error_message: "Post is forbidden due to negative sentiment"
                }
            };
        }

        ForumPostInDB forumPost = check createForumPostInDB(id, newPost);
        _ = check forumDBClient->execute(`
            INSERT INTO posts 
            VALUES (${forumPost.id}, ${forumPost.title}, ${forumPost.description}, 
                ${forumPost.user_id}, ${forumPost.likes}, ${forumPost.posted_at})
        `);

        return {
            body: {
                message: "Post created successfully"
            }
        };
    }

    resource function post posts/[string id]/likes(LikePost req) returns PostLiked|PostNotFound|PostAlreadyLiked|error {
        ForumPostInDB|error forumPost = check forumDBClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            return <PostNotFound>{
                body: {
                    error_message: "Post not found"
                }
            };
        }

        string[] likes = check forumPost.likes.fromJsonStringWithType();
        if likes.indexOf(req.userId) != () {
            return <PostAlreadyLiked>{
                body: {
                    error_message: "Already liked"
                }
            };
        }

        likes.push(req.userId);
        _ = check forumDBClient->execute(`UPDATE posts SET likes = ${likes.toJsonString()} WHERE id = ${id}`);

        return {
            body: {
                message: "Post liked successfully"
            }
        };
    }

    resource function post posts/[string id]/comments(NewPostComment newComment) returns CommentAdded|PostNotFound|error {
        ForumPostInDB|error forumPost = check forumDBClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            return {
                body: {
                    error_message: "Post not found"
                }
            };
        }

        PostCommentInDB comment = check createPostCommentInDB(id, newComment);
        _ = check forumDBClient->execute(`
            INSERT INTO comments 
            VALUES (${comment.id}, ${comment.post_id}, ${comment.user_id}, ${comment.comment}, ${comment.posted_at})
        `);

        return {
            body: {
                message: "Comment created successfully"
            }
        };
    }

    resource function get posts/[string id]() returns ForumPost|PostNotFound|error {
        ForumPostInDB|error forumPost = check forumDBClient->queryRow(`
            SELECT posts.*, users.name 
            FROM posts INNER JOIN users ON posts.user_id = users.id 
            WHERE posts.id = ${id}
        `);
        if forumPost is error {
            return {
                body: {
                    error_message: "Post not found"
                }
            };
        }

        return getForumPost(forumPost);
    }

    resource function get posts() returns ForumPost[]|error {
        stream<ForumPostInDB, error?> forumPostStream = forumDBClient->query(`
            SELECT posts.*, users.name 
            FROM posts INNER JOIN users ON posts.user_id = users.id
        `);
        ForumPost[] forumPosts = check from ForumPostInDB forumPost in forumPostStream
            select check getForumPost(forumPost);

        return forumPosts;
    }
}

type PostForbidden record {|
    *http:Forbidden;
    FailureResponse body;
|};

type CommentAdded record {|
    *http:Ok;
    SuccessResponse body;
|};

type PostAlreadyLiked record {|
    *http:Conflict;
    FailureResponse body;
|};

type PostNotFound record {|
    *http:NotFound;
    FailureResponse body;
|};

type PostLiked record {|
    *http:Ok;
    SuccessResponse body;
|};

type UserNotFound record {|
    *http:NotFound;
    FailureResponse body;
|};

type PostCreated record {|
    *http:Created;
    SuccessResponse body;
|};

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
