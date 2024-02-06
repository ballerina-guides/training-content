import React from "react";
import useQuery from "./hooks/query";
import { useGetRooms } from "./hooks/rooms";
import { Room } from "./types/generated";

function RoomListItem(props: { room: Room }) {
    const { room: {type} } = props;
    return (
        <div>
            <div>{type.id}</div>
            <div>{type.name}</div>
            <div>{type.guestCapacity}</div>
            <div>{type.price}</div>
        </div>
    );
}


function RoomList() {
    // get checkIn, checkOut, roomType from url
    // const query = useQuery();
    // const checkIn = query.get("checkin_date") || "";
    // const checkOut = query.get("checkout_date") || "";
    // const roomType = query.get("room_type") || "";
    // console.log("roomlist", checkIn, checkOut, roomType);

    // get rooms from backend
    // TODO: get checkIn, checkOut, roomType dynamically
    const { rooms: roomList, loading, error } = useGetRooms('2024-02-19T14:00:00Z', '2024-02-20T14:00:00Z', 'Family');

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>{error.message}</div>;
    }

    return (
        <div>
            {roomList && roomList.map((room) => (
                <RoomListItem room={room} key={room.number} />
            ))}
        </div>
    );
}

export default RoomList;

