import React from "react";
import { useGetRooms } from "../../hooks/rooms";
import { Room } from "../../types/generated";
import { RoomSearchBar } from "./RoomSearchBar";
import RoomListItem from "./RoomListItem";
import { Box } from "@mui/material";

function RoomListing() {
  const { fetchRooms, rooms: roomList, loading, error } = useGetRooms();

  return (
    <div style={{ display: "flex", flexDirection: "column", width: "70%" }}>
      <RoomSearchBar searchRooms={fetchRooms} error={error} loading={loading} />
      <Box style={{ background: "rgba(0, 0, 0, 0.5)" }} px={8} py={4}>
        {roomList &&
          roomList.map((room: Room) => (
            <RoomListItem room={room} key={room.number} />
          ))}
      </Box>
    </div>
  );
}

export default RoomListing;
