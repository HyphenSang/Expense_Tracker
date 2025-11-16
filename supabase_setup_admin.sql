-- ============================================
-- SETUP ADMIN ROLES
-- Gán user đầu tiên làm admin, user thứ hai làm user thường
-- ============================================

-- Bước 1: Lấy user_id của 2 user đầu tiên
-- Chạy query này để xem user_id:
-- SELECT id, email FROM auth.users ORDER BY created_at LIMIT 2;

-- Bước 2: Thay thế USER1_ID và USER2_ID trong file này bằng user_id thực tế
-- Bước 3: Chạy file này trong SQL Editor

-- ============================================
-- THAY THẾ 2 DÒNG SAU BẰNG USER_ID THỰC TẾ
-- ============================================
-- User 1: nhiy9130@gmail.com → làm admin
-- User 2: tranyennhi692491@gmail.com → làm user thường

DO $$
DECLARE
  USER1_ID UUID := 'THAY_BANG_USER_ID_1'::UUID;  -- nhiy9130@gmail.com (sẽ làm admin)
  USER2_ID UUID := 'THAY_BANG_USER_ID_2'::UUID;  -- tranyennhi692491@gmail.com (user thường)
BEGIN

-- ============================================
-- INSERT ADMIN CHO USER 1
-- ============================================
INSERT INTO public.admins (user_id, role_id)
SELECT USER1_ID, id FROM public.roles WHERE name = 'admin'
ON CONFLICT (user_id) DO UPDATE
SET role_id = (SELECT id FROM public.roles WHERE name = 'admin');

-- ============================================
-- ĐẢM BẢO USER 2 KHÔNG PHẢI ADMIN
-- ============================================
-- Xóa user 2 khỏi bảng admins nếu có
DELETE FROM public.admins WHERE user_id = USER2_ID;

END $$;

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
-- Chạy query này để xem kết quả:
SELECT 
  u.email,
  u.id as user_id,
  r.name as role_name,
  CASE WHEN a.id IS NOT NULL THEN 'Admin' ELSE 'User' END as user_type
FROM auth.users u
LEFT JOIN public.admins a ON a.user_id = u.id
LEFT JOIN public.roles r ON r.id = a.role_id
ORDER BY u.created_at
LIMIT 2;

