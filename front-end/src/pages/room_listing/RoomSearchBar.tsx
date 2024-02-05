import {
  Box,
  Button,
  FormControl,
  MenuItem,
  Select,
  SelectChangeEvent,
  TextField,
  Theme,
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

  const handleRoomTypeChange = (event: any) => {
    setRoomType(event.target.value as string);
  };

  const handleCheckInChange = (e: any) => {
    const { value } = e.target;
    setCheckIn(new Date(value));
  };

  const handleCheckOutChange = (e: any) => {
    const { value } = e.target;
    setCheckOut(new Date(value));
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
      justifyContent="space-between"
      border={1}
      px={8}
      py={4}
      mb={4}
      style={{ background: "rgba(0, 0, 0, 0.5)" }}
    >
      <Box display="flex" width="70%" justifyContent="space-between">
        <Box style={{ backgroundColor: "white" }} width="30%" borderRadius={2}>
          <TextField
            onChange={handleCheckInChange}
            fullWidth
            label="Check In Date"
            variant="filled"
            type="date"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
        <Box style={{ backgroundColor: "white" }} width="30%" borderRadius={2}>
          <TextField
            onChange={handleCheckOutChange}
            fullWidth
            label="Check In Date"
            variant="filled"
            type="date"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
        <Box style={{ backgroundColor: "white" }} width="30%" borderRadius={2}>
          <TextField
            fullWidth
            label="Room Type"
            id="demo-simple-select"
            value={roomType}
            placeholder="All types"
            select={true}
            onChange={handleRoomTypeChange}
            variant="filled"
          >
            <MenuItem value={"Single"}>Single</MenuItem>
            <MenuItem value={"Double"}>Double</MenuItem>
            <MenuItem value={"Suit"}>Suit</MenuItem>
          </TextField>
        </Box>
      </Box>
      <Button
        style={{ textTransform: "none", width: "20%", borderRadius: '8px' }}
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
