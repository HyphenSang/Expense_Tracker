const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000/api';

/**
 * Lấy token từ localStorage hoặc từ URL params
 * Token có thể được lưu khi login từ Flutter app
 * Export để dùng trong ProtectedRoute
 */
export const getAuthToken = () => {
  // Lấy từ localStorage (nếu Flutter app đã lưu)
  const tokenFromStorage = localStorage.getItem('supabase_access_token');
  if (tokenFromStorage) return tokenFromStorage;

  // Lấy từ URL params (nếu redirect từ Flutter app với token)
  const urlParams = new URLSearchParams(window.location.search);
  const tokenFromUrl = urlParams.get('token');
  if (tokenFromUrl) {
    localStorage.setItem('supabase_access_token', tokenFromUrl);
    // Xóa token khỏi URL để bảo mật
    window.history.replaceState({}, document.title, window.location.pathname);
    return tokenFromUrl;
  }

  return null;
};

const handleResponse = async (response) => {
  const payload = await response.json();
  if (!response.ok || payload.success === false) {
    const message = payload?.message || 'Có lỗi xảy ra khi gọi API';
    
    // Nếu lỗi 401, xóa token và redirect về login
    if (response.status === 401) {
      localStorage.removeItem('supabase_access_token');
      // TODO: Redirect về login page hoặc hiển thị thông báo
      throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }
    
    throw new Error(message);
  }
  return payload.data ?? payload;
};

/**
 * Fetch với authentication header
 */
const fetchWithAuth = (url, options = {}) => {
  const token = getAuthToken();
  
  if (!token) {
    return Promise.reject(new Error('Chưa đăng nhập. Vui lòng đăng nhập từ Flutter app trước.'));
  }

  return fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...options.headers,
    },
  }).then(handleResponse);
};

export const fetchOverview = () => fetchWithAuth(`${API_BASE_URL}/dashboard/overview`);

export const fetchCategoryBreakdown = () => fetchWithAuth(`${API_BASE_URL}/dashboard/category-breakdown`);

export const fetchExpenses = (limit = 25) =>
  fetchWithAuth(`${API_BASE_URL}/expenses?limit=${limit}`);

export const fetchUsers = (limit = 20) => fetchWithAuth(`${API_BASE_URL}/users?limit=${limit}`);

export const createExpense = (payload) =>
  fetchWithAuth(`${API_BASE_URL}/expenses`, {
    method: 'POST',
    body: JSON.stringify(payload),
  });

/**
 * Set token từ Flutter app (có thể gọi từ window hoặc localStorage)
 */
export const setAuthToken = (token) => {
  if (token) {
    localStorage.setItem('supabase_access_token', token);
  } else {
    localStorage.removeItem('supabase_access_token');
  }
};

/**
 * Logout - Xóa token và clear authentication
 */
export const logout = async () => {
  // Xóa token từ localStorage
  localStorage.removeItem('supabase_access_token');
  
  // Xóa Supabase session (nếu có)
  const { supabaseClient } = await import('../lib/supabaseClient');
  if (supabaseClient) {
    await supabaseClient.auth.signOut();
  }
};

