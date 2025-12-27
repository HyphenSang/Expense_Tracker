import { useEffect, useState } from 'react';
import { useLocation, Navigate } from 'react-router-dom';
import { Box, CircularProgress, Typography } from '@mui/material';
import { getAuthToken } from '../api/adminApi';

/**
 * Protected Route Component
 * Kiểm tra authentication trước khi render route
 * Nếu chưa có token → hiển thị thông báo yêu cầu đăng nhập
 */
const ProtectedRoute = ({ children }) => {
  const location = useLocation();
  const [isChecking, setIsChecking] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    // Kiểm tra token trong localStorage hoặc URL params
    const token = getAuthToken();
    
    if (token) {
      setIsAuthenticated(true);
    } else {
      setIsAuthenticated(false);
    }
    
    setIsChecking(false);
  }, [location]);

  if (isChecking) {
    return (
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          gap: 2,
        }}
      >
        <CircularProgress />
        <Typography variant="body2" color="text.secondary">
          Đang kiểm tra quyền truy cập...
        </Typography>
      </Box>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return children;
};

export default ProtectedRoute;

