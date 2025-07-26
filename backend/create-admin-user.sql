-- ADMIN USER CREATION SCRIPT
-- Run this after the main Module 1 setup is complete

-- Function to create admin user (run this from your backend application)
CREATE OR REPLACE FUNCTION create_admin_user(
    admin_email TEXT,
    admin_user_id UUID
)
RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
BEGIN
    -- Insert admin user into users table
    INSERT INTO public.users (
        id,
        email,
        first_name,
        last_name,
        role,
        is_active,
        email_verified,
        created_at,
        updated_at
    ) VALUES (
        admin_user_id,
        admin_email,
        'Admin',
        'User',
        'admin',
        true,
        true,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        role = 'admin',
        is_active = true,
        email_verified = true,
        updated_at = NOW()
    RETURNING id INTO new_user_id;
    
    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION create_admin_user TO authenticated;
GRANT EXECUTE ON FUNCTION create_admin_user TO service_role;
