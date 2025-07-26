# Sonna Restaurant App 🍕

A modern food delivery and restaurant ordering application built with React, TypeScript, and Tailwind CSS.

## 📋 Complete Development Guide

**🎯 [View the Complete Development Guide](./guide.md)** - Essential reading for all contributors!

The comprehensive guide covers:
- **Design System & Style Guide** - Colors, typography, component patterns
- **Frontend Architecture** - React patterns, state management, data flow
- **Backend Integration** - API specs, database schema, real-time features
- **Admin Dashboard** - Restaurant management interface and workflows
- **Kitchen Staff Interface** - Order management and kitchen display system
- **Development Standards** - Code quality, testing, and performance requirements

## 🚀 Features

### 🍽️ Menu & Ordering
- **Interactive Menu**: Browse through categorized food items with detailed descriptions
- **Smart Search**: Find your favorite dishes quickly with real-time search
- **Shopping Cart**: Add items, customize orders, and manage quantities
- **Wishlist**: Save favorite items for later ordering

### 👤 User Experience
- **Loyalty Points**: Earn and track rewards with every order
- **Pre-booking System**: Schedule orders in advance
  - Birthday cake pre-orders with customization
  - Regular meal scheduling for future dates
- **Order History**: Track past and current orders
- **User Profile**: Manage personal information, addresses, and preferences

### 📱 Mobile-First Design
- Responsive design optimized for mobile devices
- Bottom navigation for easy thumb navigation
- Floating cart for quick access
- Touch-friendly interface

## 🛠️ Tech Stack

- **Frontend**: React 18 with TypeScript
- **Styling**: Tailwind CSS with custom design system
- **UI Components**: Shadcn/ui component library
- **State Management**: React Context API
- **Routing**: React Router DOM
- **Build Tool**: Vite
- **Icons**: Lucide React
- **Notifications**: Sonner toast notifications

## 🏃‍♂️ Quick Start

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn

### Installation

1. **Clone the repository**
   ```bash
   git clone <YOUR_GIT_URL>
   cd <YOUR_PROJECT_NAME>
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   ```
   http://localhost:8080
   ```

## 📂 Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── ui/             # Shadcn/ui components
│   ├── Header.tsx      # Main navigation header
│   ├── BottomNav.tsx   # Mobile bottom navigation
│   ├── FoodCard.tsx    # Menu item display component
│   └── ...
├── pages/              # Route components
│   ├── Index.tsx       # Home page
│   ├── Menu.tsx        # Menu browsing
│   ├── Cart.tsx        # Shopping cart
│   ├── Profile.tsx     # User profile
│   ├── PreBook.tsx     # Pre-booking system
│   └── ...
├── contexts/           # React Context providers
│   ├── CartContext.tsx # Shopping cart state
│   └── WishlistContext.tsx # Wishlist state
├── data/               # Static data and types
├── hooks/              # Custom React hooks
└── lib/                # Utility functions
```

## 🎨 Design System

The app uses a custom design system built with Tailwind CSS featuring:
- **HSL Color Palette**: Semantic color tokens for consistent theming
- **Typography Scale**: Responsive text sizing and hierarchy  
- **Component Variants**: Flexible UI components with multiple styles
- **Dark/Light Theme**: Automatic theme switching support

## 📱 Key Pages

- **Home** (`/`): Hero section, featured items, and category navigation
- **Menu** (`/menu`): Full menu browsing with category filters
- **Search** (`/search`): Real-time food item search
- **Cart** (`/cart`): Shopping cart management and checkout
- **Pre-book** (`/prebook`): Schedule future orders and birthday cakes
- **Profile** (`/profile`): User account and preferences
- **Orders** (`/orders`): Order history and tracking
- **Wishlist** (`/wishlist`): Saved favorite items

## 🚀 Deployment



### Custom Hosting
The app generates standard web assets that can be deployed to any static hosting service:
- Netlify
- Vercel  
- AWS S3 + CloudFront
- GitHub Pages

```bash
npm run build  # Generate production build
```

## 🌐 Custom Domain

To connect a custom domain:
1. Navigate to **Project > Settings > Domains** in Lovable
2. Click **Connect Domain**
3. Follow the DNS configuration steps

*Note: Custom domains require a paid Lovable plan*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License


Please ...

---# admin_backend
