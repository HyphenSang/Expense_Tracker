import { Box, Card, CardContent, Typography } from '@mui/material';

const StatCard = ({ label, value, trend, icon, color = 'primary.main' }) => (
  <Card
    elevation={0}
    sx={{
      borderRadius: 4,
      border: '1px solid',
      borderColor: 'divider',
      background: 'linear-gradient(135deg, rgba(79,70,229,0.07), rgba(14,165,233,0.04))',
    }}
  >
    <CardContent>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="body2" color="text.secondary">
          {label}
        </Typography>
        <Box
          sx={{
            width: 40,
            height: 40,
            borderRadius: 2,
            display: 'grid',
            placeItems: 'center',
            backgroundColor: `${color}20`,
            color,
          }}
        >
          {icon}
        </Box>
      </Box>
      <Typography variant="h4" fontWeight={700}>
        {value}
      </Typography>
      {trend && (
        <Typography variant="body2" color={trend.startsWith('+') ? 'success.main' : 'error.main'}>
          {trend} so với tháng trước
        </Typography>
      )}
    </CardContent>
  </Card>
);

export default StatCard;

