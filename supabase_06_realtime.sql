-- ============================================
-- SUPABASE DATABASE SCHEMA - REAL-TIME
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

