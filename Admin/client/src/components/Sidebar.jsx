import { NavLink } from 'react-router-dom';
import DashboardIcon from '@mui/icons-material/SpaceDashboard';
import GroupIcon from '@mui/icons-material/Group';
import CloseIcon from '@mui/icons-material/Close';
import {
  Avatar,
  Box,
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
        borderRight: '1px solid #E5E7EB',
        backgroundColor: '#fff',
        color: '#111827',
        p: 3,
        position: 'relative',
      },
    }}
  >
    {/* Header */}
    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 4 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Avatar
          sx={{
            bgcolor: '#D2F273',
            color: '#111827',
            fontWeight: 700,
            width: 40,
            height: 40,
          }}
        >
          Ex
        </Avatar>
        <Typography fontWeight={700} fontSize="1.125rem">
          Quản trị
        </Typography>
      </Box>
      {onClose && variant === 'temporary' && (
        <IconButton onClick={onClose} sx={{ color: '#111827' }}>
          <CloseIcon />
        </IconButton>
      )}
    </Box>

    {/* Navigation */}
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
            py: 1.5,
            color: '#6B7280',
            '&.Mui-selected': {
              backgroundColor: '#D2F273',
              color: '#111827',
              '& .MuiListItemIcon-root': {
                color: '#111827',
              },
              '&:hover': {
                backgroundColor: '#D2F273',
              },
            },
            '&:hover': {
              backgroundColor: '#F5F5F5',
            },
          }}
        >
          <ListItemIcon sx={{ color: 'inherit', minWidth: 40 }}>
            {item.icon}
          </ListItemIcon>
          <ListItemText
            primary={item.label}
            primaryTypographyProps={{
              fontWeight: currentPath === item.path ? 600 : 500,
              fontSize: '0.9375rem',
            }}
          />
        </ListItemButton>
      ))}
    </List>
  </Drawer>
);

export default Sidebar;
