const asyncHandler = require('express-async-handler');
const paymentService = require('../services/payment.service');
const { uploadToCloudinary } = require('../utils/cloudinary');
const ApiError = require('../utils/ApiError');

/**
 * GET /payments/booking/:bookingId — auth
 */
const getPaymentByBooking = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const payment = await paymentService.getPaymentByBooking(bookingId);

    if (!payment) {
        throw new ApiError(404, 'ไม่พบข้อมูลการชำระเงิน');
    }

    res.status(200).json({ success: true, data: payment });
});

/**
 * POST /payments/booking/:bookingId/pay — auth (passenger)
 * body: { method: 'CASH' | 'TRANSFER' }
 * file: slip (optional, for TRANSFER)
 */
const markAsPaid = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const { bookingId } = req.params;
    const method = req.body.method;

    if (!method || !['CASH', 'TRANSFER'].includes(method)) {
        throw new ApiError(400, 'กรุณาเลือกวิธีชำระเงิน (CASH หรือ TRANSFER)');
    }

    let slipUrl = null;
    if (req.file) {
        const result = await uploadToCloudinary(req.file.buffer, 'painamnae/payment-slips');
        slipUrl = result.url;
    }

    const payment = await paymentService.markAsPaid(bookingId, passengerId, {
        method,
        slipUrl,
    });

    res.status(200).json({ success: true, data: payment });
});

/**
 * PATCH /payments/booking/:bookingId/confirm — auth (driver)
 */
const confirmPayment = asyncHandler(async (req, res) => {
    const driverId = req.user.sub;
    const { bookingId } = req.params;

    const payment = await paymentService.confirmPayment(bookingId, driverId);

    res.status(200).json({ success: true, data: payment });
});

/**
 * GET /payments/booking/:bookingId/receipt — auth
 */
const getReceipt = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const payment = await paymentService.getReceipt(bookingId);

    res.status(200).json({ success: true, data: payment });
});

module.exports = {
    getPaymentByBooking,
    markAsPaid,
    confirmPayment,
    getReceipt,
};
