import ReceiptIcon from '@mui/icons-material/Receipt';
import { Avatar, Box, Card, CardContent, List, ListItem, ListItemAvatar, ListItemText, Typography } from '@mui/material';

const RecentActivity = ({ items = [] }) => (
  <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
    <CardContent>
      <Typography variant="h6" gutterBottom>
        Giao dịch gần đây
      </Typography>
      <List>
        {items.map((item) => (
          <ListItem key={item.id || item.created_at} disableGutters>
            <ListItemAvatar>
              <Avatar sx={{ bgcolor: 'primary.main', color: '#fff' }}>
                <ReceiptIcon />
              </Avatar>
            </ListItemAvatar>
            <ListItemText
              primary={item.title || item.category || 'Không rõ'}
              secondary={
                <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                  <Typography variant="body2" color="text.secondary">
                    {item.category || 'Khác'}
                  </Typography>
                  {item.created_at ? (
                    <Typography variant="body2" color="text.secondary">
                      {new Date(item.created_at).toLocaleString('vi-VN')}
                    </Typography>
                  ) : null}
                </Box>
              }
            />
            <Typography fontWeight={700}>{Intl.NumberFormat('vi-VN').format(item.amount || 0)} đ</Typography>
          </ListItem>
        ))}
        {!items.length && (
          <Typography variant="body2" color="text.secondary">
            Chưa có giao dịch.
          </Typography>
        )}
      </List>
    </CardContent>
  </Card>
);

export default RecentActivity;

