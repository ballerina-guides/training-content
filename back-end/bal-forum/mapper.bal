import ballerina/uuid;
import ballerina/time;

function createForumPostInDB(string userId, NewForumPost newForumPost) returns ForumPostInDB|error => {
    id: uuid:createType1AsString(),
    user_id: userId,
    description: newForumPost.description,
    title: newForumPost.title,
    posted_at: check time:civilFromString(newForumPost.timestamp),
    likes: "[]"
};
