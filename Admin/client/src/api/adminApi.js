const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000/api';

const handleResponse = async (response) => {
  const payload = await response.json();
  if (!response.ok || payload.success === false) {
    const message = payload?.message || 'Có lỗi xảy ra khi gọi API';
    throw new Error(message);
  }
  return payload.data ?? payload;
};

export const fetchOverview = () => fetch(`${API_BASE_URL}/dashboard/overview`).then(handleResponse);

export const fetchCategoryBreakdown = () => fetch(`${API_BASE_URL}/dashboard/category-breakdown`).then(handleResponse);

export const fetchExpenses = (limit = 25) =>
  fetch(`${API_BASE_URL}/expenses?limit=${limit}`).then(handleResponse);

export const fetchUsers = (limit = 20) => fetch(`${API_BASE_URL}/users?limit=${limit}`).then(handleResponse);

export const createExpense = (payload) =>
  fetch(`${API_BASE_URL}/expenses`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  }).then(handleResponse);

