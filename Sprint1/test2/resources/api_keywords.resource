*** Settings ***
Documentation     Keywords เฉพาะสำหรับ API Testing
Library           RequestsLibrary
Library           Collections
Library           String
Resource          common.resource

*** Keywords ***
# =========================================================
# Auth API Keywords
# =========================================================
Register New User
    [Documentation]    ลงทะเบียนผู้ใช้ใหม่ผ่าน API
    [Arguments]    ${username}    ${email}    ${password}    ${firstName}    ${lastName}    ${phone}    ${gender}    ${nationalId}    ${nationalIdExpiry}
    Create API Session
    ${body}=    Create Dictionary
    ...    username=${username}
    ...    email=${email}
    ...    password=${password}
    ...    firstName=${firstName}
    ...    lastName=${lastName}
    ...    phoneNumber=${phone}
    ...    gender=${gender}
    ...    nationalIdNumber=${nationalId}
    ...    nationalIdExpiryDate=${nationalIdExpiry}
    ${response}=    POST On Session    painamnae    /users    json=${body}    expected_status=any
    RETURN    ${response}

Login User
    [Documentation]    เข้าสู่ระบบผ่าน API
    [Arguments]    ${email}    ${password}
    Create API Session
    ${body}=    Create Dictionary    email=${email}    password=${password}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}    expected_status=any
    RETURN    ${response}

# =========================================================
# User API Keywords
# =========================================================
Get My Profile
    [Documentation]    ดึงข้อมูลโปรไฟล์ตัวเอง
    ${response}=    GET On Session    painamnae_auth    /users/me    expected_status=any
    RETURN    ${response}

Update My Profile
    [Documentation]    อัปเดตข้อมูลโปรไฟล์ตัวเอง
    [Arguments]    ${data}
    ${response}=    PUT On Session    painamnae_auth    /users/me    json=${data}    expected_status=any
    RETURN    ${response}

Get User By Id
    [Documentation]    ดึงข้อมูลผู้ใช้ตาม ID
    [Arguments]    ${user_id}
    Create API Session
    ${response}=    GET On Session    painamnae    /users/${user_id}    expected_status=any
    RETURN    ${response}

# =========================================================
# Vehicle API Keywords
# =========================================================
Create Vehicle
    [Documentation]    สร้างยานพาหนะใหม่
    [Arguments]    ${vehicle_data}
    ${response}=    POST On Session    painamnae_auth    /vehicles    json=${vehicle_data}    expected_status=any
    RETURN    ${response}

Get My Vehicles
    [Documentation]    ดึงรายการยานพาหนะของตัวเอง
    ${response}=    GET On Session    painamnae_auth    /vehicles    expected_status=any
    RETURN    ${response}

Update Vehicle
    [Documentation]    อัปเดตข้อมูลยานพาหนะ
    [Arguments]    ${vehicle_id}    ${data}
    ${response}=    PUT On Session    painamnae_auth    /vehicles/${vehicle_id}    json=${data}    expected_status=any
    RETURN    ${response}

Delete Vehicle
    [Documentation]    ลบยานพาหนะ
    [Arguments]    ${vehicle_id}
    ${response}=    DELETE On Session    painamnae_auth    /vehicles/${vehicle_id}    expected_status=any
    RETURN    ${response}

# =========================================================
# Route API Keywords
# =========================================================
Create Route
    [Documentation]    สร้างเส้นทางใหม่
    [Arguments]    ${route_data}
    ${response}=    POST On Session    painamnae_auth    /routes    json=${route_data}    expected_status=any
    RETURN    ${response}

Get My Routes
    [Documentation]    ดึงเส้นทางของตัวเอง
    ${response}=    GET On Session    painamnae_auth    /routes/me    expected_status=any
    RETURN    ${response}

Search Routes
    [Documentation]    ค้นหาเส้นทาง
    [Arguments]    ${params}=${None}
    ${response}=    GET On Session    painamnae_auth    /routes    params=${params}    expected_status=any
    RETURN    ${response}

Get Route By Id
    [Documentation]    ดึงข้อมูลเส้นทางตาม ID
    [Arguments]    ${route_id}
    Create API Session
    ${response}=    GET On Session    painamnae    /routes/${route_id}    expected_status=any
    RETURN    ${response}

Update Route
    [Documentation]    อัปเดตเส้นทาง
    [Arguments]    ${route_id}    ${data}
    ${response}=    PUT On Session    painamnae_auth    /routes/${route_id}    json=${data}    expected_status=any
    RETURN    ${response}

Cancel Route
    [Documentation]    ยกเลิกเส้นทาง
    [Arguments]    ${route_id}    ${reason}
    ${body}=    Create Dictionary    reason=${reason}
    ${response}=    PATCH On Session    painamnae_auth    /routes/${route_id}/cancel    json=${body}    expected_status=any
    RETURN    ${response}

Delete Route
    [Documentation]    ลบเส้นทาง
    [Arguments]    ${route_id}
    ${response}=    DELETE On Session    painamnae_auth    /routes/${route_id}    expected_status=any
    RETURN    ${response}

# =========================================================
# Booking API Keywords
# =========================================================
Create Booking
    [Documentation]    สร้างการจองใหม่
    [Arguments]    ${booking_data}
    ${response}=    POST On Session    painamnae_auth    /bookings    json=${booking_data}    expected_status=any
    RETURN    ${response}

Get My Bookings
    [Documentation]    ดึงรายการจองของตัวเอง
    ${response}=    GET On Session    painamnae_auth    /bookings/me    expected_status=any
    RETURN    ${response}

Get Booking By Id
    [Documentation]    ดึงข้อมูลการจองตาม ID
    [Arguments]    ${booking_id}
    ${response}=    GET On Session    painamnae_auth    /bookings/${booking_id}    expected_status=any
    RETURN    ${response}

Update Booking Status
    [Documentation]    อัปเดตสถานะการจอง (สำหรับคนขับ)
    [Arguments]    ${booking_id}    ${status}
    ${body}=    Create Dictionary    status=${status}
    ${response}=    PATCH On Session    painamnae_auth    /bookings/${booking_id}/status    json=${body}    expected_status=any
    RETURN    ${response}

Cancel Booking
    [Documentation]    ยกเลิกการจอง
    [Arguments]    ${booking_id}    ${reason}
    ${body}=    Create Dictionary    reason=${reason}
    ${response}=    PATCH On Session    painamnae_auth    /bookings/${booking_id}/cancel    json=${body}    expected_status=any
    RETURN    ${response}

Delete Booking
    [Documentation]    ลบการจอง
    [Arguments]    ${booking_id}
    ${response}=    DELETE On Session    painamnae_auth    /bookings/${booking_id}    expected_status=any
    RETURN    ${response}

# =========================================================
# Notification API Keywords
# =========================================================
Get My Notifications
    [Documentation]    ดึงรายการแจ้งเตือนของตัวเอง
    ${response}=    GET On Session    painamnae_auth    /notifications    expected_status=any
    RETURN    ${response}

Get Unread Count
    [Documentation]    ดึงจำนวนแจ้งเตือนที่ยังไม่อ่าน
    ${response}=    GET On Session    painamnae_auth    /notifications/unread-count    expected_status=any
    RETURN    ${response}

Mark Notification Read
    [Documentation]    ทำเครื่องหมายว่าอ่านแล้ว
    [Arguments]    ${notification_id}
    ${response}=    PATCH On Session    painamnae_auth    /notifications/${notification_id}/read    expected_status=any
    RETURN    ${response}

Mark All Notifications Read
    [Documentation]    ทำเครื่องหมายว่าอ่านทั้งหมด
    ${response}=    PATCH On Session    painamnae_auth    /notifications/read-all    expected_status=any
    RETURN    ${response}
