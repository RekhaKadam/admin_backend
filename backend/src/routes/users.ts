import express from 'express';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// @route   GET /api/v1/users
// @desc    Get all users (admin only)
// @access  Private (Admin only)
router.get('/', authenticate, authorize('admin'), async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      data: [],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

export default router;
