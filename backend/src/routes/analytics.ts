import express from 'express';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// @route   GET /api/v1/analytics/dashboard
// @desc    Get analytics dashboard data
// @access  Private (Admin only)
router.get('/dashboard', authenticate, authorize('admin'), async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      data: {
        totalRevenue: 0,
        totalOrders: 0,
        totalCustomers: 0,
        popularItems: [],
        salesTrend: [],
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

export default router;
