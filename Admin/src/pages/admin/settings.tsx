import {
  Card,
  CardContent,
  FormControlLabel,
  Grid,
  Switch,
  TextField,
  Typography
} from '@mui/material';
import React from 'react';
import Layout from '../../components/Layout';
import withAuth from '../../utils/withAuth';

const SettingsPage: React.FC = () => {
    return (
    <Layout title="Cài đặt hệ thống">
      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} gutterBottom>
                Thông tin doanh nghiệp
              </Typography>
              <TextField
                label="Tên doanh nghiệp"
                fullWidth
                defaultValue="Expenses Corp"
                sx={{ mb: 3 }}
              />
              <TextField
                label="Email liên hệ"
                fullWidth
                type="email"
                defaultValue="finance@expenses.app"
                sx={{ mb: 3 }}
              />
              <TextField
                label="Ngưỡng cảnh báo (₫)"
                fullWidth
                type="number"
                defaultValue="50000000"
              />
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} gutterBottom>
                Thông báo & bảo mật
              </Typography>
              <FormControlLabel
                control={<Switch defaultChecked />}
                label="Nhận thông báo email khi vượt ngân sách"
              />
              <FormControlLabel
                control={<Switch />}
                label="Yêu cầu 2FA khi đăng nhập"
              />
              <FormControlLabel
                control={<Switch defaultChecked />}
                label="Nhắc nhở đối soát hàng tuần"
              />
            </CardContent>
          </Card>
        </Grid>
      </Grid>
        </Layout>
    );
};

export default withAuth(SettingsPage);