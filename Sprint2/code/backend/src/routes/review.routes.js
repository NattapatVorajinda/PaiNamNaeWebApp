const express = require('express');
const validate = require('../middlewares/validate');
const { protect } = require('../middlewares/auth');
const reviewController = require('../controllers/review.controller');
const {
    driverIdParamSchema,
    bookingIdParamSchema,
    createReviewSchema,
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

// POST /reviews — auth (passenger)
router.post(
    '/',
    protect,
    validate({ body: createReviewSchema }),
    reviewController.createReview
);

module.exports = router;
