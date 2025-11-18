import {
  Avatar,
  Card,
  CardContent,
  Stack,
  Typography
} from '@mui/material';
import React from 'react';

type StatCardProps = {
  icon: React.ReactNode;
  title: string;
  value: string;
  trend: string;
  trendType?: 'positive' | 'negative' | 'neutral';
};

const getTrendColor = (trendType?: StatCardProps['trendType']) => {
  if (trendType === 'positive') {
    return 'success.main';
  }

  if (trendType === 'negative') {
    return 'error.main';
  }

  return 'text.secondary';
};

const StatCard: React.FC<StatCardProps> = ({
  icon,
  title,
  value,
  trend,
  trendType = 'neutral'
}) => {
  return (
    <Card elevation={0} sx={{ borderRadius: 3, border: '1px solid #e5e7eb' }}>
      <CardContent>
        <Stack direction="row" alignItems="center" spacing={2}>
          <Avatar
            sx={{
              bgcolor: 'primary.light',
              color: 'primary.dark',
              width: 48,
              height: 48
            }}
          >
            {icon}
          </Avatar>
          <Stack spacing={0.5}>
            <Typography variant="body2" color="text.secondary">
              {title}
            </Typography>
            <Typography variant="h5" fontWeight={600}>
              {value}
            </Typography>
            <Typography variant="caption" color={getTrendColor(trendType)}>
              {trend}
            </Typography>
          </Stack>
        </Stack>
      </CardContent>
    </Card>
  );
};

export default StatCard;


