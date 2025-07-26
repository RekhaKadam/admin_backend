# Supabase Database Setup Guide

This guide walks you through setting up the complete Supabase database structure for Sonna Sweet Bites, including tables, security policies, and storage buckets.

## 📋 Module 1: Core Database & Security Setup

### Prerequisites

1. **Supabase Project**: Create a new project at [supabase.com](https://supabase.com)
2. **Node.js**: Version 18+ installed
3. **pnpm**: Package manager installed

### Quick Setup

1. **Clone and Install Dependencies**
```bash
cd backend
pnpm install
```

2. **Environment Configuration**
```bash
cp .env.example .env
```

Update your `.env` file with your Supabase credentials:
```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_PROJECT_ID=your-project-id

# Admin Configuration
ADMIN_EMAIL=admin@sonnasweet.com
ADMIN_PASSWORD=Admin@123456
```

3. **Run Database Migration**
```bash
pnpm run db:migrate
```

This command will:
- Create all core tables with proper structure
- Set up Row Level Security (RLS) policies
- Create storage buckets for images
- Seed initial data
- Create an admin user

## 🗄️ Database Schema Overview

### Core Tables Created

#### 1. Users Table
```sql
-- Extends Supabase auth.users with profile information
public.users (
  id UUID PRIMARY KEY,           -- Links to auth.users
  email VARCHAR(255) UNIQUE,     -- User email
  first_name VARCHAR(255),       -- First name
  last_name VARCHAR(255),        -- Last name
  role user_role,                -- 'admin', 'manager', 'kitchen_staff', 'customer'
  phone VARCHAR(20),             -- Phone number
  avatar TEXT,                   -- Avatar URL
  is_active BOOLEAN,             -- Account status
  email_verified BOOLEAN,        -- Email verification status
  last_login TIMESTAMP,          -- Last login time
  address JSONB,                 -- Address information
  preferences JSONB,             -- User preferences
  created_at TIMESTAMP,          -- Creation time
  updated_at TIMESTAMP           -- Last update time
)
```

#### 2. Categories Table
```sql
public.categories (
  id UUID PRIMARY KEY,
  name VARCHAR(255) UNIQUE,      -- Category name
  description TEXT,              -- Category description
  image_url TEXT,                -- Category image
  emoji VARCHAR(10),             -- Category emoji
  sort_order INTEGER,            -- Display order
  is_active BOOLEAN,             -- Active status
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

#### 3. Menu Items Table
```sql
public.menu_items (
  id UUID PRIMARY KEY,
  name VARCHAR(255),             -- Item name
  description TEXT,              -- Item description
  price DECIMAL(10,2),           -- Item price
  category_id UUID,              -- Foreign key to categories
  image_url TEXT,                -- Item image
  is_available BOOLEAN,          -- Availability status
  ingredients TEXT[],            -- Array of ingredients
  allergens TEXT[],              -- Array of allergens
  nutritional_info JSONB,        -- Nutrition information
  preparation_time INTEGER,      -- Prep time in minutes
  is_vegan BOOLEAN,              -- Vegan flag
  is_vegetarian BOOLEAN,         -- Vegetarian flag
  is_gluten_free BOOLEAN,        -- Gluten-free flag
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

#### 4. Orders Table
```sql
public.orders (
  id UUID PRIMARY KEY,
  user_id UUID,                  -- Foreign key to users
  status order_status,           -- Order status enum
  total_amount DECIMAL(10,2),    -- Total order amount
  delivery_address JSONB,        -- Delivery address
  special_instructions TEXT,     -- Special instructions
  estimated_delivery_time TIMESTAMP,
  actual_delivery_time TIMESTAMP,
  payment_method payment_method, -- Payment method enum
  payment_status payment_status, -- Payment status enum
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

#### 5. Order Items Table
```sql
public.order_items (
  id UUID PRIMARY KEY,
  order_id UUID,                 -- Foreign key to orders
  menu_item_id UUID,             -- Foreign key to menu_items
  quantity INTEGER,              -- Item quantity
  unit_price DECIMAL(10,2),      -- Price per unit
  customizations JSONB,          -- Item customizations
  created_at TIMESTAMP
)
```

## 🔒 Security Policies (RLS)

### Access Control Overview

#### Admins
- **Full access** to all tables
- Can manage users, orders, menu items, and categories
- Can upload and manage all images

#### Managers
- **Read/Write access** to menu items and categories
- **Read/Update access** to orders
- Can upload menu images

#### Kitchen Staff
- **Read access** to all menu items (including unavailable)
- **Read access** to orders
- **Update access** to order status only

#### Customers
- **Read access** to available menu items and categories
- **Full access** to their own orders
- **Read access** to their own profile
- **Update access** to their own profile (excluding role)

### Key Security Features

1. **Row Level Security (RLS)** enabled on all tables
2. **Role-based access control** using helper functions
3. **Secure storage policies** for file uploads
4. **Data validation** with CHECK constraints
5. **Audit trails** with timestamps

## 📁 Storage Buckets

### Created Buckets

#### 1. menu-images (Public)
- **Purpose**: Store menu item and category images
- **Access**: Public read, Manager/Admin write
- **Size Limit**: 5MB per file
- **Allowed Types**: JPEG, PNG, WebP

#### 2. avatars (Public)
- **Purpose**: Store user profile pictures
- **Access**: Public read, User owns their folder
- **Size Limit**: 2MB per file
- **Allowed Types**: JPEG, PNG, WebP

#### 3. order-attachments (Private)
- **Purpose**: Store order-related documents
- **Access**: Private, user-specific access
- **Size Limit**: 10MB per file
- **Allowed Types**: JPEG, PNG, WebP, PDF

## 🌱 Sample Data

The migration includes sample data:

- **8 Categories**: Cakes, Pizza, Burgers, Pasta, Cold Drinks, Hot Drinks, Small Bites, House Specials
- **15+ Menu Items**: Representative items across all categories
- **Nutritional Information**: Calories, protein, carbs, fat
- **Dietary Information**: Vegan, vegetarian, gluten-free flags
- **Allergen Information**: Common allergens listed

## 🔧 Verification Steps

After running the migration, verify your setup:

### 1. Check Tables
In Supabase Dashboard → Table Editor:
- [ ] `users` table exists with proper structure
- [ ] `categories` table has sample data
- [ ] `menu_items` table has sample items
- [ ] `orders` and `order_items` tables exist

### 2. Test Security
In Supabase Dashboard → Authentication:
- [ ] Admin user exists with email from config
- [ ] Test login with admin credentials

### 3. Verify Storage
In Supabase Dashboard → Storage:
- [ ] `menu-images` bucket exists and is public
- [ ] `avatars` bucket exists and is public
- [ ] `order-attachments` bucket exists and is private

### 4. Test Policies
In Supabase Dashboard → SQL Editor:
```sql
-- Test admin access
SELECT * FROM users; -- Should work for admin

-- Test public access to menu
SELECT * FROM menu_items WHERE is_available = true; -- Should work
```

## 🚀 Next Steps

1. **Upload Images**: Add actual product images to the storage buckets
2. **Update URLs**: Replace placeholder image URLs with actual ones
3. **Test Authentication**: Verify login flows work correctly
4. **Configure Frontend**: Set up frontend environment variables
5. **Test API**: Verify backend API endpoints work with the database

## 🔍 Troubleshooting

### Common Issues

#### Migration Fails
```bash
# Check your environment variables
cat .env

# Verify Supabase connection
pnpm run dev
```

#### RLS Policies Not Working
- Verify you're using the correct user roles
- Check policy definitions in Supabase Dashboard
- Ensure RLS is enabled on all tables

#### Storage Upload Issues
- Verify bucket policies are correctly set
- Check file size and type restrictions
- Ensure proper authentication

### Getting Help

1. Check the Supabase logs in the dashboard
2. Review the RLS policies in the SQL editor
3. Test queries directly in the SQL editor
4. Check the browser network tab for API errors

## 📞 Support

If you encounter issues:

1. **Documentation**: [Supabase Docs](https://supabase.com/docs)
2. **Community**: [Supabase Discord](https://discord.supabase.com)
3. **Database Issues**: Check the SQL files in `/backend/database/`
4. **Security Issues**: Review the RLS policies in `02_security_policies.sql`

---

**🎉 Congratulations!** Your Supabase database is now ready for the Sonna Sweet Bites application!
