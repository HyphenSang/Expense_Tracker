-- ============================================
-- SETUP ADMIN ROLES - AUTO VERSION
-- Tự động lấy 2 user đầu tiên và gán role
-- User 1 → admin
-- User 2 → user thường
-- ============================================

-- ============================================
-- INSERT ADMIN CHO USER ĐẦU TIÊN
-- ============================================
INSERT INTO public.admins (user_id, role_id)
SELECT 
  u.id,
  r.id
FROM auth.users u
CROSS JOIN public.roles r
WHERE r.name = 'admin'
  AND u.id = (
    SELECT id FROM auth.users 
    ORDER BY created_at 
    LIMIT 1
  )
ON CONFLICT (user_id) DO UPDATE
SET role_id = (SELECT id FROM public.roles WHERE name = 'admin');

-- ============================================
-- ĐẢM BẢO USER THỨ 2 KHÔNG PHẢI ADMIN
-- ============================================
DELETE FROM public.admins 
WHERE user_id = (
  SELECT id FROM auth.users 
  ORDER BY created_at 
  OFFSET 1 
  LIMIT 1
);

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
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

