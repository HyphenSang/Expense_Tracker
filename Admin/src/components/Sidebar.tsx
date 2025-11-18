import AssessmentOutlined from '@mui/icons-material/AssessmentOutlined';
import DashboardOutlined from '@mui/icons-material/DashboardOutlined';
import SettingsOutlined from '@mui/icons-material/SettingsOutlined';
import {
  Box,
  Divider,
  Drawer,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography
} from '@mui/material';
import Link from 'next/link';
import { useRouter } from 'next/router';
import React, { Fragment } from 'react';

export const drawerWidth = 260;

type SidebarProps = {
  mobileOpen: boolean;
  onClose: () => void;
};

const menuItems = [
  {
    label: 'Tổng quan',
    href: '/admin/dashboard',
    icon: <DashboardOutlined />
  },
  {
    label: 'Báo cáo',
    href: '/admin/dashboard?tab=reports',
    icon: <AssessmentOutlined />
  },
  {
    label: 'Cài đặt',
    href: '/admin/settings',
    icon: <SettingsOutlined />
  }
];

const Sidebar: React.FC<SidebarProps> = ({ mobileOpen, onClose }) => {
  const router = useRouter();

  const drawerContent = (
    <Box sx={{ p: 2 }}>
      <Typography variant="h6" fontWeight={700} sx={{ mb: 3 }}>
        Expenses Admin
      </Typography>
      <Divider />
      <List>
        {menuItems.map((item) => {
          const isActive = router.asPath === item.href;

          return (
            <Fragment key={item.label}>
              <ListItemButton
                component={Link}
                href={item.href}
                selected={isActive}
                sx={{
                  borderRadius: 2,
                  mt: 1,
                  '&.Mui-selected': {
                    backgroundColor: 'primary.light',
                    color: 'primary.dark'
                  }
                }}
                onClick={onClose}
              >
                <ListItemIcon sx={{ color: 'inherit' }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText primary={item.label} />
              </ListItemButton>
            </Fragment>
          );
        })}
      </List>
    </Box>
  );

    return (
    <>
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={onClose}
        ModalProps={{ keepMounted: true }}
        sx={{
          display: { xs: 'block', md: 'none' },
          '& .MuiDrawer-paper': { width: drawerWidth }
        }}
      >
        {drawerContent}
      </Drawer>

      <Drawer
        variant="permanent"
        open
        sx={{
          display: { xs: 'none', md: 'block' },
          '& .MuiDrawer-paper': {
            width: drawerWidth,
            boxSizing: 'border-box',
            borderRight: '1px solid #e5e7eb'
          }
        }}
      >
        <Toolbar />
        {drawerContent}
      </Drawer>
    </>
    );
};

export default Sidebar;