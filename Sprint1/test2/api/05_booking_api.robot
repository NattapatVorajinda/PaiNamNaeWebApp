*** Settings ***
Documentation     API Test Suite: Booking Management (การจัดการการจอง)
...
...               Test Design:
...               - TC-API-BOOK-001: ดูรายการจองของตัวเองสำเร็จ
...               - TC-API-BOOK-002: ดูรายการจองโดยไม่มี token
...               - TC-API-BOOK-003: ดูการจองตาม ID
...               - TC-API-BOOK-004: สร้างการจองใหม่
...               - TC-API-BOOK-005: สร้างการจองด้วยข้อมูลไม่ครบ
...               - TC-API-BOOK-006: อัปเดตสถานะการจอง (confirm)
...               - TC-API-BOOK-007: ยกเลิกการจอง
...               - TC-API-BOOK-008: ดูการจองที่ไม่มีอยู่
...               - TC-API-BOOK-009: ตรวจสอบข้อมูลติดต่อคนขับในรายการจอง
...               - TC-API-BOOK-010: Admin ดูรายการจองทั้งหมด

Library           RequestsLibrary
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Teardown    Delete All Sessions

Force Tags        api    booking

*** Test Cases ***
# =============================================================
# Positive Tests
# =============================================================

TC-API-BOOK-001 Get My Bookings Successfully
    [Documentation]    ทดสอบดูรายการจองของตัวเอง
    ...    Expected: HTTP 200
    [Tags]    smoke    critical    positive
    Login As Admin
    ${response}=    Get My Bookings
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    ดูรายการจองสำเร็จ

TC-API-BOOK-002 Get Booking By Id Successfully
    [Documentation]    ทดสอบดูการจองตาม ID
    ...    Precondition: ต้องมีการจองในระบบ
    ...    Expected: HTTP 200
    [Tags]    positive
    Login As Admin
    ${response}=    Get My Bookings
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีการจองในระบบสำหรับทดสอบ
    ${first_booking}=    Set Variable    ${data}[0]
    ${booking_id}=    Set Variable    ${first_booking}[id]
    ${detail_response}=    Get Booking By Id    ${booking_id}
    Response Status Should Be    ${detail_response}    ${HTTP_OK}
    Log    ดูการจองตาม ID สำเร็จ: ${booking_id}

# =============================================================
# Negative Tests
# =============================================================

TC-API-BOOK-003 Get My Bookings Without Token
    [Documentation]    ทดสอบดูรายการจองโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${response}=    GET On Session    painamnae    /bookings/me    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ดูรายการจองโดยไม่มี token ถูกปฏิเสธ

TC-API-BOOK-004 Create Booking Without Token
    [Documentation]    ทดสอบสร้างการจองโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${pickup}=    Create Dictionary    lat=13.7563    lng=100.5018    name=จุดรับ
    ${dropoff}=    Create Dictionary    lat=14.8821    lng=102.0156    name=จุดส่ง
    ${booking_data}=    Create Dictionary
    ...    routeId=some-route-id
    ...    numberOfSeats=1
    ...    pickupLocation=${pickup}
    ...    dropoffLocation=${dropoff}
    ${response}=    POST On Session    painamnae    /bookings    json=${booking_data}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    สร้างการจองโดยไม่มี token ถูกปฏิเสธ

TC-API-BOOK-005 Create Booking With Missing Route Id
    [Documentation]    ทดสอบสร้างการจองโดยไม่มี routeId
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    Login As Admin
    ${booking_data}=    Create Dictionary    numberOfSeats=1
    ${response}=    Create Booking    ${booking_data}
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    สร้างการจองไม่มี routeId ถูกปฏิเสธ - status: ${status}

TC-API-BOOK-006 Get Non-Existent Booking
    [Documentation]    ทดสอบดูการจองที่ไม่มีอยู่
    ...    Expected: HTTP 404
    [Tags]    negative
    Login As Admin
    ${response}=    Get Booking By Id    nonexistent_booking_id
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ดูการจองที่ไม่มีอยู่ถูกปฏิเสธ - status: ${status}

# =============================================================
# Contact Info Tests
# =============================================================

TC-API-BOOK-007 My Bookings Returns Driver Contact Info
    [Documentation]    ทดสอบว่ารายการจองมีข้อมูลติดต่อคนขับ (email, phoneNumber)
    ...    Expected: HTTP 200, route.driver ใน booking มี email, phoneNumber
    [Tags]    smoke    critical    positive    contact-info
    Login As Admin
    ${response}=    Get My Bookings
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีการจองในระบบสำหรับทดสอบ
    ${first_booking}=    Set Variable    ${data}[0]
    # ตรวจสอบว่า booking มี route และ route มี driver
    Dictionary Should Contain Key    ${first_booking}    route
    ${route}=    Set Variable    ${first_booking}[route]
    Dictionary Should Contain Key    ${route}    driver
    ${driver}=    Set Variable    ${route}[driver]
    Dictionary Should Contain Key    ${driver}    email
    ...    msg=ข้อมูล driver ไม่มี email ในรายการจอง
    Dictionary Should Contain Key    ${driver}    phoneNumber
    ...    msg=ข้อมูล driver ไม่มี phoneNumber ในรายการจอง
    Log    ข้อมูลติดต่อคนขับในรายการจอง: email=${driver}[email], phone=${driver}[phoneNumber]

# =============================================================
# Admin Tests
# =============================================================

TC-API-BOOK-008 Admin List All Bookings
    [Documentation]    ทดสอบ Admin ดูรายการจองทั้งหมด
    ...    Expected: HTTP 200
    [Tags]    positive    admin
    Login As Admin
    ${response}=    GET On Session    painamnae_auth    /bookings/admin    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    Admin ดูรายการจองทั้งหมดสำเร็จ

TC-API-BOOK-009 Non-Admin Cannot Access Admin Bookings
    [Documentation]    ทดสอบว่า request ที่ไม่มี token เข้าถึง admin booking endpoint ไม่ได้
    ...    Expected: HTTP 401
    [Tags]    negative    security    authorization
    Create API Session
    ${response}=    GET On Session    painamnae    /bookings/admin    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ไม่มี token เข้าถึง admin booking ไม่ได้
