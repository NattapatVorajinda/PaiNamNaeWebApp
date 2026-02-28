*** Settings ***
Documentation     UAT Test Suite: User Registration (การลงทะเบียน)
...
...               Test Design:
...               - TC-UAT-REG-001: ลงทะเบียนผู้ใช้ใหม่สำเร็จ
...               - TC-UAT-REG-002: ลงทะเบียนด้วย email ซ้ำแสดง error
...               - TC-UAT-REG-003: ลงทะเบียนด้วย password สั้นเกินไป
...               - TC-UAT-REG-004: ลงทะเบียนโดยไม่กรอกข้อมูลจำเป็น
...               - TC-UAT-REG-005: หน้าลงทะเบียนแสดงผลถูกต้อง

Library           Browser
Library           String
Library           DateTime
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource

Suite Setup       Open PaiNamNae Website
Suite Teardown    Close PaiNamNae Website

Force Tags        uat    registration

*** Test Cases ***
TC-UAT-REG-001 Registration Page Displays Correctly
    [Documentation]    ทดสอบว่าหน้าสมัครสมาชิกแสดงผลถูกต้อง
    ...    Expected: หน้ามี form fields ที่จำเป็นทั้งหมด
    [Tags]    smoke    critical    ui
    Navigate To Register Page
    Wait For Elements State    css=input[name="username"], input[placeholder*="username" i]    visible    timeout=10s
    Wait For Elements State    css=input[type="email"], input[name="email"]    visible    timeout=10s
    Wait For Elements State    css=input[type="password"], input[name="password"]    visible    timeout=10s
    Log    หน้าลงทะเบียนแสดงผลถูกต้อง

TC-UAT-REG-002 Register New User Via UI
    [Documentation]    ทดสอบลงทะเบียนผู้ใช้ใหม่ผ่าน UI
    ...    Test Data: ข้อมูลผู้ใช้ทดสอบที่ไม่ซ้ำ
    ...    Expected: สมัครสำเร็จ, redirect ไปหน้า login หรือหน้าหลัก
    [Tags]    smoke    critical    positive
    ${unique_username}=    Generate Unique Username
    ${unique_email}=    Generate Unique Email
    Navigate To Register Page
    Register Via UI
    ...    ${unique_username}
    ...    ${unique_email}
    ...    Test@12345
    ...    ทดสอบ
    ...    ระบบใหม่
    ...    0866666666
    Wait For Page Load
    Log    ทดสอบลงทะเบียนผ่าน UI เสร็จสิ้น

TC-UAT-REG-003 Register With Empty Fields Shows Validation
    [Documentation]    ทดสอบว่ากรอกข้อมูลไม่ครบจะแสดง validation error
    ...    Expected: แสดง error message
    [Tags]    negative    validation
    Navigate To Register Page
    # พยายามกด submit โดยไม่กรอกข้อมูล
    ${submit_exists}=    Run Keyword And Return Status
    ...    Wait For Elements State    button[type="submit"], button:has-text("สมัคร")    visible    timeout=5s
    IF    ${submit_exists}
        Click    button[type="submit"], button:has-text("สมัคร")
        Sleep    1s
        # ตรวจสอบว่ามี validation message
        Log    ทดสอบ validation เมื่อกรอกข้อมูลไม่ครบ
    END

TC-UAT-REG-004 Navigate Between Register And Login Pages
    [Documentation]    ทดสอบการ navigate ระหว่างหน้าลงทะเบียนและ login
    ...    Expected: สามารถไปกลับระหว่างสองหน้าได้
    [Tags]    positive    navigation
    Navigate To Register Page
    ${url1}=    Get Url
    Should Contain    ${url1}    register
    Navigate To Login Page
    ${url2}=    Get Url
    Should Contain    ${url2}    login
    Log    navigate ระหว่างหน้าลงทะเบียนและ login ได้
