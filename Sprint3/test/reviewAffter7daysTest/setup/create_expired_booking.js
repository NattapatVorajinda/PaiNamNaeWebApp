/**
 * setup: Expire ทุก Booking ของ test passenger สำหรับทดสอบ 7-day review window
 *
 * วิธีรัน:
 *   cd Sprint2/code/backend
 *   node ../../test/setup/create_expired_booking.js
 *
 * ผลลัพธ์: พิมพ์ "OK" เมื่อสำเร็จ
 * หมายเหตุ: แก้ PASSENGER_EMAIL ให้ตรงกับบัญชีที่ใช้ทดสอบ
 */

const path = require('path');
const backendDir = path.resolve(__dirname, '../../../code/backend');
const { PrismaClient } = require(path.join(backendDir, 'node_modules/@prisma/client'));
const prisma = new PrismaClient();

const PASSENGER_EMAIL = 'panawat.c@kkumail.com'; // ← แก้ถ้าใช้ email อื่น อันนี้เมลเทส

async function main() {
  const user = await prisma.user.findUnique({ where: { email: PASSENGER_EMAIL } });
  if (!user) {
    console.error(`ERROR: ไม่พบ user email: ${PASSENGER_EMAIL}`);
    process.exit(1);
  }

  const bookings = await prisma.booking.findMany({
    where: {
      passengerId: user.id,
      status: 'CONFIRMED',
      route: { status: 'COMPLETED' },
    },
    include: { route: true },
  });

  if (bookings.length === 0) {
    console.error(
      'ERROR: ไม่พบ Booking ที่ Route COMPLETED สำหรับ ' + PASSENGER_EMAIL + '\n' +
      'กรุณาทำขั้นตอนก่อน:\n' +
      '  1. Driver สร้าง Route\n' +
      '  2. Passenger จอง\n' +
      '  3. Driver ยืนยัน Booking\n' +
      '  4. Driver Complete Route  (PATCH /routes/:id/complete)\n' +
      'แล้วรัน script นี้อีกครั้ง'
    );
    process.exit(1);
  }

  // ย้อนหลัง 8 วัน (เกิน 7-day window)
  const eightDaysAgo = new Date();
  eightDaysAgo.setDate(eightDaysAgo.getDate() - 8);

  for (const b of bookings) {
    await prisma.route.update({
      where: { id: b.routeId },
      data: { completedAt: eightDaysAgo },
    });
  }

  console.log('OK');
  console.error(
    `INFO: ตั้ง completedAt = ${eightDaysAgo.toISOString()} ` +
    `ให้ ${bookings.length} route(s) ของ ${PASSENGER_EMAIL}`
  );
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
