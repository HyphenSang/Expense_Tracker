const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000/api';

/**
 * Lấy token từ Supabase session (ưu tiên) hoặc localStorage
 * Export để dùng trong ProtectedRoute
 */
export const getAuthToken = async () => {
  // Ưu tiên: Lấy từ Supabase session (Supabase client tự động quản lý)
  try {
    const { supabaseClient } = await import('../lib/supabaseClient');
    if (supabaseClient) {
      const { data: { session } } = await supabaseClient.auth.getSession();
      if (session?.access_token) {
        return session.access_token;
      }
    }
  } catch (error) {
    console.warn('Không thể lấy token từ Supabase session:', error);
  }

  // Fallback: Lấy từ localStorage (nếu Flutter app đã lưu)
  const tokenFromStorage = localStorage.getItem('supabase_access_token');
  if (tokenFromStorage) return tokenFromStorage;

  // Fallback: Lấy từ URL params (nếu redirect từ Flutter app với token)
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
 * Tự động lấy token từ Supabase session
 */
const fetchWithAuth = async (url, options = {}) => {
  const token = await getAuthToken();
  
  // Tạm thời không bắt buộc token - gọi trực tiếp từ Supabase
  // if (!token) {
  //   return Promise.reject(new Error('Chưa đăng nhập. Vui lòng đăng nhập từ Flutter app trước.'));
  // }

  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  // Chỉ thêm Authorization header nếu có token
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  return fetch(url, {
    ...options,
    headers,
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
 * Set token từ Flutter app (fallback - chỉ dùng khi cần)
 * Supabase client tự động quản lý token, không cần lưu thủ công
 */
export const setAuthToken = (token) => {
  // Chỉ lưu vào localStorage như fallback (nếu Supabase session không có)
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
  // Xóa Supabase session (sẽ tự động xóa token)
  const { supabaseClient } = await import('../lib/supabaseClient');
  if (supabaseClient) {
    await supabaseClient.auth.signOut();
  }
  
  // Xóa token từ localStorage (fallback)
  localStorage.removeItem('supabase_access_token');
};

