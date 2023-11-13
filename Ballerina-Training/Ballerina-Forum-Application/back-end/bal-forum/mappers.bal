import ballerina/time;
import ballerina/uuid;

function transformPostFromDatabase(PostDb postDb) returns Post|error => {
    title: postDb.title,
    username: postDb.username,
    description: postDb.description,
    id: postDb.id,
    likes: check postDb.likes.fromJsonStringWithType(),
    comments: check postDb.comments.fromJsonStringWithType(),
    postedAt: postDb.postedAt
};

function transformUserFromDatabase(UserDb userDb) returns User|error => {
    name: userDb.name,
    id: userDb.id,
    email: userDb.email,
    subscribtions: check userDb.subscribtions.fromJsonStringWithType()
};

function createPostFromNewPost(NewPost newPost, string username) returns Post|error => {
    title: newPost.title,
    username: username,
    description: newPost.description,
    id: uuid:createType1AsString(),
    likes: [],
    comments: [],
    postedAt: check time:civilFromString(newPost.timestamp)
};

function createCommentFromNewComment(NewComment newComment) returns Comment|error => {
    id: uuid:createType1AsString(),
    username: newComment.username,
    comment: newComment.comment,
    postedAt: check time:civilFromString(newComment.timestamp)
};
