const { z } = require("zod");

const driverIdParamSchema = z.object({
    driverId: z.string().min(1, "driverId is required"),
});

const bookingIdParamSchema = z.object({
    bookingId: z.string().min(1, "bookingId is required"),
});

const createReviewSchema = z.object({
    bookingId: z.string().min(1, "bookingId is required"),
    rating: z.number().int().min(1).max(5),
    comment: z.string().max(500).optional().nullable(),
});

const reviewQuerySchema = z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
});

module.exports = {
    driverIdParamSchema,
    bookingIdParamSchema,
    createReviewSchema,
    reviewQuerySchema,
};
