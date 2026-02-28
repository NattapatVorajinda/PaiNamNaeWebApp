*** Settings ***
Documentation     API Test Suite: Route Management (การจัดการเส้นทาง)
...
...               Test Design:
...               - TC-API-ROUTE-001: ค้นหาเส้นทางทั้งหมด (public)
...               - TC-API-ROUTE-002: ค้นหาเส้นทางตาม ID (public)
...               - TC-API-ROUTE-003: ดูเส้นทางของตัวเอง
...               - TC-API-ROUTE-004: สร้างเส้นทางใหม่ (driver verified)
...               - TC-API-ROUTE-005: อัปเดตเส้นทาง
...               - TC-API-ROUTE-006: ยกเลิกเส้นทาง
...               - TC-API-ROUTE-007: ลบเส้นทาง
...               - TC-API-ROUTE-008: สร้างเส้นทางโดยไม่มี token
...               - TC-API-ROUTE-009: ค้นหาเส้นทางด้วย filter
...               - TC-API-ROUTE-010: Admin ดูเส้นทางทั้งหมด
...               - TC-API-ROUTE-011: ตรวจสอบข้อมูลติดต่อคนขับในผลค้นหา

Library           RequestsLibrary
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Teardown    Delete All Sessions

Force Tags        api    route

*** Test Cases ***
# =============================================================
# Public Route Search Tests
# =============================================================

TC-API-ROUTE-001 Search All Routes Public
    [Documentation]    ทดสอบค้นหาเส้นทางทั้งหมด (ไม่ต้อง login)
    ...    Expected: HTTP 200, response มี data
    [Tags]    smoke    critical    positive
    Create API Session
    ${response}=    GET On Session    painamnae    /routes    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    ค้นหาเส้นทางสาธารณะสำเร็จ

TC-API-ROUTE-002 Get Route By Id Public
    [Documentation]    ทดสอบดูเส้นทางตาม ID (ไม่ต้อง login)
    ...    Precondition: ต้องมีเส้นทางในระบบ
    ...    Expected: HTTP 200 หรือ 404
    [Tags]    positive
    Create API Session
    # ดึงเส้นทางแรกจากรายการ
    ${response}=    GET On Session    painamnae    /routes    expected_status=any
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีเส้นทางในระบบสำหรับทดสอบ
    ${first_route}=    Set Variable    ${data}[0]
    ${route_id}=    Set Variable    ${first_route}[id]
    ${detail_response}=    GET On Session    painamnae    /routes/${route_id}    expected_status=any
    Response Status Should Be    ${detail_response}    ${HTTP_OK}
    Log    ดูเส้นทางตาม ID สำเร็จ: ${route_id}

TC-API-ROUTE-003 Search Routes With Filters
    [Documentation]    ทดสอบค้นหาเส้นทางด้วย filter
    ...    Test Data: status=AVAILABLE
    ...    Expected: HTTP 200
    [Tags]    positive
    Create API Session
    ${params}=    Create Dictionary    status=AVAILABLE    limit=5
    ${response}=    GET On Session    painamnae    /routes    params=${params}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    ค้นหาเส้นทางด้วย filter สำเร็จ

# =============================================================
# Authenticated Route Tests
# =============================================================

TC-API-ROUTE-004 Get My Routes Successfully
    [Documentation]    ทดสอบดูเส้นทางของตัวเอง
    ...    Expected: HTTP 200
    [Tags]    smoke    positive
    Login As Admin
    ${response}=    Get My Routes
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Log    ดูเส้นทางของตัวเองสำเร็จ

# =============================================================
# Negative Tests
# =============================================================

TC-API-ROUTE-005 Create Route Without Token
    [Documentation]    ทดสอบสร้างเส้นทางโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${start}=    Create Dictionary    lat=${ROUTE_START_LAT}    lng=${ROUTE_START_LNG}    name=${ROUTE_START_NAME}
    ${end}=    Create Dictionary    lat=${ROUTE_END_LAT}    lng=${ROUTE_END_LNG}    name=${ROUTE_END_NAME}
    ${route_data}=    Create Dictionary
    ...    startLocation=${start}
    ...    endLocation=${end}
    ...    departureTime=2025-12-01T09:00:00.000Z
    ...    availableSeats=3
    ...    pricePerSeat=200
    ${response}=    POST On Session    painamnae    /routes    json=${route_data}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    สร้างเส้นทางโดยไม่มี token ถูกปฏิเสธ

TC-API-ROUTE-006 Get My Routes Without Token
    [Documentation]    ทดสอบดูเส้นทางของตัวเองโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${response}=    GET On Session    painamnae    /routes/me    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ดูเส้นทางโดยไม่มี token ถูกปฏิเสธ

TC-API-ROUTE-007 Get Non-Existent Route
    [Documentation]    ทดสอบดูเส้นทางที่ไม่มีอยู่จริง
    ...    Expected: HTTP 404
    [Tags]    negative
    Create API Session
    ${response}=    GET On Session    painamnae    /routes/nonexistent_route_id    expected_status=any
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ดูเส้นทางที่ไม่มีอยู่ถูกปฏิเสธ - status: ${status}

# =============================================================
# Contact Info in Route Search Results
# =============================================================

TC-API-ROUTE-008 Route Search Returns Driver Contact Info
    [Documentation]    ทดสอบว่าผลค้นหาเส้นทางมีข้อมูลติดต่อคนขับ (email, phoneNumber)
    ...    Expected: HTTP 200, driver ใน response มี email และ phoneNumber
    [Tags]    smoke    critical    positive    contact-info
    Create API Session
    ${response}=    GET On Session    painamnae    /routes    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีเส้นทางในระบบสำหรับทดสอบ
    ${first_route}=    Set Variable    ${data}[0]
    Dictionary Should Contain Key    ${first_route}    driver
    ${driver}=    Set Variable    ${first_route}[driver]
    Dictionary Should Contain Key    ${driver}    email
    ...    msg=ข้อมูล driver ไม่มี email - ตรวจสอบ backend baseInclude
    Dictionary Should Contain Key    ${driver}    phoneNumber
    ...    msg=ข้อมูล driver ไม่มี phoneNumber - ตรวจสอบ backend baseInclude
    Log    ข้อมูลติดต่อคนขับ: email=${driver}[email], phone=${driver}[phoneNumber]

TC-API-ROUTE-009 My Routes Returns Passenger Contact Info
    [Documentation]    ทดสอบว่าเส้นทางของฉันมีข้อมูลติดต่อผู้โดยสาร
    ...    Expected: HTTP 200, bookings ใน response มี passenger พร้อม phoneNumber
    [Tags]    positive    contact-info
    Login As Admin
    ${response}=    Get My Routes
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีเส้นทางในระบบสำหรับทดสอบ
    # ตรวจสอบเส้นทางที่มี bookings
    FOR    ${route}    IN    @{data}
        ${has_bookings}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${route}    bookings
        IF    ${has_bookings}
            ${bookings}=    Set Variable    ${route}[bookings]
            ${booking_count}=    Get Length    ${bookings}
            IF    ${booking_count} > 0
                ${first_booking}=    Set Variable    ${bookings}[0]
                Dictionary Should Contain Key    ${first_booking}    passenger
                ${passenger}=    Set Variable    ${first_booking}[passenger]
                Dictionary Should Contain Key    ${passenger}    phoneNumber
                ...    msg=ข้อมูล passenger ไม่มี phoneNumber
                Log    ข้อมูลติดต่อผู้โดยสาร: phone=${passenger}[phoneNumber]
                BREAK
            END
        END
    END
    Log    ตรวจสอบข้อมูลติดต่อผู้โดยสารเสร็จสิ้น

# =============================================================
# Admin Route Tests
# =============================================================

TC-API-ROUTE-010 Admin List All Routes
    [Documentation]    ทดสอบ Admin ดูเส้นทางทั้งหมด
    ...    Expected: HTTP 200
    [Tags]    positive    admin
    Login As Admin
    ${response}=    GET On Session    painamnae_auth    /routes/admin    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    Admin ดูเส้นทางทั้งหมดสำเร็จ
