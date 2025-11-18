const { createClient } = require('@supabase/supabase-js');

const missingEnv = [];
if (!process.env.SUPABASE_URL) missingEnv.push('SUPABASE_URL');
if (!process.env.SUPABASE_SECRET_KEY) missingEnv.push('SUPABASE_SECRET_KEY');

if (missingEnv.length) {
  throw new Error(
    `Thiếu biến môi trường Supabase: ${missingEnv.join(
      ', ',
    )}. Vui lòng kiểm tra lại API của bạn`,
  );
}

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SECRET_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

module.exports = supabase;

