const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { BookingStatus, RouteStatus } = require('@prisma/client');

const REVIEW_WINDOW_DAYS = 7;

/**
 * GET /reviews/driver/:driverId — public
 */
const getDriverReviews = async (driverId, page = 1, limit = 20) => {
    const skip = (page - 1) * limit;

    const [reviews, totalReviews, avgResult] = await prisma.$transaction([
        prisma.review.findMany({
            where: { driverId },
            include: {
                passenger: {
                    select: { id: true, firstName: true, lastName: true, profilePicture: true }
                },
                booking: {
                    select: {
                        route: {
                            select: {
                                routeSummary: true,
                                startLocation: true,
                                endLocation: true,
                                driver: {
                                    select: { id: true, firstName: true, lastName: true, profilePicture: true }
                                }
                            }
                        }
                    }
                }
            },
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit,
        }),
        prisma.review.count({ where: { driverId } }),
        prisma.review.aggregate({
            where: { driverId },
            _avg: { rating: true },
        }),
    ]);

    const averageRating = avgResult._avg.rating
        ? Math.round(avgResult._avg.rating * 10) / 10
        : 0;

    return {
        data: reviews,
        averageRating,
        totalReviews,
        pagination: {
            page,
            limit,
            total: totalReviews,
            totalPages: Math.ceil(totalReviews / limit),
        },
    };
};

/**
 * GET /reviews/reviewable — auth (passenger)
 * Bookings ที่ route COMPLETED ภายใน 7 วัน + ยังไม่มี review
 */
const getReviewableBookings = async (passengerId) => {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - REVIEW_WINDOW_DAYS);

    const bookings = await prisma.booking.findMany({
        where: {
            passengerId,
            status: BookingStatus.CONFIRMED,
            review: null, // ยังไม่มี review
            route: {
                status: RouteStatus.COMPLETED,
                completedAt: { gte: cutoff }, // ภายใน 7 วัน
            },
        },
        include: {
            route: {
                select: {
                    id: true,
                    routeSummary: true,
                    startLocation: true,
                    endLocation: true,
                    completedAt: true,
                    driverId: true,
                    driver: {
                        select: { id: true, firstName: true, lastName: true, profilePicture: true }
                    },
                }
            },
        },
        orderBy: { createdAt: 'desc' },
    });

    return bookings;
};

/**
 * GET /reviews/booking/:bookingId — auth
 */
const getReviewByBookingId = async (bookingId) => {
    return prisma.review.findUnique({
        where: { bookingId },
        include: {
            passenger: {
                select: { id: true, firstName: true, lastName: true, profilePicture: true }
            },
        },
    });
};

/**
 * POST /reviews — auth (passenger)
 */
const createReview = async (passengerId, { bookingId, rating, comment }) => {
    // 1. ดึง booking + route
    const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
        include: {
            route: { select: { id: true, driverId: true, status: true, completedAt: true } },
            review: true,
        },
    });

    if (!booking) throw new ApiError(404, 'ไม่พบการจองนี้');
    if (booking.passengerId !== passengerId) throw new ApiError(403, 'คุณไม่ใช่ผู้โดยสารของการจองนี้');
    if (booking.status !== BookingStatus.CONFIRMED) throw new ApiError(400, 'การจองยังไม่ได้รับการยืนยัน');
    if (booking.route.status !== RouteStatus.COMPLETED) throw new ApiError(400, 'เส้นทางยังไม่เสร็จสิ้น');
    if (booking.review) throw new ApiError(400, 'คุณรีวิวการจองนี้ไปแล้ว');

    // 2. ตรวจ 7-day window
    if (booking.route.completedAt) {
        const cutoff = new Date();
        cutoff.setDate(cutoff.getDate() - REVIEW_WINDOW_DAYS);
        if (booking.route.completedAt < cutoff) {
            throw new ApiError(400, 'หมดเวลารีวิวแล้ว (เกิน 7 วัน)');
        }
    }

    // 3. สร้าง review
    const review = await prisma.review.create({
        data: {
            bookingId,
            passengerId,
            driverId: booking.route.driverId,
            rating,
            comment: comment || null,
        },
        include: {
            passenger: {
                select: { id: true, firstName: true, lastName: true, profilePicture: true }
            },
        },
    });

    return review;
};

/**
 * ดึงค่าเฉลี่ยรีวิวของ driver (สำหรับใช้ภายใน)
 */
const getDriverRatingSummary = async (driverId) => {
    const result = await prisma.review.aggregate({
        where: { driverId },
        _avg: { rating: true },
        _count: true,
    });

    return {
        averageRating: result._avg.rating ? Math.round(result._avg.rating * 10) / 10 : 0,
        totalReviews: result._count,
    };
};

/**
 * GET /reviews/me — auth (driver)
 * รีวิวทั้งหมดที่คนอื่นเขียนให้ผู้ใช้ (ในฐานะคนขับ)
 */
const getMyReviews = async (driverId, page = 1, limit = 10) => {
    const skip = (page - 1) * limit;

    const [reviews, totalReviews, avgResult] = await prisma.$transaction([
        prisma.review.findMany({
            where: { driverId },
            include: {
                passenger: {
                    select: { id: true, firstName: true, lastName: true, profilePicture: true }
                },
                booking: {
                    select: {
                        route: {
                            select: {
                                routeSummary: true,
                                startLocation: true,
                                endLocation: true,
                                departureTime: true,
                            }
                        }
                    }
                }
            },
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit,
        }),
        prisma.review.count({ where: { driverId } }),
        prisma.review.aggregate({
            where: { driverId },
            _avg: { rating: true },
        }),
    ]);

    const averageRating = avgResult._avg.rating
        ? Math.round(avgResult._avg.rating * 10) / 10
        : 0;

    return {
        data: reviews,
        averageRating,
        totalReviews,
        pagination: {
            page,
            limit,
            total: totalReviews,
            totalPages: Math.ceil(totalReviews / limit),
        },
    };
};

module.exports = {
    getDriverReviews,
    getReviewableBookings,
    getReviewByBookingId,
    createReview,
    getDriverRatingSummary,
    getMyReviews,
};
