import { supabaseAdmin } from '../config/database.js';
import { logger } from '../utils/logger.js';

export const seedDatabase = async (): Promise<void> => {
  try {
    logger.info('🌱 Starting database seeding...');

    // Seed categories
    await seedCategories();
    
    // Seed menu items
    await seedMenuItems();
    
    logger.info('✅ Database seeding completed successfully');
  } catch (error) {
    logger.error('❌ Database seeding failed:', error);
    throw error;
  }
};

const seedCategories = async (): Promise<void> => {
  const categories = [
    {
      name: 'Cakes',
      description: 'Delicious handcrafted cakes for every occasion',
      image_url: '/assets/cakes-category.jpg',
      sort_order: 1,
      is_active: true,
    },
    {
      name: 'Pizza',
      description: 'Authentic wood-fired pizzas with fresh ingredients',
      image_url: '/assets/pizza-category.jpg',
      sort_order: 2,
      is_active: true,
    },
    {
      name: 'Burgers',
      description: 'Juicy burgers made with premium ingredients',
      image_url: '/assets/burgers-category.jpg',
      sort_order: 3,
      is_active: true,
    },
    {
      name: 'Pasta',
      description: 'Traditional Italian pasta dishes',
      image_url: '/assets/pasta-category.jpg',
      sort_order: 4,
      is_active: true,
    },
    {
      name: 'Cold Drinks',
      description: 'Refreshing beverages to quench your thirst',
      image_url: '/assets/cold-drinks-category.jpg',
      sort_order: 5,
      is_active: true,
    },
    {
      name: 'Hot Drinks',
      description: 'Warming beverages for any time of day',
      image_url: '/assets/hot-drinks-category.jpg',
      sort_order: 6,
      is_active: true,
    },
  ];

  const { error } = await supabaseAdmin
    .from('categories')
    .upsert(categories, { onConflict: 'name' });

  if (error) {
    throw new Error(`Failed to seed categories: ${error.message}`);
  }

  logger.info('📂 Categories seeded successfully');
};

const seedMenuItems = async (): Promise<void> => {
  // Get category IDs
  const { data: categories } = await supabaseAdmin
    .from('categories')
    .select('id, name');

  if (!categories) return;

  const categoryMap = categories.reduce((acc, cat) => {
    acc[cat.name] = cat.id;
    return acc;
  }, {} as Record<string, string>);

  const menuItems = [
    // Cakes
    {
      name: 'Chocolate Birthday Cake',
      description: 'Rich chocolate cake with buttercream frosting, perfect for celebrations',
      price: 25.99,
      category: categoryMap['Cakes'],
      image_url: '/assets/birthday-cake.jpg',
      is_available: true,
      ingredients: ['flour', 'cocoa powder', 'eggs', 'butter', 'sugar'],
      allergens: ['gluten', 'eggs', 'dairy'],
      preparation_time: 45,
    },
    {
      name: 'Red Velvet Cake',
      description: 'Classic red velvet with cream cheese frosting',
      price: 28.99,
      category: categoryMap['Cakes'],
      is_available: true,
      ingredients: ['flour', 'cocoa powder', 'red food coloring', 'buttermilk'],
      allergens: ['gluten', 'eggs', 'dairy'],
      preparation_time: 50,
    },
    
    // Pizza
    {
      name: 'Margherita Pizza',
      description: 'Classic pizza with fresh mozzarella, tomatoes, and basil',
      price: 16.99,
      category: categoryMap['Pizza'],
      is_available: true,
      ingredients: ['pizza dough', 'mozzarella', 'tomatoes', 'basil'],
      allergens: ['gluten', 'dairy'],
      preparation_time: 20,
    },
    {
      name: 'Pepperoni Pizza',
      description: 'Traditional pepperoni pizza with mozzarella cheese',
      price: 18.99,
      category: categoryMap['Pizza'],
      is_available: true,
      ingredients: ['pizza dough', 'pepperoni', 'mozzarella', 'tomato sauce'],
      allergens: ['gluten', 'dairy'],
      preparation_time: 22,
    },
    
    // Burgers
    {
      name: 'Classic Beef Burger',
      description: 'Juicy beef patty with lettuce, tomato, and our special sauce',
      price: 12.99,
      category: categoryMap['Burgers'],
      is_available: true,
      ingredients: ['beef patty', 'lettuce', 'tomato', 'onion', 'pickle'],
      allergens: ['gluten'],
      preparation_time: 15,
    },
    
    // Cold Drinks
    {
      name: 'Fresh Lemonade',
      description: 'Freshly squeezed lemonade with a hint of mint',
      price: 4.99,
      category: categoryMap['Cold Drinks'],
      is_available: true,
      ingredients: ['lemons', 'water', 'sugar', 'mint'],
      allergens: [],
      preparation_time: 5,
    },
    
    // Hot Drinks
    {
      name: 'Cappuccino',
      description: 'Rich espresso with steamed milk and foam',
      price: 5.99,
      category: categoryMap['Hot Drinks'],
      is_available: true,
      ingredients: ['espresso', 'milk'],
      allergens: ['dairy'],
      preparation_time: 8,
    },
  ];

  const { error } = await supabaseAdmin
    .from('menu_items')
    .upsert(menuItems, { onConflict: 'name' });

  if (error) {
    throw new Error(`Failed to seed menu items: ${error.message}`);
  }

  logger.info('🍕 Menu items seeded successfully');
};

// Run seeding if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  seedDatabase()
    .then(() => {
      logger.info('✅ Seeding completed successfully');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('❌ Seeding failed:', error);
      process.exit(1);
    });
}
