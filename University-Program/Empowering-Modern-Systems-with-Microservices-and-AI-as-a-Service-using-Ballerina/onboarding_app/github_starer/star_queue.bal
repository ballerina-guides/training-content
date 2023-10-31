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

import ballerinax/github;
import ballerinax/rabbitmq;
import ballerina/log;

map <StarData> starDB = {};

service "StarQueue" on new rabbitmq:Listener(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT) {

    remote function onMessage(StarEntry entry) returns error? {
        final github:Client ghClient = check new ({auth: {token: entry.token}});
        log:printInfo("Started starting the repos for user id : " + entry.uid);
        StarData payload = {
            uid: entry.uid,
            status: "pending"
        };
        starDB[entry.uid] = payload;

        stream<github:Repository, github:Error?> repos = check ghClient->getRepositories(entry.org, true);
        check repos.forEach(function(github:Repository repo) {
            github:Error? starRepository = ghClient -> starRepository(repo.owner.login, repo.name);
            if (starRepository is github:Error) {
                log:printError("Error occurred while starring the repo : ", starRepository);
            } else {
                log:printInfo("Starred the repo : " +  repo.name);
            }
        });
        
        payload = {
            uid: entry.uid,
            status: "completed"
        };
        starDB[entry.uid] = payload;
        log:printInfo("Finished staring orgs for the user id : " + entry.uid);
    }
}
