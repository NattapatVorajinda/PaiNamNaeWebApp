const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { PaymentStatus, BookingStatus, RouteStatus } = require('@prisma/client');

/**
 * สร้าง Payment records สำหรับทุก Booking ที่ CONFIRMED เมื่อ Route COMPLETED
 */
const createPaymentsForRoute = async (routeId) => {
    const route = await prisma.route.findUnique({
        where: { id: routeId },
        include: {
            bookings: {
                where: { status: BookingStatus.CONFIRMED },
                include: { payment: true },
            },
        },
    });

    if (!route) return [];

    const payments = [];
    for (const booking of route.bookings) {
        // ข้ามถ้ามี payment อยู่แล้ว
        if (booking.payment) continue;

        const amount = route.pricePerSeat * booking.numberOfSeats;
        const payment = await prisma.payment.create({
            data: {
                bookingId: booking.id,
                amount,
                status: PaymentStatus.PENDING,
            },
        });
        payments.push(payment);
    }

    return payments;
};

/**
 * ดึง Payment ตาม bookingId — ถ้ายังไม่มี + route COMPLETED → สร้างให้อัตโนมัติ
 */
const getPaymentByBooking = async (bookingId) => {
    let payment = await prisma.payment.findUnique({
        where: { bookingId },
        include: {
            booking: {
                include: {
                    route: {
                        select: {
                            id: true,
                            routeSummary: true,
                            startLocation: true,
                            endLocation: true,
                            departureTime: true,
                            pricePerSeat: true,
                            status: true,
                            driverId: true,
                            driver: {
                                select: {
                                    id: true,
                                    firstName: true,
                                    lastName: true,
                                    promptPayNumber: true,
                                    promptPayQrUrl: true,
                                },
                            },
                        },
                    },
                    passenger: {
                        select: { id: true, firstName: true, lastName: true },
                    },
                },
            },
        },
    });

    // ถ้ายังไม่มี Payment → ตรวจว่า booking + route มีอยู่จริงไหม แล้วสร้างให้
    if (!payment) {
        const booking = await prisma.booking.findUnique({
            where: { id: bookingId },
            include: {
                route: { select: { pricePerSeat: true, status: true } },
            },
        });

        if (booking && booking.route && booking.route.status === 'COMPLETED' && booking.status === 'CONFIRMED') {
            const amount = booking.route.pricePerSeat * booking.numberOfSeats;
            await prisma.payment.create({
                data: {
                    bookingId: booking.id,
                    amount,
                    status: 'PENDING',
                },
            });

            // ดึงใหม่พร้อม relations
            payment = await prisma.payment.findUnique({
                where: { bookingId },
                include: {
                    booking: {
                        include: {
                            route: {
                                select: {
                                    id: true,
                                    routeSummary: true,
                                    startLocation: true,
                                    endLocation: true,
                                    departureTime: true,
                                    pricePerSeat: true,
                                    status: true,
                                    driverId: true,
                                    driver: {
                                        select: {
                                            id: true,
                                            firstName: true,
                                            lastName: true,
                                            promptPayNumber: true,
                                            promptPayQrUrl: true,
                                        },
                                    },
                                },
                            },
                            passenger: {
                                select: { id: true, firstName: true, lastName: true },
                            },
                        },
                    },
                },
            });
        }
    }

    return payment;
};

/**
 * ผู้โดยสารแจ้งจ่ายเงิน
 */
const markAsPaid = async (bookingId, passengerId, { method, slipUrl }) => {
    const payment = await prisma.payment.findUnique({
        where: { bookingId },
        include: { booking: true },
    });

    if (!payment) throw new ApiError(404, 'ไม่พบข้อมูลการชำระเงิน');
    if (payment.booking.passengerId !== passengerId) {
        throw new ApiError(403, 'คุณไม่ใช่ผู้โดยสารของการจองนี้');
    }
    if (payment.status !== PaymentStatus.PENDING) {
        throw new ApiError(400, 'การชำระเงินนี้ดำเนินการไปแล้ว');
    }
    if (method === 'TRANSFER' && !slipUrl) {
        throw new ApiError(400, 'กรุณาแนบสลิปโอนเงิน');
    }

    return prisma.payment.update({
        where: { bookingId },
        data: {
            method,
            status: PaymentStatus.PAID,
            slipUrl: slipUrl || null,
            paidAt: new Date(),
        },
    });
};

/**
 * คนขับยืนยันรับเงิน → generate เลขที่ใบเสร็จ
 */
const confirmPayment = async (bookingId, driverId) => {
    const payment = await prisma.payment.findUnique({
        where: { bookingId },
        include: {
            booking: {
                include: {
                    route: { select: { driverId: true } },
                },
            },
        },
    });

    if (!payment) throw new ApiError(404, 'ไม่พบข้อมูลการชำระเงิน');
    if (payment.booking.route.driverId !== driverId) {
        throw new ApiError(403, 'คุณไม่ใช่คนขับของเส้นทางนี้');
    }
    if (payment.status === PaymentStatus.CONFIRMED) {
        throw new ApiError(400, 'ยืนยันรับเงินไปแล้ว');
    }
    if (payment.status !== PaymentStatus.PAID) {
        throw new ApiError(400, 'ผู้โดยสารยังไม่ได้แจ้งชำระเงิน');
    }

    // Generate receipt number: REC-YYYYMMDD-XXX
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10).replace(/-/g, '');
    const count = await prisma.payment.count({
        where: {
            receiptNumber: { startsWith: `REC-${dateStr}` },
        },
    });
    const receiptNumber = `REC-${dateStr}-${String(count + 1).padStart(3, '0')}`;

    return prisma.payment.update({
        where: { bookingId },
        data: {
            status: PaymentStatus.CONFIRMED,
            confirmedAt: now,
            receiptNumber,
        },
    });
};

/**
 * ดึงข้อมูลใบเสร็จ
 */
const getReceipt = async (bookingId) => {
    const payment = await prisma.payment.findUnique({
        where: { bookingId },
        include: {
            booking: {
                include: {
                    route: {
                        select: {
                            routeSummary: true,
                            startLocation: true,
                            endLocation: true,
                            departureTime: true,
                            pricePerSeat: true,
                            completedAt: true,
                            driver: {
                                select: { id: true, firstName: true, lastName: true },
                            },
                        },
                    },
                    passenger: {
                        select: { id: true, firstName: true, lastName: true },
                    },
                },
            },
        },
    });

    if (!payment) throw new ApiError(404, 'ไม่พบข้อมูลการชำระเงิน');
    if (payment.status !== PaymentStatus.CONFIRMED) {
        throw new ApiError(400, 'ยังไม่ได้ยืนยันการชำระเงิน');
    }

    return payment;
};

module.exports = {
    createPaymentsForRoute,
    getPaymentByBooking,
    markAsPaid,
    confirmPayment,
    getReceipt,
};
