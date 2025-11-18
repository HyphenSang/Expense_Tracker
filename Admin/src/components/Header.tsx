import MenuOutlined from '@mui/icons-material/MenuOutlined';
import LogoutRounded from '@mui/icons-material/LogoutRounded';
import NotificationsNoneOutlined from '@mui/icons-material/NotificationsNoneOutlined';
import SearchOutlined from '@mui/icons-material/SearchOutlined';
import {
  AppBar,
  Avatar,
  Badge,
  Box,
  Button,
  IconButton,
  InputAdornment,
  TextField,
  Toolbar,
  Typography
} from '@mui/material';
import React from 'react';
import useAuth from '../hooks/useAuth';

type HeaderProps = {
  onToggleSidebar: () => void;
  title?: string;
};

const Header: React.FC<HeaderProps> = ({ onToggleSidebar, title }) => {
  const { user, logout } = useAuth();

    return (
    <AppBar
      position="fixed"
      elevation={0}
      sx={{
        backgroundColor: 'background.paper',
        color: 'text.primary',
        borderBottom: '1px solid',
        borderColor: 'divider'
      }}
    >
      <Toolbar sx={{ gap: 2 }}>
        <IconButton
          onClick={onToggleSidebar}
          sx={{ display: { md: 'none' } }}
          edge="start"
        >
          <MenuOutlined />
        </IconButton>

        <Box sx={{ flexGrow: 1 }}>
          <Typography variant="subtitle2" color="text.secondary">
            {title ?? 'Expenses Admin'}
          </Typography>
          <Typography variant="h6" fontWeight={700}>
            Xin chào, {user?.username ?? 'admin'} 👋
          </Typography>
        </Box>

        <TextField
          size="small"
          placeholder="Tìm kiếm..."
          sx={{
            width: 240,
            display: { xs: 'none', sm: 'block' }
          }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchOutlined fontSize="small" />
              </InputAdornment>
            )
          }}
        />

        <IconButton>
          <Badge color="error" variant="dot">
            <NotificationsNoneOutlined />
          </Badge>
        </IconButton>

        <Avatar sx={{ bgcolor: 'primary.main' }}>
          {user?.username?.[0]?.toUpperCase() ?? 'A'}
        </Avatar>

        <Button
          color="inherit"
          startIcon={<LogoutRounded />}
          onClick={logout}
          sx={{ display: { xs: 'none', sm: 'flex' } }}
        >
          Đăng xuất
        </Button>
      </Toolbar>
    </AppBar>
    );
};

export default Header;