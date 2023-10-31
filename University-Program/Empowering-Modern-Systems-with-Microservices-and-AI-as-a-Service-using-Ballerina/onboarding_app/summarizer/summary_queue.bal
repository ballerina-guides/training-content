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

import ballerina/log;
import ballerinax/github;
import ballerinax/openai.chat;
import ballerinax/rabbitmq;

configurable string openAIToken = ?;

map<SummaryEntry> summaryDB = {};

service "SummaryQueue" on new rabbitmq:Listener(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT) {

    remote function onMessage(SummaryRequest entry) returns error? {
        final github:Client ghClient = check new ({auth: {token: entry.token}});
        summaryDB[entry.uid] = {
            uid: entry.uid,
            summaries: {}
        };
        stream<github:Repository, github:Error?> repos = check ghClient->getRepositories(entry.org, true);
        check from github:Repository repo in repos
            do {
                string readmeContents = check getReadmeContents(ghClient, repo.owner.login, repo.name);
                string summary = check getSummarizedContents(readmeContents); //See if we can do batch
                map<string> entries = {};
                SummaryEntry? existingSummary = summaryDB[entry.uid];
                if existingSummary is SummaryEntry {
                    entries = existingSummary.summaries;
                }
                entries[repo.name] = summary;
                summaryDB[entry.uid] = {
                    uid: entry.uid,
                    summaries: entries
                };
                log:printInfo("Summary for repo: " + repo.name + " Added to the database");
            };
    }
}
function getSummarizedContents(string readmeContents) returns string|error {
    chat:Client chatClient = check new ({auth: {token: openAIToken}});
    chat:CreateChatCompletionRequest req = {
        model: "gpt-3.5-turbo-16k",
        messages: [{"role": "user", "content": string `Summarize the following Readme.md :\n '" ${readmeContents}'`}]
    };
    chat:CreateChatCompletionResponse completionRes = check chatClient->/chat/completions.post(req);
    chat:ChatCompletionResponseMessage? message = completionRes.choices[0].message;
    if message is chat:ChatCompletionResponseMessage {
        string? summary = message?.content;
        if summary is string {
            return summary;
        }
    }
    return error("Failed to summarize the given text.");
}

function getReadmeContents(github:Client ghClient, string org, string repo) returns string|error {
    string|() defaultBranch = check getDefaultBranch(ghClient, org, repo);
    if (defaultBranch is ()) {
        return error("Failed to get the default branch");
    }
    github:File[] files = check ghClient->getRepositoryContent(org, repo, defaultBranch + ":");
    string? readmeContnets = extractReadmeContents(files);
    if readmeContnets is string {
        return readmeContnets;
    }
    return error("Failed to get the readme file");
}

function getDefaultBranch(github:Client ghClient, string org, string repo) returns string?|error {
    stream<github:Branch, github:Error?> streamResult = check ghClient->getBranches(org, repo);
    github:Branch[]|github:ClientError|github:ServerError branches = from github:Branch branch in streamResult
        where branch.name == "main" || branch.name == "master"
        select branch;
    if branches is github:Branch[] {
        return branches[0].name;
    }
    return ();
}

function extractReadmeContents(github:File[] files) returns string? {
    github:File readmeFile = (from github:File file in files
        where file.name == "README.md"
        limit 1
        select file)[0];
    github:FileContent? readmeContents = readmeFile.'object;
    if readmeContents is github:FileContent {
        string? str = readmeContents?.text;
        if str is string {
            return str;
        }
    }
    return ();
}
