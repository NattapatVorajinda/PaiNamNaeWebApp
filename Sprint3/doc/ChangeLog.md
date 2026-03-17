# Change Log

วันที่: **14/03/2026**

| สถานะ   | ผู้ดูแล            | รายละเอียด                                                                                                              |
| ------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| add     | NATTAPAT VORAJINDA | เพิ่ม middleware `reviewUpload.middleware.js` สำหรับ upload ไฟล์สื่อ (รูป, วิดีโอ, เสียง สูงสุด 5 ไฟล์) ผ่าน Cloudinary |
| updated | NATTAPAT VORAJINDA | แก้ `review.controller.js` ให้รองรับ multipart/form-data และส่ง URL สื่อกลับใน `mediaUrls`                              |
| updated | NATTAPAT VORAJINDA | แก้ `review.routes.js` เพิ่ม middleware upload ใน route POST `/reviews`                                                 |
| updated | NATTAPAT VORAJINDA | แก้ `review.service.js` ให้บันทึก `mediaUrls` (JSON array) ลง database                                                  |
| updated | NATTAPAT VORAJINDA | แก้ schema prisma เพิ่ม field `mediaUrls` ใน Review model                                                               |
| updated | NATTAPAT VORAJINDA | แก้ `ReviewPopupModal.vue` เพิ่ม UI แสดงไฟล์ (preview รูป/วิดีโอ/เสียง) ตอนเขียนรีวิว                                   |
| updated | NATTAPAT VORAJINDA | แก้ `my-reviews.vue` แสดงชื่อไฟล์แนบในรีวิว                                                                             |
| updated | NATTAPAT VORAJINDA | แก้ `driver/[id].vue` แสดงสื่อที่แนบมากับรีวิวคนขับ                                                                     |
| updated | NATTAPAT VORAJINDA | แก้ `nuxt.config.js` เพิ่ม config สำหรับ upload ขนาดไฟล์                                                                |
| add     | NATTAPAT VORAJINDA | เพิ่ม migration SQL สำหรับ field `mediaUrls` ใหม่                                                                       |
| add     | NATTAPAT VORAJINDA | เพิ่ม enum `PaymentStatus` (PENDING, PAID, CONFIRMED) และ `PaymentMethod` (CASH, TRANSFER) ใน `schema.prisma`           |
| add     | NATTAPAT VORAJINDA | เพิ่ม model `Payment` ใน `schema.prisma` (amount, method, status, slipUrl, receiptNumber ฯลฯ)                           |
| updated | NATTAPAT VORAJINDA | แก้ User model เพิ่ม field `promptPayNumber`, `promptPayQrUrl` สำหรับรับเงิน                                            |
| add     | NATTAPAT VORAJINDA | สร้าง `payment.service.js` จัดการ payment สร้าง/อัปเดตสถานะ, สร้างเลขบิล, ออกเลขที่ใบเสร็จ (REC-YYYYMMDD-XXX)           |
| add     | NATTAPAT VORAJINDA | สร้าง `payment.controller.js` – 4 endpoints: ดึงข้อมูล, สร้าง, อัปเดตสถานะ, อัปโหลดสลิป                                 |
| add     | NATTAPAT VORAJINDA | สร้าง `payment.routes.js` เชื่อม route `/payments/booking/:bookingId`                                                   |
| add     | NATTAPAT VORAJINDA | สร้าง `paymentUpload.middleware.js` – Multer สำหรับ upload สลิปเงิน (10MB)                                              |
| updated | NATTAPAT VORAJINDA | แก้ `routes/index.js` ลงทะเบียน payment routes                                                                          |
| updated | NATTAPAT VORAJINDA | แก้ `routes.service.js` เช็ค `PaymentStatus` ก่อนอัปเดตสถานะ route เป็น COMPLETED                                       |
| updated | NATTAPAT VORAJINDA | แก้ `user.controller.js` ให้ route `users/me/promptpay`                                                                 |
| add     | NATTAPAT VORAJINDA | สร้างหน้า `pages/profile/promptpay.vue` สำหรับจัดการ PromptPay                                                          |
| add     | NATTAPAT VORAJINDA | สร้างหน้า `pages/payment/booking/[bookingId].vue` – ผู้โดยสารอัปโหลดสลิป / เลือกช่องทางโอน / แสดงบิล                    |
| add     | NATTAPAT VORAJINDA | สร้างหน้า `pages/receipt/[bookingId].vue` – ใบเสร็จรับเงิน + พิมพ์ PDF                                                  |
| updated | NATTAPAT VORAJINDA | แก้ `pages/myTrip/index.vue` เพิ่มปุ่ม "ชำระเงิน" สำหรับทริปที่เสร็จแล้ว                                                |
| updated | NATTAPAT VORAJINDA | แก้ `pages/myRoute/index.vue` เพิ่มปุ่ม "ยืนยันรับเงิน" (สำหรับคนขับ)                                                   |
| updated | NATTAPAT VORAJINDA | แก้ `ProfileSidebar.vue` เพิ่มเมนู "ตั้งค่าพร้อมเพย์" ในเมนูผู้ขับ                                                      |
| fix | Yanawit Pichayakumkong | จัด UI ให้ดูง่ายขึ้นและปรับคำ ชำระเงิน / ดูใบเสร็จ ให้เป็น ชำระเงินหรือดูใบเสร็จ ตามสถานะ
| add | Yanawit Pichayakumkong | Add Invoice คร่าวๆ 

วันที่: **15/03/2026**

| สถานะ   | ผู้ดูแล            | รายละเอียด       |
| ------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| Use deployed API base in Nuxt config | ปาณวัฒน์ จันทร์ทองหลาง | Switch runtimeConfig.public.apiBase to the deployed Render URL (https://painamnaewebapp-af4j.onrender.com/api/) instead of localhost so the frontend targets the production backend; the localhost URL is left commented for local development. 
| Refactor Prisma schema and notification logic | ปาณวัฒน์ จันทร์ทองหลาง | Reformat and reorganize prisma schema: reflowed models/enums and field ordering, moved relations into consistent positions, added/moved indexes, and removed the Payment model and its payment-related enums (PaymentStatus/PaymentMethod). Adjustments include explicit user relations on Vehicle/Notification, reordered DriverVerification/Route/Booking/Review fields, and enum repositioning. Backend: add validation in booking.service to prevent arrival notifications for routes with status COMPLETED. Frontend: reduce arrival toast duration for "กำลังจะถึง" notifications from 15 minutes to 8 seconds to avoid excessively long toasts.
| Include vehicle in receipt; remove tax-invoice  | ปาณวัฒน์ จันทร์ทองหลาง | Add vehicle fields to backend receipt query and update frontend receipt page to show vehicle plate and description. Redesign receipt layout (spacing, typography, table styling), add formatNumber helper, improve date/number formatting and print styles, and move receipt container ID for printing. Remove tax-invoice page and the link to it from the payment page.
| Fix bug vehicleModel instead of brand/model  | ปาณวัฒน์ จันทร์ทองหลาง | Align vehicle field naming between backend and frontend: backend payment service now selects vehicleModel (removing brand and model), and the receipt page uses vehicleModel and color to build the vehicle description. This fixes a mismatch that could produce undefined brand/model values in receipts.
