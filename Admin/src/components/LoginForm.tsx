import {
  Alert,
  Box,
  Button,
  Stack,
  TextField,
  Typography
} from '@mui/material';
import React, { useState } from 'react';
import useAuth from '../hooks/useAuth';

const LoginForm: React.FC = () => {
  const { login } = useAuth();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setIsSubmitting(true);

    try {
      await login({ username, password });
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setIsSubmitting(false);
        }
    };

    return (
    <Box component="form" onSubmit={handleSubmit}>
      <Stack spacing={3}>
            <div>
          <Typography variant="subtitle2" color="text.secondary">
            Tài khoản mặc định
          </Typography>
          <Typography variant="body2">
            admin / <strong>admin123</strong>
          </Typography>
        </div>

        <TextField
          label="Tên đăng nhập"
                    value={username}
          onChange={(event) => setUsername(event.target.value)}
                    required
          fullWidth
        />

        <TextField
          label="Mật khẩu"
                    type="password"
                    value={password}
          onChange={(event) => setPassword(event.target.value)}
                    required
          fullWidth
        />

        {error && (
          <Alert severity="error" variant="outlined">
            {error}
          </Alert>
        )}

        <Button
          type="submit"
          variant="contained"
          size="large"
          disabled={isSubmitting}
        >
          {isSubmitting ? 'Đang xử lý...' : 'Đăng nhập'}
        </Button>
      </Stack>
    </Box>
    );
};

export default LoginForm;
