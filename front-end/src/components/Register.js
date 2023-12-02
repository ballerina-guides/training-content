import React, { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Notification from "./Notification";

const Register = () => {
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
	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");
	const [notify, setNotify] = useState(false);
	const [error, setError] = useState(false);
	const [message, setMessage] = useState("");

	const signUp = () => {
		fetch("http://localhost:4000/api/users", {
			method: "POST",
			body: JSON.stringify({
				email,
				password,
				"name": username,
			}),
			headers: {
				"Content-Type": "application/json",
			},
		})
			.then((res) => {
				if (res.status === 201 || res.status === 409) {
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
					setMessage("Account created successfully");
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
		setMessage("");
		setError(false);
		if (!error) {
			navigate("/");
		}
	}

	const handleSubmit = (e) => {
		e.preventDefault();
		signUp();
		setEmail("");
		setUsername("");
		setPassword("");
	};
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
			<div className='register'>
				<h1 className='registerTitle'>Create an account</h1>
				<form className='registerForm' onSubmit={handleSubmit}>
					<label htmlFor='username'>Username</label>
					<input
						type='text'
						name='username'
						id='username'
						required
						value={username}
						onChange={(e) => setUsername(e.target.value)}
					/>
					<label htmlFor='email'>Email Address</label>
					<input
						type='text'
						name='email'
						id='email'
						required
						value={email}
						onChange={(e) => setEmail(e.target.value)}
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
					<button className='registerBtn'>REGISTER</button>
					<p>
						Have an account? <Link to='/'>Sign in</Link>
					</p>
				</form>
			</div>
		</main>
	);
};

export default Register;
