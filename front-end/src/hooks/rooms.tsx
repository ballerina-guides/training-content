import { useEffect, useState } from 'react';
import { Room } from '../types/generated';
import { AxiosResponse } from 'axios';
import { performRequestWithRetry } from '../api/retry';
import { apiUrl } from '../api/constants';

export function useGetRooms(checkIn: string, checkOut: string, roomType: string) {
    console.log('hook', checkIn, checkOut, roomType);
    const [rooms, setRooms] = useState<Room[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<Error>();

    useEffect(() => {
        const fetchRooms = async () => {
            setLoading(true);
            const options = {
                method: 'GET',
                params: {
                    checkinDate: checkIn,
                    checkoutDate: checkOut,
                    roomType,
                }
            };
            try {
                const response = await performRequestWithRetry(`${apiUrl}/rooms`, options);
                const roomList = (response as AxiosResponse<Room[]>).data
                setRooms(roomList);
            } catch (e: any) {
                setError(e);
            }
            setLoading(false);
        };

        fetchRooms();
    }, [checkIn, checkOut, roomType]);

    return { rooms, loading, error };
}
