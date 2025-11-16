-- ============================================
-- SUPABASE DATABASE SCHEMA - IMPORT FILE
-- App Quản Lý Tài Chính 6 Hũ Chi Tiêu
-- File này dùng để import vào Supabase Table Editor
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PROFILES TABLE
-- Mapping với auth.users
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. ROLES TABLE
-- Quản lý vai trò trong hệ thống
-- ============================================
CREATE TABLE IF NOT EXISTS public.roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default roles (chỉ insert nếu chưa có)
INSERT INTO public.roles (name)
SELECT 'user' WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'user')
UNION ALL
SELECT 'admin' WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'admin')
UNION ALL
SELECT 'super_admin' WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'super_admin');

-- ============================================
-- 3. ADMIN TABLE
-- Kế thừa user_id, role_id và created_at
-- ============================================
CREATE TABLE IF NOT EXISTS public.admins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- ============================================
-- 4. WALLETS TABLE
-- Quản lý các ví/tài khoản ngân hàng
-- ============================================
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('CASH', 'BANK', 'CARD', 'EWALLET')),
  bank_name TEXT,
  account_number TEXT,
  balance NUMERIC(14, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 5. CATEGORIES TABLE
-- Phân loại thu nhập và chi tiêu
-- ============================================
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('INCOME', 'EXPENSE')),
  icon TEXT,
  color TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 6. JARS TABLE
-- 6 Hũ Tài Chính theo phương pháp JARS
-- ============================================
CREATE TABLE IF NOT EXISTS public.jars (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  percentage INTEGER NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
  target_amount NUMERIC(14, 2),
  balance NUMERIC(14, 2) DEFAULT 0,
  icon TEXT,
  color TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, slug)
);

-- ============================================
-- 7. TRANSACTIONS TABLE
-- Giao dịch thu chi
-- ============================================
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  type TEXT NOT NULL CHECK (type IN ('INCOME', 'EXPENSE')),
  amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
  note TEXT,
  occurred_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 8. JAR_ALLOCATIONS TABLE
-- Phân bổ giao dịch vào các hũ
-- ============================================
CREATE TABLE IF NOT EXISTS public.jar_allocations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jar_id UUID NOT NULL REFERENCES public.jars(id) ON DELETE CASCADE,
  transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  amount NUMERIC(14, 2) NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(jar_id, transaction_id)
);

-- ============================================
-- 9. BUDGETS TABLE
-- Ngân sách theo category hoặc jar
-- ============================================
CREATE TABLE IF NOT EXISTS public.budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  jar_id UUID REFERENCES public.jars(id) ON DELETE SET NULL,
  period TEXT NOT NULL DEFAULT 'MONTHLY' CHECK (period IN ('WEEKLY', 'MONTHLY', 'YEARLY')),
  limit_amount NUMERIC(14, 2) NOT NULL CHECK (limit_amount > 0),
  spent_amount NUMERIC(14, 2) DEFAULT 0,
  start_date DATE NOT NULL,
  end_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (
    (category_id IS NOT NULL AND jar_id IS NULL) OR
    (category_id IS NULL AND jar_id IS NOT NULL)
  )
);

-- ============================================
-- 10. REMINDERS TABLE
-- Nhắc nhở tài chính
-- ============================================
CREATE TABLE IF NOT EXISTS public.reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  jar_id UUID REFERENCES public.jars(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 11. ATTACHMENTS TABLE
-- File đính kèm cho giao dịch
-- ============================================
CREATE TABLE IF NOT EXISTS public.attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT,
  file_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- Tối ưu hiệu suất truy vấn
-- ============================================
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(id);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username) WHERE username IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_admins_user_id ON public.admins(user_id);
CREATE INDEX IF NOT EXISTS idx_admins_role_id ON public.admins(role_id);
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON public.wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON public.categories(type);
CREATE INDEX IF NOT EXISTS idx_jars_user_id ON public.jars(user_id);
CREATE INDEX IF NOT EXISTS idx_jars_slug ON public.jars(slug);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON public.transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_occurred_at ON public.transactions(occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_jar_allocations_jar_id ON public.jar_allocations(jar_id);
CREATE INDEX IF NOT EXISTS idx_jar_allocations_transaction_id ON public.jar_allocations(transaction_id);
CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON public.budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_category_id ON public.budgets(category_id);
CREATE INDEX IF NOT EXISTS idx_budgets_jar_id ON public.budgets(jar_id);
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON public.reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_jar_id ON public.reminders(jar_id);
CREATE INDEX IF NOT EXISTS idx_reminders_is_active ON public.reminders(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_attachments_transaction_id ON public.attachments(transaction_id);

-- ============================================
-- TRIGGERS
-- Tự động cập nhật updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_wallets_updated_at ON public.wallets;
CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON public.wallets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_categories_updated_at ON public.categories;
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_jars_updated_at ON public.jars;
CREATE TRIGGER update_jars_updated_at BEFORE UPDATE ON public.jars
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_transactions_updated_at ON public.transactions;
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_budgets_updated_at ON public.budgets;
CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON public.budgets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_reminders_updated_at ON public.reminders;
CREATE TRIGGER update_reminders_updated_at BEFORE UPDATE ON public.reminders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Bảo mật dữ liệu theo user
-- ============================================

-- Enable RLS cho tất cả các bảng
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jar_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (để tránh lỗi khi chạy lại)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all admins" ON public.admins;
DROP POLICY IF EXISTS "Users can view own wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can insert own wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can update own wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can delete own wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can view own categories" ON public.categories;
DROP POLICY IF EXISTS "Users can insert own categories" ON public.categories;
DROP POLICY IF EXISTS "Users can update own categories" ON public.categories;
DROP POLICY IF EXISTS "Users can delete own categories" ON public.categories;
DROP POLICY IF EXISTS "Users can view own jars" ON public.jars;
DROP POLICY IF EXISTS "Users can insert own jars" ON public.jars;
DROP POLICY IF EXISTS "Users can update own jars" ON public.jars;
DROP POLICY IF EXISTS "Users can delete own jars" ON public.jars;
DROP POLICY IF EXISTS "Users can view own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can insert own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can update own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can delete own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can view own jar allocations" ON public.jar_allocations;
DROP POLICY IF EXISTS "Users can insert own jar allocations" ON public.jar_allocations;
DROP POLICY IF EXISTS "Users can update own jar allocations" ON public.jar_allocations;
DROP POLICY IF EXISTS "Users can delete own jar allocations" ON public.jar_allocations;
DROP POLICY IF EXISTS "Users can view own budgets" ON public.budgets;
DROP POLICY IF EXISTS "Users can insert own budgets" ON public.budgets;
DROP POLICY IF EXISTS "Users can update own budgets" ON public.budgets;
DROP POLICY IF EXISTS "Users can delete own budgets" ON public.budgets;
DROP POLICY IF EXISTS "Users can view own reminders" ON public.reminders;
DROP POLICY IF EXISTS "Users can insert own reminders" ON public.reminders;
DROP POLICY IF EXISTS "Users can update own reminders" ON public.reminders;
DROP POLICY IF EXISTS "Users can delete own reminders" ON public.reminders;
DROP POLICY IF EXISTS "Users can view own attachments" ON public.attachments;
DROP POLICY IF EXISTS "Users can insert own attachments" ON public.attachments;
DROP POLICY IF EXISTS "Users can delete own attachments" ON public.attachments;

-- Profiles policies
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Admins policies
CREATE POLICY "Admins can view all admins"
  ON public.admins FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admins
      WHERE user_id = auth.uid()
    )
  );

-- Wallets policies
CREATE POLICY "Users can view own wallets"
  ON public.wallets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wallets"
  ON public.wallets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wallets"
  ON public.wallets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own wallets"
  ON public.wallets FOR DELETE
  USING (auth.uid() = user_id);

-- Categories policies
CREATE POLICY "Users can view own categories"
  ON public.categories FOR SELECT
  USING (auth.uid() = user_id OR is_system = TRUE);

CREATE POLICY "Users can insert own categories"
  ON public.categories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own categories"
  ON public.categories FOR UPDATE
  USING (auth.uid() = user_id AND is_system = FALSE);

CREATE POLICY "Users can delete own categories"
  ON public.categories FOR DELETE
  USING (auth.uid() = user_id AND is_system = FALSE);

-- Jars policies
CREATE POLICY "Users can view own jars"
  ON public.jars FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own jars"
  ON public.jars FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own jars"
  ON public.jars FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own jars"
  ON public.jars FOR DELETE
  USING (auth.uid() = user_id);

-- Transactions policies
CREATE POLICY "Users can view own transactions"
  ON public.transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions"
  ON public.transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions"
  ON public.transactions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions"
  ON public.transactions FOR DELETE
  USING (auth.uid() = user_id);

-- Jar allocations policies
CREATE POLICY "Users can view own jar allocations"
  ON public.jar_allocations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.jars
      WHERE jars.id = jar_allocations.jar_id
      AND jars.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own jar allocations"
  ON public.jar_allocations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.jars
      WHERE jars.id = jar_allocations.jar_id
      AND jars.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own jar allocations"
  ON public.jar_allocations FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.jars
      WHERE jars.id = jar_allocations.jar_id
      AND jars.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own jar allocations"
  ON public.jar_allocations FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.jars
      WHERE jars.id = jar_allocations.jar_id
      AND jars.user_id = auth.uid()
    )
  );

-- Budgets policies
CREATE POLICY "Users can view own budgets"
  ON public.budgets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budgets"
  ON public.budgets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets"
  ON public.budgets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets"
  ON public.budgets FOR DELETE
  USING (auth.uid() = user_id);

-- Reminders policies
CREATE POLICY "Users can view own reminders"
  ON public.reminders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reminders"
  ON public.reminders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reminders"
  ON public.reminders FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reminders"
  ON public.reminders FOR DELETE
  USING (auth.uid() = user_id);

-- Attachments policies
CREATE POLICY "Users can view own attachments"
  ON public.attachments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.transactions
      WHERE transactions.id = attachments.transaction_id
      AND transactions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own attachments"
  ON public.attachments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.transactions
      WHERE transactions.id = attachments.transaction_id
      AND transactions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own attachments"
  ON public.attachments FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.transactions
      WHERE transactions.id = attachments.transaction_id
      AND transactions.user_id = auth.uid()
    )
  );

-- ============================================
-- REAL-TIME SUBSCRIPTIONS
-- Enable real-time cho các bảng quan trọng
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.wallets;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.categories;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.jars;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.jar_allocations;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.budgets;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.reminders;

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function: Validate tổng percentage của các hũ active = 100%
CREATE OR REPLACE FUNCTION public.validate_jars_percentage()
RETURNS TRIGGER AS $$
DECLARE
  total_percentage INTEGER;
  jar_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO jar_count
  FROM public.jars
  WHERE user_id = NEW.user_id AND is_active = TRUE;
  
  IF jar_count < 6 THEN
    RETURN NEW;
  END IF;
  
  SELECT COALESCE(SUM(percentage), 0) INTO total_percentage
  FROM public.jars
  WHERE user_id = NEW.user_id AND is_active = TRUE;
  
  IF total_percentage != 100 THEN
    RAISE EXCEPTION 'Tổng percentage của các hũ active phải bằng 100%%. Hiện tại: %%', total_percentage;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_jars_percentage_trigger ON public.jars;
CREATE TRIGGER validate_jars_percentage_trigger
  AFTER INSERT OR UPDATE OF percentage, is_active ON public.jars
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_jars_percentage();

-- Function: Cập nhật balance của jar khi có allocation
CREATE OR REPLACE FUNCTION public.update_jar_balance()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.jars
    SET balance = balance + NEW.amount
    WHERE id = NEW.jar_id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE public.jars
    SET balance = balance - OLD.amount + NEW.amount
    WHERE id = NEW.jar_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.jars
    SET balance = balance - OLD.amount
    WHERE id = OLD.jar_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_jar_allocation_insert ON public.jar_allocations;
CREATE TRIGGER on_jar_allocation_insert
  AFTER INSERT OR UPDATE OR DELETE ON public.jar_allocations
  FOR EACH ROW EXECUTE FUNCTION public.update_jar_balance();

-- Function: Cập nhật balance của wallet khi có transaction
CREATE OR REPLACE FUNCTION public.update_wallet_balance()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.type = 'INCOME' THEN
      UPDATE public.wallets
      SET balance = balance + NEW.amount
      WHERE id = NEW.wallet_id;
    ELSIF NEW.type = 'EXPENSE' THEN
      UPDATE public.wallets
      SET balance = balance - NEW.amount
      WHERE id = NEW.wallet_id;
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.type = 'INCOME' THEN
      UPDATE public.wallets
      SET balance = balance - OLD.amount
      WHERE id = OLD.wallet_id;
    ELSIF OLD.type = 'EXPENSE' THEN
      UPDATE public.wallets
      SET balance = balance + OLD.amount
      WHERE id = OLD.wallet_id;
    END IF;
    IF NEW.type = 'INCOME' THEN
      UPDATE public.wallets
      SET balance = balance + NEW.amount
      WHERE id = NEW.wallet_id;
    ELSIF NEW.type = 'EXPENSE' THEN
      UPDATE public.wallets
      SET balance = balance - NEW.amount
      WHERE id = NEW.wallet_id;
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.type = 'INCOME' THEN
      UPDATE public.wallets
      SET balance = balance - OLD.amount
      WHERE id = OLD.wallet_id;
    ELSIF OLD.type = 'EXPENSE' THEN
      UPDATE public.wallets
      SET balance = balance + OLD.amount
      WHERE id = OLD.wallet_id;
    END IF;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_transaction_insert ON public.transactions;
CREATE TRIGGER on_transaction_insert
  AFTER INSERT OR UPDATE OR DELETE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.update_wallet_balance();

-- Function: Tạo categories mặc định cho user mới
CREATE OR REPLACE FUNCTION public.create_default_categories(user_uuid UUID)
RETURNS void AS $$
BEGIN
  INSERT INTO public.categories (user_id, name, type, icon, color, is_system)
  VALUES
    (user_uuid, 'Lương', 'INCOME', 'account_balance_wallet', '#10B981', TRUE),
    (user_uuid, 'Thưởng', 'INCOME', 'card_giftcard', '#10B981', TRUE),
    (user_uuid, 'Đầu tư', 'INCOME', 'trending_up', '#10B981', TRUE),
    (user_uuid, 'Khác', 'INCOME', 'attach_money', '#10B981', TRUE),
    (user_uuid, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444', TRUE),
    (user_uuid, 'Mua sắm', 'EXPENSE', 'shopping_bag', '#EF4444', TRUE),
    (user_uuid, 'Di chuyển', 'EXPENSE', 'directions_car', '#EF4444', TRUE),
    (user_uuid, 'Giáo dục', 'EXPENSE', 'school', '#F59E0B', TRUE),
    (user_uuid, 'Y tế', 'EXPENSE', 'local_hospital', '#EF4444', TRUE),
    (user_uuid, 'Giải trí', 'EXPENSE', 'movie', '#D2F273', TRUE),
    (user_uuid, 'Hóa đơn', 'EXPENSE', 'receipt', '#EF4444', TRUE),
    (user_uuid, 'Khác', 'EXPENSE', 'more_horiz', '#9CA3AF', TRUE)
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Tự động tạo profile, 6 hũ và categories khi user đăng ký
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (
    NEW.id, 
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'full_name'
  )
  ON CONFLICT (id) DO NOTHING;
  
  INSERT INTO public.jars (user_id, name, slug, percentage, icon, color, description)
  VALUES
    (NEW.id, 'Nhu cầu thiết yếu', 'necessities', 55, 'home', '#EF4444', 'Chi tiêu cho các nhu cầu cơ bản hàng ngày'),
    (NEW.id, 'Tiết kiệm dài hạn', 'long_term_savings', 10, 'savings', '#3B82F6', 'Tiết kiệm cho mục tiêu dài hạn'),
    (NEW.id, 'Giáo dục', 'education', 10, 'school', '#F59E0B', 'Đầu tư vào học tập và phát triển bản thân'),
    (NEW.id, 'Hưởng thụ', 'enjoyment', 10, 'celebration', '#D2F273', 'Chi tiêu cho giải trí và hưởng thụ'),
    (NEW.id, 'Tự do tài chính', 'financial_freedom', 10, 'account_balance_wallet', '#10B981', 'Đầu tư để đạt tự do tài chính'),
    (NEW.id, 'Cho đi', 'giving', 5, 'favorite', '#EF4444', 'Quyên góp và giúp đỡ người khác')
  ON CONFLICT (user_id, slug) DO NOTHING;
  
  PERFORM public.create_default_categories(NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

