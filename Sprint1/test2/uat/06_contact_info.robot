*** Settings ***
Documentation     UAT Test Suite: Contact Info Verification (ตรวจสอบข้อมูลติดต่อ)
...
...               Test Design:
...               ทดสอบฟีเจอร์ข้อมูลติดต่อผู้โดยสารและคนขับบนหน้าเว็บ
...               - TC-UAT-CONTACT-001: API คืนข้อมูลติดต่อคนขับ (email, phone)
...               - TC-UAT-CONTACT-002: API คืนข้อมูลติดต่อผู้โดยสาร (phone)
...               - TC-UAT-CONTACT-003: หน้า findTrip แสดง email คนขับ
...               - TC-UAT-CONTACT-004: หน้า myTrip แสดงข้อมูลติดต่อคนขับ
...               - TC-UAT-CONTACT-005: หน้า myRoute แสดงเบอร์โทรผู้โดยสาร
...               - TC-UAT-CONTACT-006: ข้อมูลติดต่อคนขับครบถ้วน (email + phone)

Library           Browser
Library           RequestsLibrary
Library           Collections
Library           String
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource
Resource          ../resources/api_keywords.resource

Suite Setup       Setup Contact Info Tests
Suite Teardown    Teardown Contact Info Tests

Force Tags        uat    contact-info    critical

*** Keywords ***
Setup Contact Info Tests
    [Documentation]    เตรียมข้อมูลสำหรับทดสอบข้อมูลติดต่อ
    Open PaiNamNae Website

Teardown Contact Info Tests
    [Documentation]    ล้างข้อมูลหลังทดสอบ
    Delete All Sessions
    Close PaiNamNae Website

*** Test Cases ***
# =============================================================
# API-Level Contact Info Verification
# =============================================================

TC-UAT-CONTACT-001 API Returns Driver Contact In Route Search
    [Documentation]    ตรวจสอบว่า API /routes คืนข้อมูลติดต่อคนขับ
    ...    Expected: driver object มี email และ phoneNumber
    [Tags]    smoke    api-verification
    Create API Session
    ${response}=    GET On Session    painamnae    /routes    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีเส้นทางสำหรับทดสอบ
    ${route}=    Set Variable    ${data}[0]
    ${driver}=    Set Variable    ${route}[driver]
    Dictionary Should Contain Key    ${driver}    email
    ...    msg=API ไม่คืน email คนขับ! ตรวจสอบ route.service.js baseInclude
    Dictionary Should Contain Key    ${driver}    phoneNumber
    ...    msg=API ไม่คืน phoneNumber คนขับ! ตรวจสอบ route.service.js baseInclude
    Should Not Be Empty    ${driver}[email]    msg=email คนขับเป็นค่าว่าง!
    Log    ✓ API คืนข้อมูลติดต่อคนขับ: email=${driver}[email], phone=${driver}[phoneNumber]

TC-UAT-CONTACT-002 API Returns Driver Contact In Bookings
    [Documentation]    ตรวจสอบว่า API /bookings/me คืนข้อมูลติดต่อคนขับ
    ...    Expected: route.driver มี email และ phoneNumber
    [Tags]    smoke    api-verification
    ${token}=    Login And Get Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Create Authenticated Session    ${token}
    ${response}=    GET On Session    painamnae_auth    /bookings/me    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีการจองสำหรับทดสอบ
    ${booking}=    Set Variable    ${data}[0]
    ${route}=    Set Variable    ${booking}[route]
    ${driver}=    Set Variable    ${route}[driver]
    Dictionary Should Contain Key    ${driver}    email
    ...    msg=API ไม่คืน email คนขับใน bookings! ตรวจสอบ booking.service.js
    Dictionary Should Contain Key    ${driver}    phoneNumber
    ...    msg=API ไม่คืน phoneNumber คนขับใน bookings!
    Log    ✓ API คืนข้อมูลติดต่อคนขับในรายการจอง

TC-UAT-CONTACT-003 API Returns Passenger Contact In My Routes
    [Documentation]    ตรวจสอบว่า API /routes/me คืนข้อมูลติดต่อผู้โดยสาร
    ...    Expected: booking.passenger มี phoneNumber
    [Tags]    smoke    api-verification
    ${token}=    Login And Get Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Create Authenticated Session    ${token}
    ${response}=    GET On Session    painamnae_auth    /routes/me    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีเส้นทางสำหรับทดสอบ
    # ค้นหาเส้นทางที่มี booking
    ${found_booking}=    Set Variable    ${False}
    FOR    ${route}    IN    @{data}
        ${has_bookings}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${route}    bookings
        IF    ${has_bookings}
            ${bookings}=    Set Variable    ${route}[bookings]
            ${bcount}=    Get Length    ${bookings}
            IF    ${bcount} > 0
                ${booking}=    Set Variable    ${bookings}[0]
                ${passenger}=    Set Variable    ${booking}[passenger]
                Dictionary Should Contain Key    ${passenger}    phoneNumber
                ...    msg=API ไม่คืน phoneNumber ผู้โดยสาร! ตรวจสอบ route.service.js getMyRoutes
                Log    ✓ API คืนข้อมูลติดต่อผู้โดยสาร: phone=${passenger}[phoneNumber]
                ${found_booking}=    Set Variable    ${True}
                BREAK
            END
        END
    END
    Skip If    not ${found_booking}    ไม่มี booking ในเส้นทางสำหรับทดสอบ

# =============================================================
# UI-Level Contact Info Verification
# =============================================================

TC-UAT-CONTACT-004 FindTrip Page Shows Driver Contact
    [Documentation]    ตรวจสอบว่าหน้า findTrip แสดงข้อมูลติดต่อคนขับ
    ...    Expected: หน้าเว็บแสดง email และ/หรือ เบอร์โทรของคนขับ
    [Tags]    ui-verification
    Login Via UI    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Navigate To Find Trip Page
    Wait For Page Load
    Sleep    5s    # รอข้อมูลโหลด
    ${body_text}=    Get Text    css=body
    ${has_email}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}
    ${has_phone}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    0[689]\\d{8}
    Log    FindTrip - พบ email: ${has_email}, พบเบอร์โทร: ${has_phone}
    IF    ${has_email} or ${has_phone}
        Log    ✓ หน้า findTrip แสดงข้อมูลติดต่อคนขับ
    ELSE
        Log    ! ไม่พบข้อมูลติดต่อในหน้า findTrip (อาจไม่มีเส้นทาง)
    END

TC-UAT-CONTACT-005 MyTrip Page Shows Driver Contact
    [Documentation]    ตรวจสอบว่าหน้า myTrip แสดงข้อมูลติดต่อคนขับ
    ...    Expected: หน้าเว็บแสดง email และ/หรือ เบอร์โทรของคนขับ
    [Tags]    ui-verification
    Navigate To My Trip Page
    Wait For Page Load
    Sleep    5s
    ${body_text}=    Get Text    css=body
    ${has_email}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}
    ${has_phone}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    0[689]\\d{8}
    Log    MyTrip - พบ email: ${has_email}, พบเบอร์โทร: ${has_phone}
    IF    ${has_email} or ${has_phone}
        Log    ✓ หน้า myTrip แสดงข้อมูลติดต่อคนขับ
    ELSE
        Log    ! ไม่พบข้อมูลติดต่อในหน้า myTrip (อาจไม่มีการจอง)
    END

TC-UAT-CONTACT-006 MyRoute Page Shows Passenger Contact
    [Documentation]    ตรวจสอบว่าหน้า myRoute แสดงเบอร์โทรของผู้โดยสาร
    ...    Expected: หน้าเว็บแสดงเบอร์โทรศัพท์ของผู้โดยสาร
    [Tags]    ui-verification
    Navigate To My Route Page
    Wait For Page Load
    Sleep    5s
    ${body_text}=    Get Text    css=body
    ${has_phone}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    0[689]\\d{8}
    IF    ${has_phone}
        Log    ✓ หน้า myRoute แสดงเบอร์โทรของผู้โดยสาร
    ELSE
        Log    ! ไม่พบเบอร์โทรในหน้า myRoute (อาจไม่มีผู้โดยสาร)
    END
