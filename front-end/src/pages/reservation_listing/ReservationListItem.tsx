import React from "react";
import { Reservation } from "../../types/generated";
import { Box, Button, CircularProgress, Typography } from "@mui/material";
import LuggageOutlinedIcon from '@mui/icons-material/LuggageOutlined';
import { Link } from "react-router-dom";
import { useDeleteReservation } from "../../hooks/reservations";

export default function ReservationListItem(props: { reservation: Reservation }) {
    const { reservation } = props;
    const { deleting, error: deleteError, deleteReservation } = useDeleteReservation();

    const handleDeleteReservation = async () => {
        await deleteReservation(reservation.id);
        if (deleteError) {
            alert("Error occurred while deleting the reservation")
        } else {
            alert("Reservation deleted successfully");
        }
        window.location.reload();
    }

    return (
        <Box style={{ background: 'white' }}
            display="flex" justifyContent="space-between"
            width="100%" border={1} borderRadius={4} mb={1}
        >
            <Box
                width="13%"
                p={2}
                pl={4}
                display="flex"
                flexDirection="column"
                justifyContent="center"
                alignItems="flex=start"
            >
                <Box>
                    <Typography>
                        {reservation.room.type.name}
                    </Typography>
                </Box>
                <Box display="flex" justifyContent="flex-start" alignItems="center">
                    <Box><LuggageOutlinedIcon /></Box>
                    <Box>
                        <Typography fontSize={12}>{reservation.room.type.guestCapacity} Guests</Typography>
                    </Box>
                </Box>
            </Box>

            <Box
                width="53%"
                p={2}
                display="flex"
                flexDirection="column"
                justifyContent="center"
                alignItems="center"
            >
                {/* TODO: display more meaningful details */}
                <Typography>
                    Room: {reservation.room.number}, User: {reservation.user?.id},
                    Check-In: {reservation.checkinDate}, Check-Out: {reservation.checkoutDate}
                </Typography>
            </Box>

            <Box
                width="13%"
                p={2}
                display="flex"
                flexDirection="column"
                justifyContent="center"
                alignItems="flex-end"
            >
                <Typography>{reservation.room.type.price} $ /day</Typography>
            </Box>

            <Box
                width="13%"
                p={2}
                pr={4}
                display="flex"
                flexDirection="column"
                justifyContent="flex-end"
                alignItems="center"
            >
                <Link to="/reservations/change" state={{ reservation }}>
                    <Button style={{ textTransform: 'none' }} variant="outlined">Change</Button>
                </Link>
                <Button
                    style={{ textTransform: 'none', color: 'red' }}
                    variant="contained"
                    onClick={handleDeleteReservation}
                    disabled={deleting}
                >
                    {deleting ? <CircularProgress /> : "Delete"}
                </Button>
            </Box>
        </Box>
    );
}
