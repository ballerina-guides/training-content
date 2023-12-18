import React from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import Register from "./components/Register";
import Login from "./components/Login";
import Home from "./components/Home";
import Comments from "./components/Comments";
import Posts from "./components/Posts";
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { SnackbarProvider } from "notistack";

const theme = createTheme({
	typography: {
		fontFamily: "Space Grotesk, sans-serif"
	}
});

const App = () => {
	return (
		<ThemeProvider theme={theme}>
			<SnackbarProvider maxSnack={3}>
				<div>
					<BrowserRouter>
						<Routes>
							<Route path='/' element={<Login />} />
							<Route path='/register' element={<Register />} />
							<Route path='/dashboard' element={<Home />} />
							<Route path='/posts' element={<Posts />} />
							<Route path='/posts/:id/comments' element={<Comments />} />
						</Routes>
					</BrowserRouter>
				</div>
			</SnackbarProvider>
		</ThemeProvider>
	);
};

export default App;
