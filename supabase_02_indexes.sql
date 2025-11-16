-- ============================================
-- SUPABASE DATABASE SCHEMA - INDEXES
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

