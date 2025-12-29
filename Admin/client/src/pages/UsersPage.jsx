import { useEffect } from 'react';
import { Alert, Box, Typography } from '@mui/material';

import UsersTable from '../components/UsersTable';
import useDashboardStore from '../state/useDashboardStore';

const UsersPage = () => {
  const { users, isLoading, error, refresh } = useDashboardStore();

  useEffect(() => {
    refresh();
  }, [refresh]);

  return (
    <Box sx={{ width: '100%' }}>
      <Typography variant="h6" fontWeight={600} gutterBottom mb={4} fontSize="1.25rem">
        Quản lý người dùng
      </Typography>
      {error && (
        <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>
          {error}
        </Alert>
      )}
      <UsersTable rows={users || []} loading={isLoading} />
    </Box>
  );
};

export default UsersPage;

