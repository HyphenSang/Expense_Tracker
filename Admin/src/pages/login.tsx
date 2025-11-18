import {
  Box,
  Card,
  CardContent,
  Container,
  Typography
} from '@mui/material';
import Head from 'next/head';
import React from 'react';
import LoginForm from '../components/LoginForm';

const LoginPage: React.FC = () => {
    return (
    <>
      <Head>
        <title>Đăng nhập | Expenses Admin</title>
      </Head>
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          bgcolor: 'grey.100'
        }}
      >
        <Container maxWidth="sm">
          <Card elevation={0} sx={{ borderRadius: 4, p: { xs: 2, md: 4 } }}>
            <CardContent>
              <Typography variant="h4" fontWeight={700} gutterBottom>
                Expenses Admin
              </Typography>
              <Typography color="text.secondary" sx={{ mb: 4 }}>
                Vui lòng đăng nhập để quản trị chi tiêu doanh nghiệp.
              </Typography>
            <LoginForm />
            </CardContent>
          </Card>
        </Container>
      </Box>
    </>
    );
};

export default LoginPage;