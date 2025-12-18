import { Box, Card, CardContent, Typography } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'title', headerName: 'Nội dung', flex: 1, minWidth: 180 },
  { field: 'category', headerName: 'Danh mục', flex: 0.6, minWidth: 120 },
  {
    field: 'amount',
    headerName: 'Số tiền',
    flex: 0.5,
    minWidth: 140,
    valueFormatter: ({ value }) => `${Intl.NumberFormat('vi-VN').format(value || 0)} đ`,
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
            backgroundColor: value === 'approved' ? theme.palette.success.main : theme.palette.warning.main,
            color: '#fff',
            fontWeight: 500,
            fontSize: '0.75rem',
            whiteSpace: 'nowrap',
          })}
        >
          {value === 'approved' ? 'Đã duyệt' : 'Chờ duyệt'}
        </Typography>
      </Box>
    ),
  },
  {
    field: 'createdAt',
    headerName: 'Ngày tạo',
    flex: 0.6,
    minWidth: 180,
    valueFormatter: ({ value }) => (value ? new Date(value).toLocaleString('vi-VN') : ''),
  },
];

const ExpensesTable = ({ rows = [], loading }) => (
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
        Danh sách chi tiêu
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

export default ExpensesTable;
