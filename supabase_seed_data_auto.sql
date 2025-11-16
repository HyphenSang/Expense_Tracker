-- ============================================
-- SUPABASE SEED DATA - AUTO VERSION
-- Tự động lấy user_id đầu tiên và insert dữ liệu mẫu
-- ============================================

-- Lưu ý: File này sẽ tự động lấy user_id đầu tiên từ auth.users
-- Nếu bạn có nhiều user, nên dùng file supabase_seed_data.sql và chỉ định user_id cụ thể

-- ============================================
-- INSERT PROFILE (nếu chưa có)
-- ============================================
INSERT INTO public.profiles (id, username, full_name, avatar_url)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'username', 'user_' || substring(id::text, 1, 8)),
  COALESCE(raw_user_meta_data->>'full_name', 'Người Dùng'),
  NULL
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles)
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET username = COALESCE(EXCLUDED.username, profiles.username),
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name);

-- ============================================
-- INSERT 6 HŨ MẶC ĐỊNH
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
SELECT 
  u.id,
  jar_data.name,
  jar_data.slug,
  jar_data.percentage,
  jar_data.icon,
  jar_data.color,
  jar_data.description,
  jar_data.balance
FROM auth.users u
CROSS JOIN (VALUES
  ('Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 55000000),
  ('Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 10000000),
  ('Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 10000000),
  ('Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 10000000),
  ('Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 10000000),
  ('Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 5000000)
) AS jar_data(name, slug, percentage, icon, color, description, balance)
WHERE NOT EXISTS (
  SELECT 1 FROM public.jars j 
  WHERE j.user_id = u.id AND j.slug = jar_data.slug
)
LIMIT 6;

-- ============================================
-- INSERT WALLET (Ví/Tài khoản ngân hàng)
-- ============================================
INSERT INTO public.wallets (user_id, name, type, bank_name, account_number, balance, is_active)
SELECT 
  u.id,
  wallet_data.name,
  wallet_data.type,
  wallet_data.bank_name,
  wallet_data.account_number,
  wallet_data.balance,
  TRUE
FROM auth.users u
CROSS JOIN (VALUES
  ('Vietcombank', 'BANK', 'Vietcombank', '****1234', 100000000),
  ('Tiền mặt', 'CASH', NULL, NULL, 5000000)
) AS wallet_data(name, type, bank_name, account_number, balance)
WHERE NOT EXISTS (
  SELECT 1 FROM public.wallets w 
  WHERE w.user_id = u.id AND w.name = wallet_data.name
)
LIMIT 2;

-- ============================================
-- INSERT CATEGORIES MẶC ĐỊNH
-- ============================================
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
SELECT 
  u.id,
  cat_data.name,
  cat_data.type,
  cat_data.icon,
  cat_data.color,
  TRUE
FROM auth.users u
CROSS JOIN (VALUES
  -- Income categories
  ('Lương', 'INCOME', 'account_balance_wallet', '#10B981'),
  ('Thưởng', 'INCOME', 'card_giftcard', '#10B981'),
  ('Đầu tư', 'INCOME', 'trending_up', '#10B981'),
  ('Khác', 'INCOME', 'attach_money', '#10B981'),
  -- Expense categories
  ('Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
  ('Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444'),
  ('Di chuyển', 'EXPENSE', 'directions_car', '#EF4444'),
  ('Giáo dục', 'EXPENSE', 'school', '#F59E0B'),
  ('Y tế', 'EXPENSE', 'local_hospital', '#EF4444'),
  ('Giải trí', 'EXPENSE', 'movie', '#D2F273'),
  ('Hóa đơn', 'EXPENSE', 'receipt', '#EF4444'),
  ('Khác', 'EXPENSE', 'more_horiz', '#9CA3AF')
) AS cat_data(name, type, icon, color)
WHERE NOT EXISTS (
  SELECT 1 FROM public.categories c 
  WHERE c.user_id = u.id AND c.name = cat_data.name AND c.type = cat_data.type
)
LIMIT 12;

-- ============================================
-- INSERT REMINDER MẪU
-- ============================================
INSERT INTO public.reminders (user_id, jar_id, title, message, is_active)
SELECT 
  u.id,
  j.id,
  'Nhắc nhở tiết kiệm',
  'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
  TRUE
FROM auth.users u
INNER JOIN public.jars j ON j.user_id = u.id AND j.slug = 'financial_freedom'
WHERE NOT EXISTS (
  SELECT 1 FROM public.reminders r 
  WHERE r.user_id = u.id AND r.jar_id = j.id
)
LIMIT 1;

-- ============================================
-- INSERT TRANSACTIONS MẪU (Tùy chọn)
-- ============================================
-- Uncomment phần này nếu muốn có transactions mẫu
/*
INSERT INTO public.transactions (user_id, wallet_id, category_id, type, amount, note, occurred_at)
SELECT 
  u.id,
  w.id,
  c.id,
  trans_data.type,
  trans_data.amount,
  trans_data.note,
  trans_data.occurred_at
FROM auth.users u
CROSS JOIN LATERAL (
  SELECT id FROM public.wallets WHERE user_id = u.id AND type = 'BANK' LIMIT 1
) w
CROSS JOIN LATERAL (
  SELECT id FROM public.categories WHERE user_id = u.id AND name = trans_data.category_name LIMIT 1
) c
CROSS JOIN (VALUES
  ('Lương', 'INCOME', 15000000, 'Lương tháng 12', NOW() - INTERVAL '1 day'),
  ('Ăn uống', 'EXPENSE', 150000, 'Grab Food', NOW()),
  ('Giáo dục', 'EXPENSE', 250000, 'Mua sách', NOW() - INTERVAL '2 days')
) AS trans_data(category_name, type, amount, note, occurred_at)
WHERE w.id IS NOT NULL AND c.id IS NOT NULL
LIMIT 3;
*/

-- ============================================
-- XEM KẾT QUẢ
-- ============================================
-- Chạy query này để xem dữ liệu đã được insert:
-- SELECT 'profiles' as table_name, COUNT(*) as count FROM public.profiles
-- UNION ALL
-- SELECT 'jars', COUNT(*) FROM public.jars
-- UNION ALL
-- SELECT 'wallets', COUNT(*) FROM public.wallets
-- UNION ALL
-- SELECT 'categories', COUNT(*) FROM public.categories
-- UNION ALL
-- SELECT 'reminders', COUNT(*) FROM public.reminders;

