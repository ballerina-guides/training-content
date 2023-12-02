import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import Notification from "./Notification";
import { Card, CardContent, Grid, Typography } from "@mui/material";
import Nav from "./PostsNav";

const Comments = () => {
	const [commentList, setCommentList] = useState([]);
	const [comment, setComment] = useState("");
	const [title, setTitle] = useState("");
	const [description, setDescription] = useState("");
	const [post, setPost] = useState("");
	const [notify, setNotify] = useState(false);
	const [message, setMessage] = useState("");
	const [error, setError] = useState(false);
	const navigate = useNavigate();
	const { id } = useParams();

	const addComment = () => {
		fetch("http://localhost:4000/api/posts/" + id + "/comments", {
			method: "POST",
			body: JSON.stringify({
				userId: localStorage.getItem("_id"),
				comment,
				timestamp: new Date().toISOString(),
			}),
			headers: {
				"Content-Type": "application/json",
			},
		})
			.then((res) => {
				if (res.status === 200) {
					return res.json();
				}
				throw new Error("Something went wrong", res.json());
			})
			.then((data) => {
				setNotify(true);
				setMessage(data.message);
			})
			.catch((err) => {
				setNotify(true);
				setError(true);
				setMessage("Something went wrong");
				console.error(err);
			});
	};
	const handleSubmitComment = (e) => {
		e.preventDefault();
		addComment();
		setComment("");
	};

	const handleNotification = () => {
		if (!error) {
			navigate("/dashboard");
		}
		setNotify(false);
		setMessage("");
		setError(false);
	};

	useEffect(() => {
		const fetchComments = () => {
			fetch("http://localhost:4000/api/posts/" + id, {
				method: "GET"
			})
				.then((res) => {
					if (res.status === 200) {
						return res.json();
					}
					throw new Error("Something went wrong", res.json());
				})
				.then((data) => {
					setCommentList(data.comments);
					setTitle(data.title);
					setPost(data);
					setDescription(data.description);
				})
				.catch((err) => {
					setNotify(true);
					setError(true);
					setMessage("Something went wrong");
					console.error(err);
				});
		};
		fetchComments();
	}, [id]);

	const getSubHeader = (comment) => {
		return "posted by " + comment.username + " on " + comment.postedAt.year + "-" + comment.postedAt.month + "-" + comment.postedAt.day + " at " + comment.postedAt.hour + ":" + comment.postedAt.minute;
	}

	return (
		<div>
			<Nav logoPath="../../../images/bal.svg" />
			{notify && <Notification message={message} handle={handleNotification} error={error} />}

			<div style={{ padding: 80 }} >
				<Typography variant="h4" padding="30px">{title}</Typography>
				<Grid container spacing={3} direction="column" alignItems="left" justify="center">
					{post && <Grid item xs={12} key={id}>
						<Card sx={{ width: "1200px" }}>
							<CardContent>
								<Typography variant="h5" component="div">
									{description}
								</Typography>
								<Typography sx={{ mb: 1.5 }} color="text.secondary">
									{getSubHeader(post)}
								</Typography>
							</CardContent>
						</Card>
					</Grid>}
					{commentList.map((comment) => (
						<Grid item xs={12} key={comment.id}>
							<Card sx={{ width: "1200px" }}>
								<CardContent>
									<Typography variant="h5" component="div">
										{comment.comment}
									</Typography>
									<Typography sx={{ mb: 1.5 }} color="text.secondary">
										{getSubHeader(comment)}
									</Typography>
								</CardContent>
							</Card>
						</Grid>
					))}
				</Grid >
			</div>

			<form className='modal__content' onSubmit={handleSubmitComment}>
				<label htmlFor='comment'>Comment to the post</label>
				<textarea
					rows={5}
					value={comment}
					onChange={(e) => setComment(e.target.value)}
					type='text'
					name='comment'
					className='modalInput'
				/>

				<button className='modalBtn'>SEND</button>
			</form>
		</div>
	);
};

export default Comments;
