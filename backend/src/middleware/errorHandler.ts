import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger.js';

interface ErrorWithStatus extends Error {
  status?: number;
  statusCode?: number;
  code?: string | number;
  path?: string;
  value?: any;
  errors?: any;
}

export const errorHandler = (
  err: ErrorWithStatus,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  logger.error(err);

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = { name: 'CastError', message } as ErrorWithStatus;
    error.status = 404;
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = { name: 'DuplicateField', message } as ErrorWithStatus;
    error.status = 400;
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors || {}).map((val: any) => val.message);
    error = { name: 'ValidationError', message } as ErrorWithStatus;
    error.status = 400;
  }

  // JWT error
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = { name: 'JsonWebTokenError', message } as ErrorWithStatus;
    error.status = 401;
  }

  // JWT expired error
  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = { name: 'TokenExpiredError', message } as ErrorWithStatus;
    error.status = 401;
  }

  res.status(error.status || error.statusCode || 500).json({
    success: false,
    error: {
      message: error.message || 'Server Error',
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
};
