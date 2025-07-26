# 🚀 Quick Start: Supabase Database Setup

Complete Module 1 setup in 5 minutes!

## Step 1: Prerequisites ✅

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Choose organization and set project name: `sonna-sweet-bites`
   - Select region closest to you
   - Set a strong database password
   - Wait for project to be ready (~2 minutes)

2. **Get Your Credentials**
   - In your Supabase project dashboard
   - Go to **Settings → API**
   - Copy these values:
     - Project URL
     - `anon` `public` key
     - `service_role` `secret` key

## Step 2: Backend Setup ⚙️

```bash
# Navigate to backend directory
cd backend

# Install dependencies with pnpm
pnpm install

# Create environment file
cp .env.example .env
```

## Step 3: Configure Environment 🔧

Edit your `.env` file:

```env
# Supabase Configuration (REPLACE WITH YOUR VALUES)
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_PROJECT_ID=your-project-id

# Admin User (You can change these)
ADMIN_EMAIL=admin@sonnasweet.com
ADMIN_PASSWORD=Admin@123456

# Other settings (defaults are fine for development)
PORT=5000
NODE_ENV=development
JWT_SECRET=your-super-secret-jwt-key
```

## Step 4: Run Database Setup 🏗️

```bash
# Run the complete setup (this does everything!)
pnpm run setup
```

This command will:
- ✅ Create all database tables
- ✅ Set up Row Level Security policies
- ✅ Create storage buckets
- ✅ Seed sample data
- ✅ Create admin user
- ✅ Verify everything works

## Step 5: Verify Setup 🔍

If the setup command completed successfully, you should see:

```
🎉 Setup verification completed successfully!
📋 Summary:
   - Database connection: ✅
   - Core tables: ✅
   - Sample data: ✅
   - Security policies: ✅
   - Storage buckets: ✅

🚀 Your Supabase setup is ready for development!
```

## Step 6: Test in Supabase Dashboard 🧪

### Check Tables
1. Go to **Table Editor** in Supabase Dashboard
2. You should see tables: `users`, `categories`, `menu_items`, `orders`, `order_items`
3. Click on `categories` - should have 8 sample categories
4. Click on `menu_items` - should have 15+ sample items

### Check Authentication
1. Go to **Authentication → Users**
2. You should see one admin user with your email
3. Try to test login (optional)

### Check Storage
1. Go to **Storage**
2. You should see 3 buckets:
   - `menu-images` (public)
   - `avatars` (public)
   - `order-attachments` (private)

## 🎯 Success Criteria

You've successfully completed Module 1 if:

- [ ] ✅ Database tables created with proper structure
- [ ] ✅ Row Level Security (RLS) enabled and policies active
- [ ] ✅ User roles implemented (`admin`, `manager`, `kitchen_staff`, `customer`)
- [ ] ✅ Storage buckets created with proper access controls
- [ ] ✅ Sample data loaded (categories and menu items)
- [ ] ✅ Admin user created and can authenticate

## 🔧 Troubleshooting

### Issue: "Connection failed"
**Solution**: Check your Supabase URL and keys in `.env`

### Issue: "Permission denied"
**Solution**: Make sure you're using the `service_role` key, not the `anon` key

### Issue: "Tables already exist"
**Solution**: This is normal - the migration handles existing tables

### Issue: Migration fails partway
**Solution**: Run individual commands:
```bash
pnpm run db:migrate  # Create tables and policies
pnpm run db:verify   # Check what worked
```

## 📊 What You've Built

### Database Schema
- **5 Core Tables** with proper relationships
- **Enum Types** for data consistency
- **Indexes** for query performance
- **Triggers** for auto-updating timestamps

### Security Implementation
- **Row Level Security** on all tables
- **Role-based access control** with 4 user types
- **Secure storage policies** for file uploads
- **Helper functions** for permission checking

### Sample Data
- **8 Food Categories** (Cakes, Pizza, Burgers, etc.)
- **15+ Menu Items** with full details
- **Nutritional Information** and dietary flags
- **Realistic pricing** and preparation times

## 🚀 Next Steps

With Module 1 complete, you're ready for:

1. **Module 2**: Build the admin authentication system
2. **Module 3**: Create the admin dashboard
3. **Module 4**: Implement kitchen management
4. **Module 5**: Add analytics and reporting

**You've built a production-ready database foundation! 🎉**

---

### Quick Commands Reference

```bash
# Full setup
pnpm run setup

# Individual commands
pnpm run db:migrate    # Create schema
pnpm run db:verify     # Test setup
pnpm run dev          # Start backend server

# If you need to start over
# (In Supabase Dashboard: Settings → Database → Reset Database)
# Then run: pnpm run setup
```
