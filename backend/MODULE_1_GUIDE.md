# 🎯 Module 1: Core Database & Security Setup - Complete Guide

## Overview
This module establishes the foundational database structure, security policies, and inventory system for your Sonna Sweet Bites backend using Supabase.

## ✅ What This Module Delivers

### 1. Core Database Tables
- **users**: User profiles with role-based access (admin, manager, kitchen_staff, customer)
- **categories**: Food categories with sorting and activation status
- **menu_items**: Complete menu with pricing, dietary info, and availability
- **inventory**: Stock tracking with automatic depletion and low-stock alerts
- **orders**: Order management with status tracking and payment info
- **order_items**: Detailed line items for each order

### 2. Security Implementation
- **Row Level Security (RLS)**: Enabled on all tables
- **Role-based Access Control**: Granular permissions for each user type
- **Storage Security**: Secure file upload policies for images and documents

### 3. Storage Buckets
- **menu-images**: Public bucket for food photos (5MB limit)
- **avatars**: User profile pictures (2MB limit)
- **order-attachments**: Private order documents (10MB limit)

### 4. Inventory Management (Module 2 Preview)
- **Automatic Stock Tracking**: Inventory decreases when orders are placed
- **Low Stock Alerts**: Function to check items below minimum threshold
- **Stock Management**: Functions to increase/decrease inventory

## 🚀 Setup Instructions

### Step 1: Manual Database Setup (Recommended)

1. **Open Supabase Dashboard**:
   ```
   https://supabase.com/dashboard/project/wbhfwagjmtyxipuntrut
   ```

2. **Navigate to SQL Editor**:
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Execute Setup Script**:
   - Copy the entire content from: `backend/MODULE_1_COMPLETE_SETUP.sql`
   - Paste into the SQL Editor
   - Click "Run" to execute

### Step 2: Verify Setup

Run the verification script to check if everything was created correctly:

```cmd
cd "e:\sonna-sweet-bites-app\backend"
pnpm run verify:module1
```

### Step 3: Create Admin User

1. **In Supabase Dashboard, go to Authentication > Users**
2. **Click "Add User"**:
   - Email: `admin@sonnasweet.com`
   - Password: `Admin@123456`
   - Email Confirm: ✅ (checked)

3. **After creating the auth user, run this in SQL Editor**:
   ```sql
   -- Replace the UUID with the actual user ID from Authentication tab
   SELECT create_admin_user('admin@sonnasweet.com', 'USER_UUID_FROM_AUTH_TAB');
   ```

## 📊 Expected Results

After successful setup, you should see:

### Tables Created (6):
- ✅ users
- ✅ categories  
- ✅ menu_items
- ✅ inventory
- ✅ orders
- ✅ order_items

### Sample Data:
- ✅ 10 food categories (Cakes, Pizza, Burgers, etc.)
- ✅ 4 sample menu items
- ✅ Inventory records for all menu items

### Storage Buckets (3):
- ✅ menu-images (public)
- ✅ avatars (public)
- ✅ order-attachments (private)

### Security Policies:
- ✅ RLS enabled on all tables
- ✅ Role-based access control
- ✅ Storage upload/download policies

### Functions Created:
- ✅ `check_low_inventory()` - Returns items below minimum stock
- ✅ `update_inventory_stock()` - Manages stock changes
- ✅ `create_admin_user()` - Creates admin users

## 🔧 Troubleshooting

### If Setup Fails:
1. Check your Supabase project is active
2. Verify your service role key in `.env`
3. Try running the SQL manually in Supabase SQL Editor
4. Check for any error messages in the SQL Editor

### Common Issues:
- **"relation does not exist"**: Tables weren't created - run setup SQL again
- **"insufficient permissions"**: Check your service role key
- **"duplicate key value"**: Some data already exists - this is usually OK

## 🎯 Next Steps

Once Module 1 is complete:

1. **Test your admin login** in the frontend
2. **Start Module 2**: Menu & Inventory Management API
3. **Build the admin dashboard** for managing menu items
4. **Test file uploads** to storage buckets

## 📝 Module 1 Checklist

- [ ] Database setup script executed successfully
- [ ] All 6 tables created with proper relationships
- [ ] RLS policies active and working
- [ ] Storage buckets created with correct policies
- [ ] Sample data loaded (categories and menu items)
- [ ] Admin user created in Authentication
- [ ] Admin user profile created in database
- [ ] Verification script passes all checks

## 🔗 Files Created in This Module

```
backend/
├── MODULE_1_COMPLETE_SETUP.sql     # Main setup script
├── create-admin-user.sql           # Admin user creation
├── verify-module1.js               # Verification script
├── MANUAL_SETUP.sql               # Fallback setup (simpler)
├── src/
│   ├── database/
│   │   ├── migrate.ts             # Automated migration
│   │   └── verify.ts              # TypeScript verification
│   └── config/
│       └── database.ts            # Supabase client config
└── .env                           # Environment variables
```

---

**🎉 Module 1 Complete!** 

Your database foundation is now ready. The next step is to build the API endpoints for menu management in Module 2.
