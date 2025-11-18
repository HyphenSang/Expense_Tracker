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
    <Box sx={{ display: 'flex', minHeight: '100vh', backgroundColor: 'background.default' }}>
      <Sidebar
        open={isDesktop ? true : open}
        onClose={toggleDrawer}
        drawerWidth={drawerWidth}
        currentPath={location.pathname}
        variant={isDesktop ? 'permanent' : 'temporary'}
      />

      <Box component="main" sx={{ flexGrow: 1, ml: { lg: `${drawerWidth}px` } }}>
        <TopBar
          startAdornment={
            !isDesktop && (
              <IconButton color="inherit" onClick={toggleDrawer}>
                <MenuIcon />
              </IconButton>
            )
          }
        />
        <Container maxWidth="xl" sx={{ py: 4 }}>
          <Outlet />
        </Container>
      </Box>
    </Box>
  );
};

export default DashboardLayout;

