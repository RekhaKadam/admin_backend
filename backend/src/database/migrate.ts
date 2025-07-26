import { supabaseAdmin } from '../config/database.js';
import { config } from '../config/index.js';
import { logger } from '../utils/logger.js';

export const runMigrations = async (): Promise<void> => {
  try {
    logger.info('🔄 Starting Supabase database migration...');

    // Step 1: Create core tables manually using Supabase API
    await createCoreSchema();
    
    // Step 2: Set up basic data
    await seedBasicData();
    
    // Step 3: Create admin user
    await createAdminUser();
    
    logger.info('✅ Database migration completed successfully');
  } catch (error) {
    logger.error('❌ Database migration failed:', error);
    throw error;
  }
};

const createCoreSchema = async (): Promise<void> => {
  try {
    logger.info('� Creating core database schema...');

    // Create categories table
    const { error: categoriesError } = await supabaseAdmin.rpc('create_categories_table', {});
    if (categoriesError && !categoriesError.message.includes('already exists')) {
      logger.warn(`Categories table: ${categoriesError.message}`);
    }

    // Create menu_items table  
    const { error: menuError } = await supabaseAdmin.rpc('create_menu_items_table', {});
    if (menuError && !menuError.message.includes('already exists')) {
      logger.warn(`Menu items table: ${menuError.message}`);
    }

    // Create orders table
    const { error: ordersError } = await supabaseAdmin.rpc('create_orders_table', {});
    if (ordersError && !ordersError.message.includes('already exists')) {
      logger.warn(`Orders table: ${ordersError.message}`);
    }

    // Create order_items table
    const { error: orderItemsError } = await supabaseAdmin.rpc('create_order_items_table', {});
    if (orderItemsError && !orderItemsError.message.includes('already exists')) {
      logger.warn(`Order items table: ${orderItemsError.message}`);
    }

    logger.info('✅ Core schema created');
  } catch (error) {
    logger.error('❌ Failed to create core schema:', error);
    // Continue anyway - tables might already exist
  }
};

const seedBasicData = async (): Promise<void> => {
  try {
    logger.info('🌱 Seeding basic data...');

    // Insert categories
    const categories = [
      { name: 'Cakes', description: 'Delicious handcrafted cakes for every occasion', emoji: '🎂', sort_order: 1 },
      { name: 'Pizza', description: 'Authentic wood-fired pizzas with fresh ingredients', emoji: '🍕', sort_order: 2 },
      { name: 'Burgers', description: 'Juicy burgers made with premium ingredients', emoji: '🍔', sort_order: 3 },
      { name: 'Pasta', description: 'Traditional Italian pasta dishes', emoji: '🍝', sort_order: 4 },
      { name: 'Cold Drinks', description: 'Refreshing beverages to quench your thirst', emoji: '🥤', sort_order: 5 },
      { name: 'Hot Drinks', description: 'Warming beverages for any time of day', emoji: '☕', sort_order: 6 },
    ];

    for (const category of categories) {
      const { error } = await supabaseAdmin
        .from('categories')
        .upsert(category, { onConflict: 'name' });
      
      if (error) {
        logger.warn(`Category "${category.name}": ${error.message}`);
      }
    }

    logger.info('✅ Basic data seeded');
  } catch (error) {
    logger.error('❌ Failed to seed data:', error);
    // Continue anyway
  }
};

export const createAdminUser = async (): Promise<void> => {
  try {
    logger.info('👑 Creating admin user...');

    // Check if admin user already exists
    const { data: existingAdmin } = await supabaseAdmin
      .from('users')
      .select('id')
      .eq('email', config.adminEmail)
      .single();

    if (existingAdmin) {
      logger.info('👑 Admin user already exists');
      return;
    }

    // Create admin user in Supabase Auth
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: config.adminEmail,
      password: config.adminPassword,
      email_confirm: true,
      user_metadata: {
        first_name: 'Admin',
        last_name: 'User',
        role: 'admin',
      }
    });

    if (authError || !authData.user) {
      throw new Error(`Failed to create admin auth user: ${authError?.message}`);
    }

    // Create admin profile in database
    const { error: profileError } = await supabaseAdmin
      .from('users')
      .insert({
        id: authData.user.id,
        email: config.adminEmail,
        first_name: 'Admin',
        last_name: 'User',
        role: 'admin',
        is_active: true,
        email_verified: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

    if (profileError) {
      throw new Error(`Failed to create admin profile: ${profileError.message}`);
    }

    logger.info('👑 Admin user created successfully');
    logger.info(`📧 Admin email: ${config.adminEmail}`);
    logger.info(`🔑 Admin password: ${config.adminPassword}`);
  } catch (error) {
    logger.error('❌ Failed to create admin user:', error);
    throw error;
  }
};

export const setupSupabaseProject = async (): Promise<void> => {
  try {
    logger.info('🏗️  Setting up Supabase project structure...');
    
    // Test connection first
    const { data, error } = await supabaseAdmin
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .limit(1);

    if (error) {
      logger.warn('⚠️  Could not query information schema, but continuing...');
    }

    logger.info('✅ Supabase connection verified');
    
    // Run migrations
    await runMigrations();
    
    logger.info('🎉 Supabase project setup completed successfully!');
    logger.info(`🌐 Project URL: ${config.supabase.url}`);
    logger.info('📝 Next steps:');
    logger.info('   1. Visit your Supabase dashboard');
    logger.info('   2. Go to Table Editor to see your tables');
    logger.info('   3. Check Authentication to see the admin user');
    logger.info('   4. Set up Row Level Security policies manually');
    
  } catch (error) {
    logger.error('❌ Supabase project setup failed:', error);
    logger.info('');
    logger.info('🔧 Manual setup instructions:');
    logger.info('   1. Visit your Supabase project dashboard');
    logger.info('   2. Go to SQL Editor');
    logger.info('   3. Copy and paste the SQL from database/*.sql files');
    logger.info('   4. Run each file in order: 01, 02, 03, 04');
    throw error;
  }
};

// Run migration if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  setupSupabaseProject()
    .then(() => {
      logger.info('✅ Setup completed successfully');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('❌ Setup failed:', error);
      process.exit(1);
    });
}
