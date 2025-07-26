-- Storage setup and policies for Sonna Sweet Bites
-- This file sets up Supabase Storage buckets and access policies

-- Create storage bucket for menu images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'menu-images',
    'menu-images',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
) ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for user avatars
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true,
    2097152, -- 2MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
) ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for order attachments (private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'order-attachments',
    'order-attachments',
    false,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg', 'application/pdf']
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STORAGE POLICIES FOR MENU IMAGES
-- ============================================================================

-- Anyone can view menu images (public bucket)
CREATE POLICY "Public read access for menu images" ON storage.objects
    FOR SELECT USING (bucket_id = 'menu-images');

-- Managers and admins can upload menu images
CREATE POLICY "Managers can upload menu images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'menu-images' AND
        (
            SELECT role IN ('admin', 'manager')
            FROM public.users
            WHERE id = auth.uid()
        )
    );

-- Managers and admins can update menu images
CREATE POLICY "Managers can update menu images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'menu-images' AND
        (
            SELECT role IN ('admin', 'manager')
            FROM public.users
            WHERE id = auth.uid()
        )
    );

-- Managers and admins can delete menu images
CREATE POLICY "Managers can delete menu images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'menu-images' AND
        (
            SELECT role IN ('admin', 'manager')
            FROM public.users
            WHERE id = auth.uid()
        )
    );

-- ============================================================================
-- STORAGE POLICIES FOR AVATARS
-- ============================================================================

-- Anyone can view avatars (public bucket)
CREATE POLICY "Public read access for avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

-- Users can upload their own avatar
CREATE POLICY "Users can upload own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can update their own avatar
CREATE POLICY "Users can update own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can delete their own avatar
CREATE POLICY "Users can delete own avatar" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================================================
-- STORAGE POLICIES FOR ORDER ATTACHMENTS
-- ============================================================================

-- Users can view their own order attachments
CREATE POLICY "Users can view own order attachments" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'order-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Staff can view all order attachments
CREATE POLICY "Staff can view order attachments" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'order-attachments' AND
        (
            SELECT role IN ('admin', 'manager', 'kitchen_staff')
            FROM public.users
            WHERE id = auth.uid()
        )
    );

-- Users can upload attachments to their own orders
CREATE POLICY "Users can upload order attachments" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'order-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can delete their own order attachments
CREATE POLICY "Users can delete own order attachments" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'order-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
