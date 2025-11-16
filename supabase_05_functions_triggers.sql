-- ============================================
-- SUPABASE DATABASE SCHEMA - FUNCTIONS & TRIGGERS
-- Các hàm và trigger tự động
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

