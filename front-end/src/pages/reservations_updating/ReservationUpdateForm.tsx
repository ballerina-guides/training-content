import React, { useContext, useState } from "react";
import {
  Box,
  TextField,
  Typography,
  Button,
  CircularProgress,
} from "@mui/material";
import { useUpdateReservation } from "../../hooks/reservations";
import { useLocation, useNavigate } from "react-router-dom";
import { Reservation, Room } from "../../types/generated";
import { Location } from "history";
import { UserContext } from "../../contexts/user";
import {toast} from "react-toastify";

interface ReservationState {
  reservation: Reservation;
}

const ReservationUpdateForm = () => {
  const { updateReservation, updated, updating, error } =
    useUpdateReservation();

  const user = useContext(UserContext);

  const {
    state: { reservation },
  } = useLocation() as Location<ReservationState>;
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    checkinDate: "",
    checkoutDate: "",
  });

  const handleDateChange = (name: string) => (e: any) => {
    const { value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: new Date(value).toISOString(),
    }));
  };

  const handleReserve = async () => {
    await updateReservation(reservation.id, formData);
    if (error) {
      toast.error("Error occurred while updating the reservation");
      return;
    }
    toast.success("Reservation updated successfully");
    navigate("/reservations");
  };

  return (
    <Box
      style={{ background: "white" }}
      display="flex"
      flexDirection="column"
      py={4}
      px={8}
    >
      <Typography variant="h4" gutterBottom>
        Update Reservation
      </Typography>
      <Typography variant="body1" gutterBottom>
        You can update the check-in and check-out dates
      </Typography>
      <Box
        display="flex"
        justifyContent="space-between"
        alignItems="center"
        my={4}
      >
        <Box width="48%">
          <TextField
            onChange={handleDateChange("checkinDate")}
            fullWidth
            label="Check In Date"
            variant="outlined"
            type="date"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
        <Box width="48%">
          <TextField
            onChange={handleDateChange("checkoutDate")}
            fullWidth
            label="Check Out Date"
            variant="outlined"
            type="date"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
      </Box>

      {/* Action buttons */}
      <Box display="flex" justifyContent="flex-end">
        <Button variant="outlined" style={{ textTransform: "none" }} onClick={() => navigate("/reservations")} color="secondary">
          Cancel
        </Button>
        <Button
          variant="contained"
          color="primary"
          style={{ marginLeft: "8px", textTransform: "none" }}
          onClick={handleReserve}
          disabled={updating}
        >
          {updating ? <CircularProgress size={24} color="primary" /> : "Update"}
        </Button>
      </Box>
    </Box>
  );
};

export default ReservationUpdateForm;
