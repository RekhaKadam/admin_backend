import winston from 'winston';
import { config } from '../config/index.js';

const { combine, timestamp, errors, json, colorize, simple } = winston.format;

// Custom format for development
const devFormat = combine(
  colorize(),
  timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  errors({ stack: true }),
  simple()
);

// Custom format for production
const prodFormat = combine(
  timestamp(),
  errors({ stack: true }),
  json()
);

export const logger = winston.createLogger({
  level: config.nodeEnv === 'production' ? 'info' : 'debug',
  format: config.nodeEnv === 'production' ? prodFormat : devFormat,
  defaultMeta: { service: 'sonna-sweet-bites-api' },
  transports: [
    new winston.transports.Console(),
    
    // Write all logs with importance level of `error` or less to `error.log`
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error',
      format: prodFormat
    }),
    
    // Write all logs with importance level of `info` or less to `combined.log`
    new winston.transports.File({ 
      filename: 'logs/combined.log',
      format: prodFormat
    }),
  ],
});

// If we're not in production, log to the console with simple format
if (config.nodeEnv !== 'production') {
  logger.add(new winston.transports.Console({
    format: devFormat
  }));
}
