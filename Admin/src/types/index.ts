export type LoginCredentials = {
  username: string;
  password: string;
};

export type AuthUser = {
  username: string;
  email?: string;
  role: 'admin' | 'viewer';
  avatarUrl?: string;
};

export type AuthContextValue = {
  user: AuthUser | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
};

export type RecentExpense = {
  id: string;
  category: string;
  amount: number;
  date: string;
  status: 'Đã duyệt' | 'Chờ duyệt' | 'Từ chối';
};

export type BudgetItem = {
  id: string;
  title: string;
  spent: number;
  limit: number;
};

export type ActivityLog = {
  id: string;
  description: string;
  time: string;
};