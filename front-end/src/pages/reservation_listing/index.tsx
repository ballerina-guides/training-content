import { Reservation } from "../../types/generated";
import { Box, CircularProgress } from "@mui/material";
import { useGetReservations } from "../../hooks/reservations";
import ReservationListItem from "./ReservationListItem";
import { useContext, useEffect } from "react";
import { UserContext } from "../../contexts/user";

function ReservationListing() {
  const user = useContext(UserContext);
  // TODO: use loader and error handling
  const { fetchReservations, reservations, loading, error } =
    useGetReservations();

  // TODO: try and avoid fetching reservations twice
  useEffect(() => {
    fetchReservations(user?.id);
  }, []);

  return (
    <div style={{ display: "flex", flexDirection: "column", width: "70%" }}>
      <Box style={{ background: "rgba(0, 0, 0, 0.5)" }} px={8} py={4}>
        {loading && (
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
            }}
          >
            <CircularProgress />
          </div>
        )}
        {reservations &&
          reservations.map((reservation: Reservation) => (
            <ReservationListItem
              reservation={reservation}
              key={reservation.id}
            />
          ))}
      </Box>
    </div>
  );
}

export default ReservationListing;
