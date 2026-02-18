# Test Sprint 1 - Passenger Pickup Notification

## 📋 Overview
การทดสอบสำหรับ User Story:
> **"As a passenger, I want to get a notification when the driver is about to pick me up so that I can get myself ready or respond to the driver."**

---

## 🎯 Test Scope

### User Story Requirement
ผู้โดยสารต้องการได้รับแจ้งเตือนเมื่อคนขับกำลังมาถึงเพื่อให้พร้อมสำหรับการรับบริการ

### Test Coverage
- **UAT Tests**: 5 Test Cases (ทดสอบระดับ UI/UX)
- **API Tests**: 8 Test Cases (ทดสอบระดับ Backend)
- **Total**: 13 Test Cases

---

## 📁 Test Files Created

### 1. UAT Test File
**Location**: `Sprint1/test2/uat/07_passenger_pickup_notification.robot`

#### Test Cases:
| ID | Test Case | Purpose | Tags |
|----|----|---------|------|
| TC-UAT-NOTIFY-001 | Passenger Receives Pickup Notification | ตรวจสอบว่าผู้โดยสารรับแจ้งเตือน | smoke, critical |
| TC-UAT-NOTIFY-002 | Passenger Sees Notification in Panel | ตรวจสอบแจ้งเตือนในหน้าแจ้งเตือน | smoke, positive |
| TC-UAT-NOTIFY-003 | Visual Alert on Browser | ตรวจสอบการแจ้งเตือนภาพ/badge | positive, ui |
| TC-UAT-NOTIFY-004 | Mark Notification As Read | ตรวจสอบการทำเครื่องหมายอ่าน | positive, interaction |
| TC-UAT-NOTIFY-005 | Driver Contact Info in Notification | ตรวจสอบข้อมูลติดต่อคนขับ | critical, contact-info |

### 2. API Test File
**Location**: `Sprint1/test2/api/07_pickup_notification_api.robot`

#### Test Cases:
| ID | Test Case | Purpose | Tags |
|----|----|---------|------|
| TC-API-NOTIFY-001 | Admin Creates Pickup Notification | Admin สร้างแจ้งเตือน pickup | smoke, critical |
| TC-API-NOTIFY-002 | Passenger Retrieves Notifications | ผู้โดยสารดูแจ้งเตือน | smoke, positive |
| TC-API-NOTIFY-003 | Notification Contains Driver Info | แจ้งเตือนมีข้อมูลคนขับ | critical, data-validation |
| TC-API-NOTIFY-004 | Mark As Read | ผู้โดยสารทำเครื่องหมายอ่าน | positive, interaction |
| TC-API-NOTIFY-005 | Get Unread Count | ดูจำนวนแจ้งเตือนไม่อ่าน | positive, data |
| TC-API-NOTIFY-006 | Authorization Check | ตรวจสอบการกำหนดสิทธิ์ | negative, security |
| TC-API-NOTIFY-007 | Notification Structure | ตรวจสอบโครงสร้าง schema | positive, schema |
| TC-API-NOTIFY-008 | Delete Notification | ลบแจ้งเตือน | positive, interaction |

---

## 🚀 วิธีการรันเทสต์

### Prerequisites
```bash
# 1. ติดตั้ง dependencies
pip install robotframework robotframework-requests robotframework-browser robotframework-jsonlibrary
rfbrowser init

# 2. เตรียม Backend
cd Sprint1/code/backend
npm install
npm run dev
# Backend จะรันที่ http://localhost:3000
```

### Running Tests

#### Option 1: รันเฉพาะ Notification Tests
```bash
# เปิด Terminal ใหม่
cd Sprint1/test2

# รัน Passenger Notification UAT Tests
robot --outputdir results uat/07_passenger_pickup_notification.robot

# รัน Passenger Notification API Tests
robot --outputdir results api/07_pickup_notification_api.robot
```

#### Option 2: รันทั้งชุดการทดสอบเชื่อมโยง
```bash
# รัน Notification Tests only (ทั้ง UAT + API)
robot --include notification --outputdir results .

# รัน Pickup-specific Tests
robot --include pickup --outputdir results .

# รัน Critical Tests (ทำการทดสอบ smoke)
robot --include smoke --outputdir results .
```

#### Option 3: รันตามประเภท
```bash
# รัน API Tests เท่านั้น
robot --outputdir results api/07_pickup_notification_api.robot

# รัน UAT Tests เท่านั้น
robot --outputdir results uat/07_passenger_pickup_notification.robot

# รัน Tests ด้วย verbose output
robot --outputdir results -v --loglevel DEBUG uat/07_passenger_pickup_notification.robot
```

### ดูผลลัพธ์
```bash
# เปิดรายงาน (Windows)
.\results\report.html      # รายงานสรุป
.\results\log.html         # รายละเอียดบันทึก

# หรือ double-click ไฟล์ HTML ใน folder: Sprint1/test2/results/
```

---

## 📊 Test Execution Plan

### Test Environment Requirements
| Item | Value |
|------|-------|
| Backend Server | http://localhost:3000/api |
| Frontend URL | http://localhost:3001 |
| Database | ต้องมีข้อมูลทดสอบ |
| Browser | Chrome/Chromium (ผ่าน Playwright) |

### Test Data Required
| Role | Email | Password | Purpose |
|------|-------|----------|---------|
| Admin | admin@painamnae.com | 123456789 | สำหรับสร้างแจ้งเตือน |
| Passenger | testpassenger01@test.com | Test@12345 | สำหรับทดสอบรับแจ้งเตือน |
| Driver | testdriver01@test.com | Test@12345 | สำหรับสร้างเส้นทาง |

---

## ✅ Test Validation Checklist

### UAT Tests Validate:
- [ ] ผู้โดยสารได้รับแจ้งเตือนในหน้าแจ้งเตือน
- [ ] แจ้งเตือนมีข้อมูลคนขับ (ชื่อ, เบอร์โทร, รถ)
- [ ] แจ้งเตือนมีสิ่งบ่งบอก "ใหม่" หรือ "unread"
- [ ] ผู้โดยสารสามารถทำเครื่องหมายอ่าน
- [ ] ข้อมูลติดต่อแสดงอย่างถูกต้อง

### API Tests Validate:
- [ ] API สามารถสร้างแจ้งเตือน pickup
- [ ] ผู้โดยสารสามารถดูแจ้งเตือน
- [ ] แจ้งเตือนมีโครงสร้างข้อมูลถูกต้อง
- [ ] สามารถทำเครื่องหมายอ่าน
- [ ] สามารถลบแจ้งเตือน
- [ ] มีการตรวจสอบ authorization
- [ ] ข้อมูลติดต่อรวมอยู่ในแจ้งเตือน

---

## 🔍 Test Results Interpretation

### Success Criteria
- ✅ **All Tests Pass**: ระบบแจ้งเตือน pickup ทำงานถูกต้อง
- ⚠️ **Some Tests Fail**: ต้องตรวจสอบระบบหรือแพ็ตช์โค้ด
- ❌ **Critical Tests Fail**: ต้องหยุดการปล่อยรุ่น

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Backend not found | ตรวจสอบว่า Backend กำลังรัน ที่ localhost:3000 |
| Tests timeout | เพิ่มลิงก์ connection timeout หรือรอนานขึ้น |
| Notification not showing | ตรวจสอบว่ามี booking record ในระบบ |
| Contact info missing | ตรวจสอบ schema หรือ return data จาก API |

---

## 📈 Metrics

### Test Execution Metrics
```
Total Test Cases:        13
  - UAT Tests:           5
  - API Tests:           8

Test Types:
  - Smoke Tests:         4
  - Critical Tests:      4
  - Positive Tests:      12
  - Negative Tests:      1
  - Security Tests:      1

Coverage:
  - Notification Creation:      ✅
  - Notification Retrieval:     ✅
  - Contact Info Display:       ✅
  - Authorization Checks:       ✅
  - Data Structure Validation:  ✅
```

---

## 📝 Test Execution Log Template

```
Test Execution Date:     [Date]
Test Environment:        [Local/Staging/Production]
Backend Version:         [Version]
Frontend Version:        [Version]

Test Results:
  - Passed:   [X] tests
  - Failed:   [X] tests
  - Skipped:  [X] tests

Pass Rate: [X]%

Issues Found:
  1. [Description]
  2. [Description]

Recommendations:
  - [Action Item 1]
  - [Action Item 2]

Tested By: [Name]
Date: [Date/Time]
```

---

## 🔗 Related Files & Documentation

- Backend Routes: `Sprint1/code/backend/src/routes/`
- Notification Service: `Sprint1/code/backend/src/services/`
- Test Resources: `Sprint1/test2/resources/`
- Common Keywords: `Sprint1/test2/resources/common.resource`
- API Keywords: `Sprint1/test2/resources/api_keywords.resource`
- UAT Keywords: `Sprint1/test2/resources/uat_keywords.resource`

---

## 💡 Tips for Test Execution

### เพิ่มประสิทธิภาพการทดสอบ
1. **รันเทสต์ในเวลากลางคืน**: ใช้เวลาการทำงานนอกเวลา
2. **ตั้งค่า Headless Mode**: เพื่อให้เร็วขึ้น
3. **ใช้ Parallel Execution**: สำหรับเทสต์จำนวนมาก
4. **บันทึกผลการทดสอบ**: สำหรับการติดตามและวิเคราะห์

### Parallel Execution Example
```bash
# ถ้ามีการดำเนนการจำนวนมาก
robot --outputdir results \
       --processes 2 \
       --suite uat \
       .
```

---

## 🎓 Additional Resources

- [Robot Framework Documentation](https://robotframework.org/)
- [RequestsLibrary](https://marketsquare.github.io/robotframework-requests/latest/)
- [Browser Library (Playwright)](https://marketsquare.github.io/robotframework-browser/)
- Project Documentation: `Sprint1/Doc/User_Manual.md`

---

## 📞 Support & Escalation

หากพบปัญหาในการรันเทสต์:
1. ตรวจสอบ Backend กำลังรันอยู่
2. ตรวจสอบ .env และการตั้งค่าฐานข้อมูล
3. ตรวจสอบข้อมูลทดสอบในระบบ
4. ดู log.html สำหรับรายละเอียดข้อผิดพลาด

---

**Created**: หา 19 ก.พ. 2566
**Status**: ✅ Ready for Testing
**Version**: 1.0
