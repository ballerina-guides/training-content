import {
  Box,
  Button,
  FormControl,
  MenuItem,
  Select,
  SelectChangeEvent,
  Typography,
} from "@mui/material";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import React from "react";

interface RoomSearchProps {
  searchRooms: (checkIn: string, checkOut: string, roomType: string) => void;
  loading: boolean;
  error?: Error;
}

export function RoomSearchBar(props: RoomSearchProps) {
  const { searchRooms, loading, error } = props;
  const [roomType, setRoomType] = React.useState("Single");
  const [checkIn, setCheckIn] = React.useState<Date | null>(new Date());
  const [checkOut, setCheckOut] = React.useState<Date | null>(new Date());
  const [validationError, setValidationError] = React.useState<string>("");

  const handleRoomTypeChange = (event: SelectChangeEvent) => {
    setRoomType(event.target.value as string);
  };

  const handleCheckInChange = (date: Date | null) => {
    setCheckIn(date);
  };

  const handleCheckOutChange = (date: Date | null) => {
    setCheckOut(date);
  };

  const handleRoomSearch = () => {
    // TODO: make the search button disable if the date is not selected
    console.log(checkIn, checkOut, roomType);
    if (checkIn === null || checkOut === null) {
      setValidationError("Please select check-in and check-out dates");
      return;
    }
    searchRooms(checkIn.toISOString(), checkOut.toISOString(), roomType);
  };

  return (
    <Box
      flexDirection="row"
      display="flex"
      justifyContent="space-around"
      border={1}
      px={8}
      py={4}
      mb={4}
      style={{ background: "rgba(0, 0, 0, 0.5)" }}
    >
      <Box style={{ backgroundColor: "white" }}>
        <Typography variant="h6">Check-in date</Typography>
        <LocalizationProvider dateAdapter={AdapterDayjs}>
          <DatePicker onChange={handleCheckInChange} />
        </LocalizationProvider>
      </Box>
      <Box style={{ backgroundColor: "white" }}>
        <Typography variant="h6">Check-out date</Typography>
        <LocalizationProvider dateAdapter={AdapterDayjs}>
          <DatePicker onChange={handleCheckOutChange} />
        </LocalizationProvider>
      </Box>
      <Box style={{ backgroundColor: "white" }}>
        <Typography variant="h6">Room type</Typography>
        <FormControl>
          <Select
            labelId="demo-simple-select-label"
            id="demo-simple-select"
            value={roomType}
            placeholder="All types"
            onChange={handleRoomTypeChange}
          >
            <MenuItem value={"Single"}>Single</MenuItem>
            <MenuItem value={"Double"}>Double</MenuItem>
            <MenuItem value={"Suit"}>Suit</MenuItem>
          </Select>
        </FormControl>
      </Box>
      <Button
        style={{ textTransform: "none" }}
        variant="contained"
        onClick={handleRoomSearch}
      >
        {loading ? (
          <Typography>Searching...</Typography>
        ) : (
          <Typography>Search</Typography>
        )}
      </Button>
      {error && <Typography color="red">{error.message}</Typography>}
      {validationError && (
        <Typography color="red">{validationError}</Typography>
      )}
    </Box>
  );
}
