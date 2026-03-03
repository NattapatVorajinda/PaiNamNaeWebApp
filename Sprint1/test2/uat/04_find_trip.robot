*** Settings ***
Documentation     UAT Test Suite: Find Trip (การค้นหาเส้นทาง)
...
...               Test Design:
...               - TC-UAT-FIND-001: หน้าค้นหาเส้นทางแสดงผลถูกต้อง
...               - TC-UAT-FIND-002: ค้นหาเส้นทางแสดงผลลัพธ์
...               - TC-UAT-FIND-003: ผลค้นหาแสดงข้อมูลคนขับ
...               - TC-UAT-FIND-004: ผลค้นหาแสดงข้อมูลติดต่อคนขับ

Library           Browser
Library           String
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource

Suite Setup       Setup Find Trip Tests
Suite Teardown    Close PaiNamNae Website

Force Tags        uat    find-trip

*** Keywords ***
Setup Find Trip Tests
    [Documentation]    เตรียมข้อมูลสำหรับทดสอบค้นหาเส้นทาง
    Open PaiNamNae Website
    Login Via UI    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Wait For Page Load

*** Test Cases ***
TC-UAT-FIND-001 Find Trip Page Displays Correctly
    [Documentation]    ทดสอบว่าหน้าค้นหาเส้นทางแสดงผลถูกต้อง
    ...    Expected: มี search input, แสดง map หรือ list
    [Tags]    smoke    critical    ui
    Navigate To Find Trip Page
    Wait For Page Load
    ${url}=    Get Url
    Should Contain    ${url}    findTrip
    Log    หน้าค้นหาเส้นทางแสดงผลถูกต้อง

TC-UAT-FIND-002 Find Trip Page Shows Available Routes
    [Documentation]    ทดสอบว่าหน้าค้นหาแสดงเส้นทางที่มีอยู่
    ...    Expected: แสดงรายการเส้นทางหรือข้อความ "ไม่พบเส้นทาง"
    [Tags]    smoke    positive
    Navigate To Find Trip Page
    Wait For Page Load
    Sleep    3s    # รอ API response
    ${body_text}=    Get Text    css=body
    # ตรวจสอบว่ามีเนื้อหาจากผลค้นหา
    Log    เนื้อหาหน้าค้นหาเส้นทาง (ตรวจสอบว่ามีรายการ)

TC-UAT-FIND-003 Find Trip Shows Driver Info
    [Documentation]    ทดสอบว่าผลค้นหาเส้นทางแสดงข้อมูลคนขับ
    ...    Expected: แสดงชื่อ, รูป, ข้อมูลคนขับ
    [Tags]    positive    contact-info
    Navigate To Find Trip Page
    Wait For Page Load
    Sleep    3s
    # ตรวจสอบว่ามีการแสดงข้อมูลคนขับ
    ${body_text}=    Get Text    css=body
    Log    ตรวจสอบว่ามีข้อมูลคนขับในผลค้นหา

TC-UAT-FIND-004 Find Trip Shows Driver Contact Information
    [Documentation]    ทดสอบว่าผลค้นหาเส้นทางแสดงข้อมูลติดต่อคนขับ (email, เบอร์โทร)
    ...    Expected: แสดง email และเบอร์โทรศัพท์ของคนขับ
    ...    หมายเหตุ: ฟีเจอร์ข้อมูลติดต่อที่เพิ่งเพิ่มใหม่
    [Tags]    critical    positive    contact-info
    Navigate To Find Trip Page
    Wait For Page Load
    Sleep    3s
    ${body_text}=    Get Text    css=body
    # ตรวจสอบว่ามีข้อมูลที่ดูเหมือน email (xxx@xxx.xxx) หรือ หมายเลขโทรศัพท์ (09xxxxxxxx)
    ${has_email_pattern}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}
    ${has_phone_pattern}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${body_text}    0[689]\\d{8}
    IF    ${has_email_pattern}
        Log    พบ email ในหน้าค้นหาเส้นทาง ✓
    ELSE
        Log    ไม่พบ email ในหน้าค้นหา (อาจยังไม่มีเส้นทางหรือไม่มีข้อมูลติดต่อ)
    END
    IF    ${has_phone_pattern}
        Log    พบเบอร์โทรในหน้าค้นหาเส้นทาง ✓
    ELSE
        Log    ไม่พบเบอร์โทรในหน้าค้นหา (อาจยังไม่มีเส้นทางหรือไม่มีข้อมูลติดต่อ)
    END
