import { useNavigate } from "react-router-dom";
import Button from '@mui/material/Button';
import LogoutIcon from '@mui/icons-material/Logout';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';

const Nav = ({ logoPath }) => {
	const navigate = useNavigate();

	const logOut = () => {
		localStorage.removeItem("_id");
		navigate("/");
	};

	const dashborad = () => {
		navigate("/dashboard")
	}

	return (
		<Box sx={{ flexGrow: 1 }}>
			<AppBar position="fixed" sx={{ bgcolor: "#585a5e" }} component="nav">
				<Toolbar>
					<Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
						<img src={logoPath} alt='Bal Logo' height='15' /> Forum
					</Typography>
					<Button variant="contained" size="medium" onClick={dashborad} sx={{ bgcolor: "#20b6b0", marginRight: "10px" }}>Dashboard</Button>
					<Button variant="contained" size="medium" onClick={logOut} endIcon={<LogoutIcon />} sx={{ bgcolor: "#20b6b0" }}>Log out</Button>
				</Toolbar>
			</AppBar>
		</Box>
	);
};

export default Nav;
