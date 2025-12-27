import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import NotificationsNoneIcon from '@mui/icons-material/NotificationsNone';
import SearchIcon from '@mui/icons-material/Search';
import LogoutIcon from '@mui/icons-material/Logout';
import PersonIcon from '@mui/icons-material/Person';
import { alpha } from '@mui/material/styles';
import {
  Avatar,
  Box,
  IconButton,
  InputBase,
  Paper,
  Typography,
  Menu,
  MenuItem,
  ListItemIcon,
  ListItemText,
  Divider,
} from '@mui/material';
import { logout, getAuthToken } from '../api/adminApi';

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
    // Redirect về trang login
    navigate('/login', { replace: true });
  };

  // Lấy token để hiển thị thông tin user (nếu có)
  const token = getAuthToken();
  const userEmail = token ? 'Admin' : 'Guest';

  return (
    <Paper
      elevation={0}
      sx={{
        width: '100%',
        borderRadius: 0,
        px: 3,
        py: 2.5,
        borderBottom: '1px solid',
        borderColor: 'divider',
        backgroundColor: '#fff',
        display: 'flex',
        alignItems: 'center',
        gap: 2,
      }}
    >
      {startAdornment}
      <Box sx={{ flexGrow: 1 }}>
        <Typography variant="h5" fontWeight={700} color="text.primary">
          Trang quản trị
        </Typography>
        <Typography variant="body2" color="text.secondary" fontSize="0.875rem">
          Kiểm soát chi tiêu và người dùng của ứng dụng Expenses
        </Typography>
      </Box>
      <Paper
        component="form"
        sx={{
          display: { xs: 'none', sm: 'flex' },
          alignItems: 'center',
          backgroundColor: '#fff',
          px: 2,
          py: 0.75,
          borderRadius: 3,
          border: '1px solid',
          borderColor: 'divider',
          height: 'fit-content',
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center' }}>
          <SearchIcon fontSize="small" sx={{ color: 'primary.main', mr: 1 }} />
          <InputBase
            sx={{ fontSize: '0.875rem' }}
            placeholder="Tìm kiếm..."
            inputProps={{ 'aria-label': 'search' }}
          />
        </Box>
      </Paper>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <IconButton
          sx={(theme) => ({
            color: 'text.secondary',
            '&:hover': {
              backgroundColor: alpha(theme.palette.primary.main, 0.1),
              color: 'primary.main',
            },
          })}
        >
          <NotificationsNoneIcon />
        </IconButton>
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
              bgcolor: 'primary.main',
              color: 'text.primary',
              width: 40,
              height: 40,
              fontWeight: 700,
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
          onClick={handleClose}
          transformOrigin={{ horizontal: 'right', vertical: 'top' }}
          anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
          PaperProps={{
            elevation: 8,
            sx: {
              mt: 1.5,
              minWidth: 200,
              borderRadius: 2,
              '& .MuiMenuItem-root': {
                px: 2,
                py: 1,
              },
            },
          }}
        >
          <MenuItem disabled>
            <ListItemIcon>
              <PersonIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText
              primary={userEmail}
              secondary="Admin User"
              secondaryTypographyProps={{
                component: 'div',
                sx: { fontSize: '0.75rem' },
              }}
            />
          </MenuItem>
          <Divider />
          <MenuItem onClick={handleLogout} sx={{ color: 'error.main' }}>
            <ListItemIcon>
              <LogoutIcon fontSize="small" sx={{ color: 'error.main' }} />
            </ListItemIcon>
            <ListItemText primary="Đăng xuất" />
          </MenuItem>
        </Menu>
      </Box>
    </Paper>
  );
};

export default TopBar;
