-- ============================================
-- SUPABASE DATABASE SCHEMA - TABLES ONLY
-- Chỉ tạo các bảng, không có indexes, triggers, RLS
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

-- Insert default roles
INSERT INTO public.roles (name)
SELECT 'user' WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'user')
UNION ALL
SELECT 'admin' WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'admin')
UNION ALL
SELECT 'super_admin' WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'super_admin');

-- ============================================
-- 3. ADMIN TABLE
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

