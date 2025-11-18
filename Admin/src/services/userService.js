const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

const getUsers = async ({ limit = 20 } = {}) => {
  const { data, error } = await supabase
    .from('profiles')
    .select('id,username,full_name,avatar_url,created_at,updated_at')
    .order('created_at', { ascending: false, nullsFirst: false })
    .limit(limit);

  if (error) {
    throw createHttpError(error.message, 400);
  }

  return data || [];
};

module.exports = {
  getUsers,
};

