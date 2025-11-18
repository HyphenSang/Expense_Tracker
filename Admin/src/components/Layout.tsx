import { Box, CssBaseline, Toolbar } from '@mui/material';
import React, { useState } from 'react';
import Header from './Header';
import Sidebar, { drawerWidth } from './Sidebar';

type LayoutProps = {
  children: React.ReactNode;
  title?: string;
};

const Layout: React.FC<LayoutProps> = ({ children, title }) => {
  const [mobileOpen, setMobileOpen] = useState(false);

  const toggleSidebar = () => {
    setMobileOpen((prev) => !prev);
  };

    return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'grey.50' }}>
      <CssBaseline />
      <Header onToggleSidebar={toggleSidebar} title={title} />
      <Sidebar mobileOpen={mobileOpen} onClose={toggleSidebar} />

      <Box
        component="main"
        sx={{
          flexGrow: 1,
          width: { md: `calc(100% - ${drawerWidth}px)` },
          p: { xs: 2, md: 4 },
          mt: 10
        }}
      >
        <Toolbar sx={{ display: { xs: 'flex', md: 'none' } }} />
                    {children}
      </Box>
    </Box>
    );
};

export default Layout;