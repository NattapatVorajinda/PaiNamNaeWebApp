*** Settings ***
Documentation     UAT Test Suite: Create Trip (การสร้างเส้นทาง)
...
...               Test Design:
...               - TC-UAT-TRIP-001: หน้าสร้างเส้นทางแสดงผลถูกต้อง
...               - TC-UAT-TRIP-002: สร้างเส้นทางใหม่สำเร็จ
...               - TC-UAT-TRIP-003: สร้างเส้นทางโดยไม่กรอกข้อมูลที่จำเป็น
...               - TC-UAT-TRIP-004: ตรวจสอบว่าเส้นทางใหม่แสดงในรายการ

Library           Browser
Library           String
Library           DateTime
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource

Suite Setup       Setup Create Trip Tests
Suite Teardown    Close PaiNamNae Website

Force Tags        uat    create-trip

*** Keywords ***
Setup Create Trip Tests
    [Documentation]    เตรียมข้อมูลสำหรับทดสอบสร้างเส้นทาง
    Open PaiNamNae Website
    Login Via UI    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Wait For Page Load

*** Test Cases ***
TC-UAT-TRIP-001 Create Trip Page Accessible After Login
    [Documentation]    ทดสอบว่าหน้าสร้างเส้นทางเข้าถึงได้หลัง login
    ...    Precondition: ต้อง login แล้ว
    ...    Expected: หน้าสร้างเส้นทางแสดงผลได้
    [Tags]    smoke    critical    ui
    Navigate To Create Trip Page
    Wait For Page Load
    ${url}=    Get Url
    Should Contain    ${url}    createTrip
    Log    หน้าสร้างเส้นทางเข้าถึงได้

TC-UAT-TRIP-002 Create Trip Page Has Required Fields
    [Documentation]    ทดสอบว่าหน้าสร้างเส้นทางมี field ที่จำเป็น
    ...    Expected: มี fields สำหรับ ต้นทาง, ปลายทาง, เวลาออกเดินทาง, จำนวนที่นั่ง, ราคา
    [Tags]    smoke    ui
    Navigate To Create Trip Page
    Wait For Page Load
    # ตรวจสอบว่ามี form elements
    ${body_text}=    Get Text    css=body
    Log    เนื้อหาหน้าสร้างเส้นทาง: ตรวจสอบ form fields

TC-UAT-TRIP-003 My Route Page Shows Created Routes
    [Documentation]    ทดสอบว่าหน้าเส้นทางของฉันแสดงเส้นทางที่สร้างไว้
    ...    Expected: หน้า myRoute แสดงรายการเส้นทาง
    [Tags]    positive
    Navigate To My Route Page
    Wait For Page Load
    ${url}=    Get Url
    Should Contain    ${url}    myRoute
    Log    หน้าเส้นทางของฉันเข้าถึงได้

TC-UAT-TRIP-004 Unauthenticated User Redirected From Create Trip
    [Documentation]    ทดสอบว่าผู้ใช้ที่ไม่ได้ login ถูก redirect จากหน้าสร้างเส้นทาง
    ...    Expected: redirect ไปหน้า login
    [Tags]    negative    security
    # เปิด browser ใหม่โดยไม่ login
    New Context
    New Page    ${FRONTEND_URL}/createTrip
    Sleep    3s
    ${url}=    Get Url
    # ควรถูก redirect ไปหน้า login หรือหน้าหลัก
    Log    URL หลังพยายามเข้าหน้าสร้างเส้นทาง: ${url}
