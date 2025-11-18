import { useEffect, useState } from 'react';
import Grid from '@mui/material/Grid';
import { Alert, Box, Button, Stack, TextField, Typography } from '@mui/material';

import ExpensesTable from '../components/ExpensesTable';
import { createExpense } from '../api/adminApi';
import useDashboardStore from '../state/useDashboardStore';

const initialForm = {
  title: '',
  amount: '',
  category: '',
  note: '',
};

const ExpensesPage = () => {
  const { expenses, isLoading, refresh, error } = useDashboardStore();
  const [form, setForm] = useState(initialForm);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [feedback, setFeedback] = useState(null);

  const handleChange = (event) => {
    setForm((prev) => ({
      ...prev,
      [event.target.name]: event.target.value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setIsSubmitting(true);
    setFeedback(null);

    try {
      await createExpense({
        ...form,
        amount: Number(form.amount),
      });
      setFeedback({ type: 'success', message: 'Tạo chi tiêu thành công' });
      setForm(initialForm);
      refresh();
    } catch (submitError) {
      setFeedback({ type: 'error', message: submitError.message });
    } finally {
      setIsSubmitting(false);
    }
  };

  useEffect(() => {
    if (!expenses.length) {
      refresh();
    }
  }, [expenses.length, refresh]);

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} gutterBottom>
        Quản lý chi tiêu
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {feedback && (
        <Alert severity={feedback.type} sx={{ mb: 2 }} onClose={() => setFeedback(null)}>
          {feedback.message}
        </Alert>
      )}

      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Box
            component="form"
            onSubmit={handleSubmit}
            sx={{ p: 3, borderRadius: 4, border: '1px solid', borderColor: 'divider', backgroundColor: '#fff' }}
          >
            <Typography variant="h6" gutterBottom>
              Thêm chi tiêu mới
            </Typography>
            <Stack spacing={2}>
              <TextField label="Tiêu đề" name="title" value={form.title} onChange={handleChange} required />
              <TextField
                label="Số tiền"
                name="amount"
                type="number"
                value={form.amount}
                onChange={handleChange}
                required
              />
              <TextField label="Danh mục" name="category" value={form.category} onChange={handleChange} />
              <TextField label="Ghi chú" name="note" value={form.note} onChange={handleChange} multiline minRows={2} />
              <Button type="submit" variant="contained" disabled={isSubmitting}>
                {isSubmitting ? 'Đang tạo...' : 'Tạo chi tiêu'}
              </Button>
            </Stack>
          </Box>
        </Grid>
        <Grid item xs={12} md={8}>
          <ExpensesTable rows={expenses} loading={isLoading} />
        </Grid>
      </Grid>
    </Box>
  );
};

export default ExpensesPage;

