# Hướng dẫn Setup Admin Authentication

## Bước 1: Tạo Admin Users trong Supabase

1. Mở Supabase Dashboard → SQL Editor
2. Chạy script `Admin/scripts/seed_admins.sql`
3. Hoặc chạy SQL sau (thay UUID đầy đủ từ bảng `profiles`):

```sql
-- Lấy full UUID từ bảng profiles cho user "Ngọc Hân" và "SangTr"
-- Sau đó chạy:

-- Tạo admin cho user "Ngọc Hân" với role "Admin"
INSERT INTO admins (user_id, role_id)
SELECT 
  p.id as user_id,
  r.id as role_id
FROM profiles p
CROSS JOIN roles r
WHERE p.username = 'Ngọc Hân' 
  AND r.name = 'Admin'
  AND NOT EXISTS (
    SELECT 1 FROM admins a WHERE a.user_id = p.id
  );

-- Tạo admin cho user "SangTr" với role "Super_Admin"
INSERT INTO admins (user_id, role_id)
SELECT 
  p.id as user_id,
  r.id as role_id
FROM profiles p
CROSS JOIN roles r
WHERE p.username = 'SangTr' 
  AND r.name = 'Admin'
  AND NOT EXISTS (
    SELECT 1 FROM admins a WHERE a.user_id = p.id
  );
```

## Bước 2: Lấy Token từ Flutter App

1. Đăng nhập vào Flutter app với tài khoản admin (Ngọc Hân hoặc SangTr)
2. Lấy access token từ Supabase client:
   ```dart
   final session = Supabase.instance.client.auth.currentSession;
   final token = session?.accessToken;
   ```

3. Hoặc check trong Flutter DevTools → Network → Xem request headers

## Bước 3: Test Admin API

### Test với curl:

```bash
# Thay <YOUR_TOKEN> bằng token từ Flutter app
curl -X GET http://localhost:4000/api/dashboard/overview \
  -H "Authorization: Bearer <YOUR_TOKEN>"
```

### Test với Postman:

1. Method: GET
2. URL: `http://localhost:4000/api/dashboard/overview`
3. Headers:
   - Key: `Authorization`
   - Value: `Bearer <YOUR_TOKEN>`

## Bước 4: Cập nhật Frontend để gửi Token

Cần cập nhật `Admin/client/src/api/adminApi.js` để gửi token trong header:

```javascript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000/api';

// Lấy token từ localStorage hoặc từ Flutter app
const getAuthToken = () => {
  // TODO: Lấy token từ Flutter app hoặc localStorage
  return localStorage.getItem('supabase_token') || '';
};

const handleResponse = async (response) => {
  const payload = await response.json();
  if (!response.ok || payload.success === false) {
    const message = payload?.message || 'Có lỗi xảy ra khi gọi API';
    throw new Error(message);
  }
  return payload.data ?? payload;
};

const fetchWithAuth = (url, options = {}) => {
  const token = getAuthToken();
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
export const fetchExpenses = (limit = 25) => fetchWithAuth(`${API_BASE_URL}/expenses?limit=${limit}`);
export const fetchUsers = (limit = 20) => fetchWithAuth(`${API_BASE_URL}/users?limit=${limit}`);
```

## Lưu ý

- Token có thời hạn 1 giờ (3600 seconds)
- Cần refresh token khi hết hạn
- Service role key đang dùng trong backend để bypass RLS
- Tất cả routes (trừ `/demo-seed`) đều yêu cầu authentication

