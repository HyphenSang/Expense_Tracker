-- ============================================
-- SUPABASE SEED DATA - 3 USERS
-- Dữ liệu mẫu cho 3 user với 3 role khác nhau
-- ============================================
-- 
-- BƯỚC 1: Tạo 3 user trong Auth Dashboard trước
-- Authentication > Users > Add user
-- 
-- User 1: user1@test.com (role: user)
-- User 2: user2@test.com (role: admin)  
-- User 3: user3@test.com (role: super_admin)
--
-- BƯỚC 2: Lấy user_id bằng query:
-- SELECT id, email FROM auth.users ORDER BY created_at;
--
-- BƯỚC 3: Thay thế USER1_ID, USER2_ID, USER3_ID trong file này
-- BƯỚC 4: Chạy file này trong SQL Editor
-- ============================================

-- ============================================
-- THAY THẾ CÁC USER_ID SAU BẰNG ID THỰC TẾ
-- ============================================
-- Chạy query này để lấy user_id:
-- SELECT id, email FROM auth.users ORDER BY created_at;
-- 
-- Sau đó thay thế:
-- USER1_ID = user_id của user đầu tiên
-- USER2_ID = user_id của user thứ hai
-- USER3_ID = user_id của user thứ ba

-- Ví dụ (thay bằng user_id thực tế của bạn):
\set USER1_ID '00000000-0000-0000-0000-000000000001'::UUID
\set USER2_ID '00000000-0000-0000-0000-000000000002'::UUID
\set USER3_ID '00000000-0000-0000-0000-000000000003'::UUID

-- Nếu dùng Supabase SQL Editor, thay \set bằng:
-- Thay tất cả :USER1_ID bằng user_id thực tế (dạng UUID)
-- Thay tất cả :USER2_ID bằng user_id thực tế
-- Thay tất cả :USER3_ID bằng user_id thực tế

-- ============================================
-- INSERT PROFILES CHO 3 USER
-- ============================================
INSERT INTO public.profiles (id, username, full_name, avatar_url)
VALUES 
  ('USER1_ID'::UUID, 'user1', 'Người Dùng 1', NULL),
  ('USER2_ID'::UUID, 'user2', 'Người Dùng 2', NULL),
  ('USER3_ID'::UUID, 'user3', 'Người Dùng 3', NULL)
ON CONFLICT (id) DO UPDATE
SET username = EXCLUDED.username,
    full_name = EXCLUDED.full_name;

-- ============================================
-- INSERT ADMIN ROLES
-- ============================================
-- Lấy role_id từ bảng roles
INSERT INTO public.admins (user_id, role_id)
SELECT 
  u.id,
  r.id
FROM (VALUES 
  ('USER2_ID'::UUID, 'admin'),
  ('USER3_ID'::UUID, 'super_admin')
) AS user_roles(user_id, role_name)
CROSS JOIN auth.users u ON u.id = user_roles.user_id
CROSS JOIN public.roles r ON r.name = user_roles.role_name
WHERE NOT EXISTS (
  SELECT 1 FROM public.admins a WHERE a.user_id = u.id
);

-- ============================================
-- INSERT 6 HŨ CHO USER 1
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  ('USER1_ID'::UUID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 55000000),
  ('USER1_ID'::UUID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 10000000),
  ('USER1_ID'::UUID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 10000000),
  ('USER1_ID'::UUID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 10000000),
  ('USER1_ID'::UUID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 10000000),
  ('USER1_ID'::UUID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 5000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT 6 HŨ CHO USER 2
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  ('USER2_ID'::UUID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 110000000),
  ('USER2_ID'::UUID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 20000000),
  ('USER2_ID'::UUID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 20000000),
  ('USER2_ID'::UUID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 20000000),
  ('USER2_ID'::UUID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 20000000),
  ('USER2_ID'::UUID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 10000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT 6 HŨ CHO USER 3
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  ('USER3_ID'::UUID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 275000000),
  ('USER3_ID'::UUID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 50000000),
  ('USER3_ID'::UUID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 50000000),
  ('USER3_ID'::UUID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 50000000),
  ('USER3_ID'::UUID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 50000000),
  ('USER3_ID'::UUID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 25000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT WALLETS CHO 3 USER
-- ============================================
INSERT INTO public.wallets (user_id, name, type, bank_name, account_number, balance, is_active)
VALUES
  -- User 1
  ('USER1_ID'::UUID, 'Vietcombank', 'BANK', 'Vietcombank', '****1234', 100000000, TRUE),
  ('USER1_ID'::UUID, 'Tiền mặt', 'CASH', NULL, NULL, 5000000, TRUE),
  -- User 2
  ('USER2_ID'::UUID, 'Vietcombank', 'BANK', 'Vietcombank', '****5678', 200000000, TRUE),
  ('USER2_ID'::UUID, 'Tiền mặt', 'CASH', NULL, NULL, 10000000, TRUE),
  -- User 3
  ('USER3_ID'::UUID, 'Vietcombank', 'BANK', 'Vietcombank', '****9012', 500000000, TRUE),
  ('USER3_ID'::UUID, 'Tiền mặt', 'CASH', NULL, NULL, 25000000, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT CATEGORIES CHO 3 USER
-- ============================================
-- User 1
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
SELECT 'USER1_ID'::UUID, name, type, icon, color, TRUE
FROM (VALUES
  ('Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  ('Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  ('Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  ('Khác', 'INCOME', 'attach_money', '#10B981'),
  ('Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  ('Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  ('Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  ('Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  ('Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  ('Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  ('Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  ('Khác', 'EXPENSE', 'more_horiz', '#9CA3AF')
) AS cat_data(name, type, icon, color)
ON CONFLICT DO NOTHING;

-- User 2
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
SELECT 'USER2_ID'::UUID, name, type, icon, color, TRUE
FROM (VALUES
  ('Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  ('Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  ('Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  ('Khác', 'INCOME', 'attach_money', '#10B981'),
  ('Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  ('Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  ('Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  ('Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  ('Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  ('Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  ('Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  ('Khác', 'EXPENSE', 'more_horiz', '#9CA3AF')
) AS cat_data(name, type, icon, color)
ON CONFLICT DO NOTHING;

-- User 3
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
SELECT 'USER3_ID'::UUID, name, type, icon, color, TRUE
FROM (VALUES
  ('Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  ('Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  ('Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  ('Khác', 'INCOME', 'attach_money', '#10B981'),
  ('Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  ('Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  ('Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  ('Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  ('Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  ('Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  ('Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  ('Khác', 'EXPENSE', 'more_horiz', '#9CA3AF')
) AS cat_data(name, type, icon, color)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT REMINDERS CHO 3 USER
-- ============================================
INSERT INTO public.reminders (user_id, jar_id, title, message, is_active)
SELECT 
  u.id,
  j.id,
  'Nhắc nhở tiết kiệm',
  'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
  TRUE
FROM (VALUES 
  ('USER1_ID'::UUID),
  ('USER2_ID'::UUID),
  ('USER3_ID'::UUID)
) AS user_ids(user_id)
CROSS JOIN auth.users u ON u.id = user_ids.user_id
INNER JOIN public.jars j ON j.user_id = u.id AND j.slug = 'financial_freedom'
WHERE NOT EXISTS (
  SELECT 1 FROM public.reminders r 
  WHERE r.user_id = u.id AND r.jar_id = j.id
);

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
-- Chạy query này để xem tổng kết:
/*
SELECT 
  'profiles' as table_name, COUNT(*) as count FROM public.profiles
UNION ALL
SELECT 'admins', COUNT(*) FROM public.admins
UNION ALL
SELECT 'jars', COUNT(*) FROM public.jars
UNION ALL
SELECT 'wallets', COUNT(*) FROM public.wallets
UNION ALL
SELECT 'categories', COUNT(*) FROM public.categories
UNION ALL
SELECT 'reminders', COUNT(*) FROM public.reminders;
*/

