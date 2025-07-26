import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/index.js';
import { UserService } from '../models/User.js';
import { supabaseAdmin } from '../config/database.js';

export interface AuthenticatedRequest extends Request {
  user?: any;
}

export const authenticate = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    let token: string | undefined;

    // Get token from header
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      res.status(401).json({
        success: false,
        message: 'Not authorized to access this route',
      });
      return;
    }

    try {
      // First try to verify with Supabase JWT
      const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
      
      if (error || !user) {
        // Fallback to custom JWT verification
        const decoded = jwt.verify(token, config.jwtSecret) as any;
        
        // Get user from database
        const dbUser = await UserService.findById(decoded.id);
        
        if (!dbUser) {
          res.status(401).json({
            success: false,
            message: 'Not authorized to access this route',
          });
          return;
        }

        req.user = dbUser;
      } else {
        // Get user profile from database
        const dbUser = await UserService.findById(user.id);
        
        if (!dbUser) {
          res.status(401).json({
            success: false,
            message: 'User profile not found',
          });
          return;
        }

        req.user = dbUser;
      }

      next();
    } catch (jwtError) {
      res.status(401).json({
        success: false,
        message: 'Not authorized to access this route',
      });
    }
  } catch (error) {
    next(error);
  }
};

export const authorize = (...roles: string[]) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Not authorized to access this route',
      });
      return;
    }

    if (!roles.includes(req.user.role)) {
      res.status(403).json({
        success: false,
        message: `User role ${req.user.role} is not authorized to access this route`,
      });
      return;
    }

    next();
  };
};
