-- ============================================
-- SUPABASE DATABASE SCHEMA - ROW LEVEL SECURITY
-- Bảo mật dữ liệu theo user
-- ============================================

-- Enable RLS cho tất cả các bảng
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jar_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Everyone can view roles" ON public.roles;
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

-- Roles policies (Tất cả user đều có thể xem roles, chỉ admin mới có thể sửa)
CREATE POLICY "Everyone can view roles"
  ON public.roles FOR SELECT
  USING (true);

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

