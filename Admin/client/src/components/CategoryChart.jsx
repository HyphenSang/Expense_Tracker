import { Card, CardContent, Typography, Box } from '@mui/material';
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip, Legend } from 'recharts';

const colors = ['#D2F273', '#6B9F3D', '#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];

const CategoryChart = ({ data = [] }) => (
  <Card
    elevation={0}
    sx={{
      borderRadius: 3,
      border: '1px solid #E5E7EB',
      backgroundColor: '#fff',
      width: '100%',
      minWidth: 0,
    }}
  >
    <CardContent sx={{ p: 3, width: '100%', minWidth: 0 }}>
      <Typography variant="h6" gutterBottom fontWeight={600} mb={3} fontSize="1.125rem">
        Phân bổ theo danh mục
      </Typography>
      {data.length === 0 ? (
        <Box sx={{ textAlign: 'center', py: 6, height: 400, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Typography variant="body1" color="#6B7280" fontSize="0.9375rem">
            Chưa có dữ liệu
          </Typography>
        </Box>
      ) : (
        <Box
          sx={{
            width: '100%',
            height: 450,
            minWidth: 0,
            position: 'relative',
          }}
        >
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={data}
                dataKey="amount"
                nameKey="category"
                cx="50%"
                cy="45%"
                outerRadius={140}
                innerRadius={35}
                label={({ category, percent }) => `${category}: ${(percent * 100).toFixed(0)}%`}
                labelLine={true}
              >
                {data.map((entry, index) => (
                  <Cell key={`slice-${entry.category}`} fill={colors[index % colors.length]} />
                ))}
              </Pie>
              <Tooltip
                formatter={(value, name) => [
                  `${Intl.NumberFormat('vi-VN').format(value)} đ`,
                  name,
                ]}
                contentStyle={{
                  backgroundColor: '#fff',
                  border: '1px solid #E5E7EB',
                  borderRadius: 8,
                  fontSize: '0.9375rem',
                  padding: '12px',
                  boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
                }}
              />
              <Legend
                verticalAlign="bottom"
                height={50}
                wrapperStyle={{ fontSize: '0.875rem', fontWeight: 500 }}
                formatter={(value) => value}
                iconType="circle"
                iconSize={10}
              />
            </PieChart>
          </ResponsiveContainer>
        </Box>
      )}
    </CardContent>
  </Card>
);

export default CategoryChart;
