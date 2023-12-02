import { Button } from "@mui/material";
import React from "react";
import FavoriteIcon from '@mui/icons-material/Favorite';
import Notification from "../components/Notification";

const Likes = ({ numberOfLikes, postId }) => {
	const [notify, setNotify] = React.useState(false);
	const [message, setMessage] = React.useState("");
	const [error, setError] = React.useState(false);
	const handleLikeFunction = () => {
		fetch("http://localhost:4000/api/posts/" + postId + "/likes", {
			method: "POST",
			body: JSON.stringify({
				userId: localStorage.getItem("_id"),
			}),
			headers: {
				"Content-Type": "application/json",
			},
		})
			.then((res) => res.json())
			.then((data) => {
				if (data.error_message) {
					setNotify(true);
					setError(true);
					setMessage(data.error_message);
				} else {
					setNotify(true);
					setMessage(data.message);
				}
			})
			.catch((err) => {
				setNotify(true);
				setError(true);
				setMessage("Something went wrong");
				console.error(err);
			});
	};

	const handleNotification = () => {
		setNotify(false);
		setError(false);
		setMessage("");
	};

	return (
		<div>
			{notify && <Notification message={message} error={error} handle={handleNotification} />}
			<Button startIcon={<FavoriteIcon />} onClick={handleLikeFunction} sx={{ color: "#20b6b0" }}>{numberOfLikes}</Button>
		</div>
	);
};

export default Likes;
