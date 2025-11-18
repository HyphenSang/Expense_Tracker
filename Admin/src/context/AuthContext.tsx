import { useRouter } from 'next/router';
import React, {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState
} from 'react';
import { AuthContextValue, AuthUser, LoginCredentials } from '../types';

const SESSION_KEY = 'expenses-admin-session';

export const AuthContext = createContext<AuthContextValue | undefined>(
  undefined
);

type AuthProviderProps = {
  children: React.ReactNode;
};

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const router = useRouter();
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const existingSession =
      typeof window !== 'undefined'
        ? window.localStorage.getItem(SESSION_KEY)
        : null;

    if (existingSession) {
      try {
        setUser(JSON.parse(existingSession));
      } catch (error) {
        window.localStorage.removeItem(SESSION_KEY);
      }
    }

    setLoading(false);
  }, []);

  const persistUser = useCallback((authUser: AuthUser) => {
    window.localStorage.setItem(SESSION_KEY, JSON.stringify(authUser));
    setUser(authUser);
  }, []);

  const login = useCallback(
    async (credentials: LoginCredentials) => {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(credentials)
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message ?? 'Không thể đăng nhập');
      }

      const authUser: AuthUser = {
        username: data.user?.username ?? credentials.username,
        email: data.user?.email,
        role: data.user?.role ?? 'admin',
        avatarUrl: data.user?.avatarUrl
      };

      persistUser(authUser);
      router.push('/admin/dashboard');
    },
    [persistUser, router]
  );

  const logout = useCallback(() => {
    window.localStorage.removeItem(SESSION_KEY);
    setUser(null);
    router.push('/login');
  }, [router]);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      isAuthenticated: Boolean(user),
      loading,
      login,
      logout
    }),
    [user, loading, login, logout]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};


