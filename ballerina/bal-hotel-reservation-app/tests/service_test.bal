import ballerina/http;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090");

@test:Config {}
function testReservation() returns error? {
    // Get available Rooms
    Room[] availableRooms = check testClient->get("/reservations/rooms?checkinDate=2024-02-19T14:00:00Z&checkoutDate=2024-02-20T10:00:00Z&roomType=Family");
    test:assertEquals(availableRooms.length(), 2, "Invalid rooms length");
    test:assertEquals(availableRooms[0].number, 303);
    test:assertEquals(availableRooms[1].number, 403);

    // Create a reservation
    ReservationRequest reservationRequest = {checkinDate: "2024-02-19T14:00:00Z", checkoutDate: "2024-02-20T10:00:00Z", rate: 100, user: {id: "123", name: "waruna", email: "warunaj@wso2.com", mobileNumber: "+94713255198"}, roomType: "Family"};
    Reservation reservation = check testClient->post("/reservations", reservationRequest);
    test:assertEquals(reservation.room.number, 303);

    // Update a reservation
    UpdateReservationRequest updateReservationRequest = {checkinDate: "2024-02-20T14:00:00Z", checkoutDate: "2024-02-21T10:00:00Z"};
    reservation = check testClient->put("/reservations/" + reservation.id.toString(), updateReservationRequest);
    test:assertEquals(reservation.room.number, 303);

    // Get Users reservations
    Reservation[] reservations = check testClient->get("/reservations/users/123");
    test:assertEquals(reservations.length(), 1);
    test:assertEquals(reservations[0].room.number, 303);

    // Delete a reservation
    http:Response delete = check testClient->delete("/reservations/" + reservation.id.toString());
    test:assertEquals(delete.statusCode, 200);
}

@test:Config {}
function testMultipleReservations() returns error? {
    // Get available Rooms
    Room[] availableRooms = check testClient->get("/reservations/rooms?checkinDate=2024-02-19T14:00:00Z&checkoutDate=2024-02-20T10:00:00Z&roomType=Suite");
    test:assertEquals(availableRooms.length(), 3, "Invalid rooms length");

    ReservationRequest reservationRequest;
    Reservation[] reservations = [];

    // Create 3 reservations
    foreach int i in 0 ... 2 {
        reservationRequest = {checkoutDate: "2024-02-20T10:00:00Z", rate: 100, checkinDate: "2024-02-19T14:00:00Z", user: {id: "123", name: "waruna", email: "warunaj@wso2.com", mobileNumber: "+94713255198"}, roomType: "Suite"};
        reservations[i] = check testClient->post("/reservations", reservationRequest);
        test:assertEquals(reservations[i].room.number, availableRooms[i].number);
    }

    // Create addtional reservation and get No rooms available message
    reservationRequest = {checkoutDate: "2024-02-20T10:00:00Z", rate: 100, checkinDate: "2024-02-19T14:00:00Z", user: {id: "123", name: "waruna", email: "warunaj@wso2.com", mobileNumber: "+94713255198"}, roomType: "Suite"};
    Reservation|http:ClientError response = testClient->post("/reservations", reservationRequest);
    test:assertTrue(response is http:ClientError);
    if (response is http:ClientError) {
        test:assertEquals(response.detail()["body"], "No rooms available for the given dates");
    }

    // Delete 3 reservations
    foreach var item in reservations {
        http:Response delete = check testClient->delete("/reservations/" + item.id.toString());
        test:assertEquals(delete.statusCode, 200);
    }
}
