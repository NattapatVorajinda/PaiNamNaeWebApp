const asyncHandler = require('express-async-handler');
const reviewService = require('../services/review.service');

const getDriverReviews = asyncHandler(async (req, res) => {
    const { driverId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    const result = await reviewService.getDriverReviews(driverId, page, limit);
    res.status(200).json({
        success: true,
        ...result,
    });
});

const getReviewableBookings = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const bookings = await reviewService.getReviewableBookings(passengerId);
    res.status(200).json({
        success: true,
        data: bookings,
    });
});

const getReviewByBookingId = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const review = await reviewService.getReviewByBookingId(bookingId);
    res.status(200).json({
        success: true,
        data: review,
    });
});

const createReview = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const { bookingId, rating, comment } = req.body;

    const review = await reviewService.createReview(passengerId, { bookingId, rating, comment });
    res.status(201).json({
        success: true,
        data: review,
    });
});

const getMyReviews = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const result = await reviewService.getMyReviews(passengerId, page, limit);
    res.status(200).json({
        success: true,
        ...result,
    });
});

module.exports = {
    getDriverReviews,
    getReviewableBookings,
    getReviewByBookingId,
    createReview,
    getMyReviews,
};
