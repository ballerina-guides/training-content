CREATE TABLE forum_database.users (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255)
);

CREATE TABLE forum_database.posts (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    title VARCHAR(255),
    description LONGTEXT,
    user_id VARCHAR(255),
    likes VARCHAR(255),
    posted_at TIMESTAMP
);

CREATE TABLE forum_database.comments (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    post_id VARCHAR(255),
    user_id VARCHAR(255),
    comment LONGTEXT,
    posted_at TIMESTAMP
);

INSERT INTO `comments` VALUES ('01ee82c7-1526-1530-b3d7-89902934ab7a','01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','- Knowledge Sharing: Share your experiences, tips, and best practices with Ballerina. Whether you\'re working on integration projects, exploring the latest language features, or just curious about Ballerina\'s capabilities, this forum is the space to discuss it all.','2023-11-14 08:23:26'),('01ee82c7-1fe0-1e86-bc3b-4fabd92eeab7','01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','- Community Support: Need help with a Ballerina code snippet? Facing challenges in your project? Our community is here to support you. Ask questions, seek advice, and collaborate with fellow Ballerina enthusiasts.','2023-11-14 08:23:45'),('01ee82c7-2bcc-1aa6-9eff-3c96a8527d98','01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','- Latest Updates: Stay tuned for announcements about Ballerina releases, updates, and community events. We\'ll keep you informed about the latest developments in the Ballerina ecosystem.','2023-11-14 08:24:05'),('01ee82c7-4dc6-12ce-aba4-89f52375b6c7','01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','- Forum Guidelines: Please take a moment to review our forum guidelines. Let\'s maintain a positive and inclusive environment where everyone feels welcome to participate.','2023-11-14 08:25:02'),('01ee82c7-56b6-1fe6-9405-b7e5955a0d90','01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','- Admin Announcements: As the forum Admin, I\'ll be sharing important updates and announcements. Keep an eye out for these posts to stay informed about the forum\'s evolution.','2023-11-14 08:25:17'),('01ee82c7-6767-1746-b228-fd9738715f28','01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','This forum is not just about Ballerina; it\'s about the people who make up the Ballerina community. Let\'s foster a collaborative and friendly environment where we can all learn, share, and grow together.','2023-11-14 08:25:45'),('01ee82c7-a39a-1d4e-bbac-140867f41875','01ee82c7-8d8d-1140-b16d-561f3efc2220','01ee82c7-72ba-19fe-906f-42da2d48e6fd','Functions are declared using the `function` keyword. It accepts zero or more arguments and returns a single value. The `returns` keyword is used to indicate the return type of the function.','2023-11-14 08:27:26'),('01ee82c8-3d62-1818-b078-efa535d2079e','01ee82c7-8d8d-1140-b16d-561f3efc2220','01ee82c8-1a37-1d26-9ee8-605e80c5c2a3','Can we modify the function parameter value within the function?','2023-11-14 08:31:43');

INSERT INTO `posts` VALUES ('01ee82c6-fe7f-1fc6-87c0-bd86c3ccdcf1','Welcome to the Ballerina Language Forum! ','Hello Ballerina Enthusiasts!\n\nI am thrilled to welcome each and every one of you to our brand new Ballerina Language Forum! Whether you\'re a seasoned developer or just starting to explore the world of Ballerina, this forum is the perfect place for you to connect, share knowledge, and grow together as a community.','01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','[\"01ee82c7-72ba-19fe-906f-42da2d48e6fd\", \"01ee82c8-1a37-1d26-9ee8-605e80c5c2a3\"]','2023-11-14 08:22:48'),('01ee82c7-8d8d-1140-b16d-561f3efc2220','Introduction to Ballerina Functions','In this post, I\'ll walk you through the basics of functions in Ballerina. From defining parameters to return types, let\'s dive into the world of function declarations and invocations.','01ee82c7-72ba-19fe-906f-42da2d48e6fd','[\"01ee82c8-1a37-1d26-9ee8-605e80c5c2a3\"]','2023-11-14 08:26:48');

INSERT INTO `users` VALUES ('01ee82c5-b3b1-1b4e-b2d1-d8bb46e0d454','Admin','balforuma@gmail.com','admin@123'),('01ee82c8-1a37-1d26-9ee8-605e80c5c2a3','John','john@gmail.com','john@123'), ('01ee82c7-72ba-19fe-906f-42da2d48e6fd','Tharmigan','tharmigan@wso2.com','tharmi@123');
