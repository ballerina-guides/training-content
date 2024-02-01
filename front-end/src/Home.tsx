import { Box, Button, FormControl, MenuItem, Select, SelectChangeEvent, TextField, Typography } from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import React from 'react';
import { Link } from 'react-router-dom';

function RoomSearch() {
    const [roomType, setRoomType] = React.useState('');
    const [checkIn, setCheckIn] = React.useState<Date | null>(null);
    const [checkOut, setCheckOut] = React.useState<Date | null>(null);

    const handleRoomTypeChange = (event: SelectChangeEvent) => {
        setRoomType(event.target.value as string);
    };

    const handleCheckInChange = (date: Date | null) => {
        setCheckIn(date);
    }

    const handleCheckOutChange = (date: Date | null) => {
        setCheckOut(date);
    }

    return (
        <Box display="flex" alignItems="center" width="100%" flexDirection="column" justifyContent="center">
            <Typography variant="h1">Search a room and Reserve</Typography>
            <Box flexDirection="row" display="flex" justifyContent="space-around" border={1} borderRadius={8}
                padding={8}>
                <Box>
                    <Typography variant="h6">Check-in date</Typography>
                    <LocalizationProvider dateAdapter={AdapterDayjs}>
                        <DatePicker onChange={handleCheckInChange} />
                    </LocalizationProvider>
                </Box>
                <Box>
                    <Typography variant="h6">Check-out date</Typography>
                    <LocalizationProvider dateAdapter={AdapterDayjs}>
                        <DatePicker onChange={handleCheckOutChange} />
                    </LocalizationProvider>
                </Box>
                <Box>
                    <Typography variant="h6">Room type</Typography>
                    <FormControl>
                        <Select
                            labelId="demo-simple-select-label"
                            id="demo-simple-select"
                            value={roomType}
                            placeholder="All types"
                            onChange={handleRoomTypeChange}
                        >
                            <MenuItem value={"single"}>Single</MenuItem>
                            <MenuItem value={"double"}>Double</MenuItem>
                            <MenuItem value={"suit"}>Suit</MenuItem>
                        </Select>
                    </FormControl>
                </Box>
                <Link to={`/rooms?checkin_date=${checkIn}&checkout_date=${checkOut}&room_type=${roomType}`}>
                    <Button variant="contained">Search</Button>
                </Link>
            </Box>
        </Box>
    );
}

function ReservationSearch() {
    return (
        <Box display="flex" alignItems="center" width="100%" flexDirection="column" justifyContent="center">
            <Typography variant="h2">or view your reservations</Typography>
            <Box flexDirection="row" display="flex" justifyContent="space-around" border={1} borderRadius={8}
                padding={8}>
                <TextField placeholder="Enter your NIC or Passport number" variant="outlined" />
                <Button variant="contained">Search</Button>
            </Box>
        </Box>
    );
}

function Home() {
    return (
        <Box display="flex" flexDirection="column" height="100%" width="100%" justifyContent="center">
            <RoomSearch />
            <br /> <br /><br /> <br />
            <ReservationSearch />
        </Box>
    );
}

export default Home;
