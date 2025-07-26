-- Initial data seeding for Sonna Sweet Bites
-- This file contains sample data to get started

-- Insert default categories
INSERT INTO public.categories (name, description, image_url, emoji, sort_order, is_active) VALUES
('Cakes', 'Delicious handcrafted cakes for every occasion', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/cakes.jpg', '🎂', 1, true),
('Pizza', 'Authentic wood-fired pizzas with fresh ingredients', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/pizza.jpg', '🍕', 2, true),
('Burgers', 'Juicy burgers made with premium ingredients', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/burgers.jpg', '🍔', 3, true),
('Pasta', 'Traditional Italian pasta dishes', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/pasta.jpg', '🍝', 4, true),
('Cold Drinks', 'Refreshing beverages to quench your thirst', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/cold-drinks.jpg', '🥤', 5, true),
('Hot Drinks', 'Warming beverages for any time of day', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/hot-drinks.jpg', '☕', 6, true),
('Small Bites', 'Perfect appetizers and snacks', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/small-bites.jpg', '🥪', 7, true),
('House Specials', 'Our signature dishes you cannot miss', 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/categories/house-specials.jpg', '⭐', 8, true)
ON CONFLICT (name) DO NOTHING;

-- Get category IDs for menu items
DO $$
DECLARE
    cakes_id UUID;
    pizza_id UUID;
    burgers_id UUID;
    pasta_id UUID;
    cold_drinks_id UUID;
    hot_drinks_id UUID;
    small_bites_id UUID;
    house_specials_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO cakes_id FROM public.categories WHERE name = 'Cakes';
    SELECT id INTO pizza_id FROM public.categories WHERE name = 'Pizza';
    SELECT id INTO burgers_id FROM public.categories WHERE name = 'Burgers';
    SELECT id INTO pasta_id FROM public.categories WHERE name = 'Pasta';
    SELECT id INTO cold_drinks_id FROM public.categories WHERE name = 'Cold Drinks';
    SELECT id INTO hot_drinks_id FROM public.categories WHERE name = 'Hot Drinks';
    SELECT id INTO small_bites_id FROM public.categories WHERE name = 'Small Bites';
    SELECT id INTO house_specials_id FROM public.categories WHERE name = 'House Specials';

    -- Insert sample menu items
    INSERT INTO public.menu_items (name, description, price, category_id, image_url, is_available, ingredients, allergens, nutritional_info, preparation_time, is_vegan, is_vegetarian, is_gluten_free) VALUES
    
    -- Cakes
    ('Chocolate Birthday Cake', 'Rich chocolate cake with buttercream frosting, perfect for celebrations', 25.99, cakes_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/cakes/chocolate-birthday-cake.jpg', true, ARRAY['flour', 'cocoa powder', 'eggs', 'butter', 'sugar'], ARRAY['gluten', 'eggs', 'dairy'], '{"calories": 450, "protein": 6, "carbohydrates": 65, "fat": 18}'::jsonb, 45, false, true, false),
    
    ('Red Velvet Cake', 'Classic red velvet with cream cheese frosting', 28.99, cakes_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/cakes/red-velvet-cake.jpg', true, ARRAY['flour', 'cocoa powder', 'red food coloring', 'buttermilk'], ARRAY['gluten', 'eggs', 'dairy'], '{"calories": 420, "protein": 5, "carbohydrates": 60, "fat": 16}'::jsonb, 50, false, true, false),
    
    ('Vegan Carrot Cake', 'Moist carrot cake with dairy-free cream cheese frosting', 26.99, cakes_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/cakes/vegan-carrot-cake.jpg', true, ARRAY['flour', 'carrots', 'coconut oil', 'maple syrup'], ARRAY['gluten', 'nuts'], '{"calories": 380, "protein": 4, "carbohydrates": 55, "fat": 14}'::jsonb, 55, true, true, false),
    
    -- Pizza
    ('Margherita Pizza', 'Classic pizza with fresh mozzarella, tomatoes, and basil', 16.99, pizza_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/pizza/margherita.jpg', true, ARRAY['pizza dough', 'mozzarella', 'tomatoes', 'basil'], ARRAY['gluten', 'dairy'], '{"calories": 280, "protein": 12, "carbohydrates": 35, "fat": 10}'::jsonb, 20, false, true, false),
    
    ('Pepperoni Pizza', 'Traditional pepperoni pizza with mozzarella cheese', 18.99, pizza_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/pizza/pepperoni.jpg', true, ARRAY['pizza dough', 'pepperoni', 'mozzarella', 'tomato sauce'], ARRAY['gluten', 'dairy'], '{"calories": 320, "protein": 14, "carbohydrates": 35, "fat": 14}'::jsonb, 22, false, false, false),
    
    ('Vegan Supreme Pizza', 'Plant-based pizza with vegetables and vegan cheese', 19.99, pizza_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/pizza/vegan-supreme.jpg', true, ARRAY['pizza dough', 'vegan cheese', 'bell peppers', 'mushrooms', 'olives'], ARRAY['gluten'], '{"calories": 260, "protein": 8, "carbohydrates": 38, "fat": 8}'::jsonb, 25, true, true, false),
    
    -- Burgers
    ('Classic Beef Burger', 'Juicy beef patty with lettuce, tomato, and our special sauce', 12.99, burgers_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/burgers/classic-beef.jpg', true, ARRAY['beef patty', 'lettuce', 'tomato', 'onion', 'pickle'], ARRAY['gluten'], '{"calories": 580, "protein": 28, "carbohydrates": 42, "fat": 32}'::jsonb, 15, false, false, false),
    
    ('Chicken Deluxe Burger', 'Grilled chicken breast with avocado and bacon', 14.99, burgers_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/burgers/chicken-deluxe.jpg', true, ARRAY['chicken breast', 'avocado', 'bacon', 'lettuce', 'tomato'], ARRAY['gluten'], '{"calories": 520, "protein": 35, "carbohydrates": 38, "fat": 26}'::jsonb, 18, false, false, false),
    
    ('Impossible Burger', 'Plant-based patty that tastes like meat', 15.99, burgers_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/burgers/impossible.jpg', true, ARRAY['impossible patty', 'lettuce', 'tomato', 'vegan mayo'], ARRAY['gluten'], '{"calories": 480, "protein": 19, "carbohydrates": 40, "fat": 24}'::jsonb, 16, true, true, false),
    
    -- Pasta
    ('Spaghetti Carbonara', 'Classic Italian pasta with eggs, cheese, and pancetta', 16.99, pasta_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/pasta/carbonara.jpg', true, ARRAY['spaghetti', 'eggs', 'parmesan', 'pancetta'], ARRAY['gluten', 'eggs', 'dairy'], '{"calories": 650, "protein": 25, "carbohydrates": 75, "fat": 28}'::jsonb, 20, false, false, false),
    
    ('Penne Arrabbiata', 'Spicy tomato sauce with garlic and red chili', 14.99, pasta_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/pasta/arrabbiata.jpg', true, ARRAY['penne pasta', 'tomatoes', 'garlic', 'chili'], ARRAY['gluten'], '{"calories": 420, "protein": 12, "carbohydrates": 85, "fat": 8}'::jsonb, 18, true, true, false),
    
    -- Cold Drinks
    ('Fresh Lemonade', 'Freshly squeezed lemonade with a hint of mint', 4.99, cold_drinks_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/drinks/lemonade.jpg', true, ARRAY['lemons', 'water', 'sugar', 'mint'], ARRAY[], '{"calories": 120, "protein": 0, "carbohydrates": 32, "fat": 0}'::jsonb, 5, true, true, true),
    
    ('Iced Coffee', 'Cold brew coffee served over ice', 5.99, cold_drinks_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/drinks/iced-coffee.jpg', true, ARRAY['coffee beans', 'water', 'ice'], ARRAY[], '{"calories": 5, "protein": 0, "carbohydrates": 1, "fat": 0}'::jsonb, 3, true, true, true),
    
    -- Hot Drinks
    ('Cappuccino', 'Rich espresso with steamed milk and foam', 5.99, hot_drinks_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/drinks/cappuccino.jpg', true, ARRAY['espresso', 'milk'], ARRAY['dairy'], '{"calories": 80, "protein": 4, "carbohydrates": 6, "fat": 4}'::jsonb, 8, false, true, true),
    
    ('Green Tea Latte', 'Ceremonial matcha with steamed oat milk', 6.99, hot_drinks_id, 'https://your-supabase-url.supabase.co/storage/v1/object/public/menu-images/drinks/matcha-latte.jpg', true, ARRAY['matcha powder', 'oat milk'], ARRAY[], '{"calories": 140, "protein": 3, "carbohydrates": 20, "fat": 5}'::jsonb, 10, true, true, true)
    
    ON CONFLICT (name) DO NOTHING;
    
END $$;
