import BallerinaBasics.'error;
import BallerinaBasics.'json;
import BallerinaBasics.'xml;
import BallerinaBasics.concurrency as _;
import BallerinaBasics.network as _;
import BallerinaBasics.query;
import BallerinaBasics.transactions;
import BallerinaBasics.types;

import ballerina/io;

// Exercise 02
string 'from;

string first\ name;

string '\{http\:\/\/test\.com\}_name;

function init() {
    'from = "contact@ballerina.io";
    first\ name = "Ballerina";
    '\{http\:\/\/test\.com\}_name = "W";
    io:println(`Initialized from: ${'from} first name: ${first\ name} name: ${'\{http\:\/\/test\.com\}_name}`);
}

// Exercise 01
public function main(string arg) returns error? {
    // Session 05
    io:println(`Arg: ${arg}`);
    types:simpleTypes();
    types:arrayValues();
    types:tupleValues();
    types:recordValues();
    types:tableValues();
    types:xmlValues();
    types:jsonValues();
    query:queryExpressions();
    query:queryActions();
    check query:streamValues();
    'xml:convertXML();
    check 'json:convertJson();

    // Session 06
    'error:distinctErrors();
    'error:errorIntersection();
    check transactions:callTrxFunction();
}

