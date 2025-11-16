-- ============================================
-- SUPABASE SEED DATA - 2 USERS
-- Dữ liệu mẫu cho 2 user với user_id cụ thể
-- ============================================
--
-- User 1: nhiy9130@gmail.com (UID: 72ea62e1-6e68-4797-8f11-4dc748a68682)
-- User 2: tranyennhi692491@gmail.com (UID: 4be87b2e-9314-4c28-8f10-4451107b0507)
-- ============================================

-- ============================================
-- USER IDs
-- ============================================
DO $$
DECLARE
  USER1_ID UUID := '72ea62e1-6e68-4797-8f11-4dc748a68682'::UUID;  -- nhiy9130@gmail.com
  USER2_ID UUID := '4be87b2e-9314-4c28-8f10-4451107b0507'::UUID;  -- tranyennhi692491@gmail.com
BEGIN

-- ============================================
-- INSERT PROFILES
-- ============================================
INSERT INTO public.profiles (id, username, full_name, avatar_url)
VALUES 
  (USER1_ID, 'nhiy9130', 'Người dùng 1', NULL),
  (USER2_ID, 'tranyennhi', 'Người dùng 2', NULL)
ON CONFLICT (id) DO UPDATE
SET username = EXCLUDED.username,
    full_name = EXCLUDED.full_name;

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
-- INSERT WALLETS CHO USER 1
-- ============================================
INSERT INTO public.wallets (user_id, name, type, bank_name, account_number, balance, is_active)
VALUES
  (USER1_ID, 'Vietcombank', 'BANK', 'Vietcombank', '****1234', 100000000, TRUE),
  (USER1_ID, 'Tiền mặt', 'CASH', NULL, NULL, 5000000, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT WALLETS CHO USER 2
-- ============================================
INSERT INTO public.wallets (user_id, name, type, bank_name, account_number, balance, is_active)
VALUES
  (USER2_ID, 'Vietcombank', 'BANK', 'Vietcombank', '****5678', 200000000, TRUE),
  (USER2_ID, 'Tiền mặt', 'CASH', NULL, NULL, 10000000, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT CATEGORIES CHO USER 1
-- ============================================
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
VALUES
  -- Income categories
  (USER1_ID, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981', TRUE),
  (USER1_ID, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981', TRUE),
  (USER1_ID, 'Đầu tư', 'INCOME', 'trending_up', '#10B981', TRUE),
  (USER1_ID, 'Khác', 'INCOME', 'attach_money', '#10B981', TRUE),
  -- Expense categories
  (USER1_ID, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444', TRUE),
  (USER1_ID, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444', TRUE),
  (USER1_ID, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444', TRUE),
  (USER1_ID, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B', TRUE),
  (USER1_ID, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444', TRUE),
  (USER1_ID, 'Giải trí', 'EXPENSE', 'movie', '#D2F273', TRUE),
  (USER1_ID, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444', TRUE),
  (USER1_ID, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT CATEGORIES CHO USER 2
-- ============================================
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
VALUES
  -- Income categories
  (USER2_ID, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981', TRUE),
  (USER2_ID, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981', TRUE),
  (USER2_ID, 'Đầu tư', 'INCOME', 'trending_up', '#10B981', TRUE),
  (USER2_ID, 'Khác', 'INCOME', 'attach_money', '#10B981', TRUE),
  -- Expense categories
  (USER2_ID, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444', TRUE),
  (USER2_ID, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444', TRUE),
  (USER2_ID, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444', TRUE),
  (USER2_ID, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B', TRUE),
  (USER2_ID, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444', TRUE),
  (USER2_ID, 'Giải trí', 'EXPENSE', 'movie', '#D2F273', TRUE),
  (USER2_ID, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444', TRUE),
  (USER2_ID, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT REMINDERS CHO USER 1
-- ============================================
INSERT INTO public.reminders (user_id, jar_id, title, message, is_active)
SELECT 
  USER1_ID,
  j.id,
  'Nhắc nhở tiết kiệm',
  'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
  TRUE
FROM public.jars j
WHERE j.user_id = USER1_ID AND j.slug = 'financial_freedom'
  AND NOT EXISTS (
    SELECT 1 FROM public.reminders r 
    WHERE r.user_id = USER1_ID AND r.jar_id = j.id
  )
LIMIT 1;

-- ============================================
-- INSERT REMINDERS CHO USER 2
-- ============================================
INSERT INTO public.reminders (user_id, jar_id, title, message, is_active)
SELECT 
  USER2_ID,
  j.id,
  'Nhắc nhở tiết kiệm',
  'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
  TRUE
FROM public.jars j
WHERE j.user_id = USER2_ID AND j.slug = 'financial_freedom'
  AND NOT EXISTS (
    SELECT 1 FROM public.reminders r 
    WHERE r.user_id = USER2_ID AND r.jar_id = j.id
  )
LIMIT 1;

-- ============================================
-- INSERT TRANSACTIONS MẪU CHO USER 1
-- ============================================
INSERT INTO public.transactions (user_id, wallet_id, category_id, type, amount, note, occurred_at)
SELECT 
  USER1_ID,
  (SELECT id FROM public.wallets WHERE user_id = USER1_ID AND type = 'BANK' LIMIT 1),
  c.id,
  trans_data.type,
  trans_data.amount,
  trans_data.note,
  trans_data.occurred_at
FROM public.categories c
CROSS JOIN (VALUES
  ('Lương', 'INCOME', 15000000, 'Lương tháng 12', NOW() - INTERVAL '1 day'),
  ('Ăn uống', 'EXPENSE', 150000, 'Grab Food', NOW()),
  ('Giáo dục', 'EXPENSE', 250000, 'Mua sách', NOW() - INTERVAL '2 days')
) AS trans_data(category_name, type, amount, note, occurred_at)
WHERE c.user_id = USER1_ID
  AND c.name = trans_data.category_name
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT TRANSACTIONS MẪU CHO USER 2
-- ============================================
INSERT INTO public.transactions (user_id, wallet_id, category_id, type, amount, note, occurred_at)
SELECT 
  USER2_ID,
  (SELECT id FROM public.wallets WHERE user_id = USER2_ID AND type = 'BANK' LIMIT 1),
  c.id,
  trans_data.type,
  trans_data.amount,
  trans_data.note,
  trans_data.occurred_at
FROM public.categories c
CROSS JOIN (VALUES
  ('Lương', 'INCOME', 20000000, 'Lương tháng 12', NOW() - INTERVAL '1 day'),
  ('Ăn uống', 'EXPENSE', 200000, 'Grab Food', NOW()),
  ('Mua sắm', 'EXPENSE', 500000, 'Mua quần áo', NOW() - INTERVAL '2 days')
) AS trans_data(category_name, type, amount, note, occurred_at)
WHERE c.user_id = USER2_ID
  AND c.name = trans_data.category_name
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT JAR ALLOCATIONS (Phân bổ giao dịch vào hũ)
-- ============================================
-- Phân bổ transaction INCOME vào các hũ theo percentage
INSERT INTO public.jar_allocations (jar_id, transaction_id, amount)
SELECT 
  j.id,
  t.id,
  CASE j.slug
    WHEN 'necessities' THEN t.amount * 0.55
    WHEN 'long_term_savings' THEN t.amount * 0.10
    WHEN 'education' THEN t.amount * 0.10
    WHEN 'enjoyment' THEN t.amount * 0.10
    WHEN 'financial_freedom' THEN t.amount * 0.10
    WHEN 'giving' THEN t.amount * 0.05
  END as amount
FROM public.transactions t
INNER JOIN public.jars j ON j.user_id = t.user_id
WHERE t.type = 'INCOME'
  AND NOT EXISTS (
    SELECT 1 FROM public.jar_allocations ja 
    WHERE ja.transaction_id = t.id AND ja.jar_id = j.id
  )
ON CONFLICT (jar_id, transaction_id) DO NOTHING;

END $$;

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
SELECT 
  'Tổng kết dữ liệu' as info,
  (SELECT COUNT(*) FROM public.profiles) as profiles,
  (SELECT COUNT(*) FROM public.jars) as jars,
  (SELECT COUNT(*) FROM public.wallets) as wallets,
  (SELECT COUNT(*) FROM public.categories) as categories,
  (SELECT COUNT(*) FROM public.transactions) as transactions,
  (SELECT COUNT(*) FROM public.jar_allocations) as jar_allocations,
  (SELECT COUNT(*) FROM public.reminders) as reminders;

-- Chi tiết theo user:
SELECT 
  u.email,
  (SELECT COUNT(*) FROM public.profiles p WHERE p.id = u.id) as has_profile,
  (SELECT COUNT(*) FROM public.jars j WHERE j.user_id = u.id) as jar_count,
  (SELECT COUNT(*) FROM public.wallets w WHERE w.user_id = u.id) as wallet_count,
  (SELECT COUNT(*) FROM public.categories c WHERE c.user_id = u.id) as category_count,
  (SELECT COUNT(*) FROM public.transactions t WHERE t.user_id = u.id) as transaction_count,
  (SELECT COUNT(*) FROM public.reminders r WHERE r.user_id = u.id) as reminder_count
FROM auth.users u
WHERE u.id IN ('72ea62e1-6e68-4797-8f11-4dc748a68682', '4be87b2e-9314-4c28-8f10-4451107b0507')
ORDER BY u.created_at;

