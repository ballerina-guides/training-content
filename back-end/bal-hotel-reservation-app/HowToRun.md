# Hotel Reservation Ballerina APP

This ballerina project exposes reservation http service. 

## Base URL 

http:localhost:9090/reservations

## Resources

### 1) Get All available rooms

**Path** : /rooms/

**HTTP Method:** GET

**Query Paramters:** 

    string checkinDate
    string checkoutDate
    string roomType

**Sample Response :**

```json

[
    {
        "number": 101,
        "type": {
            "id": 0,
            "name": "Single",
            "guestCapacity": 1,
            "price": 80
        }
    },
    {
        "number": 102,
        "type": {
            "id": 0,
            "name": "Double",
            "guestCapacity": 2,
            "price": 100
        }
    }
]

```

### 2) Create a new reservation

**Path :** /

**HTTP Method:** POST

**Sample Request :**

```json
{
    "checkinDate": "2024-02-19T14:00:00Z",
    "checkoutDate": "2024-02-20T10:00:00Z",
    "rate": 100,
    "user": {
        "id": "123",
        "name": "waruna",
        "email": "waruna@someemail.com",
        "mobileNumber": "987"
    },
    "roomType": "Family"
}
```


**Sample Response :**

```json
{
    "id": "1",
    "checkinDate": "2024-02-19T14:00:00Z",
    "checkoutDate": "2024-02-20T10:00:00Z",
    "user": {
        "id": "123",
        "name": "waruna",
        "email": "waruna@someemail.com",
        "mobileNumber": "987"
    },
    "room": {
        "number" :  201,
        "type": {
            "id": 0,
            "name": "Double",
            "guestCapacity": 2,
            "price": 100
        }
    }
}
```

### 3) Update a exsisting reservation

**Path :** /[reservationId]

**HTTP Method:** PUT

**Sample Request :**

```json
{
    "checkinDate": "2024-02-20T14:00:00Z",
    "checkoutDate": "2024-02-21T10:00:00Z"
}
```

**Sample Response :**

Same as create new reservation

### 4) Remove a reservation

**Path** : /[reservationId]

**HTTP Method:** DELETE

### 5) Get all reservations for  given user id

**Path :** /users/[userID]

**HTTP Method:** GET

**Sample Response :**

Same as Get available rooms
