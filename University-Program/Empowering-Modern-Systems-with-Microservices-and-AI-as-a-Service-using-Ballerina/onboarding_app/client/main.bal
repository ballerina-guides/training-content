// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;
import ballerina/lang.runtime;

type OnboardData record {|
    string uid;
    string likeStatus;
    map<string> repoSummary;
|};

type OnboardEntry record {|
    string uid;
    string token;
    string org;
|};

public function main() returns error? {
    http:Client onboardClient = check new ("localhost:9092");

    OnboardEntry reqData = {
        uid: "Anjana Supun",
        token: "<<PAT Token>>",
        org: "ballerina-platform"
    };

    io:println("Sending the request");
    // TODO : Send a POST Request to /onboard using onboardClient varaible with above reqData and assign it to http:Response variable
    // TODO : Check if the response status code is 202
    http:Response resp = check onboardClient->/onboard.post(reqData);
    io:println("Response code recieved " + resp.statusCode.toString());

    // Sleep for 20 seconds to wait till some onboarded data is available
    io:println("Waiting 20 seconds till some onboarded data is available");
    runtime:sleep(20);

    // TODO : Send a GET request to /onboard/status using onboardClient varaible. It should have a uid query parameter. 
    // TODO : Then assign it to OnboardData and print it.
    io:println("Sending the GET request to retrieve the data");
    OnboardData data = check onboardClient->/onboard/status(uid=reqData.uid);
    io:println(data.toJsonString());
}
