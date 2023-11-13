import ballerina/http;
import ballerina/time;

# Represents the new user request
type NewUser record {|
    # Name of the user
    string name;
    # Email of the user
    string email;
    # Password of the user
    string password;
|};

# Represents the user record
type User record {|
    # Name of the user
    string name;
    # Email of the user
    string email;
    # Id of the user
    string id;
    # Subscribtions of the user
    string[] subscribtions;
|};

# Represents the user record in the database
type UserDb record {|
    # Name of the user
    string name;
    # Email of the user
    string email;
    # Id of the user
    string id;
    # Subscribtions of the user
    string subscribtions;
|};

# Represents the new post request
type NewPost record {|
    # Title of the post
    string title;
    # Description of the post
    string description;
    # Posted time
    string timestamp;
|};

# Represents the post record
type Post record {|
    # Title of the post
    string title;
    # Description of the post
    string description;
    # Username of the user who posted the post
    string username;
    # Id of the post
    string id;
    # Likes of the post
    string[] likes;
    # Comments of the post
    Comment[] comments;
    # Posted time
    time:Civil postedAt;
|};

# Represents the post record in the database
type PostDb record {|
    # Title of the post
    string title;
    # Description of the post
    string username;
    # Username of the user who posted the post
    string description;
    # Id of the post
    string id;
    # Likes of the post
    string likes;
    # Comments of the post
    string comments;
    # Posted time
    time:Civil postedAt;
|};

# Represents the user login request
type UserLogin record {|
    # Username of the user
    string name;
    # Password of the user
    string password;
|};

# Represents the user like request
type Like record {|
    # Id of the user
    string userId;
|};

# Represents the user comment request
type NewComment record {|
    # Id of the user
    string username;
    # Comment of the user
    string comment;
    # Posted time
    string timestamp;
|};

# Represents the comment record
type Comment record {|
    # Id of the user
    string id;
    # Username of the user
    string username;
    # Comment of the user
    string comment;
    # Posted time
    time:Civil postedAt;
|};

# Represents the sentiment endpoint response
type Sentiment record {
    # Sentiment label
    string label;
};

# Represents the common error details
type ErrorResponse record {|
    # Error message
    string error_message;
|};

# Represents the success details
type SuccessResponse record {|
    # Success message
    string message;
|};

# Represents the login success details
type SuccessLogin record {|
    # Success message
    string message;
    # User record
    User user;
|};

# Represents the login success response
type LoginOk record {|
    *http:Ok;
    # Body of the response
    SuccessLogin body;
|};

# Represents the common unauthorized response
type Unauthorized record {|
    *http:Unauthorized;
    # Body of the response
    ErrorResponse body;
|};

# Represents the common forbidden response
type Forbidden record {|
    *http:Forbidden;
    # Body of the response
    ErrorResponse body;
|};

# Represents the common success response
type Ok record {|
    *http:Ok;
    # Body of the response
    SuccessResponse body;
|};

# Represents the common created response
type Created record {|
    *http:Created;
    # Body of the response
    SuccessResponse body;
|};

# Represents the common not found response
type NotFound record {|
    *http:NotFound;
    # Body of the response
    ErrorResponse body;
|};

# Represents the common conflict response
type Conflict record {|
    *http:Conflict;
    # Body of the response
    ErrorResponse body;
|};
