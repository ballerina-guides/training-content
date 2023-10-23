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

import ballerina/graphql;
import ballerina/uuid;

service /news on new graphql:Listener(9090) {

    # Retrieve the list of users.
    # 
    # + return - The list of all users
    isolated resource function get users() returns readonly & User[] {
        lock {
            return userTable.toArray().cloneReadOnly();
        }
    }

    # Retrieve the list of publishers.
    # 
    # + return - The list of all publishers
    isolated resource function get publishers() returns readonly & Publisher[] {
        lock {
            return publisherTable.toArray().cloneReadOnly();
        }
    }

    # Register a new user. This will return the registered user record.
    # 
    # + newUser - The information of the new user
    # + return - The registered user record
    isolated remote function registerUser(NewUser newUser) returns User {
        User user = {
            id: uuid:createType1AsString(),
            ...newUser
        };
        lock {
            userTable.put(user);
        }
        return user;
    }

    # Register a new publisher. This will return the registered publisher record.
    # 
    # + newPublisher - The information of the new publisher
    # + return - The registered publisher record
    isolated remote function registerPublisher(NewPublisher newPublisher) returns Publisher {
        Publisher publisher = {
            id: uuid:createType1AsString(),
            ...newPublisher
        };
        lock {
            publisherTable.put(publisher);
        }
        return publisher;
    }


    # Publish a news update. This will return the published news record, or an error if the publisher is not registered.
    # 
    # + newsUpdate - The news update to be published
    # + return - The published news record
    isolated remote function publish(NewsUpdate newsUpdate) returns NewsRecord|error {
        lock {
            if !publisherTable.hasKey(newsUpdate.publisherId) {
                return error("Publisher not found");
            }
        }
        NewsRecord newsRecord = {
            id: uuid:createType1AsString(),
            ...newsUpdate
        };
        check produceNewsUpdate(newsRecord);
        return newsRecord;
    }

    # Subscribe to news updates. If the user is not registered, an error will be returned. Otherwise, subscribers will receive the news updates once they are published.
    # 
    # + userId - The ID of the user
    # + agency - The news agency to subscribe to
    # + return - The stream of news updates
    isolated resource function subscribe news(string userId, Agency agency) returns stream<News>|error {
        NewsStreamGenerator newsStreamGenerator = check new (userId, agency);
        stream<News> newsStream = new (newsStreamGenerator);
        return newsStream;
    }
}
