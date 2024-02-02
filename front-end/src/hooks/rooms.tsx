import { useEffect, useState } from "react";
import { RoomList } from "../types/generated";
import axios from "axios";

const baseUrl = "https://21f987d9-ad58-4eea-aafb-a109066aaccc.mock.pstmn.io";

export function useGetRooms(checkIn: string, checkOut: string, roomType: string) {
    console.log("hook", checkIn, checkOut, roomType);
    const [rooms, setRooms] = useState<RoomList>({ rooms: [], count: 0 });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<Error>();

    useEffect(() => {
        const fetchRooms = async () => {
            setLoading(true);
            try {
                const response = await axios.get<RoomList>(baseUrl + "/rooms", {
                    params: {
                        checkin_date: checkIn,
                        checkout_date: checkOut,
                        room_type: roomType
                    }
                });
                setRooms(response.data);
            } catch (e: any) {
                setError(e);
            }
            setLoading(false);
        };

        fetchRooms();
    }, [checkIn, checkOut, roomType]);

    return { rooms, loading, error };
}
