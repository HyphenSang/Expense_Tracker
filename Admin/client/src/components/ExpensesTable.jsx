import { Box, Card, CardContent, Typography } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'title', headerName: 'Nội dung', flex: 1, minWidth: 220 },
  { field: 'category', headerName: 'Danh mục', flex: 0.7, minWidth: 150 },
  {
    field: 'amount',
    headerName: 'Số tiền',
    flex: 0.6,
    minWidth: 160,
    valueFormatter: ({ value }) => `${Intl.NumberFormat('vi-VN').format(value || 0)} đ`,
  },
  {
    field: 'status',
    headerName: 'Trạng thái',
    flex: 0.5,
    minWidth: 140,
    align: 'center',
    headerAlign: 'center',
    renderCell: ({ value }) => (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: '100%' }}>
        <Typography
          variant="body2"
          sx={(theme) => ({
            px: 2,
            py: 0.75,
            borderRadius: 1.5,
            backgroundColor: value === 'approved' ? theme.palette.success.main : theme.palette.warning.main,
            color: '#fff',
            fontWeight: 500,
            fontSize: '0.8125rem',
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
    flex: 0.8,
    minWidth: 200,
    valueFormatter: ({ value }) => (value ? new Date(value).toLocaleString('vi-VN') : ''),
  },
];

const ExpensesTable = ({ rows = [], loading }) => (
  <Card
    elevation={0}
    sx={{
      borderRadius: 3,
      border: '1px solid #E5E7EB',
      backgroundColor: '#fff',
      height: 600,
    }}
  >
    <CardContent sx={{ height: '100%', display: 'flex', flexDirection: 'column', p: 4 }}>
      <Typography variant="h6" gutterBottom fontWeight={600} mb={3} fontSize="1.125rem">
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
          fontSize: '0.9375rem',
          '& .MuiDataGrid-cell': {
            borderBottom: '1px solid #F5F5F5',
            display: 'flex',
            alignItems: 'center',
            py: 1.5,
          },
          '& .MuiDataGrid-columnHeaders': {
            backgroundColor: '#FAFAFA',
            borderBottom: '2px solid #E5E7EB',
            fontWeight: 600,
            fontSize: '0.9375rem',
            py: 1.5,
          },
          '& .MuiDataGrid-row:hover': {
            backgroundColor: '#F9FAFB',
          },
        }}
      />
    </CardContent>
  </Card>
);

export default ExpensesTable;
