import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import PeopleAltIcon from '@mui/icons-material/PeopleAlt';
import Grid from '@mui/material/Grid';
import { Alert, Box, Button, CircularProgress } from '@mui/material';

import CategoryChart from '../components/CategoryChart';
import RecentActivity from '../components/RecentActivity';
import StatCard from '../components/StatCard';
import useDashboardData from '../hooks/useDashboardData';

const DashboardPage = () => {
  const { overview, categoryBreakdown, expenses, isLoading, error, refresh } = useDashboardData();

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 3 }}>
        <Button
          variant="contained"
          onClick={refresh}
          startIcon={<TrendingUpIcon />}
          sx={{
            textTransform: 'none',
            fontWeight: 600,
            borderRadius: 2,
            px: 3,
            py: 1,
          }}
        >
          Làm mới dữ liệu
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {isLoading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 6 }}>
          <CircularProgress />
        </Box>
      )}

      {!isLoading && overview && (
        <>
          <Grid container spacing={3}>
            <Grid item xs={12} md={3}>
              <StatCard
                label="Tổng giá trị chi tiêu"
                value={`${Intl.NumberFormat('vi-VN').format(overview.totalExpenses || 0)} đ`}
                trend="+8%"
                icon={<AccountBalanceWalletIcon />}
              />
            </Grid>
            <Grid item xs={12} md={3}>
              <StatCard
                label="Số giao dịch"
                value={overview.totalTransactions}
                trend="+3%"
                icon={<TrendingUpIcon />}
                color="info"
              />
            </Grid>
            <Grid item xs={12} md={3}>
              <StatCard
                label="Đang chờ duyệt"
                value={overview.pendingTransactions}
                icon={<PendingActionsIcon />}
                color="warning"
              />
            </Grid>
            <Grid item xs={12} md={3}>
              <StatCard
                label="Người dùng hoạt động"
                value={overview.activeUsers}
                icon={<PeopleAltIcon />}
                color="success"
              />
            </Grid>
          </Grid>

          <Grid container spacing={3} sx={{ mt: 1 }}>
            <Grid item xs={12} lg={6}>
              <CategoryChart data={categoryBreakdown} />
            </Grid>
            <Grid item xs={12} lg={6}>
              <RecentActivity items={(expenses || []).slice(0, 5)} />
            </Grid>
          </Grid>
        </>
      )}
    </Box>
  );
};

export default DashboardPage;

