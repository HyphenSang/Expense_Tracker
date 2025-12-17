import { Box, Card, CardContent, Typography } from '@mui/material';
import { alpha } from '@mui/material/styles';

const StatCard = ({ label, value, trend, icon, color = 'primary' }) => {
  const getColorValue = (theme) => {
    if (typeof color === 'string' && color.startsWith('#')) {
      return color;
    }
    return theme.palette[color]?.main || theme.palette.primary.main;
  };

  const getBackgroundColor = (theme) => {
    const colorValue = getColorValue(theme);
    return alpha(colorValue, 0.1);
  };

  return (
    <Card
      elevation={0}
      sx={{
        borderRadius: 3,
        border: '1px solid',
        borderColor: 'divider',
        backgroundColor: '#fff',
        transition: 'all 0.2s ease',
        '&:hover': {
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
          transform: 'translateY(-2px)',
        },
      }}
    >
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
          <Typography variant="body2" color="text.secondary" fontWeight={500} fontSize="0.875rem">
            {label}
          </Typography>
          <Box
            sx={(theme) => ({
              width: 48,
              height: 48,
              borderRadius: 2,
              display: 'grid',
              placeItems: 'center',
              backgroundColor: getBackgroundColor(theme),
              color: getColorValue(theme),
            })}
          >
            {icon}
          </Box>
        </Box>
        <Typography variant="h4" fontWeight={700} color="text.primary" mb={0.5}>
          {value}
        </Typography>
        {trend && (
          <Typography
            variant="body2"
            color={trend.startsWith('+') ? 'success.main' : 'error.main'}
            fontWeight={500}
            fontSize="0.75rem"
          >
            {trend} so với tháng trước
          </Typography>
        )}
      </CardContent>
    </Card>
  );
};

export default StatCard;
