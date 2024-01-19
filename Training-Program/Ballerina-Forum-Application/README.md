# Integration Basics with Ballerina

## Table of Contents

- [Integration Basics with Ballerina](#integration-basics-with-ballerina)
  - [Table of Contents](#table-of-contents)
  - [Training Objective](#training-objective)
  - [Prerequisites](#prerequisites)
  - [Scenario](#scenario)
    - [Areas Covered in this scenario](#areas-covered-in-this-scenario)
    - [Task 1 - Implement registration and login resources](#task-1---implement-registration-and-login-resources)
      - [Task 1.1 - Implement Registration resource](#task-11---implement-registration-resource)
      - [Task 1.2 - Login resource](#task-12---login-resource)
    - [Task 2 - Implement forum post related resources](#task-2---implement-forum-post-related-resources)
      - [Task 2.1 - Post creation resource](#task-21---post-creation-resource)
      - [Task 2.2 - Post like resource](#task-22---post-like-resource)
      - [Task 2.3 - Post comment resource](#task-23---post-comment-resource)
      - [Task 2.4 - Specific post retrieval resource](#task-24---specific-post-retrieval-resource)
      - [Task 2.5 - Posts retrieval resource](#task-25---posts-retrieval-resource)
    - [Task 3 - Verify the post content with the sentiment analysis service](#task-3---verify-the-post-content-with-the-sentiment-analysis-service)
      - [Task 3.1 - Connect to the sentiment analysis service without SSL](#task-31---connect-to-the-sentiment-analysis-service-without-ssl)
      - [Task 3.2 - Secure the sentiment analysis service with SSL and connect to it](#task-32---secure-the-sentiment-analysis-service-with-ssl-and-connect-to-it)
      - [Task 3.3 - Secure the sentiment analysis service with mutual SSL and connect to it](#task-33---secure-the-sentiment-analysis-service-with-mutual-ssl-and-connect-to-it)
      - [Task 3.4 - Secure the sentiment analysis service with OAuth2 and connect to it](#task-34---secure-the-sentiment-analysis-service-with-oauth2-and-connect-to-it)
    - [Task 4 - Make the sentiment analysis client resilient](#task-4---make-the-sentiment-analysis-client-resilient)
    - [Task 5 - Deploy and test the services using Docker](#task-5---deploy-and-test-the-services-using-docker)
  - [Extended Scenario](#extended-scenario)
    - [Areas Covered in the extended scenario](#areas-covered-in-the-extended-scenario)
    - [Task 1 - Schedule a one-time task to create a new forum post](#task-1---schedule-a-one-time-task-to-create-a-new-forum-post)
    - [Task 2 - Produce a NATS event when a new user is registered](#task-2---produce-a-nats-event-when-a-new-user-is-registered)
    - [Task 3 - Consume the above event and email the user with the welcome note provided in a file](#task-3---consume-the-above-event-and-email-the-user-with-the-welcome-note-provided-in-a-file)

## Training Objective

Cover basic integration scenarios with the Ballerina Forum application.

## Prerequisites

- Install the latest version of Ballerina
- Set up VS code by installing the Ballerina extension
- Install Docker

## Scenario

The scenario is based on a simple API written for a forum site, which has users, associated posts and comments. Following depicts the high level component diagram:

![Component Diagram](images/bal-forum.png)

The forum REST service exposes the following resources:

| Resource                       | Description                            |
|--------------------------------|----------------------------------------|
| `POST api/users`               | Create a new user                      |
| `POST api/login`               | Login as with user credentials         |
| `POST api/users/{id}/posts`    | Create a new forum post                |
| `GET api/posts`                | Get all the forum posts                |
| `GET api/posts/{id}`           | Get the forum post specified by the id |
| `POST api/posts/{id}/likes`    | Like a forum post                      |
| `POST api/posts/{id}/comments` | Comment on a post                      |

> **Note:** The service should be started in port **4000** to test with the frontend application.

For testing, the MySQL database can be started using the docker-compose. The database is configured with the following properties:

| Property | Value          |
|----------|----------------|
| Host     | localhost      |
| Port     | 3306           |
| Username | forum_user     |
| Password | dummypassword  |
| Database | forum_database |

Following is the entity relationship diagram:

![Entity Relationship Diagram](images/bal-forum-erd.png)

### Areas Covered in this scenario

- Installing and Managing distributions
- Writing a simple RESTful service
- Accessing database
- Data transformation with data mapper
- HTTP client
- Service/Client security with SSL/MTLS
- Security - OAuth2
- Resiliency
- Building Docker images

### Task 1 - Implement registration and login resources

#### Task 1.1 - Implement Registration resource

- Path: `api/users`

- Method: `POST`

- Request body:

  ```json
  {
    "name": "david",
    "email": "david@gmail.com",
    "password": "*******"
  }
  ```

- Success response - `201 CREATED`:

  ```json
  {
    "message": "User created successfully"
  }
  ```

- Failure response - `409 CONFLICT`:

  ```json
  {
    "error_message": "User already exists"
  }
  ```

#### Task 1.2 - Login resource

- Path: `api/login`

- Method: `POST`

- Request body:

   ```json
   {
     "name": "string",
     "password": "string"
   }
   ```

- Success Response - `200 OK`:

   ```json
   {
     "message": "Login successful",
     "id": "01ee82c7-1526-1530-b3d7-89902934ab7a"
   }
   ```

- Failure Response - `401 UNAUTHORIZED`:

   ```json
   {
     "error_message": "Invalid credentials"
   }
   ```

### Task 2 - Implement forum post related resources

#### Task 2.1 - Post creation resource

- Path: `api/users/{id}/posts`

- Method: `POST`

- Request body:

  ```json
  {
    "title": "This is a sample title",
    "description": "This is a sample description",
    "timestamp": "2023-12-03T10:15:30.00Z"
  }
  ```

- Success response - `201 CREATED`:

  ```json
  {
    "message": "Post created successfully"
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "User not found"
  }
  ```

> **Note:** The above new post request should be mapped to a `Post` record in the posts table.

#### Task 2.2 - Post like resource

- Path: `api/posts/{id}/likes`

- Method: `POST`

- Request body:

  ```json
  {
    "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a"
  }
  ```

- Success response - `200 OK`:

  ```json
  {
    "message": "Post liked successfully"
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "Post not found"
  }
  ```

- Failure response - `409 CONFLICT`:

  ```json
  {
    "error_message": "User already liked the post"
  }
  ```

#### Task 2.3 - Post comment resource

- Path: `api/posts/{id}/comments`

- Method: `POST`

- Request body:

  ```json
  {
    "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a",
    "comment": "This is a sample comment",
    "timestamp": "2023-12-03T10:15:30.00Z"
  }
  ```

- Success response - `200 OK`:

  ```json
  {
    "message": "Comment added successfully"
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "Post not found"
  }
  ```

#### Task 2.4 - Specific post retrieval resource

- Path: `api/posts/{id}`

- Method: `GET`

- Success Response - `200 OK`:

  ```json
  {
    "title": "This is a sample title",
    "description": "This is a sample description",
    "username": "John",
    "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
    "likes": [
      "01ee82c7-1526-1530-b3d7-89902934ab7a"
    ],
    "comments": [
      {
        "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
        "username": "David",
        "comment": "This is a sample comment",
        "postedAt": {
          "year": 2023,
          "month": 12,
          "day": 3,
          "hour": 10,
          "minute": 15
        }
      }
    ],
    "postedAt": {
      "year": 2023,
      "month": 12,
      "day": 3,
      "hour": 8,
      "minute": 10
    }
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "Post not found"
  }
  ```

> **Note:** The response should have the name of the user(in the post and comments) rather than the user id stored in the database.

#### Task 2.5 - Posts retrieval resource

- Path: `api/posts`

- Method: `GET`

- Success Response - `200 OK`:

  ```json
  [
    {
      "title": "This is a sample title",
      "description": "This is a sample description",
      "username": "John",
      "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
      "likes": [
        "01ee82c7-1526-1530-b3d7-89902934ab7a"
      ],
      "comments": [
        {
          "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
          "username": "David",
          "comment": "This is a sample comment",
          "postedAt": {
            "year": 2023,
            "month": 12,
            "day": 3,
            "hour": 10,
            "minute": 15
          }
        }
      ],
      "postedAt": {
        "year": 2023,
        "month": 12,
        "day": 3,
        "hour": 8,
        "minute": 10
      }
    }
  ]
  ```

> **Note:** The response should have the name of the user(in the posts and comments) rather than the user id stored in the database.

### Task 3 - Verify the post content with the sentiment analysis service

The mock sentiment analysis service written in Ballerina is available in the `backend/sentiment-api` directory. The service exposes a single resource, which accepts a string and returns a sentiment score.

- Port: `9000`

- Path: `/text-processing/api/sentiment`

- Method: `POST`

- Request body:

  ```json
  {
    "text": "This is a sample text"
  }
  ```

- Success response - `200 OK`:

  ```json
  {
    "probability": { 
      "neg": 0.30135019761690551, 
      "neutral": 0.27119050546800266, 
      "pos": 0.69864980238309449
    }, 
    "label": "pos"
  }
  ```

The label can be one of the following values:

- `pos` - Positive sentiment
- `neg` - Negative sentiment
- `neutral` - Neutral sentiment

Pass the post title and description to the sentiment analysis service and verify the sentiment score. If the label is `neg`, then the post is forbidden.

- Rejected response - `403 FORBIDDEN`:

  ```json
  {
    "error_message": "Post contains negative sentiment"
  }
  ```

#### Task 3.1 - Connect to the sentiment analysis service without SSL

The sentiment analysis service is not secured with SSL. Therefore, you can connect to it without SSL. Use an [HTTP client](https://ballerina.io/learn/by-example/http-client-send-request-receive-response/) to connect to the sentiment analysis service.

#### Task 3.2 - Secure the sentiment analysis service with SSL and connect to it

[Secure the sentiment analysis service with SSL](https://ballerina.io/learn/by-example/http-service-ssl-tls/) and connect to it. Use an [HTTP client secured with SSL](https://ballerina.io/learn/by-example/http-client-ssl-tls/) to connect to the sentiment analysis service.

> **Note:** For testing purpose you can use the self-signed certificates provided in the `resources` directory of each service.

#### Task 3.3 - Secure the sentiment analysis service with mutual SSL and connect to it

[Secure the sentiment analysis service with mutual SSL](https://ballerina.io/learn/by-example/http-service-mutual-ssl/) and connect to it. Use an [HTTP client secured with mutual SSL](https://ballerina.io/learn/by-example/http-client-mutual-ssl/) to connect to the sentiment analysis service.

> **Note:** For testing purpose you can use the self-signed certificates provided in the `resources` directory of each service.

#### Task 3.4 - Secure the sentiment analysis service with OAuth2 and connect to it

[Secure the sentiment analysis service with OAuth2](https://ballerina.io/learn/by-example/http-service-oauth2/) and connect to it. Use an [HTTP client secured with OAuth2 refresh token grant type](https://ballerina.io/learn/by-example/http-client-oauth2-refresh-token-grant-type/) to connect to the sentiment analysis service.

Connect to the mock STS endpoint is available through docker compose. The endpoint details are as follows:

| Property                                             | Value                                       |
|------------------------------------------------------|---------------------------------------------|
| Introspection Endpoint                               | `https://localhost:9445/oauth2/introspect`  |
| Authorization header for introspection (admin:admin) | `"Authorization": "Basic YWRtaW46YWRtaW4="` |
| Refresh Endpoint                                     | `https://localhost:9445/oauth2/token`       |
| Client ID                                            | `FlfJYKBD2c925h4lkycqNZlC2l4a`              |
| Client Secret                                        | `PJz0UhTJMrHOo68QQNpvnqAY_3Aa`              |
| Refresh Token                                        | `24f19603-8565-4b5f-a036-88a945e1f272`      |

> **Note:** The mock STS endpoint is secured with SSL and the self-signed public certificate of the STS service is given in the `resources` directory.

### Task 4 - Make the sentiment analysis client resilient

The sentiment analysis service is not reliable. It goes down frequently and return `503 - Service Unavailable`. We need to make the client resilient to handle such failures.

The Ballerina HTTP client supports the following resiliency features:

- [Retry](https://ballerina.io/learn/by-example/http-retry/)
- [Circuit Breaker](https://ballerina.io/learn/by-example/http-circuit-breaker/)
- [Load Balancer](https://ballerina.io/learn/by-example/http-load-balancer/)
- [Failover](https://ballerina.io/learn/by-example/http-failover/)

Make the sentiment analysis client resilient by retrying the request for 3 times with a delay of 1 second between each retry.

### Task 5 - Deploy and test the services using Docker

Build the docker images for the `bal-forum` and the `sentiment-api` services and run them using docker compose. The docker compose file is available in the `backend` directory.

> **Tip:** Refer to the [Ballerina Code to Cloud guide](https://ballerina.io/learn/code-to-cloud-deployment/) for more information on deploying Ballerina services as docker images.

## Extended Scenario

The Ballerina Forum application is extended with the following features:

1. Schedule a one-time task to create a new forum post
2. Produce a NATS event when a new user is registered
3. Consume the above event and email the user with the welcome note provided in a file

![Component Diagram](images/bal-forum-extended.png)

### Areas Covered in the extended scenario

- Scheduling tasks
- Consuming and producing events using NATS
- Reading a file
- Using gmail connector to send emails

### Task 1 - Schedule a one-time task to create a new forum post

The Post creation resource can now accept a query parameter named `schedule` which specify the timestamp to schedule the post creation. This query parameter is **optional** and if not provided, the post will be created immediately.

Example:

- Request URL : `http://localhost:4000/api/users/1/posts?schedule=2023-12-08T10:00:00Z`
- Request Body :

  ```json
  {
    "title": "This is a sample title",
    "description": "This is a sample description",
    "timestamp": "2023-12-05T10:15:30.00Z"
  }
  ```

- SuccessResponse - `202 Accepted`:

  ```json
  {
    "message": "Post creation scheduled successfully"
  }
  ```

- FailureResponse - `400 Bad Request`:

  ```json
  {
    "message": "Invalid post schedule request"
  }
  ```

> **Hint:** Refer to [Schedule one time job](https://ballerina.io/learn/by-example/task-one-time-job-execution/) example in the Ballerina by Example guide.

### Task 2 - Produce a NATS event when a new user is registered

When a new user is registered, a NATS event should be produced to the subject `ballerina.forum.new.user` with the following payload:

```json
{
  "email": "john@gmail.com"
} 
```

> **Note:** For testing, the NATS server can be started using the docker-compose. Connect the NATS client to `nats://localhost:4222`.

> **Hint:** Refer to [NATS client - Publish message](https://ballerina.io/learn/by-example/nats-basic-pub/) example in the Ballerina by Example guide.

### Task 3 - Consume the above event and email the user with the welcome note provided in a file

A Ballerina NATS server is defined in the `backend/nats-mail-notifier` directory. This server is configured to consume the NATS event produced in the previous task.

Add a [Gmail connector](https://central.ballerina.io/ballerinax/googleapis.gmail/4.0.0) to email the user with the welcome note provided in `resources` directory. The email should be sent to the email address provided in the NATS event payload.

> **Hints:**
>
> - Refer to the Setup Gmail API section to obtain the credentials and configure the connector.
>
> - Refer to the [send mails example](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/blob/master/examples/send-mails/main.bal) to send an email using the Gmail connector.
>
> - Use [the Ballerina IO module](https://central.ballerina.io/ballerina/io/latest) to read the content of the file as string.
