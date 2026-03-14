const express = require('express');
const { protect } = require('../middlewares/auth');
const paymentController = require('../controllers/payment.controller');
const paymentUpload = require('../middlewares/paymentUpload.middleware');

const router = express.Router();

// GET /payments/booking/:bookingId — ดึงข้อมูล payment
router.get(
    '/booking/:bookingId',
    protect,
    paymentController.getPaymentByBooking
);

// POST /payments/booking/:bookingId/pay — ผู้โดยสารแจ้งจ่ายเงิน
router.post(
    '/booking/:bookingId/pay',
    protect,
    paymentUpload.single('slip'),
    paymentController.markAsPaid
);

// PATCH /payments/booking/:bookingId/confirm — คนขับยืนยันรับเงิน
router.patch(
    '/booking/:bookingId/confirm',
    protect,
    paymentController.confirmPayment
);

// GET /payments/booking/:bookingId/receipt — ดึงใบเสร็จ
router.get(
    '/booking/:bookingId/receipt',
    protect,
    paymentController.getReceipt
);

module.exports = router;
