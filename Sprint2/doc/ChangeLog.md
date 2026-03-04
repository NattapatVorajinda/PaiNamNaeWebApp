# Change Log

| วันที่       | Change Log | ผู้รับผิดชอบ             | สิ่งที่เปลี่ยนกับระบบ |
|-------------|------------|--------------------------|------------------------|
| 28/02/2026  | add        | NATTAPAT VORAJINDA       | เพิ่ม model Review และ field completedAt ใน Route ใน schema.prisma |
| 28/02/2026  | add        | NATTAPAT VORAJINDA       | สร้าง migration add_review_model และ apply ฐานข้อมูล |
| 28/02/2026  | add        | NATTAPAT VORAJINDA       | สร้าง review.service.js – business logic รีวิว (ตรวจสอบ 7 วัน ป้องกันรีวิวซ้ำ) |
| 28/02/2026  | add        | NATTAPAT VORAJINDA       | สร้าง review.controller.js และ review.routes.js |
| 28/02/2026  | updated    | NATTAPAT VORAJINDA       | เพิ่ม review routes ใน src/routes/index.js |
| 28/02/2026  | updated    | NATTAPAT VORAJINDA       | แก้ route.service.js — บันทึก completedAt อัตโนมัติเมื่อ status เปลี่ยนเป็น COMPLETE |
| 28/02/2026  | add        | Yanawit Pichayakumkong   | เพิ่มระบบรีวิวให้ Passenger เมื่อจบการเดินทางและเปลี่ยนสถานะการเดินทางให้ Driver |
| 28/02/2026  | fix        | Yanawit Pichayakumkong   | แก้ไขปัญหาไม่ขึ้นรีวิวแล้วรีวิวซ้ำ |
| 01/03/2026  | updated    | NATTAPAT VORAJINDA       | อัปเดต myRoute/index.vue — เพิ่มสถานะ "กำลังเดินทาง" และ "สิ้นสุดการเดินทาง" |
| 01/03/2026  | updated    | NATTAPAT VORAJINDA       | ซ่อนปุ่ม "แจ้งเตือนโค้ดผิด" และ "แก้ไขเส้นทาง" เมื่อสถานะเป็น COMPLETED |
| 01/03/2026  | add        | Yanawit Pichayakumkong   | ทำหน้าให้รีวิวของตัวเองที่ผู้ใช้ได้รับรีวิวในหน้า profile |
| 01/03/2026  | updated    | panawat                  | อัปเดต CORS allowed origins ของ backend เพื่อรองรับโดเมนใหม่ |
| 01/03/2026  | switch     | panawat                  | เปลี่ยน frontend API base (Nuxt) ให้ชี้ไปยัง production API สำหรับ deploy (https://painamnaewebapp-af4j.onrender.com/api/) แทน http://localhost:3000/api/ |