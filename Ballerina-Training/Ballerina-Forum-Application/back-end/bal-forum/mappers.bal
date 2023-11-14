import ballerina/time;
import ballerina/uuid;

function transformPostFromDatabase(ForumPostInDatabase postDb) returns ForumPost|error => {
    title: postDb.title,
    username: postDb.username,
    description: postDb.description,
    id: postDb.id,
    likes: check postDb.likes.fromJsonStringWithType(),
    comments: check postDb.comments.fromJsonStringWithType(),
    postedAt: postDb.postedAt
};

function transformUserFromDatabase(UserInDatabase userDb) returns User|error => {
    name: userDb.name,
    id: userDb.id,
    email: userDb.email,
    subscribtions: check userDb.subscribtions.fromJsonStringWithType()
};

function createPostFromNewPost(NewForumPost newPost, string username) returns ForumPost|error => {
    title: newPost.title,
    username: username,
    description: newPost.description,
    id: uuid:createType1AsString(),
    likes: [],
    comments: [],
    postedAt: check time:civilFromString(newPost.timestamp)
};

function createCommentFromNewComment(NewPostComment newComment) returns PostComment|error => {
    id: uuid:createType1AsString(),
    username: newComment.username,
    comment: newComment.comment,
    postedAt: check time:civilFromString(newComment.timestamp)
};
