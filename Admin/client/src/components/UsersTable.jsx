import { Box, Card, CardContent, Typography } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'email', headerName: 'Email', flex: 1, minWidth: 220 },
  { field: 'username', headerName: 'Tên người dùng', flex: 0.8, minWidth: 160 },
  { field: 'full_name', headerName: 'Họ tên', flex: 0.8, minWidth: 160 },
  {
    field: 'role',
    headerName: 'Vai trò',
    flex: 0.4,
    minWidth: 120,
    align: 'center',
    headerAlign: 'center',
    renderCell: ({ value }) => (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: '100%' }}>
        <Typography
          variant="body2"
          sx={(theme) => ({
            px: 1.5,
            py: 0.5,
            borderRadius: 1,
            backgroundColor: value === 'Admin' ? theme.palette.primary.main : '#E5E7EB',
            color: value === 'Admin' ? theme.palette.text.primary : theme.palette.text.secondary,
            fontWeight: 500,
            fontSize: '0.75rem',
            whiteSpace: 'nowrap',
          })}
        >
          {value}
        </Typography>
      </Box>
    ),
  },
  {
    field: 'status',
    headerName: 'Trạng thái',
    flex: 0.4,
    minWidth: 120,
    align: 'center',
    headerAlign: 'center',
    renderCell: ({ value }) => (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: '100%' }}>
        <Typography
          variant="body2"
          sx={(theme) => ({
            px: 1.5,
            py: 0.5,
            borderRadius: 1,
            backgroundColor: theme.palette.success.main,
            color: '#fff',
            fontWeight: 500,
            fontSize: '0.75rem',
            whiteSpace: 'nowrap',
          })}
        >
          {value}
        </Typography>
      </Box>
    ),
  },
  {
    field: 'last_sign_in_at',
    headerName: 'Đăng nhập gần nhất',
    flex: 0.8,
    minWidth: 200,
    valueFormatter: ({ value }) => (value ? new Date(value).toLocaleString('vi-VN') : 'Chưa đăng nhập'),
  },
];

const UsersTable = ({ rows = [], loading }) => (
  <Card
    elevation={0}
    sx={{
      borderRadius: 3,
      border: '1px solid',
      borderColor: 'divider',
      backgroundColor: '#fff',
      height: 520,
    }}
  >
    <CardContent sx={{ height: '100%', display: 'flex', flexDirection: 'column', p: 2 }}>
      <Typography variant="h6" gutterBottom fontWeight={600} mb={2}>
        Người dùng
      </Typography>
      <DataGrid
        rows={rows.map((row, index) => ({ id: row.id || index, ...row }))}
        columns={columns}
        loading={loading}
        disableRowSelectionOnClick
        density="comfortable"
        sx={{
          flexGrow: 1,
          border: 'none',
          '& .MuiDataGrid-cell': {
            borderBottom: '1px solid #F5F5F5',
            display: 'flex',
            alignItems: 'center',
          },
          '& .MuiDataGrid-columnHeaders': {
            backgroundColor: '#FAFAFA',
            borderBottom: '1px solid #E5E7EB',
            fontWeight: 600,
          },
        }}
      />
    </CardContent>
  </Card>
);

export default UsersTable;
