import ballerina/log;
import ballerina/task;

class CreatPostJob {
    *task:Job;
    string id;
    NewForumPost newPost;

    function init(string id, NewForumPost newPost) {
        self.id = id;
        self.newPost = newPost;
    }

    public function execute() {
        do {
            check createForumPost(self.id, self.newPost);
            log:printInfo("Post created successfully", id = self.id, title = self.newPost.title);
        } on fail error err {
            log:printError("Error occurred while creating the post", title = self.newPost.title, 'error = err);
        }
    }
}

function createForumPost(string id, NewForumPost newPost) returns error? {
    ForumPostInDB forumPost = check createForumPostInDB(id, newPost);
    _ = check forumDBClient->execute(`
        INSERT INTO posts 
        VALUES (${forumPost.id}, ${forumPost.title}, ${forumPost.description}, 
            ${forumPost.user_id}, ${forumPost.likes}, ${forumPost.posted_at})
    `);
}

function getForumPost(ForumPostInDB forumPostInDB) returns ForumPost|error {
    stream<PostCommentInDB, error?> commentStream = forumDBClient->query(`
    SELECT comments.*, users.name 
    FROM comments
    INNER JOIN users ON comments.user_id = users.id 
    WHERE post_id = ${forumPostInDB.id} ORDER BY posted_at ASC
    `);
    PostComment[] comments = check from PostCommentInDB comment in commentStream
        select check createPostComment(comment);

    ForumPost forumPost = {
        id: forumPostInDB.id,
        username: check forumPostInDB["name"].ensureType(),
        title: forumPostInDB.title,
        description: forumPostInDB.description,
        likes: check forumPostInDB.likes.fromJsonStringWithType(),
        comments: comments,
        postedAt: forumPostInDB.posted_at
    };

    return forumPost;
}

function sendNatsMessage(string email) {
    RegisterEvent event = {email};
    do {
        _ = check natsClient->publishMessage({subject: "ballerina.forum", content: event});
    } on fail error err {
        log:printError("Error occurred while sending nats message", event = event, 'error = err);
    }
}
