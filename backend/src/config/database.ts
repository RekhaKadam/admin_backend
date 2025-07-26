import { createClient } from '@supabase/supabase-js';
import { config } from './index.js';
import { logger } from '../utils/logger.js';

// Create Supabase client for admin operations
export const supabaseAdmin = createClient(
  config.supabase.url,
  config.supabase.serviceRoleKey,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

// Create Supabase client for regular operations
export const supabase = createClient(
  config.supabase.url,
  config.supabase.anonKey
);

export const connectDB = async (): Promise<void> => {
  try {
    // Test the connection
    const { data, error } = await supabaseAdmin
      .from('users')
      .select('count', { count: 'exact', head: true });

    if (error) {
      throw error;
    }

    logger.info(`🗄️  Supabase Connected: ${config.supabase.url}`);
    logger.info(`📊 Database initialized successfully`);

  } catch (error) {
    logger.error('Supabase connection error:', error);
    
    if (config.nodeEnv === 'production') {
      process.exit(1);
    } else {
      logger.warn('⚠️  Continuing in development mode without database connection');
    }
  }
};
