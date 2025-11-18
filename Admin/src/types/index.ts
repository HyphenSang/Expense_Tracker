export type User = {
  id: string;
  username: string;
  email: string;
};

export type AuthResponse = {
  success: boolean;
  token?: string;
  message?: string;
};

export type LoginCredentials = {
  username: string;
  password: string;
};