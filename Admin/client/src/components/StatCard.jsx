import { Box, Card, CardContent, Typography } from '@mui/material';

const StatCard = ({ label, value, trend, icon, color = 'primary' }) => {
  const getColorValue = () => {
    const colorMap = {
      primary: '#D2F273',
      info: '#3B82F6',
      warning: '#F59E0B',
      success: '#10B981',
    };
    return colorMap[color] || colorMap.primary;
  };

  const colorValue = getColorValue();

  return (
    <Card
      elevation={0}
      sx={{
        borderRadius: 3,
        border: '1px solid #E5E7EB',
        backgroundColor: '#fff',
        transition: 'all 0.2s ease',
        height: '100%',
        '&:hover': {
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
          transform: 'translateY(-2px)',
        },
      }}
    >
      <CardContent sx={{ p: 4 }}>
        <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', mb: 3 }}>
          <Typography variant="body1" color="#6B7280" fontWeight={500} fontSize="0.9375rem" sx={{ flex: 1 }}>
            {label}
          </Typography>
          <Box
            sx={{
              width: 56,
              height: 56,
              borderRadius: 2,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: `${colorValue}20`,
              color: colorValue,
              ml: 2,
              flexShrink: 0,
              '& svg': {
                fontSize: 28,
              },
            }}
          >
            {icon}
          </Box>
        </Box>
        <Typography variant="h4" fontWeight={700} color="#111827" mb={1} sx={{ fontSize: { xs: '1.75rem', md: '2rem' } }}>
          {value}
        </Typography>
        {trend && (
          <Typography
            variant="body2"
            color={trend.startsWith('+') ? '#10B981' : '#EF4444'}
            fontWeight={500}
            fontSize="0.875rem"
          >
            {trend} so với tháng trước
          </Typography>
        )}
      </CardContent>
    </Card>
  );
};

export default StatCard;
