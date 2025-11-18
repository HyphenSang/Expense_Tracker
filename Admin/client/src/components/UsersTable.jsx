import { Card, CardContent, Typography } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'email', headerName: 'Email', flex: 1, minWidth: 220 },
  { field: 'full_name', headerName: 'Họ tên', flex: 0.8, minWidth: 160 },
  { field: 'role', headerName: 'Vai trò', flex: 0.4, minWidth: 120 },
  { field: 'status', headerName: 'Trạng thái', flex: 0.4, minWidth: 120 },
  {
    field: 'last_sign_in_at',
    headerName: 'Đăng nhập gần nhất',
    flex: 0.8,
    minWidth: 200,
    valueFormatter: ({ value }) => (value ? new Date(value).toLocaleString('vi-VN') : 'Chưa đăng nhập'),
  },
];

const UsersTable = ({ rows = [], loading }) => (
  <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', height: 520 }}>
    <CardContent sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Typography variant="h6" gutterBottom>
        Người dùng
      </Typography>
      <DataGrid
        rows={rows.map((row, index) => ({ id: row.id || index, ...row }))}
        columns={columns}
        loading={loading}
        disableRowSelectionOnClick
        density="comfortable"
        sx={{ flexGrow: 1, border: 'none' }}
      />
    </CardContent>
  </Card>
);

export default UsersTable;

