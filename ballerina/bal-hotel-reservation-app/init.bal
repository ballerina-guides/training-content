import ballerina/io;
table<Room> key(number) rooms;

function init() returns error? {
    json roomsJson = check io:fileReadJson("../../resources/rooms.json");
    rooms = check roomsJson.cloneWithType();
}



