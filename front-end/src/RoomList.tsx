import React from "react";
import useQuery from "./hooks/query";
import { useGetRooms } from "./hooks/rooms";
import { Room } from "./types/generated";

function RoomListItem(props: { room: Room }) {
    const { room } = props;
    return (
        <div>
            <div>{room.hotel}</div>
            <div>{room.type}</div>
            <div>{room.guest_capacity}</div>
            <div>{room.price}</div>
        </div>
    );
}


function RoomList() {
    // get checkIn, checkOut, roomType from url
    const query = useQuery();
    const checkIn = query.get("checkin_date") || "";
    const checkOut = query.get("checkout_date") || "";
    const roomType = query.get("room_type") || "";
    console.log("roomlist", checkIn, checkOut, roomType);

    // get rooms from backend
    const { rooms: roomList, loading, error } = useGetRooms("checkIn", "checkOut", "roomType");

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>{error.message}</div>;
    }

    return (
        <div>
            {roomList?.rooms && roomList.rooms.map((room) => (
                <RoomListItem room={room} key={room.room_id} />
            ))}
        </div>
    );
}

export default RoomList;

