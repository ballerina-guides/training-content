import ballerina/time;
import ballerina/uuid;

function createForumPostInDB(string userId, NewForumPost newForumPost) returns ForumPostInDB|error => {
    id: uuid:createType1AsString(),
    user_id: userId,
    description: newForumPost.description,
    title: newForumPost.title,
    posted_at: check time:civilFromString(newForumPost.timestamp),
    likes: "[]"
};

function createPostCommentInDB(string postId, NewPostComment newPostComment) returns PostCommentInDB|error => {
    id: uuid:createType1AsString(),
    user_id: newPostComment.userId,
    post_id: postId,
    comment: newPostComment.comment,
    posted_at: check time:civilFromString(newPostComment.timestamp)
};

function createPostComment(PostCommentInDB postCommentInDB) returns PostComment|error => {
    id: postCommentInDB.id,
    username: check postCommentInDB["name"].ensureType(),
    comment: postCommentInDB.comment,
    postedAt: postCommentInDB.posted_at
};
