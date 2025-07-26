# Sonna Sweet Bites Backend API

A robust Node.js/Express backend API for the Sonna Sweet Bites admin panel and food ordering system.

## Features

- **Authentication & Authorization**: JWT-based auth with role-based access control
- **User Management**: Admin can manage customers and staff
- **Menu Management**: Full CRUD operations for menu items
- **Order Management**: Order processing and tracking
- **File Upload**: Image upload for menu items
- **Analytics**: Dashboard analytics for business insights
- **Security**: Helmet, CORS, rate limiting, input validation
- **Logging**: Winston-based logging system
- **Database**: MongoDB with Mongoose ODM

## Technology Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT (JSON Web Tokens)
- **File Upload**: Multer + Cloudinary
- **Validation**: Joi
- **Security**: Helmet, CORS, bcryptjs
- **Logging**: Winston
- **Email**: Nodemailer

## Quick Start

### Prerequisites

- Node.js (v18 or higher)
- MongoDB (local or MongoDB Atlas)
- npm or yarn

### Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Update the `.env` file with your configuration:
```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/sonna-sweet-bites

# JWT Secrets (Change these in production!)
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key

# Admin Credentials
ADMIN_EMAIL=admin@sonnasweet.com
ADMIN_PASSWORD=Admin@123456
```

### Running the Application

1. **Development mode** (with hot reload):
```bash
npm run dev
```

2. **Production build**:
```bash
npm run build
npm start
```

3. **Database migration** (creates admin user):
```bash
npm run db:migrate
```

4. **Seed sample data**:
```bash
npm run db:seed
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/me` - Get current user

### Admin Panel
- `GET /api/v1/admin/dashboard` - Dashboard data
- `GET /api/v1/admin/users` - Get all users
- `PUT /api/v1/admin/users/:id/status` - Update user status

### Menu Management
- `GET /api/v1/menu` - Get menu items (public)
- `POST /api/v1/menu` - Create menu item (admin)
- `PUT /api/v1/menu/:id` - Update menu item (admin)
- `DELETE /api/v1/menu/:id` - Delete menu item (admin)

### Orders
- `GET /api/v1/orders` - Get orders
- `POST /api/v1/orders` - Create order

### Analytics
- `GET /api/v1/analytics/dashboard` - Analytics data (admin)

### File Upload
- `POST /api/v1/upload/image` - Upload image (admin/staff)

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 5000 |
| `NODE_ENV` | Environment | development |
| `MONGODB_URI` | MongoDB connection string | mongodb://localhost:27017/sonna-sweet-bites |
| `JWT_SECRET` | JWT secret key | - |
| `ADMIN_EMAIL` | Default admin email | admin@sonnasweet.com |
| `ADMIN_PASSWORD` | Default admin password | Admin@123456 |

## Project Structure

```
src/
├── config/          # Configuration files
│   ├── database.ts  # Database connection
│   └── index.ts     # Environment config
├── controllers/     # Route controllers
├── middleware/      # Custom middleware
│   ├── auth.ts      # Authentication middleware
│   ├── errorHandler.ts
│   └── notFound.ts
├── models/          # Database models
│   └── User.ts      # User model
├── routes/          # API routes
│   ├── auth.ts
│   ├── admin.ts
│   ├── menu.ts
│   ├── orders.ts
│   ├── users.ts
│   ├── analytics.ts
│   └── upload.ts
├── services/        # Business logic
├── utils/           # Utility functions
│   └── logger.ts    # Winston logger
├── types/           # TypeScript types
└── server.ts        # Main server file
```

## Security Features

- **Helmet**: Sets various HTTP headers for security
- **CORS**: Configurable cross-origin resource sharing
- **Rate Limiting**: Prevents abuse with configurable limits
- **Input Validation**: Joi validation for request data
- **Password Hashing**: bcryptjs for secure password storage
- **JWT Authentication**: Secure token-based authentication

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run lint` - Run ESLint
- `npm test` - Run tests
- `npm run db:migrate` - Run database migrations
- `npm run db:seed` - Seed sample data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Run tests and linting
6. Submit a pull request

## License

This project is licensed under the MIT License.
