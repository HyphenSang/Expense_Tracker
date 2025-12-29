import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Button,
  Container,
  TextField,
  Typography,
  Alert,
  CircularProgress,
  Paper,
  InputAdornment,
  IconButton,
} from '@mui/material';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import LockIcon from '@mui/icons-material/Lock';
import EmailIcon from '@mui/icons-material/Email';
import { supabaseClient } from '../lib/supabaseClient';
import { setAuthToken } from '../api/adminApi';

const LoginPage = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      if (!supabaseClient) {
        throw new Error('Supabase client chưa được cấu hình. Vui lòng kiểm tra biến môi trường.');
      }

      // 0. Đảm bảo xóa session cũ trước khi đăng nhập mới
      await supabaseClient.auth.signOut();

      // 1. Đăng nhập với Supabase (tạo session mới)
      const { data: authData, error: authError } = await supabaseClient.auth.signInWithPassword({
        email,
        password,
      });

      if (authError || !authData.session) {
        throw new Error(authError?.message || 'Đăng nhập thất bại');
      }

      // Lấy token mới từ session mới
      const token = authData.session.access_token;
      const userId = authData.user.id;

      // 2. Kiểm tra user có trong bảng admins không
      const { data: admin, error: adminError } = await supabaseClient
        .from('admins')
        .select(`
          user_id,
          role_id,
          roles!inner(
            id,
            name
          )
        `)
        .eq('user_id', userId)
        .maybeSingle();

      if (adminError) {
        console.error('Error checking admin:', adminError);
        throw new Error('Lỗi khi kiểm tra quyền admin');
      }

      if (!admin) {
        // Đăng xuất nếu không phải admin
        await supabaseClient.auth.signOut();
        throw new Error('Bạn không có quyền truy cập trang quản trị. Chỉ admin users mới có thể đăng nhập.');
      }

      // 3. Redirect (Supabase client đã tự động lưu token vào session)
      // Không cần lưu thủ công nữa vì Supabase client tự quản lý
      navigate('/', { replace: true });
    } catch (err) {
      setError(err.message || 'Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#F5F5F5',
        p: 3,
      }}
    >
      <Container maxWidth="sm">
        <Paper
          elevation={0}
          sx={{
            p: 4,
            borderRadius: 2,
            border: '1px solid #E5E7EB',
            backgroundColor: '#fff',
          }}
        >
          <Box sx={{ mb: 4, textAlign: 'center' }}>
            <Box
              sx={{
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                width: 56,
                height: 56,
                borderRadius: 2,
                backgroundColor: '#D2F273',
                color: '#111827',
                mb: 2,
              }}
            >
              <LockIcon sx={{ fontSize: 28 }} />
            </Box>
            <Typography variant="h5" component="h1" fontWeight={700} color="#111827" gutterBottom>
              Đăng nhập
            </Typography>
            <Typography variant="body2" color="#6B7280">
              Trang quản trị
            </Typography>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>
              {error}
            </Alert>
          )}

          <form onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              disabled={isLoading}
              autoComplete="email"
              placeholder="admin@example.com"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <EmailIcon sx={{ color: '#9CA3AF' }} />
                  </InputAdornment>
                ),
              }}
              sx={{ mb: 2 }}
            />
            <TextField
              fullWidth
              label="Mật khẩu"
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={isLoading}
              autoComplete="current-password"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <LockIcon sx={{ color: '#9CA3AF' }} />
                  </InputAdornment>
                ),
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      onClick={() => setShowPassword(!showPassword)}
                      edge="end"
                      disabled={isLoading}
                      sx={{ color: '#9CA3AF' }}
                    >
                      {showPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              sx={{ mb: 3 }}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={isLoading}
              sx={{
                py: 1.5,
                fontWeight: 600,
                textTransform: 'none',
                fontSize: '1rem',
                borderRadius: 2,
                backgroundColor: '#D2F273',
                color: '#111827',
                '&:hover': {
                  backgroundColor: '#B8D95A',
                },
              }}
            >
              {isLoading ? (
                <>
                  <CircularProgress size={20} sx={{ mr: 1 }} color="inherit" />
                  Đang đăng nhập...
                </>
              ) : (
                'Đăng nhập'
              )}
            </Button>
          </form>
        </Paper>
      </Container>
    </Box>
  );
};

export default LoginPage;

