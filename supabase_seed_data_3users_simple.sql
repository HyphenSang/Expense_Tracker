-- ============================================
-- SUPABASE SEED DATA - 3 USERS (SIMPLE VERSION)
-- Dữ liệu mẫu cho 3 user - Dễ sử dụng hơn
-- ============================================
--
-- HƯỚNG DẪN:
-- 1. Tạo 3 user trong Auth Dashboard:
--    - Authentication > Users > Add user
--    - User 1: user1@test.com
--    - User 2: user2@test.com  
--    - User 3: user3@test.com
--
-- 2. Chạy query này để lấy user_id:
--    SELECT id, email FROM auth.users ORDER BY created_at;
--
-- 3. Thay thế USER1_ID, USER2_ID, USER3_ID trong file này bằng user_id thực tế
--    (Tìm và thay thế tất cả - Ctrl+H trong editor)
--
-- 4. Chạy file này trong SQL Editor
-- ============================================

-- ============================================
-- THAY THẾ 3 DÒNG SAU BẰNG USER_ID THỰC TẾ
-- ============================================
-- Ví dụ: Nếu user_id là 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
-- Thì thay thành: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID

-- ⚠️ THAY THẾ 3 DÒNG NÀY:
DO $$
DECLARE
  USER1_ID UUID := 'THAY_BANG_USER_ID_1'::UUID;  -- User 1 (user)
  USER2_ID UUID := 'THAY_BANG_USER_ID_2'::UUID;  -- User 2 (admin)
  USER3_ID UUID := 'THAY_BANG_USER_ID_3'::UUID;  -- User 3 (super_admin)
BEGIN

-- ============================================
-- INSERT PROFILES
-- ============================================
INSERT INTO public.profiles (id, username, full_name, avatar_url)
VALUES 
  (USER1_ID, 'user1', 'Người Dùng 1', NULL),
  (USER2_ID, 'user2', 'Người Dùng 2', NULL),
  (USER3_ID, 'user3', 'Người Dùng 3', NULL)
ON CONFLICT (id) DO UPDATE
SET username = EXCLUDED.username,
    full_name = EXCLUDED.full_name;

-- ============================================
-- INSERT ADMIN ROLES
-- ============================================
INSERT INTO public.admins (user_id, role_id)
SELECT USER2_ID, id FROM public.roles WHERE name = 'admin'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO public.admins (user_id, role_id)
SELECT USER3_ID, id FROM public.roles WHERE name = 'super_admin'
ON CONFLICT (user_id) DO NOTHING;

-- ============================================
-- INSERT 6 HŨ CHO USER 1
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  (USER1_ID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 55000000),
  (USER1_ID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 10000000),
  (USER1_ID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 10000000),
  (USER1_ID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 10000000),
  (USER1_ID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 10000000),
  (USER1_ID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 5000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT 6 HŨ CHO USER 2
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  (USER2_ID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 110000000),
  (USER2_ID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 20000000),
  (USER2_ID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 20000000),
  (USER2_ID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 20000000),
  (USER2_ID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 20000000),
  (USER2_ID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 10000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT 6 HŨ CHO USER 3
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  (USER3_ID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 275000000),
  (USER3_ID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 50000000),
  (USER3_ID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 50000000),
  (USER3_ID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 50000000),
  (USER3_ID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 50000000),
  (USER3_ID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 25000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT WALLETS
-- ============================================
INSERT INTO public.wallets (user_id, name, type, bank_name, account_number, balance, is_active)
VALUES
  (USER1_ID, 'Vietcombank', 'BANK', 'Vietcombank', '****1234', 100000000, TRUE),
  (USER1_ID, 'Tiền mặt', 'CASH', NULL, NULL, 5000000, TRUE),
  (USER2_ID, 'Vietcombank', 'BANK', 'Vietcombank', '****5678', 200000000, TRUE),
  (USER2_ID, 'Tiền mặt', 'CASH', NULL, NULL, 10000000, TRUE),
  (USER3_ID, 'Vietcombank', 'BANK', 'Vietcombank', '****9012', 500000000, TRUE),
  (USER3_ID, 'Tiền mặt', 'CASH', NULL, NULL, 25000000, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT CATEGORIES (cho cả 3 user)
-- ============================================
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
SELECT user_id, name, type, icon, color, TRUE
FROM (VALUES
  (USER1_ID, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  (USER1_ID, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  (USER1_ID, 'Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  (USER1_ID, 'Khác', 'INCOME', 'attach_money', '#10B981'),
  (USER1_ID, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  (USER1_ID, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  (USER1_ID, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  (USER1_ID, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  (USER1_ID, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  (USER1_ID, 'Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  (USER1_ID, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  (USER1_ID, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF'),
  (USER2_ID, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  (USER2_ID, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  (USER2_ID, 'Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  (USER2_ID, 'Khác', 'INCOME', 'attach_money', '#10B981'),
  (USER2_ID, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  (USER2_ID, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  (USER2_ID, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  (USER2_ID, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  (USER2_ID, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  (USER2_ID, 'Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  (USER2_ID, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  (USER2_ID, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF'),
  (USER3_ID, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  (USER3_ID, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  (USER3_ID, 'Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  (USER3_ID, 'Khác', 'INCOME', 'attach_money', '#10B981'),
  (USER3_ID, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  (USER3_ID, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  (USER3_ID, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  (USER3_ID, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  (USER3_ID, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  (USER3_ID, 'Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  (USER3_ID, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  (USER3_ID, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF')
) AS cat_data(user_id, name, type, icon, color)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT REMINDERS
-- ============================================
INSERT INTO public.reminders (user_id, jar_id, title, message, is_active)
SELECT 
  u.id,
  j.id,
  'Nhắc nhở tiết kiệm',
  'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
  TRUE
FROM (VALUES (USER1_ID), (USER2_ID), (USER3_ID)) AS user_ids(user_id)
CROSS JOIN auth.users u ON u.id = user_ids.user_id
INNER JOIN public.jars j ON j.user_id = u.id AND j.slug = 'financial_freedom'
WHERE NOT EXISTS (
  SELECT 1 FROM public.reminders r 
  WHERE r.user_id = u.id AND r.jar_id = j.id
);

END $$;

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
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

