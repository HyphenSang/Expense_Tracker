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
    <Box>
      <Typography variant="h5" fontWeight={700} gutterBottom mb={2}>
        Quản lý người dùng
      </Typography>
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      <UsersTable rows={users || []} loading={isLoading} />
    </Box>
  );
};

export default UsersPage;

