import React, { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Notification from "./Notification";

const Login = () => {
	const navigate = useNavigate();

	useEffect(() => {
		const checkUser = () => {
			if (localStorage.getItem("_id")) {
				navigate("/dashboard");
			}
		};
		checkUser();
	}, [navigate]);

	const [username, setUsername] = useState("");
	const [password, setPassword] = useState("");
	const [notify, setNotify] = useState(false);
	const [error, setError] = useState(false);
	const [message, setMessage] = useState("");

	const loginUser = () => {
		fetch("http://localhost:4000/api/login", {
			method: "POST",
			body: JSON.stringify({
				"name": username,
				password,
			}),
			headers: {
				"Content-Type": "application/json",
			},
		})
			.then((res) => {
				if (res.status === 200 || res.status === 401) {
					return res.json();
				}
				throw new Error("Something went wrong", res.json());
			})
			.then((data) => {
				if (data.error_message) {
					setNotify(true);
					setError(true);
					setMessage(data.error_message);
				} else {
					setNotify(true);
					setMessage(data.message);
					localStorage.setItem("_id", data.id);
					localStorage.setItem("username", username);
				}
			})
			.catch((err) => {
				setNotify(true);
				setError(true);
				setMessage("Something went wrong");
				console.error(err);
			});
	};

	const handleSubmit = (e) => {
		e.preventDefault();
		loginUser();
		setUsername("");
		setPassword("");
	};

	const handleNotification = () => {
		setNotify(false);
		setError(false);
		setMessage("");
		if (!error) {
			navigate("/dashboard");
		}
	}

	return (
		<main>
			<Box sx={{ flexGrow: 1 }}>
				<AppBar position="fixed" sx={{ bgcolor: "#585a5e" }} component="nav">
					<Toolbar>
						<Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
							<img src="images/bal.svg" alt='Bal Logo' height='15' /> Forum
						</Typography>
					</Toolbar>
				</AppBar>
			</Box>
			{notify && <Notification error={error} message={message} handle={handleNotification} />}
			<div className='login'>
				<h1 className='loginTitle'>Log into your account</h1>
				<form className='loginForm' onSubmit={handleSubmit}>
					<label htmlFor='username'>Username</label>
					<input
						type='text'
						name='username'
						id='username'
						required
						value={username}
						onChange={(e) => setUsername(e.target.value)}
					/>
					<label htmlFor='password'>Password</label>
					<input
						type='password'
						name='password'
						id='password'
						required
						value={password}
						onChange={(e) => setPassword(e.target.value)}
					/>
					<button className='loginBtn'>SIGN IN</button>
					<p>
						Don't have an account? <Link to='/register'>Create one</Link>
					</p>
				</form>
			</div>
		</main>
	);
};

export default Login;
