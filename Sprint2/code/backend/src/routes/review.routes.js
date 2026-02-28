const express = require('express');
const { protect } = require('../middlewares/auth');
const reviewController = require('../controllers/review.controller');

const router = express.Router();

// --- Public Route (ไม่ต้อง auth) ---
// GET /reviews/driver/:driverId — ทุกคนดูรีวิวของ driver ได้
router.get(
    '/driver/:driverId',
    reviewController.getReviewsByDriver
);

// --- Protected Routes (ต้อง auth) ---
// GET /reviews/reviewable — ดึง bookings ที่รีวิวได้ (สำหรับ popup)
router.get(
    '/reviewable',
    protect,
    reviewController.getReviewableBookings
);

// GET /reviews/booking/:bookingId — ดูรีวิวของ booking
router.get(
    '/booking/:bookingId',
    protect,
    reviewController.getReviewByBooking
);

// POST /reviews — สร้างรีวิว
router.post(
    '/',
    protect,
    reviewController.createReview
);

// ไม่มี PUT / PATCH / DELETE — ป้องกันการปั่นรีวิว

module.exports = router;
