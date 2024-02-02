import React, { useState } from 'react';
import { Box, TextField, Typography, Button, CircularProgress } from '@mui/material';
import { useReserveRoom } from '../../hooks/reservations';

const ReservationForm = () => {
  const {
    // reservation,
    loading,
    error,
    reserveRoom
  } = useReserveRoom();

  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    mobileNumber: '',
    emailAddress: '',
    checkInDate: '',
    checkOutDate: '',
    comments: ''
  });

  const handleTextChange = (name: string) => (e: any) => {
    const { value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value
    }));
  };

  const handleDateChange = (name: string) => (e: any) => {
    const { value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: new Date(value).toISOString()
    }));
  };

  const handleReserve = () => {
    console.log("handleReserve");
    // TODO: remove comment input field
    const { firstName, lastName, mobileNumber, emailAddress, checkInDate, checkOutDate, comments } = formData;
    console.log('formData', formData);

    // TODO: have the user from the auth user object
    reserveRoom(checkInDate, checkOutDate, 100, 'single', {
      email: emailAddress,
      id: "1",
      mobileNumber,
      name: `${firstName} ${lastName}`
    });
  };

  return (
    <Box style={{ background: 'white' }} display="flex" flexDirection="column" py={4} px={8}>
      <Typography variant="h4" gutterBottom>
        Reserve a room
      </Typography>
      <Typography variant="body1" gutterBottom>
        Enter your details and click "Reserve". You can pay at the check-in.
      </Typography>
      <Box mt={3} mb={2} display="flex" justifyContent="space-between" alignItems="center">
        <Box width="48%">
          <TextField onChange={handleTextChange("firstName")} fullWidth label="First Name" variant="outlined" />
        </Box>
        <Box width="48%">
          <TextField onChange={handleTextChange("lastName")} fullWidth label="Last Name" variant="outlined" />
        </Box>
      </Box>
      <Box mb={2}>
        <TextField onChange={handleTextChange("mobileNumber")} fullWidth label="Mobile Number" variant="outlined" />
      </Box>
      <Box mb={2}>
        <TextField onChange={handleTextChange("emailAddress")} fullWidth label="Email Address" variant="outlined" />
      </Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
        <Box width="48%">
          <TextField onChange={handleDateChange("checkInDate")}
            fullWidth
            label="Check In Date"
            variant="outlined"
            type="date"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
        <Box width="48%">
          <TextField
            onChange={handleDateChange("checkOutDate")}
            fullWidth
            label="Check Out Date"
            variant="outlined"
            type="date"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
      </Box>
      <Box mb={2}>
        <TextField onChange={handleTextChange("comments")} fullWidth label="Comments" variant="outlined" multiline rows={3} />
      </Box>

      {/* Action buttons */}
      <Box display="flex" justifyContent="flex-end">
        <Button color="secondary">Cancel</Button>
        <Button
          variant="contained"
          color="primary"
          style={{ marginLeft: '8px' }}
          onClick={handleReserve}
          disabled={loading}
        >
          {loading ? <CircularProgress size={24} color="primary" /> : 'Reserve'}
        </Button>
      </Box>
    </Box>
  );
};

export default ReservationForm;
