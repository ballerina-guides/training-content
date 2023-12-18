import React from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@mui/material";
import CommentIcon from '@mui/icons-material/Comment';

const Comments = ({ numberOfComments, postId }) => {
	const navigate = useNavigate();

	const handleAddComment = () => {
		navigate(`/posts/${postId}/comments`);
	};
	return (
		<Button startIcon={<CommentIcon />} onClick={handleAddComment} sx={{ color: "#20b6b0" }}>{numberOfComments === 0 ? "" : numberOfComments}</Button>
	);
};

export default Comments;
