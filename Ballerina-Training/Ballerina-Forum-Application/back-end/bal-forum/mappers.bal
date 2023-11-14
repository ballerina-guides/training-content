import ballerina/time;
import ballerina/uuid;

function transformPostFromDatabase(ForumPostInDatabase postDb, PostComment[] comments) returns ForumPost|error => {
    title: postDb.title,
    username: postDb.username,
    description: postDb.description,
    id: postDb.id,
    likes: check postDb.likes.fromJsonStringWithType(),
    comments: comments,
    postedAt: postDb.postedAt
};

function transformUserFromDatabase(UserInDatabase userDb) returns User|error => {
    name: userDb.name,
    id: userDb.id,
    email: userDb.email,
    subscribtions: check userDb.subscribtions.fromJsonStringWithType()
};

function createPostFromNewPost(NewForumPost newPost, string username) returns ForumPostInDatabase|error => {
    title: newPost.title,
    username: username,
    description: newPost.description,
    id: uuid:createType1AsString(),
    likes: "[]",
    postedAt: check time:civilFromString(newPost.timestamp)
};

function createCommentFromNewComment(NewPostComment newComment, string postId) returns PostCommentInDatabase|error => {
    id: uuid:createType1AsString(),
    postId: postId,
    username: newComment.username,
    comment: newComment.comment,
    postedAt: check time:civilFromString(newComment.timestamp)
};


function createCommentFromDatabase(PostCommentInDatabase commentDb) returns PostComment|error => {
    id: commentDb.id,
    username: commentDb.username,
    comment: commentDb.comment,
    postedAt: commentDb.postedAt
};
