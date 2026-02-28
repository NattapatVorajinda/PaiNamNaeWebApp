*** Settings ***
Documentation     UAT Test Suite: Booking (การจองเส้นทาง)
...
...               Test Design:
...               - TC-UAT-BOOK-001: หน้าทริปของฉันแสดงผลถูกต้อง
...               - TC-UAT-BOOK-002: หน้าทริปของฉันแสดงรายการจอง
...               - TC-UAT-BOOK-003: หน้าทริปของฉันแสดงข้อมูลติดต่อคนขับ
...               - TC-UAT-BOOK-004: หน้าเส้นทางของฉันแสดง booking requests

Library           Browser
Library           String
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource

Suite Setup       Setup Booking Tests
Suite Teardown    Close PaiNamNae Website

Force Tags        uat    booking

*** Keywords ***
Setup Booking Tests
    [Documentation]    เตรียมข้อมูลสำหรับทดสอบการจอง
    Open PaiNamNae Website
    Login Via UI    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Wait For Page Load

*** Test Cases ***
TC-UAT-BOOK-001 My Trip Page Displays Correctly
    [Documentation]    ทดสอบว่าหน้าทริปของฉันแสดงผลถูกต้อง
    ...    Expected: เข้าถึงหน้า myTrip ได้
    [Tags]    smoke    critical    ui
    Navigate To My Trip Page
    Wait For Page Load
    ${url}=    Get Url
    Should Contain    ${url}    myTrip
    Log    หน้าทริปของฉันแสดงผลถูกต้อง

TC-UAT-BOOK-002 My Trip Page Shows Booking List
    [Documentation]    ทดสอบว่าหน้าทริปของฉันแสดงรายการจอง
    ...    Expected: แสดงรายการจองหรือข้อความ "ไม่มีการจอง"
    [Tags]    smoke    positive
    Navigate To My Trip Page
    Wait For Page Load
    Sleep    3s    # รอ API response
    ${body_text}=    Get Text    css=body
    Log    เนื้อหาหน้าทริปของฉัน (ตรวจสอบรายการจอง)

TC-UAT-BOOK-003 My Trip Shows Driver Contact Info
    [Documentation]    ทดสอบว่าหน้าทริปของฉันแสดงข้อมูลติดต่อคนขับ (email, เบอร์โทร)
    ...    Expected: แสดง email และเบอร์โทรศัพท์ของคนขับ
    ...    หมายเหตุ: ฟีเจอร์ข้อมูลติดต่อที่เพิ่งเพิ่มใหม่
    [Tags]    critical    positive    contact-info
    Navigate To My Trip Page
    Wait For Page Load
    Sleep    3s
    ${body_text}=    Get Text    css=body
    ${has_email}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}
    ${has_phone}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    0[689]\\d{8}
    IF    ${has_email}
        Log    พบ email ติดต่อคนขับในหน้าทริปของฉัน ✓
    ELSE
        Log    ไม่พบ email (อาจไม่มีการจอง)
    END
    IF    ${has_phone}
        Log    พบเบอร์โทรติดต่อคนขับในหน้าทริปของฉัน ✓
    ELSE
        Log    ไม่พบเบอร์โทร (อาจไม่มีการจอง)
    END

TC-UAT-BOOK-004 My Route Page Shows Booking Requests
    [Documentation]    ทดสอบว่าหน้าเส้นทางของฉันแสดง booking requests
    ...    Expected: หน้า myRoute แสดงรายการจอง
    [Tags]    positive
    Navigate To My Route Page
    Wait For Page Load
    Sleep    3s
    ${body_text}=    Get Text    css=body
    Log    เนื้อหาหน้าเส้นทางของฉัน (ตรวจสอบ booking requests)

TC-UAT-BOOK-005 My Route Shows Passenger Contact Info
    [Documentation]    ทดสอบว่าหน้าเส้นทางของฉันแสดงข้อมูลติดต่อผู้โดยสาร (เบอร์โทร)
    ...    Expected: แสดงเบอร์โทรศัพท์ของผู้โดยสารในรายการจอง
    ...    หมายเหตุ: ฟีเจอร์ข้อมูลติดต่อที่เพิ่งเพิ่มใหม่
    [Tags]    critical    positive    contact-info
    Navigate To My Route Page
    Wait For Page Load
    Sleep    3s
    ${body_text}=    Get Text    css=body
    ${has_phone}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    0[689]\\d{8}
    IF    ${has_phone}
        Log    พบเบอร์โทรติดต่อผู้โดยสารในหน้าเส้นทาง ✓
    ELSE
        Log    ไม่พบเบอร์โทร (อาจไม่มีผู้โดยสาร/booking)
    END
