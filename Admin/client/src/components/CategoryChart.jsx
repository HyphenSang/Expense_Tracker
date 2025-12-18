import { Card, CardContent, Typography } from '@mui/material';
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip, Legend } from 'recharts';

// Màu sắc đồng bộ với app
const colors = ['#D2F273', '#6B9F3D', '#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];

const CategoryChart = ({ data = [] }) => (
  <Card
    elevation={0}
    sx={{
      borderRadius: 3,
      border: '1px solid',
      borderColor: 'divider',
      backgroundColor: '#fff',
    }}
  >
    <CardContent>
      <Typography variant="h6" gutterBottom fontWeight={600}>
        Phân bổ chi tiêu theo danh mục
      </Typography>
      {data.length === 0 ? (
        <Typography variant="body2" color="text.secondary" textAlign="center" py={4}>
          Chưa có dữ liệu
        </Typography>
      ) : (
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={data}
              dataKey="amount"
              nameKey="category"
              cx="50%"
              cy="50%"
              outerRadius={100}
              label={({ category, percent }) => `${category}: ${(percent * 100).toFixed(0)}%`}
            >
              {data.map((entry, index) => (
                <Cell key={`slice-${entry.category}`} fill={colors[index % colors.length]} />
              ))}
            </Pie>
            <Tooltip
              formatter={(value) => `${Intl.NumberFormat('vi-VN').format(value)} đ`}
              contentStyle={{
                backgroundColor: '#fff',
                border: '1px solid #E5E7EB',
                borderRadius: 8,
              }}
            />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      )}
    </CardContent>
  </Card>
);

export default CategoryChart;
