-- ============================================
-- SUPABASE SEED DATA - CHO TẤT CẢ USER
-- Tự động lấy tất cả user_id và insert dữ liệu mẫu
-- ============================================

-- File này sẽ tự động:
-- 1. Lấy tất cả user_id từ auth.users
-- 2. Insert dữ liệu mẫu cho mỗi user:
--    - Profile (nếu chưa có)
--    - 6 Hũ tài chính
--    - 2 Wallets (Vietcombank + Tiền mặt)
--    - 12 Categories (4 thu nhập + 8 chi tiêu)
--    - 1 Reminder

-- ============================================
-- INSERT PROFILES (cho tất cả user chưa có profile)
-- ============================================
INSERT INTO public.profiles (id, username, full_name, avatar_url)
SELECT 
  u.id,
  COALESCE(
    u.raw_user_meta_data->>'username',
    'user_' || substring(u.id::text, 1, 8)
  ) as username,
  COALESCE(
    u.raw_user_meta_data->>'full_name',
    split_part(u.email, '@', 1)
  ) as full_name,
  NULL as avatar_url
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = u.id
);

-- ============================================
-- INSERT 6 HŨ CHO TẤT CẢ USER
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
);

-- ============================================
-- INSERT WALLETS CHO TẤT CẢ USER
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
);

-- ============================================
-- INSERT CATEGORIES CHO TẤT CẢ USER
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
);

-- ============================================
-- INSERT REMINDERS CHO TẤT CẢ USER
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
);

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
SELECT 
  'Tổng kết dữ liệu đã tạo' as info,
  (SELECT COUNT(*) FROM public.profiles) as profiles,
  (SELECT COUNT(*) FROM public.jars) as jars,
  (SELECT COUNT(*) FROM public.wallets) as wallets,
  (SELECT COUNT(*) FROM public.categories) as categories,
  (SELECT COUNT(*) FROM public.reminders) as reminders,
  (SELECT COUNT(*) FROM auth.users) as total_users;

-- Xem chi tiết theo user:
SELECT 
  u.email,
  (SELECT COUNT(*) FROM public.profiles p WHERE p.id = u.id) as has_profile,
  (SELECT COUNT(*) FROM public.jars j WHERE j.user_id = u.id) as jar_count,
  (SELECT COUNT(*) FROM public.wallets w WHERE w.user_id = u.id) as wallet_count,
  (SELECT COUNT(*) FROM public.categories c WHERE c.user_id = u.id) as category_count
FROM auth.users u
ORDER BY u.created_at;

