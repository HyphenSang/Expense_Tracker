import NotificationsNoneIcon from '@mui/icons-material/NotificationsNone';
import SearchIcon from '@mui/icons-material/Search';
import { alpha } from '@mui/material/styles';
import { Avatar, Box, IconButton, InputBase, Paper, Typography } from '@mui/material';

const TopBar = ({ startAdornment }) => (
  <Paper
    elevation={0}
    sx={{
      width: '100%',
      borderRadius: 0,
      px: 3,
      py: 2,
      borderBottom: '1px solid',
      borderColor: 'divider',
      display: 'flex',
      alignItems: 'center',
      gap: 2,
    }}
  >
    {startAdornment}
    <Box sx={{ flexGrow: 1 }}>
      <Typography variant="h5" fontWeight={700}>
        Trang quản trị
      </Typography>
      <Typography variant="body2" color="text.secondary">
        Kiểm soát chi tiêu và người dùng của ứng dụng Expenses
      </Typography>
    </Box>
    <Paper
      component="form"
      sx={{
        display: { xs: 'none', sm: 'flex' },
        alignItems: 'center',
        backgroundColor: (theme) => alpha(theme.palette.primary.main, 0.08),
        px: 1.5,
        py: 0.5,
        borderRadius: 999,
      }}
    >
      <SearchIcon fontSize="small" color="primary" />
      <InputBase sx={{ ml: 1 }} placeholder="Tìm kiếm..." />
    </Paper>
    <IconButton color="primary">
      <NotificationsNoneIcon />
    </IconButton>
    <Avatar sx={{ bgcolor: 'primary.main', width: 40, height: 40 }}>AD</Avatar>
  </Paper>
);

export default TopBar;

