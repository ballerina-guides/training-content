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

function transformForumPostWithComment(ForumPostWithCommentInDB forumPostWithCommentInDb) returns ForumPostWithComment|error => {
    postedAt: forumPostWithCommentInDb.posted_at,
    likes: check forumPostWithCommentInDb.likes.fromJsonStringWithType(),
    id: forumPostWithCommentInDb.id,
    comment: {
        comment: forumPostWithCommentInDb.comment,
        id: forumPostWithCommentInDb.COMMENTS\.id,
        username: forumPostWithCommentInDb.comment_user_name,
        postedAt: forumPostWithCommentInDb.COMMENTS\.posted_at
    },
    username: forumPostWithCommentInDb.user_name,
    description: forumPostWithCommentInDb.description,
    title: forumPostWithCommentInDb.title
};
