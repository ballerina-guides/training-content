import ballerina/http;
import ballerina/log;
import ballerina/time;

import wso2/choreo.sendemail;
import wso2/choreo.sendsms;

table<Reservation> key(id) roomReservations = table [];

type ReservationError record {|
    *http:NotFound;
    string body;
|};

sendsms:Client smsClient = check new ();
sendemail:Client emailClient = check new ();

service /reservations on new http:Listener(9090) {

    resource function get rooms(string checkinDate, string checkoutDate, string roomType) returns Room[]|error {
        return getAvailableRooms(checkinDate, checkoutDate, roomType);
    }

    resource function post .(ReservationRequest reservationRequest) returns Reservation|ReservationError|error {
        Room[] availableRooms = check getAvailableRooms(reservationRequest.checkinDate, reservationRequest.checkoutDate, reservationRequest.roomType);
        if (availableRooms.length() > 0) {
            Room room = availableRooms[0];
            Reservation reservation = {
                id: roomReservations.length() + 1,
                checkinDate: reservationRequest.checkinDate,
                checkoutDate: reservationRequest.checkoutDate,
                room: room,
                user: reservationRequest.user
            };
            roomReservations.put(reservation);

            return reservation;
        }
        return {body: "No rooms available for the given dates"};
    }

    resource function put [int reservation_id](UpdateReservationRequest payload) returns Reservation|ReservationError|error {
        Reservation? reservation = roomReservations[reservation_id];
        if (reservation is Reservation) {
            Room[] availableRooms = check getAvailableRooms(payload.checkinDate, payload.checkoutDate, reservation.room.'type.name);
            if (availableRooms.length() > 0) {
                Room room = availableRooms[0];
                reservation.room = room;
                reservation.checkinDate = payload.checkinDate;
                reservation.checkoutDate = payload.checkoutDate;
                sendNotificationForReservation(reservation);
                return reservation;
            }
        }
        return {body: "Reservation not found"};
    }

    resource function delete [int reservation_id]() returns http:Ok|ReservationError {
        if (roomReservations.hasKey(reservation_id)) {
            _ = roomReservations.remove(reservation_id);
            return http:OK;
        } else {
            ReservationError rError = {body: "Reservation not found"};
            return rError;
        }
    }

    resource function get users/[string userId]() returns Reservation[] {
        return from Reservation r in roomReservations
            where r.user.id == userId
            select r;
    }
}

function getAvailableRooms(string checkinDate, string checkoutDate, string roomType) returns Room[]|error {
    time:Utc checkinUTC = check time:utcFromString(checkinDate);
    time:Utc checkoutUTC = check time:utcFromString(checkoutDate);
    map<Room> allocatedRooms = map from Reservation r in roomReservations
        let time:Utc rCheckIn = check time:utcFromString(r.checkinDate)
        let time:Utc rCheckOut = check time:utcFromString(r.checkoutDate)
        where r.room.'type.name == roomType && checkinUTC >= rCheckIn && checkoutUTC <= rCheckOut
        select [r.room.number.toString(), r.room];
    return from Room r in rooms
        where r.'type.name == roomType && !allocatedRooms.hasKey(r.number.toString())
        select r;
}

function sendNotificationForReservation(Reservation reservation) {
    string message = string `We are pleased to confirm your reservation.`;
    string emailSubject = "Reservation Confirmed";
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

