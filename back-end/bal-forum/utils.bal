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