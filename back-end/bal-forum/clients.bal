import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type DBConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DBConfig dbConfig = ?;

final mysql:Client forumDBClient = check new (...dbConfig);

configurable string sentimentClientUrl = ?;

final http:Client sentimentClient = check new (sentimentClientUrl);
