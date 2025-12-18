import ReceiptIcon from '@mui/icons-material/Receipt';
import { Avatar, Box, Card, CardContent, List, ListItem, ListItemAvatar, ListItemText, Typography } from '@mui/material';

const RecentActivity = ({ items = [] }) => (
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
        Giao dịch gần đây
      </Typography>
      {items.length === 0 ? (
        <Typography variant="body2" color="text.secondary" textAlign="center" py={4}>
          Chưa có giao dịch
        </Typography>
      ) : (
        <List>
          {items.map((item) => (
            <ListItem key={item.id || item.createdAt} disableGutters sx={{ py: 1.5 }}>
              <ListItemAvatar>
                <Avatar
                  sx={{
                    bgcolor: 'primary.main',
                    color: 'text.primary',
                    width: 40,
                    height: 40,
                  }}
                >
                  <ReceiptIcon fontSize="small" />
                </Avatar>
              </ListItemAvatar>
              <ListItemText
                primary={
                  <Typography variant="body1" fontWeight={500}>
                    {item.title || item.category || 'Không rõ'}
                  </Typography>
                }
                secondary={
                  <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 0.5 }}>
                    <Typography variant="body2" color="text.secondary">
                      {item.category || 'Khác'}
                    </Typography>
                    {item.createdAt && (
                      <Typography variant="body2" color="text.secondary">
                        {new Date(item.createdAt).toLocaleString('vi-VN')}
                      </Typography>
                    )}
                  </Box>
                }
              />
              <Typography fontWeight={700} color="text.primary">
                {Intl.NumberFormat('vi-VN').format(item.amount || 0)} đ
              </Typography>
            </ListItem>
          ))}
        </List>
      )}
    </CardContent>
  </Card>
);

export default RecentActivity;
