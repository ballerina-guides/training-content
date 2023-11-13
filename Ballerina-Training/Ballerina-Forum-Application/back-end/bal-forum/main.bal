import ballerina/http;
import ballerina/sql;
import ballerina/task;
import ballerina/time;
import ballerina/uuid;

configurable int PORT = 4000;
listener http:Listener forumServerEP = new (PORT);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on forumServerEP {
    resource function post users(NewUser newUser) returns Created|Conflict|error {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${newUser.name}
        `);
        if user is User {
            Conflict userExists = {
                body: {
                    error_message: "User already exists"
                }
            };
            return userExists;
        }

        string id = uuid:createType1AsString();
        _ = check forumDbClient->execute(`
            INSERT INTO users VALUES (${id}, ${newUser.name}, ${newUser.email}, ${newUser.password}, "[]")
        `);

        _ = start sendEmailNotification(newUser);

        Created userCreated = {
            body: {
                message: "User created successfully!"
            }
        };
        return userCreated;
    }

    resource function get users/[string id]() returns User|NotFound|error {
        UserDb|error userDb = forumDbClient->queryRow(`
            SELECT name, email, id, subscribtions FROM users WHERE id = ${id}
        `);
        if userDb is UserDb {
            User user = check transformUserFromDatabase(userDb);
            return user;
        }

        NotFound userNotFound = {
            body: {
                error_message: "User not found"
            }
        };
        return userNotFound;
    }

    resource function post login(UserLogin userLogin) returns LoginOk|Unauthorized {
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

    resource function post users/[string id]/posts(NewPost newPost) returns Created|Forbidden|error {
        Sentiment sentiment = check sentimentClient->/api/sentiment.post({
            text: newPost.description
        });
        if sentiment.label == "neg" {
            Forbidden forbidden = {
                body: {
                    error_message: "Post rejected due to negative sentiment"
                }
            };
            return forbidden;
        }

        UserDb userDb = check forumDbClient->queryRow(`
            SELECT name, email, id, subscribtions FROM users WHERE id = ${id}
        `);

        User user = check transformUserFromDatabase(userDb);
        Post post = check createPostFromNewPost(newPost, user.name);

        _ = check forumDbClient->execute(`
            INSERT INTO posts VALUES (${post.id}, ${post.title}, ${post.description}, ${post.username}, ${post.likes.toJsonString()}, ${post.comments.toJsonString()}, ${post.postedAt})
        `);

        if user.subscribtions.indexOf(post.id) is () {
            user.subscribtions.push(post.id);
            _ = check forumDbClient->execute(`
                UPDATE users SET subscribtions = ${user.subscribtions.toJsonString()} WHERE id = ${id}
            `);
        }

        Created created = {
            body: {
                message: "Post created successfully!"
            }
        };
        return created;
    }

    resource function get posts() returns http:Ok|error {
        stream<PostDb, sql:Error?> postStream = forumDbClient->query(`SELECT * FROM posts`);
        Post[] posts = check from var post in postStream
            select check transformPostFromDatabase(post);
        return {
            body: {
                posts: posts
            }
        };
    }

    resource function post posts/[string id]/like(Like like) returns Ok|NotFound|Conflict|error {
        PostDb|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is PostDb {
            Post post = check transformPostFromDatabase(postDb);
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

            Ok liked = {
                body: {
                    message: "Post liked successfully!"
                }
            };
            return liked;
        }

        NotFound postNotFound = {
            body: {
                error_message: "Post not found"
            }
        };
        return postNotFound;
    }

    resource function get posts/[string id]() returns Post|NotFound|error {
        PostDb|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is PostDb {
            Post post = check transformPostFromDatabase(postDb);
            return post;
        }

        NotFound postNotFound = {
            body: {
                error_message: "Post not found"
            }
        };
        return postNotFound;
    }

    resource function post posts/[string id]/comments(NewComment newComment) returns Created|NotFound|error {
        PostDb|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is PostDb {
            Post post = check transformPostFromDatabase(postDb);
            Comment comment = check createCommentFromNewComment(newComment);

            post.comments.push(comment);
            _ = check forumDbClient->execute(`
                UPDATE posts SET comments = ${post.comments.toJsonString()} WHERE id = ${id}
            `);

            if post.username != newComment.username {
                _ = start sendNatsNotification(id, newComment.username, post.title);
            }

            Created commentCreated = {
                body: {
                    message: "Comment added successfully!"
                }
            };
            return commentCreated;
        }

        NotFound postNotFound = {
            body: {
                error_message: "Post not found"
            }
        };
        return postNotFound;
    }
}

isolated function sendEmailNotification(NewUser user) returns error? {
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
