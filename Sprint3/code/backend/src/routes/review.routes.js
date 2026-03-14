const express = require('express');
const { protect } = require('../middlewares/auth');
const reviewController = require('../controllers/review.controller');
const validate = require('../middlewares/validate');
const reviewUpload = require('../middlewares/reviewUpload.middleware');
const {
    driverIdParamSchema,
    bookingIdParamSchema,
    reviewQuerySchema,
} = require('../validations/review.validation');

const router = express.Router();

// GET /reviews/reviewable — auth (passenger), must be before /:driverId
router.get(
    '/reviewable',
    protect,
    reviewController.getReviewableBookings
);

// GET /reviews/me — auth (passenger), must be before /:driverId
router.get(
    '/me',
    protect,
    reviewController.getMyReviews
);

// GET /reviews/booking/:bookingId — auth
router.get(
    '/booking/:bookingId',
    protect,
    validate({ params: bookingIdParamSchema }),
    reviewController.getReviewByBookingId
);

// GET /reviews/driver/:driverId — public
router.get(
    '/driver/:driverId',
    validate({ params: driverIdParamSchema, query: reviewQuerySchema }),
    reviewController.getDriverReviews
);

// POST /reviews — auth (passenger) + multipart upload (max 5 files)
router.post(
    '/',
    protect,
    reviewUpload.array('media', 5),
    reviewController.createReview
);

module.exports = router;
