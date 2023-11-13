CREATE TABLE forum_database.users (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    subscribtions LONGTEXT
);

CREATE TABLE forum_database.posts (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    title VARCHAR(255),
    description LONGTEXT,
    username VARCHAR(255),
    likes VARCHAR(255),
    comments LONGTEXT,
    postedAt TIMESTAMP
);

INSERT INTO `posts` VALUES ('01ee815c-f310-1c1e-8944-64b39a9a2ef0','Introduction to Ballerina Functions','In this post, I\'ll walk you through the basics of functions in Ballerina. From defining parameters to return types, let\'s dive into the world of function declarations and invocations.','Tharmigan','[\"01ee815d-8054-1166-b5a0-95292d3f6ced\"]','[{\"id\":\"01ee815d-0885-1ebe-aeca-019b7fedca99\", \"username\":\"Tharmigan\", \"comment\":\"Functions are declared using the `function` keyword. It accepts zero or more arguments and returns a single value. The `returns` keyword is used to indicate the return type of the function.\", \"postedAt\":{\"timeAbbrev\":\"Z\", \"dayOfWeek\":0, \"year\":2023, \"month\":11, \"day\":12, \"hour\":13, \"minute\":11, \"second\":47.505}}, {\"id\":\"01ee815d-b5f8-1ff0-a418-e1d6bb96273b\", \"username\":\"John\", \"comment\":\"Is it possible to modify the function parameters within the function? \", \"postedAt\":{\"timeAbbrev\":\"Z\", \"dayOfWeek\":0, \"year\":2023, \"month\":11, \"day\":12, \"hour\":13, \"minute\":16, \"second\":38.106}}, {\"id\":\"01ee815e-31f3-1476-84cf-3727c5f10eaf\", \"username\":\"Tharmigan\", \"comment\":\"No, function parameters are final variables and cannot be modified within the function.\", \"postedAt\":{\"timeAbbrev\":\"Z\", \"dayOfWeek\":0, \"year\":2023, \"month\":11, \"day\":12, \"hour\":13, \"minute\":20, \"second\":6.622}}]','2023-11-12 13:11:12'),('01ee815d-6a46-1558-b74f-4e99e071bfe4','Main function in Ballerina','The main function is the program entry point and the `public` keyword makes this function visible outside the module.','Tharmigan','[]','[{\"id\":\"01ee815e-0a9c-17a6-94c3-80b32b920352\", \"username\":\"John\", \"comment\":\"I saw that we can have arguments for a min function. Example:\\npublic function main(int value) returns error? {\\n    io:println(value);\\n}. \\nIn that case how can I provide the value for this argument?\", \"postedAt\":{\"timeAbbrev\":\"Z\", \"dayOfWeek\":0, \"year\":2023, \"month\":11, \"day\":12, \"hour\":13, \"minute\":19, \"second\":0.708}}, {\"id\":\"01ee815e-53ec-1c98-b724-a75fed17be3a\", \"username\":\"Tharmigan\", \"comment\":\"You can pass the arguments via CLI like this: bal run main_function.bal -- 5.\", \"postedAt\":{\"timeAbbrev\":\"Z\", \"dayOfWeek\":0, \"year\":2023, \"month\":11, \"day\":12, \"hour\":13, \"minute\":21, \"second\":3.202}}]','2023-11-12 13:14:31');

INSERT INTO `users` VALUES ('01ee815c-d70d-1200-9b25-f12ac98ae93c','Tharmigan','tharmigan@wso2.com','tharmi@123','[\"01ee815c-f310-1c1e-8944-64b39a9a2ef0\", \"01ee815d-6a46-1558-b74f-4e99e071bfe4\"]'),('01ee815d-8054-1166-b5a0-95292d3f6ced','John','john@gmail.com','john@123','[]');
