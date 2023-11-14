import ballerina/http;
import ballerina/sql;
import ballerina/task;
import ballerina/time;
import ballerina/uuid;

configurable int port = 4000;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on new http:Listener(port) {
    resource function post users(UserRegistration newUser) returns Created|Conflict|error {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${newUser.name}
        `);
        if user is User {
            return {
                body: {
                    error_message: "User already exists"
                }
            };
        }

        string id = uuid:createType1AsString();
        _ = check forumDbClient->execute(`
            INSERT INTO users VALUES (${id}, ${newUser.name}, ${newUser.email}, ${newUser.password}, "[]")
        `);

        _ = start sendEmailNotification(newUser.clone());

        return {
            body: {
                message: "User created successfully!"
            }
        };
    }

    resource function get users/[string id]() returns User|NotFound|error {
        UserInDatabase|error userDb = forumDbClient->queryRow(`
            SELECT name, email, id, subscribtions FROM users WHERE id = ${id}
        `);
        if userDb is UserInDatabase {
            return transformUserFromDatabase(userDb);
        }

        return {
            body: {
                error_message: "User not found"
            }
        };
    }

    resource function post login(UserLoginDetails userLogin) returns LoginOk|Unauthorized {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${userLogin.name} && password = ${userLogin.password}
        `);
        if user is User {
            LoginOk loginOk = {
                body: {
                    message: "Login successfully",
                    user: user
                }
            };
            return loginOk;
        }

        Unauthorized unauthorized = {
            body: {
                error_message: "Invalid credentials"
            }
        };
        return unauthorized;
    }

    resource function post users/[string id]/posts(NewForumPost newPost) returns Created|Forbidden|error {
        Sentiment sentiment = check sentimentClient->/api/sentiment.post({
            text: newPost.description
        });
        if sentiment.label == "neg" {
            return {
                body: {
                    error_message: "Post rejected due to negative sentiment"
                }
            };
        }

        UserInDatabase userDb = check forumDbClient->queryRow(`
            SELECT name, email, id, subscribtions FROM users WHERE id = ${id}
        `);

        User user = check transformUserFromDatabase(userDb);
        ForumPost post = check createPostFromNewPost(newPost, user.name);
        transaction {
            _ = check forumDbClient->execute(`
            INSERT INTO posts VALUES (${post.id}, ${post.title}, ${post.description}, ${post.username}, ${post.likes.toJsonString()}, ${post.comments.toJsonString()}, ${post.postedAt})
        `);

            user.subscribtions.push(post.id);
            _ = check forumDbClient->execute(`
                UPDATE users SET subscribtions = ${user.subscribtions.toJsonString()} WHERE id = ${id}
            `);

            check commit;
        }

        return {
            body: {
                message: "Post created successfully!"
            }
        };
    }

    resource function get posts() returns ForumPost[]|error {
        stream<ForumPostInDatabase, sql:Error?> postStream = forumDbClient->query(`SELECT * FROM posts`);
        ForumPost[] posts = check from var post in postStream
            select check transformPostFromDatabase(post);
        return posts;
    }

    resource function post posts/[string id]/like(Like like) returns Ok|NotFound|Conflict|error {
        ForumPostInDatabase|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is error {
            NotFound postNotFound = {
                body: {
                    error_message: "Post not found"
                }
            };
            return postNotFound;
        }

        ForumPost post = check transformPostFromDatabase(postDb);
        if post.likes.indexOf(like.userId) is int {
            Conflict alreadyLiked = {
                body: {
                    error_message: "You have already liked this post"
                }
            };
            return alreadyLiked;
        }

        post.likes.push(like.userId);
        _ = check forumDbClient->execute(`
                UPDATE posts SET likes = ${post.likes.toJsonString()} WHERE id = ${id}
            `);

        return {
            body: {
                message: "Post liked successfully!"
            }
        };
    }

    resource function get posts/[string id]() returns ForumPost|NotFound|error {
        ForumPostInDatabase|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is error {
            return {
                body: {
                    error_message: "Post not found"
                }
            };
        }
        return transformPostFromDatabase(postDb);
    }

    resource function post posts/[string id]/comments(NewPostComment newComment) returns Created|NotFound|error {
        ForumPostInDatabase|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is error {
            return {
                body: {
                    error_message: "Post not found"
                }
            };
        }

        ForumPost post = check transformPostFromDatabase(postDb);
        PostComment comment = check createCommentFromNewComment(newComment);

        post.comments.push(comment);
        _ = check forumDbClient->execute(`
                UPDATE posts SET comments = ${post.comments.toJsonString()} WHERE id = ${id}
            `);

        if post.username != newComment.username {
            _ = start sendNatsNotification(id, newComment.username, post.title);
        }

        return {
            body: {
                message: "Comment added successfully!"
            }
        };
    }
}

function sendEmailNotification(UserRegistration user) returns error? {
    time:Utc scheduleTimeUtc = time:utcAddSeconds(time:utcNow(), 30);
    time:Civil scheduleTime = time:utcToCivil(scheduleTimeUtc);

    _ = check task:scheduleOneTimeJob(new EmailSenderTask(user.name, user.email), scheduleTime);
}

isolated function sendNatsNotification(string id, string commenter, string postTitle) returns error? {
    _ = check natsClient->publishMessage({
        subject: id,
        content: "New comment from " + commenter + " on " + postTitle + " post"
    });
}
