import { useState } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import MenuIcon from '@mui/icons-material/Menu';
import { Box, Container, IconButton, useMediaQuery } from '@mui/material';
import { useTheme } from '@mui/material/styles';

import Sidebar from '../components/Sidebar';
import TopBar from '../components/TopBar';

const drawerWidth = 260;

const DashboardLayout = () => {
  const [open, setOpen] = useState(false);
  const theme = useTheme();
  const isDesktop = useMediaQuery(theme.breakpoints.up('lg'));
  const location = useLocation();

  const toggleDrawer = () => {
    setOpen((prev) => !prev);
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', backgroundColor: 'background.default', width: '100%' }}>
      <Sidebar
        open={isDesktop ? true : open}
        onClose={toggleDrawer}
        drawerWidth={drawerWidth}
        currentPath={location.pathname}
        variant={isDesktop ? 'permanent' : 'temporary'}
      />

      <Box
        component="main"
        sx={{
          flexGrow: 1,
          width: { lg: `calc(100% - ${drawerWidth}px)` },
          minWidth: 0,
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <TopBar
          startAdornment={
            !isDesktop && (
              <IconButton onClick={toggleDrawer} sx={{ color: '#111827' }}>
                <MenuIcon />
              </IconButton>
            )
          }
        />
        <Container maxWidth="xl" sx={{ py: 4, width: '100%', px: { xs: 2, sm: 3, md: 4 } }}>
          <Outlet />
        </Container>
      </Box>
    </Box>
  );
};

export default DashboardLayout;

