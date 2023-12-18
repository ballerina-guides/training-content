import { Alert, Snackbar } from "@mui/material";
import React from "react";

const Notification = ({ message, error, handle }) => {
    return (
        <div>
            <Snackbar open autoHideDuration={5000} onClose={handle}>
                <Alert severity={error ? "error" : "success"} onClose={handle}>
                    {message}
                </Alert>
            </Snackbar>
        </div>
    )
}

export default Notification;