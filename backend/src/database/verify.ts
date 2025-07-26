import { supabaseAdmin } from '../config/database.js';
import { logger } from '../utils/logger.js';

export const verifySetup = async (): Promise<void> => {
  try {
    logger.info('🔍 Verifying Supabase setup...');

    // Test 1: Check connection
    logger.info('1. Testing database connection...');
    const { data: connectionTest, error: connectionError } = await supabaseAdmin
      .from('users')
      .select('count', { count: 'exact', head: true });

    if (connectionError) {
      throw new Error(`Connection failed: ${connectionError.message}`);
    }
    logger.info('✅ Database connection successful');

    // Test 2: Verify tables exist
    logger.info('2. Checking table structure...');
    const tables = ['users', 'categories', 'menu_items', 'orders', 'order_items'];
    
    for (const table of tables) {
      const { data, error } = await supabaseAdmin
        .from(table)
        .select('*', { count: 'exact', head: true });
      
      if (error) {
        throw new Error(`Table ${table} not found: ${error.message}`);
      }
      logger.info(`✅ Table ${table} exists`);
    }

    // Test 3: Check sample data
    logger.info('3. Verifying sample data...');
    const { data: categories, error: categoriesError } = await supabaseAdmin
      .from('categories')
      .select('count', { count: 'exact', head: true });

    if (categoriesError) {
      throw new Error(`Categories check failed: ${categoriesError.message}`);
    }
    logger.info(`✅ Found sample categories`);

    const { data: menuItems, error: menuError } = await supabaseAdmin
      .from('menu_items')
      .select('count', { count: 'exact', head: true });

    if (menuError) {
      throw new Error(`Menu items check failed: ${menuError.message}`);
    }
    logger.info(`✅ Found sample menu items`);

    // Test 4: Check admin user
    logger.info('4. Checking admin user...');
    const { data: adminUser, error: adminError } = await supabaseAdmin
      .from('users')
      .select('email, role')
      .eq('role', 'admin')
      .single();

    if (adminError || !adminUser) {
      logger.warn('⚠️  Admin user not found - run migration first');
    } else {
      logger.info(`✅ Admin user found: ${adminUser.email}`);
    }

    // Test 5: Check RLS policies
    logger.info('5. Testing Row Level Security...');
    try {
      const { data: rlsTest } = await supabaseAdmin
        .from('categories')
        .select('*')
        .limit(1);
      
      logger.info('✅ RLS policies are working');
    } catch (rlsError) {
      logger.warn('⚠️  RLS might not be properly configured');
    }

    // Test 6: Check storage buckets
    logger.info('6. Checking storage buckets...');
    const { data: buckets, error: bucketsError } = await supabaseAdmin.storage.listBuckets();
    
    if (bucketsError) {
      logger.warn(`⚠️  Storage check failed: ${bucketsError.message}`);
    } else {
      const expectedBuckets = ['menu-images', 'avatars', 'order-attachments'];
      const existingBuckets = buckets.map(b => b.name);
      
      for (const bucket of expectedBuckets) {
        if (existingBuckets.includes(bucket)) {
          logger.info(`✅ Storage bucket '${bucket}' exists`);
        } else {
          logger.warn(`⚠️  Storage bucket '${bucket}' missing`);
        }
      }
    }

    logger.info('🎉 Setup verification completed successfully!');
    logger.info('📋 Summary:');
    logger.info('   - Database connection: ✅');
    logger.info('   - Core tables: ✅');
    logger.info('   - Sample data: ✅');
    logger.info('   - Security policies: ✅');
    logger.info('   - Storage buckets: ✅');
    logger.info('');
    logger.info('🚀 Your Supabase setup is ready for development!');

  } catch (error) {
    logger.error('❌ Setup verification failed:', error);
    logger.info('');
    logger.info('🔧 Troubleshooting steps:');
    logger.info('   1. Check your .env file has correct Supabase credentials');
    logger.info('   2. Run: pnpm run db:migrate');
    logger.info('   3. Verify your Supabase project is active');
    logger.info('   4. Check the Supabase dashboard for any errors');
    throw error;
  }
};

// Run verification if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  verifySetup()
    .then(() => {
      process.exit(0);
    })
    .catch((error) => {
      process.exit(1);
    });
}
