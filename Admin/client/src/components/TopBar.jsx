import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import LogoutIcon from '@mui/icons-material/Logout';
import {
  Avatar,
  Box,
  IconButton,
  Paper,
  Typography,
  Menu,
  MenuItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import { logout } from '../api/adminApi';

const TopBar = ({ startAdornment }) => {
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = useState(null);
  const open = Boolean(anchorEl);

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = async () => {
    await logout();
    handleClose();
    navigate('/login', { replace: true });
  };

  return (
    <Paper
      elevation={0}
      sx={{
        width: '100%',
        borderRadius: 0,
        px: { xs: 2, sm: 3, md: 4 },
        py: 2.5,
        borderBottom: '1px solid #E5E7EB',
        backgroundColor: '#fff',
        display: 'flex',
        alignItems: 'center',
        gap: 2,
        flexShrink: 0,
      }}
    >
      {startAdornment}
      <Box sx={{ flexGrow: 1 }}>
        <Typography variant="h6" fontWeight={600} color="text.primary" fontSize="1.125rem">
          Trang quản trị
        </Typography>
      </Box>
      <IconButton
        onClick={handleClick}
        sx={{
          padding: 0,
          '&:hover': {
            opacity: 0.8,
          },
        }}
      >
        <Avatar
          sx={{
            bgcolor: '#D2F273',
            color: '#111827',
            width: 36,
            height: 36,
            fontWeight: 600,
            fontSize: '0.875rem',
            cursor: 'pointer',
          }}
        >
          AD
        </Avatar>
      </IconButton>
      <Menu
        anchorEl={anchorEl}
        open={open}
        onClose={handleClose}
        transformOrigin={{ horizontal: 'right', vertical: 'top' }}
        anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
        PaperProps={{
          elevation: 4,
          sx: {
            mt: 1.5,
            minWidth: 180,
            borderRadius: 2,
            '& .MuiMenuItem-root': {
              px: 2,
              py: 1.25,
            },
          },
        }}
      >
        <MenuItem onClick={handleLogout} sx={{ color: 'error.main' }}>
          <ListItemIcon>
            <LogoutIcon fontSize="small" sx={{ color: 'error.main' }} />
          </ListItemIcon>
          <ListItemText primary="Đăng xuất" />
        </MenuItem>
      </Menu>
    </Paper>
  );
};

export default TopBar;
