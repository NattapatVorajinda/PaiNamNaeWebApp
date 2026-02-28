# PaiNamNae WebApp - Robot Framework Test Suite

## โครงสร้างไฟล์ทดสอบ (Test Structure)

```
tests/
├── README.md                    # เอกสารนี้
├── api/                         # API Testing
│   ├── 01_auth_api.robot        # ทดสอบ Authentication API
│   ├── 02_user_api.robot        # ทดสอบ User API
│   ├── 03_vehicle_api.robot     # ทดสอบ Vehicle API
│   ├── 04_route_api.robot       # ทดสอบ Route API
│   ├── 05_booking_api.robot     # ทดสอบ Booking API
│   └── 06_notification_api.robot# ทดสอบ Notification API
├── uat/                         # User Acceptance Testing
│   ├── 01_registration.robot    # ทดสอบการลงทะเบียน
│   ├── 02_login.robot           # ทดสอบการเข้าสู่ระบบ
│   ├── 03_create_trip.robot     # ทดสอบการสร้างเส้นทาง
│   ├── 04_find_trip.robot       # ทดสอบการค้นหาเส้นทาง
│   ├── 05_booking.robot         # ทดสอบการจอง
│   └── 06_contact_info.robot    # ทดสอบการแสดงข้อมูลติดต่อ
├── resources/                   # Shared Resources
│   ├── common.resource          # Keywords ทั่วไป
│   ├── api_keywords.resource    # Keywords สำหรับ API Testing
│   └── uat_keywords.resource    # Keywords สำหรับ UAT
├── data/                        # Test Data
│   ├── test_data.py             # Test Data (Python variables)
│   └── test_users.py            # ข้อมูลผู้ใช้ทดสอบ
└── results/                     # ผลลัพธ์ (auto-generated)
```

## การติดตั้ง (Installation)

```bash
pip install robotframework
pip install robotframework-requests
pip install robotframework-browser
pip install robotframework-jsonlibrary
rfbrowser init
```

## การรันทดสอบ (Running Tests)

### รันทั้งหมด
```bash
robot --outputdir results tests/
```

### รัน API Tests เท่านั้น
```bash
robot --outputdir results tests/api/
```

### รัน UAT Tests เท่านั้น
```bash
robot --outputdir results tests/uat/
```

### รันตาม Tag
```bash
robot --include smoke --outputdir results tests/
robot --include critical --outputdir results tests/
robot --include api --outputdir results tests/
robot --include uat --outputdir results tests/
```

## Test Design

### API Testing Strategy
- **Positive Tests**: ทดสอบ Happy Path ของแต่ละ endpoint
- **Negative Tests**: ทดสอบ Invalid input, Unauthorized access, Not Found
- **Authentication Tests**: ทดสอบ JWT token flow, expired tokens, missing tokens
- **CRUD Tests**: ทดสอบ Create, Read, Update, Delete ของแต่ละ resource
- **Authorization Tests**: ทดสอบ Role-based access (ADMIN, DRIVER, PASSENGER)

### UAT Testing Strategy
- **User Registration Flow**: ลงทะเบียนผู้ใช้ใหม่
- **Login Flow**: เข้าสู่ระบบด้วย email/username
- **Trip Creation Flow**: สร้างเส้นทางใหม่ (สำหรับคนขับ)
- **Trip Search Flow**: ค้นหาเส้นทาง (สำหรับผู้โดยสาร)
- **Booking Flow**: จองเส้นทาง, ยืนยัน/ปฏิเสธการจอง
- **Contact Info Verification**: ตรวจสอบการแสดงข้อมูลติดต่อ (email, เบอร์โทร)

## Test Data

### ผู้ใช้ทดสอบ (Test Users)
| Role | Username | Email | Password |
|------|----------|-------|----------|
| Admin | admin123 | admin@painamnae.com | 123456789 |
| Driver | testdriver01 | testdriver01@test.com | Test@12345 |
| Passenger | testpassenger01 | testpassenger01@test.com | Test@12345 |

### Environment
| Variable | Value |
|----------|-------|
| API Base URL | http://localhost:3000/api |
| Frontend URL | http://localhost:3001 |
