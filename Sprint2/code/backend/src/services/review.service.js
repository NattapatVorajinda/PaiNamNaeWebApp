const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const REVIEW_WINDOW_DAYS = 7;

/**
 * สร้างรีวิว — passenger เท่านั้น
 * ตรวจสอบ: booking เป็นของ passenger / route COMPLETED / booking CONFIRMED / ยังไม่เคยรีวิว / ไม่เกิน 7 วัน
 */
const createReview = async (passengerId, bookingId, { rating, comment }) => {
    // 1. ดึง booking + route
    const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
        include: {
            route: { select: { id: true, driverId: true, status: true, completedAt: true } },
            review: { select: { id: true } }
        }
    });

    if (!booking) throw new ApiError(404, 'ไม่พบ Booking');
    if (booking.passengerId !== passengerId) throw new ApiError(403, 'คุณไม่มีสิทธิ์รีวิว Booking นี้');

    // 2. Route ต้อง COMPLETED
    if (booking.route.status !== 'COMPLETED') {
        throw new ApiError(400, 'ไม่สามารถรีวิวได้ เนื่องจากการเดินทางยังไม่สิ้นสุด');
    }

    // 3. Booking ต้อง CONFIRMED
    if (booking.status !== 'CONFIRMED') {
        throw new ApiError(400, 'ไม่สามารถรีวิวได้ เนื่องจาก Booking ไม่ได้อยู่ในสถานะยืนยัน');
    }

    // 4. ยังไม่เคยรีวิว
    if (booking.review) {
        throw new ApiError(400, 'คุณรีวิว Booking นี้แล้ว');
    }

    // 5. ไม่เกิน 7 วัน
    const completedAt = booking.route.completedAt;
    if (!completedAt) {
        throw new ApiError(400, 'ไม่สามารถรีวิวได้ เนื่องจากยังไม่มีข้อมูลเวลาสิ้นสุดการเดินทาง');
    }

    const now = new Date();
    const diffMs = now.getTime() - completedAt.getTime();
    const diffDays = diffMs / (1000 * 60 * 60 * 24);
    if (diffDays > REVIEW_WINDOW_DAYS) {
        throw new ApiError(400, 'หมดระยะเวลารีวิว (เกิน 7 วัน)');
    }

    // 6. ตรวจสอบ rating 1–5
    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
        throw new ApiError(400, 'คะแนนต้องเป็นจำนวนเต็ม 1–5');
    }

    // 7. สร้าง review
    const review = await prisma.review.create({
        data: {
            bookingId,
            passengerId,
            driverId: booking.route.driverId,
            rating,
            comment: comment || null
        },
        include: {
            passenger: {
                select: { id: true, firstName: true, lastName: true, profilePicture: true }
            }
        }
    });

    return review;
};

/**
 * ดึงรีวิวทั้งหมดของ driver (public — ไม่ต้อง auth)
 */
const getReviewsByDriver = async (driverId, opts = {}) => {
    const { page = 1, limit = 20 } = opts;
    const skip = (page - 1) * limit;

    const [total, data] = await prisma.$transaction([
        prisma.review.count({ where: { driverId } }),
        prisma.review.findMany({
            where: { driverId },
            include: {
                passenger: {
                    select: { id: true, firstName: true, lastName: true, profilePicture: true }
                },
                booking: {
                    select: {
                        route: {
                            select: { routeSummary: true, startLocation: true, endLocation: true }
                        }
                    }
                }
            },
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit
        })
    ]);

    // คำนวณคะแนนเฉลี่ย
    const avgResult = await prisma.review.aggregate({
        where: { driverId },
        _avg: { rating: true }
    });

    return {
        data,
        averageRating: avgResult._avg.rating ? parseFloat(avgResult._avg.rating.toFixed(1)) : null,
        totalReviews: total,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit)
        }
    };
};

/**
 * ดึงรีวิวของ booking (เจ้าของ passenger/driver ดูได้)
 */
const getReviewByBooking = async (bookingId) => {
    const review = await prisma.review.findUnique({
        where: { bookingId },
        include: {
            passenger: {
                select: { id: true, firstName: true, lastName: true, profilePicture: true }
            }
        }
    });

    return review;
};

/**
 * ดึง bookings ที่สามารถรีวิวได้ (COMPLETED + CONFIRMED + ไม่เกิน 7 วัน + ยังไม่มี review)
 */
const getReviewableBookings = async (passengerId) => {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - REVIEW_WINDOW_DAYS);

    const bookings = await prisma.booking.findMany({
        where: {
            passengerId,
            status: 'CONFIRMED',
            review: null, // ยังไม่มี review
            route: {
                status: 'COMPLETED',
                completedAt: {
                    gte: sevenDaysAgo // ยังอยู่ในช่วง 7 วัน
                }
            }
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
                    }
                }
            }
        },
        orderBy: { createdAt: 'desc' }
    });

    return bookings;
};

module.exports = {
    createReview,
    getReviewsByDriver,
    getReviewByBooking,
    getReviewableBookings
};
