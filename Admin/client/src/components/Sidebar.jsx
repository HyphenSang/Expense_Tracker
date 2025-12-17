import { NavLink } from 'react-router-dom';
import DashboardIcon from '@mui/icons-material/SpaceDashboard';
import ReceiptIcon from '@mui/icons-material/ReceiptLong';
import GroupIcon from '@mui/icons-material/Group';
import CloseIcon from '@mui/icons-material/Close';
import {
  Avatar,
  Box,
  Divider,
  Drawer,
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
} from '@mui/material';

const navItems = [
  { label: 'Tổng quan', icon: <DashboardIcon />, path: '/' },
  { label: 'Chi tiêu', icon: <ReceiptIcon />, path: '/expenses' },
  { label: 'Người dùng', icon: <GroupIcon />, path: '/users' },
];

const Sidebar = ({ open, onClose, drawerWidth, currentPath, variant = 'permanent' }) => (
  <Drawer
    variant={variant}
    open={open}
    onClose={onClose}
    sx={{
      width: drawerWidth,
      flexShrink: 0,
      '& .MuiDrawer-paper': {
        width: drawerWidth,
        boxSizing: 'border-box',
        borderRight: 'none',
        backgroundColor: '#111827', // gray900
        color: '#fff',
        p: 2,
      },
    }}
  >
    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Avatar
          sx={{
            bgcolor: '#D2F273', // primary
            color: '#111827', // gray900
            fontWeight: 700,
            width: 48,
            height: 48,
          }}
        >
          Ex
        </Avatar>
        <div>
          <Typography fontWeight={700} fontSize="1rem">
            Expenses Admin
          </Typography>
          <Typography variant="body2" color="rgba(255,255,255,0.7)" fontSize="0.75rem">
            Dashboard
          </Typography>
        </div>
      </Box>
      {onClose && variant === 'temporary' && (
        <IconButton onClick={onClose} sx={{ color: '#fff', display: { lg: 'none' } }}>
          <CloseIcon />
        </IconButton>
      )}
    </Box>

    <Divider sx={{ borderColor: 'rgba(255,255,255,0.1)', mb: 2 }} />

    <List sx={{ flexGrow: 1 }}>
      {navItems.map((item) => (
        <ListItemButton
          key={item.path}
          component={NavLink}
          to={item.path}
          selected={currentPath === item.path}
          sx={{
            borderRadius: 2,
            mb: 1,
            color: 'rgba(255,255,255,0.7)',
            '&.Mui-selected': {
              backgroundColor: 'rgba(210, 242, 115, 0.15)',
              color: '#D2F273',
              '& .MuiListItemIcon-root': {
                color: '#D2F273',
              },
            },
            '&:hover': {
              backgroundColor: 'rgba(255,255,255,0.08)',
            },
          }}
        >
          <ListItemIcon sx={{ color: currentPath === item.path ? '#D2F273' : 'rgba(255,255,255,0.7)', minWidth: 40 }}>
            {item.icon}
          </ListItemIcon>
          <ListItemText
            primary={item.label}
            primaryTypographyProps={{
              fontWeight: currentPath === item.path ? 600 : 400,
            }}
          />
        </ListItemButton>
      ))}
    </List>

    <Box
      sx={{
        p: 2,
        borderRadius: 3,
        backgroundColor: 'rgba(255,255,255,0.08)',
        border: '1px solid rgba(255,255,255,0.1)',
      }}
    >
      <Typography variant="subtitle2" gutterBottom fontWeight={600}>
        Trạng thái Supabase
      </Typography>
      <Typography variant="body2" color="rgba(255,255,255,0.7)" fontSize="0.75rem">
        Đang kết nối tới cơ sở dữ liệu
      </Typography>
    </Box>
  </Drawer>
);

export default Sidebar;
