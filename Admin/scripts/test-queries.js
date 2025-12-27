require('dotenv').config();
const supabase = require('../src/config/supabaseClient');

/**
 * Script để test các Supabase queries trong Admin backend
 * Verify queries hoạt động đúng với database schema
 */
async function testQueries() {
  console.log('🧪 Testing Supabase Queries...\n');
  console.log('='.repeat(60));

  let passedTests = 0;
  let failedTests = 0;

  // ========== TEST 1: Query Transactions ==========
  console.log('\n1️⃣ Testing transactions query...');
  try {
    const { data, error } = await supabase
      .from('transactions')
      .select('amount, type, occurred_at')
      .limit(5);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} transactions`);
      if (data && data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0], null, 2)}`);
      }
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 2: Query Transactions với Join Categories ==========
  console.log('\n2️⃣ Testing transactions with categories join...');
  try {
    const { data, error } = await supabase
      .from('transactions')
      .select('amount, type, category_id, categories!inner(name)')
      .eq('type', 'EXPENSE')
      .limit(5);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} expenses with categories`);
      if (data && data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0], null, 2)}`);
      }
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 3: Query Profiles ==========
  console.log('\n3️⃣ Testing profiles query...');
  try {
    const { count, error } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true });

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${count || 0} profiles`);
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 4: Query Profiles với Fields ==========
  console.log('\n4️⃣ Testing profiles with specific fields...');
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('id, username, full_name, avatar_url, created_at, updated_at')
      .limit(3);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} profiles`);
      if (data && data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0], null, 2)}`);
      }
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 5: Query Admins với Roles ==========
  console.log('\n5️⃣ Testing admins with roles join...');
  try {
    const { data, error } = await supabase
      .from('admins')
      .select('user_id, role_id, roles(name)')
      .limit(5);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} admins`);
      if (data && data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0], null, 2)}`);
      }
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 6: Query Categories ==========
  console.log('\n6️⃣ Testing categories query...');
  try {
    const { data, error } = await supabase
      .from('categories')
      .select('id, name, type, user_id')
      .limit(5);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} categories`);
      if (data && data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0], null, 2)}`);
      }
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 7: Query Wallets ==========
  console.log('\n7️⃣ Testing wallets query...');
  try {
    const { data, error } = await supabase
      .from('wallets')
      .select('id, user_id, name, balance, is_active')
      .eq('is_active', true)
      .limit(5);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} active wallets`);
      if (data && data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0], null, 2)}`);
      }
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 8: Query Transactions với Date Range ==========
  console.log('\n8️⃣ Testing transactions with date range...');
  try {
    const now = new Date();
    const currentMonth = {
      from: new Date(now.getFullYear(), now.getMonth(), 1).toISOString(),
      to: new Date(now.getFullYear(), now.getMonth() + 1, 1).toISOString(),
    };

    const { data, error } = await supabase
      .from('transactions')
      .select('amount, type, occurred_at')
      .gte('occurred_at', currentMonth.from)
      .lt('occurred_at', currentMonth.to);

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      console.log(`✅ Success! Found ${data?.length || 0} transactions this month`);
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== TEST 9: Auth Admin API ==========
  console.log('\n9️⃣ Testing auth.admin.listUsers()...');
  try {
    const { data: authUsersData, error } = await supabase.auth.admin.listUsers();

    if (error) {
      console.error('❌ Error:', error.message);
      failedTests++;
    } else {
      const userCount = authUsersData?.users?.length || 0;
      console.log(`✅ Success! Found ${userCount} auth users`);
      passedTests++;
    }
  } catch (err) {
    console.error('❌ Exception:', err.message);
    failedTests++;
  }

  // ========== SUMMARY ==========
  console.log('\n' + '='.repeat(60));
  console.log('\n📊 Test Summary:');
  console.log(`   ✅ Passed: ${passedTests}`);
  console.log(`   ❌ Failed: ${failedTests}`);
  console.log(`   📈 Total: ${passedTests + failedTests}`);

  if (failedTests === 0) {
    console.log('\n🎉 All tests passed! Queries are working correctly.');
  } else {
    console.log('\n⚠️ Some tests failed. Please check the errors above.');
    process.exit(1);
  }
}

// Run tests
testQueries().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});

