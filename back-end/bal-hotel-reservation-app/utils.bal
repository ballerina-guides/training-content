import ballerina/time;
import ballerina/log;

function getAvailableRooms(string checkinDate, string checkoutDate, string roomType) returns Room[]|error {
    map<Room> allocatedRooms = check getAllocatedRooms(checkinDate, checkoutDate, roomType);
    return from Room r in rooms
        where r.'type.name == roomType && !allocatedRooms.hasKey(r.number.toString())
        select r;
}

function getAvailableRoom(string checkinDate, string checkoutDate, string roomType) returns Room?|error {
    map<Room> allocatedRooms = check getAllocatedRooms(checkinDate, checkoutDate, roomType);
    foreach Room r in rooms {
        if (r.'type.name == roomType && !allocatedRooms.hasKey(r.number.toString())) {
            return r;
        }
    }
    return;
}

function getAllocatedRooms(string checkinDate, string checkoutDate, string roomType) returns map<Room>|error {
    time:Utc userCheckinUTC = check time:utcFromString(checkinDate);
    time:Utc userCheckoutUTC = check time:utcFromString(checkoutDate);
    return map from Reservation r in roomReservations
        let time:Utc rCheckin = check time:utcFromString(r.checkinDate)
        let time:Utc rCheckout = check time:utcFromString(r.checkoutDate)
        where r.room.'type.name == roomType && userCheckinUTC <= rCheckin && userCheckoutUTC >= rCheckout
        select [r.room.number.toString(), r.room];
}

function sendNotificationForReservation(Reservation reservation, string action) {
    string message = string `We are pleased to confirm your reservation.`;
    string emailSubject = string `Reservation ${action}: ${reservation.id}`;
    string emailBody = string `Dear ${reservation.user.name},${"\n"}${"\n"}We are pleased to confirm your reservation at our hotel.${"\n"}${"\n"}Thanks, ${"\n"}Reservation Team`;
    string|error sendEmal = trap emailClient->sendEmail(reservation.user.email, emailSubject, emailBody);
    if (sendEmal is error) {
        log:printError("Error sending Email: ", sendEmal);
    }
    string|error sendSms = trap smsClient->sendSms(reservation.user.mobileNumber, message);
    if (sendSms is error) {
        log:printError("Error sending SMS: ", sendSms);
    }
}
