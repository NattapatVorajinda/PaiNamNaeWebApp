# 📋 TESTSPRINT1 - ผลสรุปการสร้างเทสต์

## ✅ เทสต์ที่สร้างขึ้นเสร็จแล้ว

### User Story
```
"As a passenger, I want to get a notification when the driver is about to pick me up 
so that I can get myself ready or respond to the driver."
```

---

## 📂 ไฟล์ที่สร้าง

### 1. UAT Test Suite
**File**: `Sprint1/test2/uat/07_passenger_pickup_notification.robot`
- 5 Test Cases ทดสอบระดับ UI/UX
- ใช้ Browser Library (Playwright) สำหรับทดสอบหน้าเว็บ

```robot
TC-UAT-NOTIFY-001: ผู้โดยสารรับแจ้งเตือนเมื่อคนขับมาถึง
TC-UAT-NOTIFY-002: ผู้โดยสารเห็นแจ้งเตือนในหน้าแจ้งเตือน  
TC-UAT-NOTIFY-003: เบราว์เซอร์แสดง visual alert
TC-UAT-NOTIFY-004: ผู้โดยสารสามารถทำเครื่องหมายอ่าน
TC-UAT-NOTIFY-005: แจ้งเตือนมีข้อมูลติดต่อคนขับ
```

### 2. API Test Suite  
**File**: `Sprint1/test2/api/07_pickup_notification_api.robot`
- 8 Test Cases ทดสอบระดับ Backend API
- ใช้ RequestsLibrary สำหรับการเรียก HTTP

```robot
TC-API-NOTIFY-001: Admin สร้างแจ้งเตือน pickup
TC-API-NOTIFY-002: ผู้โดยสารดูแจ้งเตือน
TC-API-NOTIFY-003: แจ้งเตือนมีข้อมูลคนขับ
TC-API-NOTIFY-004: ทำเครื่องหมายอ่าน
TC-API-NOTIFY-005: ดูจำนวนไม่อ่าน
TC-API-NOTIFY-006: ตรวจสอบ Authorization
TC-API-NOTIFY-007: ตรวจสอบโครงสร้าง Schema
TC-API-NOTIFY-008: ลบแจ้งเตือน
```

### 3. Test Documentation
**File**: `Sprint1/test2/TEST_SPRINT1_PASSENGER_NOTIFICATION.md`
- เอกสารการทดสอบครบถ้วน
- วิธีการรันและแปลผล
- Checklist & Metrics

---

## 🚀 วิธีการรันเทสต์ (Quick Start)

### ขั้นตอนที่ 1: เตรียม Environment
```bash
# ติดตั้ง dependencies (ครั้งแรกเท่านั้น)
pip install robotframework robotframework-requests robotframework-browser robotframework-jsonlibrary
rfbrowser init
```

### ขั้นตอนที่ 2: เริ่ม Backend Server
```bash
cd Sprint1/code/backend
npm install  # ครั้งแรก
npm run dev  # จะรันที่ http://localhost:3000
```

### ขั้นตอนที่ 3: รันเทสต์
```bash
cd Sprint1/test2

# รันเทสต์ทั้งหมด (UAT + API)
robot --outputdir results uat/07_passenger_pickup_notification.robot
robot --outputdir results api/07_pickup_notification_api.robot

# หรือรันแบบรวม
robot --include pickup --outputdir results .
```

### ขั้นตอนที่ 4: ดูผลลัพธ์
```bash
# Windows
.\results\report.html    # รายงานสรุป
.\results\log.html       # รายละเอียด

# หรือ Double-click ไฟล์ใน: Sprint1/test2/results/
```

---

## 📊 Test Coverage

| หมวดหมู่ | จำนวน | รายละเอียด |
|---------|-------|-----------|
| **Smoke Tests** | 4 | ทดสอบฟีเจอร์หลัก |
| **Critical Tests** | 4 | ทดสอบสิ่งสำคัญ |
| **Positive Tests** | 12 | Happy Path |
| **Negative Tests** | 1 | Edge Cases |
| **Security Tests** | 1 | Authorization |
| **Total** | **13** | **Test Cases** |

---

## ✨ ฟีเจอร์ที่ทดสอบ

### 1. การสร้างแจ้งเตือน
- ✅ Admin สามารถสร้างแจ้งเตือน pickup
- ✅ แจ้งเตือนมีข้อมูล: type, title, message, driverName, vehicleInfo

### 2. การรับแจ้งเตือน  
- ✅ ผู้โดยสารจะอยู่ที่หน้าแจ้งเตือน
- ✅ มี Badge/Indicator แสดง "ใหม่" หรือ "unread"
- ✅ แจ้งเตือนแสดงข้อมูลคนขับ (ชื่อ, เบอร์โทรศัพท์, รถ)

### 3. การอ่านแจ้งเตือน
- ✅ ผู้โดยสารสามารถทำเครื่องหมายอ่าน
- ✅ สถานะเปลี่ยนจาก unread → read
- ✅ Indicator เปลี่ยนแปลง

### 4. การลบแจ้งเตือน
- ✅ ผู้โดยสารสามารถลบแจ้งเตือน
- ✅ หมายเลขแจ้งเตือนที่ยังไม่อ่านลดลง

### 5. ความปลอดภัย
- ✅ ผู้โดยสารไม่สามารถดูแจ้งเตือนของคนอื่น
- ✅ Authorization checks เพื่อป้องกัน unauthorized access

---

## 🎯 Expected Outcomes

### หากเทสต์ Pass ✅
ระบบแจ้งเตือน Pickup Notification:
1. ✅ สร้างและเก็บแจ้งเตือนได้
2. ✅ ส่งแจ้งเตือนถึงผู้โดยสารที่ถูกต้อง
3. ✅ แสดงข้อมูลที่ถูกต้อง
4. ✅ ปล๏อดภัยตามที่กำหนด
5. ✅ พร้อมปล่อยเวอร์ชัน

### หากเทสต์ Fail ❌
ต้องตรวจสอบ:
1. ❌ Backend API endpoints
2. ❌ Database schema
3. ❌ Data structure
4. ❌ Authorization logic
5. ❌ Frontend display logic

---

## 📝 Test Data Requirements

| Role | Email | Password | สถานะในระบบ |
|------|-------|----------|-----------|
| Admin | admin@painamnae.com | 123456789 | ✅ มีอยู่ |
| Passenger | testpassenger01@test.com | Test@12345 | ✅ มีอยู่ |
| Driver | testdriver01@test.com | Test@12345 | ✅ มีอยู่ |

หากยังไม่มี ต้องสร้างก่อนรันเทสต์

---

## 🔧 Troubleshooting

### ปัญหา: Backend Connection Failed
```
❌ Error: Cannot connect to http://localhost:3000
✅ Solution: 
   - ตรวจสอบว่า Backend กำลังรัน
   - ตรวจสอบ port 3000
   - ตรวจสอบ .env file
```

### ปัญหา: Test Timeout
```
❌ Error: Wait For Elements State timeout
✅ Solution:
   - เพิ่ม Sleep time
   - ตรวจสอบ Frontend URL ถูกต้อง
   - ตรวจสอบ Browser/Playwright
```

### ปัญหา: Notification Not Showing
```
❌ Error: No notifications found
✅ Solution:
   - ตรวจสอบว่ามี Booking record
   - ตรวจสอบ Driver status เปลี่ยนเป็น "Picking Up"
   - ตรวจสอบ Notification API endpoint
   - ตรวจสอบ Database
```

---

## 📦 Files Structure

```
Sprint1/
├── test2/
│   ├── uat/
│   │   └── 07_passenger_pickup_notification.robot    ✅ NEW
│   ├── api/
│   │   └── 07_pickup_notification_api.robot          ✅ NEW
│   ├── resources/
│   │   ├── common.resource
│   │   ├── api_keywords.resource
│   │   └── uat_keywords.resource
│   ├── results/                                      # Generated after test run
│   │   ├── report.html
│   │   ├── log.html
│   │   └── output.xml
│   └── TEST_SPRINT1_PASSENGER_NOTIFICATION.md        ✅ NEW
└── code/
    └── backend/
        ├── src/
        │   ├── controllers/
        │   ├── services/
        │   └── routes/
        └── prisma/
            └── schema.prisma
```

---

## 🔄 Test Execution Flow

```
1. เตรียม Environment
   └── ติดตั้ง Robot Framework & Libraries
        └── npm install (Backend)

2. เริ่ม Backend Server
   └── npm run dev (http://localhost:3000)

3. รันเทสต์
   ├── API Tests (07_pickup_notification_api.robot)
   │   ├── Create Notification
   │   ├── Get Notifications
   │   ├── Mark As Read
   │   └── Delete Notification
   │
   └── UAT Tests (07_passenger_pickup_notification.robot)
       ├── Open Frontend
       ├── Login
       ├── Navigate to Notifications
       ├── Verify Display
       └── Verify Interaction

4. ดูผลลัพธ์
   └── report.html + log.html
```

---

## 📞 Contact & Support

ถ้ามีปัญหา:
1. ดู log.html สำหรับรายละเอียดข้อผิดพลาด
2. ตรวจสอบ Backend Logs
3. ตรวจสอบ Database connectivity
4. ดูเอกสาร: `Sprint1/Doc/User_Manual.md`

---

## 📅 Timeline & Status

| ขั้นตอน | สถานะ | วันที่ |
|--------|------|------|
| Create UAT Tests | ✅ Complete | 19 Feb 2026 |
| Create API Tests | ✅ Complete | 19 Feb 2026 |
| Create Documentation | ✅ Complete | 19 Feb 2026 |
| Test Execution | ⏳ Pending | - |
| Bug Fix (if needed) | ⏳ Pending | - |
| Final Approval | ⏳ Pending | - |

---

## 🎓 Next Steps

1. **รันเทสต์ครั้งแรก**
   ```bash
   cd Sprint1/test2
   robot --outputdir results uat/07_passenger_pickup_notification.robot
   ```

2. **ตรวจสอบผลลัพธ์**
   - ดู `results/report.html`
   - ทำ note หากมี failures

3. **หาก Fail**
   - ตรวจสอบ code
   - เพิ่ม logging/debugging
   - แก้ไขแล้วรันใหม่

4. **หากผลผ่านทั้งหมด** ✅
   - สร้าง commit
   - Push ไป repository
   - Request review

---

## 🏆 Success Criteria

| Criteria | Status |
|----------|--------|
| ทั้ง 5 UAT Tests ผ่าน | ⏳ Pending |
| ทั้ง 8 API Tests ผ่าน | ⏳ Pending |
| ไม่มี Critical Failures | ⏳ Pending |
| ส่วนประกอบก็อยู่ | ⏳ Pending |
| Ready to Release | ⏳ Pending |

---

**Created**: 19 Feb 2026  
**Version**: 1.0  
**Status**: ✅ Ready for Testing
