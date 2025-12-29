import RefreshIcon from '@mui/icons-material/Refresh';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import PeopleAltIcon from '@mui/icons-material/PeopleAlt';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import Grid from '@mui/material/Grid';
import { Alert, Box, Button, CircularProgress } from '@mui/material';

import CategoryChart from '../components/CategoryChart';
import RecentActivity from '../components/RecentActivity';
import StatCard from '../components/StatCard';
import useDashboardData from '../hooks/useDashboardData';

const DashboardPage = () => {
  const { overview, categoryBreakdown, expenses, isLoading, error, refresh } = useDashboardData();

  return (
    <Box sx={{ width: '100%' }}>
      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {isLoading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
          <CircularProgress />
        </Box>
      )}

      {!isLoading && overview && (
        <>
          <Grid container spacing={2} sx={{ mb: 4, width: '100%', margin: 0 }}>
            <Grid item xs={12} sm={6} md={3}>
              <StatCard
                label="Tổng chi tiêu"
                value={`${Intl.NumberFormat('vi-VN').format(overview.totalExpenses || 0)} đ`}
                trend={overview.expenseTrend || '0%'}
                icon={<AccountBalanceWalletIcon />}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <StatCard
                label="Số giao dịch"
                value={overview.totalTransactions}
                trend={overview.transactionTrend || '0%'}
                icon={<TrendingUpIcon />}
                color="info"
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <StatCard
                label="Chờ duyệt"
                value={overview.pendingTransactions}
                icon={<PendingActionsIcon />}
                color="warning"
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <StatCard
                label="Người dùng"
                value={overview.activeUsers}
                icon={<PeopleAltIcon />}
                color="success"
              />
            </Grid>
          </Grid>

          <Grid container spacing={2} sx={{ width: '100%', margin: 0, mb: 4 }}>
            <Grid item xs={12} sx={{ width: '60%', minWidth: 500 }}>
              <CategoryChart data={categoryBreakdown} />
            </Grid>
            <Grid item xs={12} sx={{ width: '100%', minWidth: 0 }}>
              <RecentActivity items={(expenses || []).slice(0, 10)} />
            </Grid>
          </Grid>

          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
            <Button
              variant="outlined"
              onClick={refresh}
              startIcon={<RefreshIcon />}
              size="large"
              sx={{
                textTransform: 'none',
                fontWeight: 500,
                borderRadius: 2,
                px: 4,
                py: 1.5,
                borderColor: '#E5E7EB',
                color: '#6B7280',
                fontSize: '0.9375rem',
                '&:hover': {
                  borderColor: '#D2F273',
                  backgroundColor: '#D2F27320',
                },
              }}
            >
              Làm mới
            </Button>
          </Box>
        </>
      )}
    </Box>
  );
};

export default DashboardPage;

