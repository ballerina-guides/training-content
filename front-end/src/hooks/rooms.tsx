import { useState } from "react";
import axios from "axios";
import { Room } from "../types/generated";

// TODO: move this to a constant or a config and re-use
const baseUrl = "http://localhost:9090/reservations";

export function useGetRooms() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error>();

  const fetchRooms = async (
    checkIn: string,
    checkOut: string,
    roomType: string,
  ): Promise<void> => {
    setLoading(true);
    try {
      const response = await axios.get<Room[]>(baseUrl + "/rooms", {
        withCredentials: false,
        // TODO: use proxy to avoid CORS disabling
        headers: {
          "Acccess-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,PUT,POST,DELETE,PATCH,OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
          "Content-Type": "application/json",
        },
        params: {
          checkinDate: checkIn,
          checkoutDate: checkOut,
          roomType: roomType,
        },
      });
      setRooms(response.data);
    } catch (e: any) {
      setError(e);
    }
    setLoading(false);
  };

  return { rooms, loading, error, fetchRooms };
}
