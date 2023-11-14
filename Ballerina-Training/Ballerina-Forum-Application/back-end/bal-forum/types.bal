import ballerina/http;
import ballerina/time;

type UserRegistration record {|
    string name;
    string email;
    string password;
|};

type User record {|
    string name;
    string email;
    string id;
    string[] subscribtions;
|};

type UserInDatabase record {|
    string name;
    string email;
    string id;
    string subscribtions;
|};

type NewForumPost record {|
    string title;
    string description;
    string timestamp;
|};

type ForumPost record {|
    string title;
    string description;
    string username;
    string id;
    string[] likes;
    PostComment[] comments;
    time:Civil postedAt;
|};

type ForumPostInDatabase record {|
    string title;
    string username;
    string description;
    string id;
    string likes;
    string comments;
    time:Civil postedAt;
|};

type UserLoginDetails record {|
    string name;
    string password;
|};

type Like record {|
    string userId;
|};

type NewPostComment record {|
    string username;
    string comment;
    string timestamp;
|};

type PostComment record {|
    string id;
    string username;
    string comment;
    time:Civil postedAt;
|};

type Sentiment record {
    string label;
};

type ErrorResponse record {|
    string error_message;
|};

type SuccessResponse record {|
    string message;
|};

type SuccessLogin record {|
    string message;
    User user;
|};

type LoginOk record {|
    *http:Ok;
    SuccessLogin body;
|};

type Unauthorized record {|
    *http:Unauthorized;
    ErrorResponse body;
|};

type Forbidden record {|
    *http:Forbidden;
    ErrorResponse body;
|};

type Ok record {|
    *http:Ok;
    SuccessResponse body;
|};

type Created record {|
    *http:Created;
    SuccessResponse body;
|};

type NotFound record {|
    *http:NotFound;
    ErrorResponse body;
|};

type Conflict record {|
    *http:Conflict;
    ErrorResponse body;
|};
