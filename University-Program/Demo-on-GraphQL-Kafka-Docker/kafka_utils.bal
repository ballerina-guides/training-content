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

import ballerinax/kafka;
import ballerina/log;

final kafka:Producer newsProducer = check new (kafka:DEFAULT_URL);

isolated function produceNewsUpdate(NewsRecord newsRecord) returns error? {
    lock {
        check newsProducer->send({
            topic: publisherTable.get(newsRecord.publisherId).agency,
            value: newsRecord
        });
    }
}

isolated class NewsStreamGenerator {
    private final string consumerGroup;
    private final Agency agency;
    private final kafka:Consumer consumer;

    isolated function init(string consumerGroup, Agency agency) returns error? {
        self.consumerGroup = consumerGroup;
        self.agency = agency;
        kafka:ConsumerConfiguration consumerConfiguration = {
            groupId: consumerGroup,
            offsetReset: kafka:OFFSET_RESET_EARLIEST,
            topics: agency,
            maxPollRecords: 1
        };
        self.consumer = check new (kafka:DEFAULT_URL, consumerConfiguration);
    }

    public isolated function next() returns record {|News value;|}? {
        while true {
            NewsRecord[]|error newsRecords = self.consumer->pollPayload(20);
            if newsRecords is error {
                log:printError("Failed to retrieve data from the Kafka server", newsRecords, id = self.consumerGroup);
                return;
            }
            if newsRecords.length() < 1 {
                log:printWarn(string `No news available in "${self.agency}"`, id = self.consumerGroup);
                continue;
            }
            return {value: new (newsRecords[0])};
        }
    }
}
