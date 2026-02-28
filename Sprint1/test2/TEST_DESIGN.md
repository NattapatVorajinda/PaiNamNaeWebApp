# PaiNamNae WebApp - Test Design Document

## 1. ภาพรวม (Overview)

โครงการนี้ประกอบด้วยชุดทดสอบอัตโนมัติ (Automated Testing) สำหรับระบบ PaiNamNae WebApp 
ซึ่งเป็นแอปพลิเคชัน Car-Pooling ที่พัฒนาด้วย Node.js/Express (Backend) และ Nuxt.js/Vue (Frontend)

### เครื่องมือที่ใช้
- **Robot Framework** - Test automation framework
- **RequestsLibrary** - สำหรับ API Testing
- **Browser Library** (Playwright) - สำหรับ UAT/UI Testing

---

## 2. ขอบเขตการทดสอบ (Test Scope)

### 2.1 API Testing (6 Test Suites, ~45 Test Cases)

| Suite | Module | จำนวน TC | รายละเอียด |
|-------|--------|----------|-----------|
| 01_auth_api | Authentication | 8 | Login, Change Password |
| 02_user_api | User Management | 9 | Register, Profile, Admin CRUD |
| 03_vehicle_api | Vehicle | 9 | CRUD vehicles |
| 04_route_api | Route | 10 | Search, CRUD, Contact Info |
| 05_booking_api | Booking | 9 | CRUD bookings, Contact Info |
| 06_notification_api | Notification | 9 | CRUD, Read/Unread, Admin |

### 2.2 UAT Testing (6 Test Suites, ~25 Test Cases)

| Suite | Module | จำนวน TC | รายละเอียด |
|-------|--------|----------|-----------|
| 01_registration | Registration | 4 | UI Registration Flow |
| 02_login | Login | 5 | UI Login Flow |
| 03_create_trip | Create Trip | 4 | Trip Creation Flow |
| 04_find_trip | Find Trip | 4 | Trip Search + Contact Info |
| 05_booking | Booking | 5 | Booking Flow + Contact Info |
| 06_contact_info | Contact Info | 6 | Cross-cutting Contact Info Verification |

---

## 3. Test Design Strategy

### 3.1 API Testing Strategy

```
Positive Tests (Happy Path)
├── CRUD Operations สำหรับทุก resource
├── Authentication Flow (Login → Token → Authenticated Request)
├── Search & Filter
└── Contact Info ในผลลัพธ์ API

Negative Tests
├── Missing/Invalid Authentication (No Token, Expired Token)
├── Invalid Input Data (Missing Fields, Wrong Format)
├── Authorization (Non-Admin → Admin Endpoints)
├── Non-Existent Resources (404 scenarios)
└── Duplicate Data (Unique Constraint Violations)
```

### 3.2 UAT Testing Strategy

```
User Flows
├── Registration → Login → Browse
├── Login → Search Trip → View Driver Contact
├── Login → My Trip → View Driver Contact
├── Login → My Route → View Passenger Contact
├── Login → Create Trip → Verify in List
└── Unauthenticated Access → Redirect to Login
```

---

## 4. Test Data Design

### 4.1 ข้อมูลทดสอบ (Static)

**ผู้ใช้ทดสอบ** (ไฟล์: `data/test_data.resource`, `data/test_users.py`)

| Role | Username | Email | Password | หมายเหตุ |
|------|----------|-------|----------|---------|
| Admin | admin123 | admin@painamnae.com | 123456789 | มีอยู่ในระบบ |
| Driver | testdriver01 | testdriver01@test.com | Test@12345 | สำหรับสร้างใหม่ |
| Passenger | testpassenger01 | testpassenger01@test.com | Test@12345 | สำหรับสร้างใหม่ |

### 4.2 ข้อมูลทดสอบ (Dynamic)

- **Unique Email/Username**: สร้างจาก timestamp (`test_20250101120000@test.com`)
- **Future Datetime**: สร้างจาก current date + 1 day

### 4.3 ข้อมูลทดสอบ (Negative)

| ชนิด | ค่า | ใช้ทดสอบ |
|------|-----|---------|
| Short password | "short" | Validation |
| Invalid email | "not-an-email" | Format validation |
| Expired token | JWT ที่หมดอายุ | Authentication |
| Non-existent ID | "nonexistent_id" | 404 scenarios |

---

## 5. Tags & Categories

| Tag | ความหมาย | จำนวน TC |
|-----|---------|----------|
| `smoke` | ทดสอบพื้นฐาน - ต้อง pass ทุกครั้ง | ~15 |
| `critical` | ทดสอบสำคัญ - กระทบ core functionality | ~12 |
| `positive` | Happy path tests | ~30 |
| `negative` | Error/Edge case tests | ~20 |
| `security` | Security-related tests | ~10 |
| `validation` | Input validation tests | ~8 |
| `contact-info` | ฟีเจอร์ข้อมูลติดต่อ | ~10 |
| `admin` | Admin-specific tests | ~6 |
| `api` | API tests ทั้งหมด | ~45 |
| `uat` | UAT tests ทั้งหมด | ~25 |

---

## 6. คำสั่งรันทดสอบ (Run Commands)

```bash
# ติดตั้ง dependencies
pip install robotframework robotframework-requests robotframework-browser robotframework-jsonlibrary
rfbrowser init

# รันทั้งหมด
robot --outputdir results tests/

# รัน API tests เท่านั้น
robot --outputdir results tests/api/

# รัน UAT tests เท่านั้น
robot --outputdir results tests/uat/

# รันเฉพาะ smoke tests
robot --include smoke --outputdir results tests/

# รันเฉพาะ contact-info tests
robot --include contact-info --outputdir results tests/

# รันเฉพาะ critical tests
robot --include critical --outputdir results tests/

# รันเฉพาะ negative tests
robot --include negative --outputdir results tests/

# รันพร้อม verbose logging
robot --loglevel DEBUG --outputdir results tests/
```

---

## 7. Prerequisites

1. **Backend** ต้องรันที่ `http://localhost:3000`
2. **Frontend** ต้องรันที่ `http://localhost:3001`
3. **ฐานข้อมูล** ต้องมีข้อมูล Admin user (admin123)
4. **Python 3.8+** ติดตั้งแล้ว
5. **Robot Framework** และ libraries ติดตั้งแล้ว

---

## 8. ผลลัพธ์การทดสอบ (Test Results)

Robot Framework จะสร้างไฟล์ผลลัพธ์ใน `results/`:
- `output.xml` - ข้อมูลดิบ
- `log.html` - Log report (รายละเอียด)
- `report.html` - Summary report (ภาพรวม)
