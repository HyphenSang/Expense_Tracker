import { Card, CardContent, Typography } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'title', headerName: 'Nội dung', flex: 1, minWidth: 180 },
  { field: 'category', headerName: 'Danh mục', flex: 0.6, minWidth: 120 },
  {
    field: 'amount',
    headerName: 'Số tiền',
    flex: 0.5,
    minWidth: 140,
    valueFormatter: ({ value }) => Intl.NumberFormat('vi-VN').format(value || 0),
  },
  {
    field: 'status',
    headerName: 'Trạng thái',
    flex: 0.4,
    minWidth: 120,
  },
  {
    field: 'created_at',
    headerName: 'Ngày tạo',
    flex: 0.6,
    minWidth: 180,
    valueFormatter: ({ value }) => (value ? new Date(value).toLocaleString('vi-VN') : ''),
  },
];

const ExpensesTable = ({ rows = [], loading }) => (
  <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', height: 520 }}>
    <CardContent sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Typography variant="h6" gutterBottom>
        Danh sách chi tiêu
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

export default ExpensesTable;

