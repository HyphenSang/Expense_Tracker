import { createTheme } from '@mui/material/styles';

// Màu sắc đồng bộ với Flutter app
const colors = {
  primary: '#D2F273', // Vàng xanh lá nhạt - màu chủ đạo
  primaryDark: '#B8D95A',
  primaryLight: '#E8F9A0',
  secondary: '#6B9F3D', // Xanh lá đậm
  accent: '#4A7C2A',
  
  // Neutral colors
  gray50: '#FAFAFA',
  gray100: '#F5F5F5',
  gray200: '#E5E7EB',
  gray300: '#D1D5DB',
  gray400: '#9CA3AF',
  gray500: '#6B7280',
  gray600: '#4B5563',
  gray700: '#374151',
  gray800: '#1F2937',
  gray900: '#111827',
  
  // Semantic colors
  success: '#10B981',
  info: '#3B82F6',
  warning: '#F59E0B',
  error: '#EF4444',
};

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: colors.primary,
      light: colors.primaryLight,
      dark: colors.primaryDark,
      contrastText: colors.gray900,
    },
    secondary: {
      main: colors.secondary,
      contrastText: '#fff',
    },
    success: {
      main: colors.success,
    },
    info: {
      main: colors.info,
    },
    warning: {
      main: colors.warning,
    },
    error: {
      main: colors.error,
    },
    background: {
      default: colors.gray100,
      paper: '#ffffff',
    },
    text: {
      primary: colors.gray900,
      secondary: colors.gray500,
    },
    divider: colors.gray200,
  },
  shape: {
    borderRadius: 12, // Đồng bộ với AppRadius.md
  },
  typography: {
    fontFamily: "'Inter', 'Segoe UI', sans-serif",
    fontWeightRegular: 400,
    fontWeightMedium: 500,
    fontWeightSemiBold: 600,
    fontWeightBold: 700,
    h4: {
      fontWeight: 700,
      fontSize: '2rem',
    },
    h5: {
      fontWeight: 700,
      fontSize: '1.5rem',
    },
    h6: {
      fontWeight: 600,
      fontSize: '1.25rem',
    },
    body1: {
      fontSize: '1rem',
      fontWeight: 400,
    },
    body2: {
      fontSize: '0.875rem',
      fontWeight: 400,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 600,
          borderRadius: 12,
          padding: '10px 24px',
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: 'none',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 16,
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.08)',
          border: `1px solid ${colors.gray200}`,
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          borderRadius: 12,
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 12,
            backgroundColor: '#fff',
            '& fieldset': {
              borderColor: colors.gray300,
            },
            '&:hover fieldset': {
              borderColor: colors.gray400,
            },
            '&.Mui-focused fieldset': {
              borderColor: colors.primary,
              borderWidth: 2,
            },
          },
        },
      },
    },
  },
});

export default theme;
