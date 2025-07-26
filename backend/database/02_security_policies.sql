-- Row Level Security (RLS) Policies for Sonna Sweet Bites
-- This file contains all security policies and access controls

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT role = 'admin'
        FROM public.users
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check if user is manager or admin
CREATE OR REPLACE FUNCTION is_manager_or_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT role IN ('admin', 'manager')
        FROM public.users
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check if user is kitchen staff, manager, or admin
CREATE OR REPLACE FUNCTION is_kitchen_staff_or_above()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT role IN ('admin', 'manager', 'kitchen_staff')
        FROM public.users
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Admins can do everything with users
CREATE POLICY "Admins can manage all users" ON public.users
    FOR ALL USING (is_admin());

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile (excluding role)
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id AND
        role = (SELECT role FROM public.users WHERE id = auth.uid())
    );

-- Allow user creation during signup
CREATE POLICY "Enable insert for authenticated users during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================================
-- CATEGORIES TABLE POLICIES
-- ============================================================================

-- Everyone can read active categories
CREATE POLICY "Public read access to active categories" ON public.categories
    FOR SELECT USING (is_active = true);

-- Managers and admins can manage categories
CREATE POLICY "Managers can manage categories" ON public.categories
    FOR ALL USING (is_manager_or_admin());

-- ============================================================================
-- MENU ITEMS TABLE POLICIES
-- ============================================================================

-- Everyone can read available menu items
CREATE POLICY "Public read access to available menu items" ON public.menu_items
    FOR SELECT USING (is_available = true);

-- Managers and admins can manage menu items
CREATE POLICY "Managers can manage menu items" ON public.menu_items
    FOR ALL USING (is_manager_or_admin());

-- Kitchen staff can read all menu items (for order preparation)
CREATE POLICY "Kitchen staff can read all menu items" ON public.menu_items
    FOR SELECT USING (is_kitchen_staff_or_above());

-- ============================================================================
-- ORDERS TABLE POLICIES
-- ============================================================================

-- Admins can manage all orders
CREATE POLICY "Admins can manage all orders" ON public.orders
    FOR ALL USING (is_admin());

-- Managers can read and update orders
CREATE POLICY "Managers can read and update orders" ON public.orders
    FOR SELECT USING (is_manager_or_admin());

CREATE POLICY "Managers can update orders" ON public.orders
    FOR UPDATE USING (is_manager_or_admin());

-- Kitchen staff can read orders and update status
CREATE POLICY "Kitchen staff can read orders" ON public.orders
    FOR SELECT USING (is_kitchen_staff_or_above());

CREATE POLICY "Kitchen staff can update order status" ON public.orders
    FOR UPDATE USING (is_kitchen_staff_or_above())
    WITH CHECK (
        -- Kitchen staff can only update status, not other fields
        status != OLD.status AND
        user_id = OLD.user_id AND
        total_amount = OLD.total_amount AND
        delivery_address = OLD.delivery_address AND
        payment_method = OLD.payment_method
    );

-- Users can view their own orders
CREATE POLICY "Users can view own orders" ON public.orders
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create orders
CREATE POLICY "Users can create orders" ON public.orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their pending orders
CREATE POLICY "Users can update own pending orders" ON public.orders
    FOR UPDATE USING (
        auth.uid() = user_id AND 
        status = 'pending'
    ) WITH CHECK (
        auth.uid() = user_id AND
        status IN ('pending', 'cancelled')
    );

-- ============================================================================
-- ORDER ITEMS TABLE POLICIES
-- ============================================================================

-- Admins can manage all order items
CREATE POLICY "Admins can manage all order items" ON public.order_items
    FOR ALL USING (is_admin());

-- Managers and kitchen staff can read order items
CREATE POLICY "Staff can read order items" ON public.order_items
    FOR SELECT USING (is_kitchen_staff_or_above());

-- Users can view order items for their own orders
CREATE POLICY "Users can view own order items" ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Users can create order items for their own orders
CREATE POLICY "Users can create order items for own orders" ON public.order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
            AND orders.status = 'pending'
        )
    );

-- Users can update order items for their pending orders
CREATE POLICY "Users can update order items for pending orders" ON public.order_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
            AND orders.status = 'pending'
        )
    ) WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
            AND orders.status = 'pending'
        )
    );

-- Users can delete order items from their pending orders
CREATE POLICY "Users can delete order items from pending orders" ON public.order_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
            AND orders.status = 'pending'
        )
    );
