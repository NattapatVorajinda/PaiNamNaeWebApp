const asyncHandler = require('express-async-handler');
const reviewService = require('../services/review.service');
const { uploadToCloudinary } = require('../utils/cloudinary');
const ApiError = require('../utils/ApiError');

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

    // multipart/form-data sends fields as strings — parse them
    const bookingId = req.body.bookingId;
    const rating = parseInt(req.body.rating, 10);
    const comment = req.body.comment || undefined;

    // Validate required fields
    if (!bookingId || typeof bookingId !== 'string' || bookingId.length === 0) {
        throw new ApiError(400, 'bookingId is required');
    }
    if (isNaN(rating) || rating < 1 || rating > 5) {
        throw new ApiError(400, 'rating ต้องอยู่ระหว่าง 1-5');
    }

    // Upload media files to Cloudinary (if any)
    let mediaUrls = [];
    if (req.files && req.files.length > 0) {
        const uploadPromises = req.files.map(async (file) => {
            const result = await uploadToCloudinary(file.buffer, 'painamnae/reviews');
            // Determine file type category
            let type = 'image';
            if (file.mimetype.startsWith('audio/')) type = 'audio';
            else if (file.mimetype.startsWith('video/')) type = 'video';

            return {
                url: result.url,
                publicId: result.public_id,
                type,
                originalName: file.originalname,
            };
        });
        mediaUrls = await Promise.all(uploadPromises);
    }

    const review = await reviewService.createReview(passengerId, {
        bookingId,
        rating,
        comment,
        mediaUrls: mediaUrls.length > 0 ? mediaUrls : undefined,
    });

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
