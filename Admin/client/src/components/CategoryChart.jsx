import { Card, CardContent, Typography } from '@mui/material';
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from 'recharts';

const colors = ['#6366f1', '#8b5cf6', '#ec4899', '#f97316', '#14b8a6', '#22d3ee'];

const CategoryChart = ({ data = [] }) => (
  <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
    <CardContent>
      <Typography variant="h6" gutterBottom>
        Phân bổ chi tiêu theo danh mục
      </Typography>
      <ResponsiveContainer width="100%" height={300}>
        <PieChart>
          <Pie data={data} dataKey="amount" nameKey="category" cx="50%" cy="50%" outerRadius={110} label>
            {data.map((entry, index) => (
              <Cell key={`slice-${entry.category}`} fill={colors[index % colors.length]} />
            ))}
          </Pie>
          <Tooltip />
        </PieChart>
      </ResponsiveContainer>
    </CardContent>
  </Card>
);

export default CategoryChart;

