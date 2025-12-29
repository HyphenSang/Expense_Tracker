import ReceiptIcon from '@mui/icons-material/Receipt';
import { Box, Card, CardContent, List, ListItem, Typography } from '@mui/material';

const RecentActivity = ({ items = [] }) => (
  <Card
    elevation={0}
    sx={{
      borderRadius: 3,
      border: '1px solid #E5E7EB',
      backgroundColor: '#fff',
      width: '100%',
    }}
  >
    <CardContent sx={{ p: 3, display: 'flex', flexDirection: 'column' }}>
      <Typography variant="h6" gutterBottom fontWeight={600} mb={3} fontSize="1.125rem">
        Giao dịch gần đây
      </Typography>
      {items.length === 0 ? (
        <Box sx={{ textAlign: 'center', py: 6, minHeight: 200, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Typography variant="body1" color="#6B7280" fontSize="0.9375rem">
            Chưa có giao dịch
          </Typography>
        </Box>
      ) : (
        <Box sx={{ width: '100%', overflowX: 'auto' }}>
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: {
                xs: '1fr',
                sm: 'repeat(2, 1fr)',
                md: 'repeat(3, 1fr)',
                lg: 'repeat(4, 1fr)',
                xl: 'repeat(5, 1fr)',
              },
              gap: 2,
              minWidth: 0,
            }}
          >
            {items.map((item, index) => (
              <Box
                key={item.id || item.createdAt || index}
                sx={{
                  p: 2.5,
                  borderRadius: 2,
                  border: '1px solid #F5F5F5',
                  backgroundColor: '#FAFAFA',
                  display: 'flex',
                  flexDirection: 'column',
                  minWidth: 0,
                  transition: 'all 0.2s ease',
                  '&:hover': {
                    backgroundColor: '#F5F5F5',
                    borderColor: '#E5E7EB',
                    transform: 'translateY(-2px)',
                    boxShadow: '0 2px 8px rgba(0, 0, 0, 0.08)',
                  },
                }}
              >
                <Box sx={{ display: 'flex', alignItems: 'center', width: '100%', mb: 1.5 }}>
                  <Box
                    sx={{
                      width: 36,
                      height: 36,
                      borderRadius: 1.5,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      backgroundColor: '#D2F27320',
                      color: '#D2F273',
                      mr: 1.5,
                      flexShrink: 0,
                    }}
                  >
                    <ReceiptIcon sx={{ fontSize: 18 }} />
                  </Box>
                  <Typography
                    variant="body2"
                    fontWeight={600}
                    sx={{
                      flexGrow: 1,
                      fontSize: '0.875rem',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      whiteSpace: 'nowrap',
                      minWidth: 0,
                    }}
                    title={item.title || item.category || 'Không rõ'}
                  >
                    {item.title || item.category || 'Không rõ'}
                  </Typography>
                </Box>
                <Typography
                  variant="body1"
                  fontWeight={700}
                  color="#111827"
                  fontSize="1rem"
                  sx={{ mb: 1, width: '100%', wordBreak: 'break-word' }}
                >
                  {Intl.NumberFormat('vi-VN').format(item.amount || 0)} đ
                </Typography>
                <Box sx={{ display: 'flex', gap: 1, width: '100%', flexWrap: 'wrap', alignItems: 'center' }}>
                  {item.category && (
                    <Typography
                      variant="body2"
                      color="#6B7280"
                      fontSize="0.75rem"
                      fontWeight={500}
                      sx={{
                        px: 1,
                        py: 0.25,
                        borderRadius: 1,
                        backgroundColor: '#E5E7EB',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {item.category}
                    </Typography>
                  )}
                  {item.createdAt && (
                    <Typography
                      variant="body2"
                      color="#6B7280"
                      fontSize="0.75rem"
                      sx={{ whiteSpace: 'nowrap' }}
                    >
                      {new Date(item.createdAt).toLocaleDateString('vi-VN', {
                        day: 'numeric',
                        month: 'short',
                      })}
                    </Typography>
                  )}
                </Box>
              </Box>
            ))}
          </Box>
        </Box>
      )}
    </CardContent>
  </Card>
);

export default RecentActivity;
