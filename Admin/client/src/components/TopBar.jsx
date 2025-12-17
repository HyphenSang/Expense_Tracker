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
      py: 2.5,
      borderBottom: '1px solid',
      borderColor: 'divider',
      backgroundColor: '#fff',
      display: 'flex',
      alignItems: 'center',
      gap: 2,
    }}
  >
    {startAdornment}
    <Box sx={{ flexGrow: 1 }}>
      <Typography variant="h5" fontWeight={700} color="text.primary">
        Trang quản trị
      </Typography>
      <Typography variant="body2" color="text.secondary" fontSize="0.875rem">
        Kiểm soát chi tiêu và người dùng của ứng dụng Expenses
      </Typography>
    </Box>
    <Paper
      component="form"
      sx={{
        display: { xs: 'none', sm: 'flex' },
        alignItems: 'center',
        backgroundColor: (theme) => alpha(theme.palette.primary.main, 0.1),
        px: 2,
        py: 0.75,
        borderRadius: 3,
        border: '1px solid',
        borderColor: (theme) => alpha(theme.palette.primary.main, 0.2),
        height: 'fit-content',
      }}
    >
      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <SearchIcon fontSize="small" sx={{ color: 'primary.main', mr: 1 }} />
        <InputBase
          sx={{ fontSize: '0.875rem' }}
          placeholder="Tìm kiếm..."
          inputProps={{ 'aria-label': 'search' }}
        />
      </Box>
    </Paper>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
      <IconButton
        sx={(theme) => ({
          color: 'text.secondary',
          '&:hover': {
            backgroundColor: alpha(theme.palette.primary.main, 0.1),
            color: 'primary.main',
          },
        })}
      >
        <NotificationsNoneIcon />
      </IconButton>
      <Avatar
        sx={{
          bgcolor: 'primary.main',
          color: 'text.primary',
          width: 40,
          height: 40,
          fontWeight: 700,
          fontSize: '0.875rem',
        }}
      >
        AD
      </Avatar>
    </Box>
  </Paper>
);

export default TopBar;
