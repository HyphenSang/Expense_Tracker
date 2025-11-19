-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admins (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  role_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT admins_pkey PRIMARY KEY (id),
  CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT admins_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id)
);
CREATE TABLE public.attachments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  transaction_id uuid NOT NULL,
  file_url text NOT NULL,
  file_name text,
  file_type text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT attachments_pkey PRIMARY KEY (id),
  CONSTRAINT attachments_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id)
);
CREATE TABLE public.budgets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  category_id uuid,
  jar_id uuid,
  period USER-DEFINED NOT NULL DEFAULT 'MONTHLY'::budget_period,
  limit_amount numeric NOT NULL CHECK (limit_amount > 0::numeric),
  spent_amount numeric NOT NULL DEFAULT 0,
  start_date date NOT NULL,
  end_date date,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT budgets_pkey PRIMARY KEY (id),
  CONSTRAINT budgets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT budgets_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id),
  CONSTRAINT budgets_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jars(id)
);
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  type USER-DEFINED NOT NULL,
  icon text,
  color text,
  is_system boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.jar_allocations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  jar_id uuid NOT NULL,
  transaction_id uuid NOT NULL,
  amount numeric NOT NULL CHECK (amount >= 0::numeric),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT jar_allocations_pkey PRIMARY KEY (id),
  CONSTRAINT jar_allocations_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jars(id),
  CONSTRAINT jar_allocations_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id)
);
CREATE TABLE public.jars (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  slug text NOT NULL,
  percentage integer NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
  target_amount numeric,
  balance numeric NOT NULL DEFAULT 0,
  icon text,
  color text,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT jars_pkey PRIMARY KEY (id),
  CONSTRAINT jars_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  username text,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.reminders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  jar_id uuid,
  title text NOT NULL,
  message text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT reminders_pkey PRIMARY KEY (id),
  CONSTRAINT reminders_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT reminders_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jars(id)
);
CREATE TABLE public.roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  wallet_id uuid NOT NULL,
  category_id uuid NOT NULL,
  type USER-DEFINED NOT NULL,
  amount numeric NOT NULL CHECK (amount > 0::numeric),
  note text,
  occurred_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT transactions_pkey PRIMARY KEY (id),
  CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT transactions_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallets(id),
  CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.wallets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  type USER-DEFINED NOT NULL,
  bank_name text,
  account_number text,
  balance numeric NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  last_sync_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT wallets_pkey PRIMARY KEY (id),
  CONSTRAINT wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);