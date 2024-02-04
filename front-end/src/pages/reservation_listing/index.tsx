import { Reservation, User } from "../../types/generated";
import { Box } from "@mui/material";
import { useGetReservations } from "../../hooks/reservations";
import ReservationListItem from "./ReservationListItem";
import { useEffect } from "react";
import { Location } from 'history';
import { useLocation } from "react-router-dom";


function ReservationListing() {
    const { state: user } = useLocation() as Location<User>;
    const { fetchReservations, reservations, loading, error } = useGetReservations();

    useEffect(() => {
        fetchReservations("1")
    }, [])

    return (
        <div style={{ display: 'flex', flexDirection: 'column', width: "70%" }}>
            <Box style={{ background: "rgba(0, 0, 0, 0.5)" }} px={8} py={4}>
                {reservations && reservations.map((reservation: Reservation) => (
                    <ReservationListItem reservation={reservation} key={reservation.id} />
                ))}
                <ReservationListItem reservation={{
                    id: 1, checkinDate: '', checkoutDate: '',
                    room: { number: 1, type: { id: 1, name: "Single", price: 100, guestCapacity: 1 } },
                    user
                }} />
            </Box>
        </div>
    );
}

export default ReservationListing;
