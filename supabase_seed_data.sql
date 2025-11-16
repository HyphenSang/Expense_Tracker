-- ============================================
-- SUPABASE SEED DATA
-- Dữ liệu mẫu để test
-- LƯU Ý: Thay thế USER_ID_HERE bằng user_id thực tế từ auth.users
-- ============================================

-- Bước 1: Lấy user_id từ auth.users
-- Chạy query này trong SQL Editor để lấy user_id:
-- SELECT id, email FROM auth.users;

-- Bước 2: Thay thế 'USER_ID_HERE' trong file này bằng user_id thực tế
-- Sau đó chạy file này trong SQL Editor

-- ============================================
-- INSERT PROFILE (nếu chưa có)
-- ============================================
-- Thay 'USER_ID_HERE' bằng user_id từ auth.users
INSERT INTO public.profiles (id, username, full_name, avatar_url)
VALUES (
  'USER_ID_HERE'::UUID,  -- Thay bằng user_id thực tế
  'testuser',
  'Người Dùng Test',
  NULL
)
ON CONFLICT (id) DO UPDATE
SET username = EXCLUDED.username,
    full_name = EXCLUDED.full_name;

-- ============================================
-- INSERT 6 HŨ MẶC ĐỊNH
-- ============================================
INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description, balance)
VALUES
  ('USER_ID_HERE'::UUID, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày', 55000000),
  ('USER_ID_HERE'::UUID, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn', 10000000),
  ('USER_ID_HERE'::UUID, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân', 10000000),
  ('USER_ID_HERE'::UUID, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ', 10000000),
  ('USER_ID_HERE'::UUID, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính', 10000000),
  ('USER_ID_HERE'::UUID, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác', 5000000)
ON CONFLICT (user_id, slug) DO NOTHING;

-- ============================================
-- INSERT WALLET (Ví/Tài khoản ngân hàng)
-- ============================================
INSERT INTO public.wallets (user_id, name, type, bank_name, account_number, balance, is_active)
VALUES
  ('USER_ID_HERE'::UUID, 'Vietcombank', 'BANK', 'Vietcombank', '****1234', 100000000, TRUE),
  ('USER_ID_HERE'::UUID, 'Tiền mặt', 'CASH', NULL, NULL, 5000000, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT CATEGORIES MẶC ĐỊNH
-- ============================================
INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
VALUES
  -- Income categories
  ('USER_ID_HERE'::UUID, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981', TRUE),
  ('USER_ID_HERE'::UUID, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981', TRUE),
  ('USER_ID_HERE'::UUID, 'Đầu tư', 'INCOME', 'trending_up', '#10B981', TRUE),
  ('USER_ID_HERE'::UUID, 'Khác', 'INCOME', 'attach_money', '#10B981', TRUE),
  -- Expense categories
  ('USER_ID_HERE'::UUID, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444', TRUE),
  ('USER_ID_HERE'::UUID, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444', TRUE),
  ('USER_ID_HERE'::UUID, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444', TRUE),
  ('USER_ID_HERE'::UUID, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B', TRUE),
  ('USER_ID_HERE'::UUID, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444', TRUE),
  ('USER_ID_HERE'::UUID, 'Giải trí', 'EXPENSE', 'movie', '#D2F273', TRUE),
  ('USER_ID_HERE'::UUID, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444', TRUE),
  ('USER_ID_HERE'::UUID, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSERT TRANSACTIONS MẪU
-- ============================================
-- Lưu ý: Cần có wallet_id và category_id trước
-- Lấy wallet_id và category_id từ các bảng trên

-- Ví dụ: Insert transaction thu nhập
-- Thay WALLET_ID_HERE và CATEGORY_ID_HERE bằng id thực tế
/*
INSERT INTO public.transactions (user_id, wallet_id, category_id, type, amount, note, occurred_at)
VALUES
  (
    'USER_ID_HERE'::UUID,
    (SELECT id FROM public.wallets WHERE user_id = 'USER_ID_HERE'::UUID AND type = 'BANK' LIMIT 1),
    (SELECT id FROM public.categories WHERE user_id = 'USER_ID_HERE'::UUID AND name = 'Lương' LIMIT 1),
    'INCOME',
    15000000,
    'Lương tháng 12',
    NOW() - INTERVAL '1 day'
  ),
  (
    'USER_ID_HERE'::UUID,
    (SELECT id FROM public.wallets WHERE user_id = 'USER_ID_HERE'::UUID AND type = 'BANK' LIMIT 1),
    (SELECT id FROM public.categories WHERE user_id = 'USER_ID_HERE'::UUID AND name = 'Ăn uống' LIMIT 1),
    'EXPENSE',
    150000,
    'Grab Food',
    NOW()
  ),
  (
    'USER_ID_HERE'::UUID,
    (SELECT id FROM public.wallets WHERE user_id = 'USER_ID_HERE'::UUID AND type = 'BANK' LIMIT 1),
    (SELECT id FROM public.categories WHERE user_id = 'USER_ID_HERE'::UUID AND name = 'Giáo dục' LIMIT 1),
    'EXPENSE',
    250000,
    'Mua sách',
    NOW() - INTERVAL '2 days'
  );
*/

-- ============================================
-- INSERT REMINDER MẪU
-- ============================================
INSERT INTO public.reminders (user_id, jar_id, title, message, is_active)
VALUES
  (
    'USER_ID_HERE'::UUID,
    (SELECT id FROM public.jars WHERE user_id = 'USER_ID_HERE'::UUID AND slug = 'financial_freedom' LIMIT 1),
    'Nhắc nhở tiết kiệm',
    'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
    TRUE
  )
ON CONFLICT DO NOTHING;

-- ============================================
-- HƯỚNG DẪN SỬ DỤNG:
-- ============================================
-- 1. Mở Supabase Dashboard > SQL Editor
-- 2. Chạy query này để lấy user_id:
--    SELECT id, email, created_at FROM auth.users;
-- 3. Copy user_id và thay thế tất cả 'USER_ID_HERE' trong file này
-- 4. Chạy lại file này trong SQL Editor
-- 5. Kiểm tra dữ liệu trong Table Editor

