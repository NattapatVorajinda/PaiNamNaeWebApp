const asyncHandler = require("express-async-handler");
const reviewService = require("../services/review.service");
const ApiError = require("../utils/ApiError");

/**
 * POST /reviews — passenger สร้างรีวิว
 */
const createReview = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const { bookingId, rating, comment } = req.body;

    if (!bookingId) throw new ApiError(400, 'bookingId is required');

    const review = await reviewService.createReview(passengerId, bookingId, {
        rating,
        comment
    });

    res.status(201).json({ success: true, data: review });
});

/**
 * GET /reviews/driver/:driverId — public ดูรีวิวของ driver
 */
const getReviewsByDriver = asyncHandler(async (req, res) => {
    const { driverId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    const result = await reviewService.getReviewsByDriver(driverId, { page, limit });

    res.status(200).json({ success: true, ...result });
});

/**
 * GET /reviews/booking/:bookingId — passenger/driver ดูรีวิวของ booking
 */
const getReviewByBooking = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const review = await reviewService.getReviewByBooking(bookingId);

    if (!review) {
        return res.status(200).json({ success: true, data: null });
    }

    // ตรวจสิทธิ์: เฉพาะ passenger หรือ driver ของ booking
    const userId = req.user.sub;
    if (review.passengerId !== userId && review.driverId !== userId) {
        throw new ApiError(403, 'Forbidden');
    }

    res.status(200).json({ success: true, data: review });
});

/**
 * GET /reviews/reviewable — ดึง bookings ที่รีวิวได้ (สำหรับ popup)
 */
const getReviewableBookings = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const bookings = await reviewService.getReviewableBookings(passengerId);

    res.status(200).json({ success: true, data: bookings });
});

module.exports = {
    createReview,
    getReviewsByDriver,
    getReviewByBooking,
    getReviewableBookings
};
