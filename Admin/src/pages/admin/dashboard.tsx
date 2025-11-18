import TrendingDownRounded from '@mui/icons-material/TrendingDownRounded';
import TrendingUpRounded from '@mui/icons-material/TrendingUpRounded';
import {
  Avatar,
  Box,
  Card,
  CardContent,
  Chip,
  Divider,
  Grid,
  LinearProgress,
  List,
  ListItem,
  ListItemAvatar,
  ListItemText,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography
} from '@mui/material';
import { NextPage } from 'next';
import React, { useEffect, useState } from 'react';
import {
  activities,
  budgetItems,
  expenseTrends,
  quickStats,
  recentExpenses
} from '../../data/dashboard';
import Layout from '../../components/Layout';
import StatCard from '../../components/StatCard';
import withAuth from '../../utils/withAuth';
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts';

const DashboardPage: NextPage = () => {
  const [canRenderChart, setCanRenderChart] = useState(false);

  useEffect(() => {
    setCanRenderChart(true);
  }, []);

    return (
    <Layout title="Tổng quan chi tiêu">
      <Grid container spacing={3}>
        {quickStats.map((stat) => (
          <Grid item xs={12} md={4} key={stat.id}>
            <StatCard
              title={stat.title}
              value={stat.value}
              trend={stat.trend}
              trendType={stat.trendType}
              icon={
                stat.trendType === 'negative' ? (
                  <TrendingDownRounded />
                ) : (
                  <TrendingUpRounded />
                )
              }
            />
          </Grid>
        ))}

        <Grid item xs={12} md={8}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} gutterBottom>
                Biểu đồ chi tiêu 6 tháng gần nhất
              </Typography>
              <Box sx={{ height: 300 }}>
                {canRenderChart ? (
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={expenseTrends}>
                      <defs>
                        <linearGradient
                          id="expenses"
                          x1="0"
                          y1="0"
                          x2="0"
                          y2="1"
                        >
                          <stop
                            offset="5%"
                            stopColor="#4f46e5"
                            stopOpacity={0.8}
                          />
                          <stop
                            offset="95%"
                            stopColor="#4f46e5"
                            stopOpacity={0}
                          />
                        </linearGradient>
                      </defs>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="month" />
                      <YAxis />
                      <Tooltip />
                      <Area
                        type="monotone"
                        dataKey="expenses"
                        stroke="#4f46e5"
                        fillOpacity={1}
                        fill="url(#expenses)"
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                ) : (
                  <Box
                    sx={{
                      height: '100%',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: 'text.secondary'
                    }}
                  >
                    Đang tải biểu đồ...
                  </Box>
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} gutterBottom>
                Tình trạng ngân sách
              </Typography>
              <Stack spacing={3}>
                {budgetItems.map((item) => (
                  <Box key={item.id}>
                    <Box
                      sx={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        mb: 1
                      }}
                    >
                      <Typography fontWeight={600}>{item.title}</Typography>
                      <Typography color="text.secondary">
                        {item.spent}%
                      </Typography>
                    </Box>
                    <LinearProgress
                      variant="determinate"
                      value={item.spent}
                      sx={{ height: 8, borderRadius: 4 }}
                    />
                  </Box>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={8}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} gutterBottom>
                Giao dịch gần đây
              </Typography>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Mã giao dịch</TableCell>
                    <TableCell>Danh mục</TableCell>
                    <TableCell align="right">Số tiền</TableCell>
                    <TableCell>Ngày</TableCell>
                    <TableCell>Trạng thái</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {recentExpenses.map((expense) => (
                    <TableRow key={expense.id}>
                      <TableCell>{expense.id}</TableCell>
                      <TableCell>{expense.category}</TableCell>
                      <TableCell align="right">
                        {expense.amount.toLocaleString('vi-VN')} ₫
                      </TableCell>
                      <TableCell>
                        {new Date(expense.date).toLocaleDateString('vi-VN')}
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={expense.status}
                          color={
                            expense.status === 'Đã duyệt'
                              ? 'success'
                              : expense.status === 'Chờ duyệt'
                                ? 'warning'
                                : 'error'
                          }
                          size="small"
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} gutterBottom>
                Hoạt động gần đây
              </Typography>
              <List>
                {activities.map((activity) => (
                  <React.Fragment key={activity.id}>
                    <ListItem alignItems="flex-start" disableGutters>
                      <ListItemAvatar>
                        <Avatar sx={{ bgcolor: 'primary.light' }}>
                          {activity.id.slice(-1)}
                        </Avatar>
                      </ListItemAvatar>
                      <ListItemText
                        primary={activity.description}
                        secondary={activity.time}
                      />
                    </ListItem>
                    <Divider component="li" />
                  </React.Fragment>
                ))}
              </List>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
        </Layout>
    );
};

export default withAuth(DashboardPage);
