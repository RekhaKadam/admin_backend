import { supabaseAdmin } from '../config/database.js';
import { Database } from '../types/supabase.js';
import bcrypt from 'bcryptjs';

type UserRow = Database['public']['Tables']['users']['Row'];
type UserInsert = Database['public']['Tables']['users']['Insert'];
type UserUpdate = Database['public']['Tables']['users']['Update'];

export interface IUser extends UserRow {
  password?: string;
}

export class UserService {
  static async findById(id: string): Promise<IUser | null> {
    const { data, error } = await supabaseAdmin
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return data;
  }

  static async findByEmail(email: string): Promise<IUser | null> {
    const { data, error } = await supabaseAdmin
      .from('users')
      .select('*')
      .eq('email', email.toLowerCase())
      .single();

    if (error || !data) return null;
    return data;
  }

  static async create(userData: UserInsert & { password: string }): Promise<IUser | null> {
    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(userData.password, salt);

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: userData.email,
      password: userData.password,
      email_confirm: userData.email_verified || false,
      user_metadata: {
        first_name: userData.first_name,
        last_name: userData.last_name,
        role: userData.role || 'customer',
      }
    });

    if (authError || !authData.user) {
      throw new Error(`Failed to create auth user: ${authError?.message}`);
    }

    // Create user profile in database
    const { data, error } = await supabaseAdmin
      .from('users')
      .insert({
        ...userData,
        id: authData.user.id,
        email: userData.email.toLowerCase(),
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error || !data) {
      throw new Error(`Failed to create user profile: ${error?.message}`);
    }

    return data;
  }

  static async update(id: string, userData: UserUpdate): Promise<IUser | null> {
    const { data, error } = await supabaseAdmin
      .from('users')
      .update({
        ...userData,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error || !data) return null;
    return data;
  }

  static async delete(id: string): Promise<boolean> {
    // Delete from auth
    const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(id);
    
    if (authError) {
      throw new Error(`Failed to delete auth user: ${authError.message}`);
    }

    // Delete from database (should cascade via foreign key)
    const { error } = await supabaseAdmin
      .from('users')
      .delete()
      .eq('id', id);

    return !error;
  }

  static async findAll(page = 1, limit = 20, filters?: Partial<UserRow>): Promise<{
    users: IUser[];
    total: number;
    page: number;
    totalPages: number;
  }> {
    let query = supabaseAdmin
      .from('users')
      .select('*', { count: 'exact' });

    // Apply filters
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          query = query.eq(key, value);
        }
      });
    }

    // Apply pagination
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data, error, count } = await query
      .range(from, to)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(`Failed to fetch users: ${error.message}`);
    }

    return {
      users: data || [],
      total: count || 0,
      page,
      totalPages: Math.ceil((count || 0) / limit),
    };
  }

  static async comparePassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  static async updateLastLogin(id: string): Promise<void> {
    await supabaseAdmin
      .from('users')
      .update({ 
        last_login: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', id);
  }

  static getFullName(user: IUser): string {
    return `${user.first_name} ${user.last_name}`;
  }
}
