-- MODULE 1: COMPLETE DATABASE & SECURITY SETUP WITH INVENTORY
-- Copy and paste this entire script into your Supabase SQL Editor and run it

-- ===============================================
-- STEP 1: CREATE CUSTOM ENUMS
-- ===============================================

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'manager', 'kitchen_staff', 'customer');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ===============================================
-- STEP 2: CREATE CORE TABLES
-- ===============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role user_role DEFAULT 'customer',
    avatar_url TEXT,
    date_of_birth DATE,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories table
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    emoji VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Menu items table
CREATE TABLE IF NOT EXISTS public.menu_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    image_url TEXT,
    preparation_time INTEGER, -- in minutes
    calories INTEGER,
    is_vegetarian BOOLEAN DEFAULT false,
    is_vegan BOOLEAN DEFAULT false,
    is_gluten_free BOOLEAN DEFAULT false,
    is_spicy BOOLEAN DEFAULT false,
    allergens TEXT[], -- array of allergen strings
    ingredients TEXT[],
    is_available BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory table (for Module 2 preparation)
CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    current_stock INTEGER NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    minimum_threshold INTEGER NOT NULL DEFAULT 10 CHECK (minimum_threshold >= 0),
    maximum_capacity INTEGER NOT NULL DEFAULT 100 CHECK (maximum_capacity >= minimum_threshold),
    unit VARCHAR(50) DEFAULT 'pieces', -- pieces, kg, liters, etc.
    cost_per_unit DECIMAL(10,2) DEFAULT 0 CHECK (cost_per_unit >= 0),
    supplier_info JSONB, -- flexible supplier data
    last_restocked_at TIMESTAMPTZ,
    is_tracked BOOLEAN DEFAULT true, -- whether to track this item
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(menu_item_id)
);

-- Orders table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status order_status DEFAULT 'pending',
    payment_status payment_status DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10,2) DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    delivery_fee DECIMAL(10,2) DEFAULT 0 CHECK (delivery_fee >= 0),
    customer_notes TEXT,
    estimated_pickup_time TIMESTAMPTZ,
    actual_pickup_time TIMESTAMPTZ,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order items table
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    special_instructions TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===============================================
-- STEP 3: CREATE INDEXES FOR PERFORMANCE
-- ===============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_sort ON categories(sort_order);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_available ON menu_items(is_available);
CREATE INDEX IF NOT EXISTS idx_menu_items_featured ON menu_items(is_featured);
CREATE INDEX IF NOT EXISTS idx_inventory_menu_item ON inventory(menu_item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_low_stock ON inventory(current_stock, minimum_threshold);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_menu_item ON order_items(menu_item_id);

-- ===============================================
-- STEP 4: CREATE UPDATED_AT TRIGGERS
-- ===============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_menu_items_updated_at ON menu_items;
CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_inventory_updated_at ON inventory;
CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===============================================
-- STEP 5: ENABLE ROW LEVEL SECURITY (RLS)
-- ===============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- ===============================================
-- STEP 6: CREATE RLS HELPER FUNCTIONS
-- ===============================================

CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = user_id AND role = 'admin' AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_manager_or_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = user_id AND role IN ('admin', 'manager') AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_kitchen_staff_or_above(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = user_id AND role IN ('admin', 'manager', 'kitchen_staff') AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- STEP 7: CREATE COMPREHENSIVE RLS POLICIES
-- ===============================================

-- Users Policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert users" ON users
    FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update all users" ON users
    FOR UPDATE USING (is_admin(auth.uid()));

CREATE POLICY "Admins can delete users" ON users
    FOR DELETE USING (is_admin(auth.uid()));

-- Categories Policies
CREATE POLICY "Anyone can view active categories" ON categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Staff can view all categories" ON categories
    FOR SELECT USING (is_kitchen_staff_or_above(auth.uid()));

CREATE POLICY "Managers can manage categories" ON categories
    FOR ALL USING (is_manager_or_admin(auth.uid()));

-- Menu Items Policies
CREATE POLICY "Anyone can view available menu items" ON menu_items
    FOR SELECT USING (is_available = true);

CREATE POLICY "Staff can view all menu items" ON menu_items
    FOR SELECT USING (is_kitchen_staff_or_above(auth.uid()));

CREATE POLICY "Managers can manage menu items" ON menu_items
    FOR ALL USING (is_manager_or_admin(auth.uid()));

-- Inventory Policies
CREATE POLICY "Staff can view inventory" ON inventory
    FOR SELECT USING (is_kitchen_staff_or_above(auth.uid()));

CREATE POLICY "Managers can manage inventory" ON inventory
    FOR ALL USING (is_manager_or_admin(auth.uid()));

-- Orders Policies
CREATE POLICY "Users can view their own orders" ON orders
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own orders" ON orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pending orders" ON orders
    FOR UPDATE USING (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Staff can view all orders" ON orders
    FOR SELECT USING (is_kitchen_staff_or_above(auth.uid()));

CREATE POLICY "Staff can update order status" ON orders
    FOR UPDATE USING (is_kitchen_staff_or_above(auth.uid()));

CREATE POLICY "Managers can delete orders" ON orders
    FOR DELETE USING (is_manager_or_admin(auth.uid()));

-- Order Items Policies
CREATE POLICY "Users can view their own order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE orders.id = order_items.order_id 
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert order items for their orders" ON order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE orders.id = order_items.order_id 
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Staff can view all order items" ON order_items
    FOR SELECT USING (is_kitchen_staff_or_above(auth.uid()));

CREATE POLICY "Staff can manage all order items" ON order_items
    FOR ALL USING (is_kitchen_staff_or_above(auth.uid()));

-- ===============================================
-- STEP 8: CREATE STORAGE BUCKETS
-- ===============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('menu-images', 'menu-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('order-attachments', 'order-attachments', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- ===============================================
-- STEP 9: CREATE STORAGE POLICIES
-- ===============================================

CREATE POLICY "Anyone can view menu images" ON storage.objects
    FOR SELECT USING (bucket_id = 'menu-images');

CREATE POLICY "Managers can upload menu images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'menu-images' AND is_manager_or_admin(auth.uid()));

CREATE POLICY "Managers can update menu images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'menu-images' AND is_manager_or_admin(auth.uid()));

CREATE POLICY "Managers can delete menu images" ON storage.objects
    FOR DELETE USING (bucket_id = 'menu-images' AND is_manager_or_admin(auth.uid()));

CREATE POLICY "Users can view public avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ===============================================
-- STEP 10: INSERT SAMPLE DATA
-- ===============================================

INSERT INTO categories (name, description, emoji, sort_order) VALUES
('Cakes', 'Delicious handcrafted cakes for every occasion', '🎂', 1),
('Pizza', 'Authentic wood-fired pizzas with fresh ingredients', '🍕', 2),
('Burgers', 'Juicy burgers made with premium ingredients', '🍔', 3),
('Pasta', 'Traditional Italian pasta dishes', '🍝', 4),
('Cold Drinks', 'Refreshing beverages to quench your thirst', '🥤', 5),
('Hot Drinks', 'Warming beverages for any time of day', '☕', 6),
('Sandwiches', 'Fresh sandwiches made to order', '🥪', 7),
('Small Bites', 'Perfect snacks and appetizers', '🍿', 8),
('Soups & Appetizers', 'Hearty soups and delicious starters', '🍲', 9),
('House Specials', 'Our signature dishes and chef recommendations', '⭐', 10)
ON CONFLICT (name) DO NOTHING;

-- Sample menu items
WITH category_ids AS (
    SELECT id, name FROM categories WHERE name IN ('Cakes', 'Pizza', 'Burgers', 'Cold Drinks')
)
INSERT INTO menu_items (category_id, name, description, price, preparation_time, is_featured) 
SELECT 
    c.id,
    item.name,
    item.description,
    item.price,
    item.prep_time,
    item.featured
FROM category_ids c
CROSS JOIN (
    VALUES 
        ('Chocolate Birthday Cake', 'Rich chocolate cake perfect for celebrations', 25.99, 60, true),
        ('Margherita Pizza', 'Classic pizza with fresh tomatoes and mozzarella', 12.99, 15, true),
        ('Classic Beef Burger', 'Juicy beef patty with lettuce, tomato, and cheese', 8.99, 12, false),
        ('Fresh Orange Juice', 'Freshly squeezed orange juice', 3.99, 2, false)
) AS item(name, description, price, prep_time, featured)
WHERE (c.name = 'Cakes' AND item.name LIKE '%Cake%')
   OR (c.name = 'Pizza' AND item.name LIKE '%Pizza%')
   OR (c.name = 'Burgers' AND item.name LIKE '%Burger%')
   OR (c.name = 'Cold Drinks' AND item.name LIKE '%Juice%')
ON CONFLICT DO NOTHING;

-- ===============================================
-- STEP 11: MODULE 2 PREPARATION - INVENTORY FUNCTIONS
-- ===============================================

-- Function to check low inventory
CREATE OR REPLACE FUNCTION check_low_inventory()
RETURNS TABLE(
    menu_item_id UUID,
    menu_item_name TEXT,
    current_stock INTEGER,
    minimum_threshold INTEGER,
    shortage INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.menu_item_id,
        mi.name,
        i.current_stock,
        i.minimum_threshold,
        (i.minimum_threshold - i.current_stock) as shortage
    FROM inventory i
    JOIN menu_items mi ON mi.id = i.menu_item_id
    WHERE i.is_tracked = true 
    AND i.current_stock <= i.minimum_threshold
    ORDER BY (i.minimum_threshold - i.current_stock) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update inventory stock
CREATE OR REPLACE FUNCTION update_inventory_stock(
    p_menu_item_id UUID,
    p_quantity_change INTEGER,
    p_operation TEXT DEFAULT 'decrease'
)
RETURNS BOOLEAN AS $$
DECLARE
    current_stock_val INTEGER;
BEGIN
    -- Get current stock
    SELECT current_stock INTO current_stock_val 
    FROM inventory 
    WHERE menu_item_id = p_menu_item_id AND is_tracked = true;
    
    -- If inventory doesn't exist or isn't tracked, return false
    IF current_stock_val IS NULL THEN
        RETURN false;
    END IF;
    
    -- Update stock based on operation
    IF p_operation = 'decrease' THEN
        UPDATE inventory 
        SET current_stock = GREATEST(0, current_stock - p_quantity_change),
            updated_at = NOW()
        WHERE menu_item_id = p_menu_item_id;
    ELSIF p_operation = 'increase' THEN
        UPDATE inventory 
        SET current_stock = LEAST(maximum_capacity, current_stock + p_quantity_change),
            updated_at = NOW()
        WHERE menu_item_id = p_menu_item_id;
    END IF;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically decrease inventory when order is placed
CREATE OR REPLACE FUNCTION handle_inventory_on_order()
RETURNS TRIGGER AS $$
BEGIN
    -- Only decrease inventory when order item is inserted
    IF TG_OP = 'INSERT' THEN
        PERFORM update_inventory_stock(NEW.menu_item_id, NEW.quantity, 'decrease');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_inventory_on_order ON order_items;
CREATE TRIGGER trigger_inventory_on_order
    AFTER INSERT ON order_items
    FOR EACH ROW EXECUTE FUNCTION handle_inventory_on_order();

-- Initialize inventory for existing menu items
INSERT INTO inventory (menu_item_id, current_stock, minimum_threshold, maximum_capacity)
SELECT 
    id,
    50, -- default stock
    10, -- minimum threshold
    100 -- maximum capacity
FROM menu_items
ON CONFLICT (menu_item_id) DO NOTHING;

-- ===============================================
-- FINAL MESSAGE
-- ===============================================

SELECT 
    '🎉 MODULE 1 SETUP COMPLETE!' as status,
    'Database schema, security policies, storage buckets, and inventory system are ready!' as message,
    'Next: Create your admin user and start building the backend API!' as next_steps;
