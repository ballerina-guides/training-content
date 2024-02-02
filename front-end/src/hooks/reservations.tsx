import { useState } from "react";
import axios from "axios";
import { Reservation } from "../types/generated";
import { User } from "../types/generated";

const baseUrl = "http://localhost:9090/reservations";

export function useReserveRoom() {
    const [reservation, setReservation] = useState<Reservation>()
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<Error>();

    const reserveRoom = async (checkIn: string, checkOut: string, rate: number, roomType: string, user: User): Promise<void> => {
        setLoading(true);
        try {
            const response = await axios.post<Reservation>(baseUrl, {
                checkinDate: checkIn,
                checkoutDate: checkOut,
                rate: rate,
                roomType: roomType,
                user: user
            });
            setReservation(response.data);
        } catch (e: any) {
            setError(e);
        }
        setLoading(false);
    };

    return { reservation, loading, error, reserveRoom };
}
