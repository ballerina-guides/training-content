import {
  Box,
  Button,
  MenuItem,
  TextField,
  Typography,
} from "@mui/material";
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
    console.log(checkIn, checkOut, roomType);
    if (checkIn === null || checkOut === null) {
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
            value={checkIn?.toISOString().split("T")[0]}
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
            value={checkOut?.toISOString().split("T")[0]}
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
        disabled={checkIn === null || checkOut === null || loading || roomType === ""}
      >
        {loading ? (
          <Typography>Searching...</Typography>
        ) : (
          <Typography>Search</Typography>
        )}
      </Button>
      {error && <Typography color="red">{error.message}</Typography>}
    </Box>
  );
}
