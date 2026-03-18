*** Settings ***
Documentation     Test: ผู้โดยสารไม่สามารถรีวิวได้หลังจากผ่านไป 7 วัน
...
...               Flow ที่ทดสอบ:
...               1. Suite Setup รัน create_expired_booking.js
...                  → update completedAt ของทุก route ให้ย้อนหลัง 8 วัน
...               2. Login ด้วย Passenger account
...               3. ไปหน้า My Trips → Tab ยืนยันแล้ว
...               4. ปุ่ม "⭐ เขียนรีวิว" ต้องมีอยู่ (Frontend ไม่ filter 7 วัน)
...               5. คลิก → เลือกดาว → กด Submit
...               6. Toast "เกิดข้อผิดพลาด" ต้องแสดงขึ้น (Backend ปฏิเสธ)
...
...               วิธีรัน:
...               cd Sprint2/test
...               robot uat/review_7day_window.robot

Library           Process
Library           String
Library           SeleniumLibrary

Suite Setup       Expire All Passenger Completed Bookings
Suite Teardown    Close Browser

*** Variables ***
# ── ปรับค่าตามสภาพแวดล้อมของคุณ ──────────────────────────────────────────
# ${BROWSER}  : chrome | firefox | edge
${BROWSER}            chrome
${FRONTEND_URL}       https://csse4569.cpkku.com
${BACKEND_DIR}        ${CURDIR}/../../code/backend
# ── บัญชีผู้โดยสารที่ใช้ทดสอบ ─────────────────────────────────────────────
# ต้องมีอยู่ใน DB และมี Booking status=CONFIRMED + Route status=COMPLETED
${PASSENGER_EMAIL}    panawat.c@kkumail.com
${PASSENGER_PASS}     12345678Cp

*** Test Cases ***
TC-7DAY-001 Review Button Visible But Submit Fails After 7 Days
    [Documentation]    หลัง Route completedAt เกิน 7 วัน:
    ...    - ปุ่ม "⭐ เขียนรีวิว" ยังแสดงอยู่ (Frontend ไม่ block)
    ...    - กด Submit → Backend ปฏิเสธ → Toast "เกิดข้อผิดพลาด"
    [Tags]    7-day-window    negative    critical

    # ─── Step 1: เปิดเบราว์เซอร์ Login ─────────────────────
    Open Browser    ${FRONTEND_URL}/login    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    เข้าสู่ระบบ    timeout=15s
    Input Text      id:identifier    ${PASSENGER_EMAIL}
    Input Text      id:password      ${PASSENGER_PASS}
    Click Element    css:button[type="submit"]
    # รอ redirect หลัง login สำเร็จ (URL จะเปลี่ยนออกจาก /login)
    Wait Until Location Does Not Contain    /login    timeout=15s

    # ─── Step 2: ไปหน้า My Trips ────────────────────────────
    Go To    ${FRONTEND_URL}/myTrip
    Wait Until Page Contains    การเดินทางของฉัน    timeout=15s
    # fetchMyTrips() รอ Google Maps API + /bookings/me — เพิ่ม timeout ให้พอ
    Sleep    6s

    # ─── Step 3: คลิก Tab "ยืนยันแล้ว" ─────────────────────
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s

    # ─── Step 4: ปุ่มรีวิวต้องมีอยู่ ────────────────────────
    # Frontend ไม่กรอง 7 วัน — แสดงปุ่มตาม routeCompleted + !hasReview
    Wait Until Page Contains    ⭐ เขียนรีวิว    timeout=15s
    Log    ✓ Step 4: ปุ่ม "⭐ เขียนรีวิว" แสดงอยู่บนหน้า

    # ─── Step 5: คลิกปุ่มรีวิว → Modal เปิด ────────────────
    Click Element    xpath=(//button[contains(text(),'⭐ เขียนรีวิว')])[1]
    Wait Until Page Contains    ให้คะแนนการเดินทาง    timeout=10s
    Log    ✓ Step 5: Modal รีวิวเปิดขึ้น

    # ─── Step 6: เลือก 5 ดาว → ปุ่ม Submit ใช้งานได้ ───────
    Click Element    xpath=(//button[contains(@class,'star-btn')])[5]
    Sleep    0.5s
    Wait Until Element Is Enabled
    ...    xpath=//button[contains(text(),'ส่งรีวิว')]
    ...    timeout=5s
    Log    ✓ Step 6: เลือก 5 ดาว ปุ่ม Submit ใช้งานได้

    # ─── Step 7: กด Submit ───────────────────────────────────
    Click Element    xpath=//button[contains(text(),'ส่งรีวิว')]
    Log    ✓ Step 7: กดปุ่ม ส่งรีวิว

    # ─── Step 8: ตรวจสอบ Toast "เกิดข้อผิดพลาด" ─────────────
    Wait Until Page Contains    เกิดข้อผิดพลาด    timeout=8s
    Log    ✓ Step 8: Toast "เกิดข้อผิดพลาด" แสดงขึ้น — Backend ปฏิเสธการรีวิวเกิน 7 วัน

*** Keywords ***
Expire All Passenger Completed Bookings
    [Documentation]    รัน create_expired_booking.js เพื่อตั้ง completedAt
    ...    ย้อนหลัง 8 วันให้ทุก Booking ของ test passenger
    ${result}=    Run Process
    ...    node    ${CURDIR}/setup/create_expired_booking.js
    ...    cwd=${BACKEND_DIR}
    ...    shell=True
    Log    stdout: ${result.stdout}
    Log    stderr: ${result.stderr}
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=Setup ล้มเหลว กรุณาตรวจสอบ:\n${result.stderr}
    Log    ✓ Setup สำเร็จ: Booking ทุกอันถูก expire แล้ว
