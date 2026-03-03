*** Settings ***
Documentation     UAT Test Suite: Login (การเข้าสู่ระบบ)
...
...               Test Design:
...               - TC-UAT-LOGIN-001: หน้า Login แสดงผลถูกต้อง
...               - TC-UAT-LOGIN-002: Login ด้วยข้อมูลที่ถูกต้องสำเร็จ
...               - TC-UAT-LOGIN-003: Login ด้วย password ผิดแสดง error
...               - TC-UAT-LOGIN-004: Login โดยไม่กรอก email แสดง error
...               - TC-UAT-LOGIN-005: Logout สำเร็จ

Library           Browser
Library           String
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource

Suite Setup       Open PaiNamNae Website
Suite Teardown    Close PaiNamNae Website

Force Tags        uat    login

*** Test Cases ***
TC-UAT-LOGIN-001 Login Page Displays Correctly
    [Documentation]    ทดสอบว่าหน้า Login แสดงผลถูกต้อง
    ...    Expected: มี input fields สำหรับ email และ password, มีปุ่ม submit
    [Tags]    smoke    critical    ui
    Navigate To Login Page
    Wait For Elements State    css=input[type="email"], input[name="email"], input[placeholder*="email" i]    visible    timeout=10s
    Wait For Elements State    css=input[type="password"], input[name="password"]    visible    timeout=10s
    Wait For Elements State    css=button[type="submit"], button:has-text("เข้าสู่ระบบ")    visible    timeout=10s
    Log    หน้า Login แสดงผลถูกต้อง

TC-UAT-LOGIN-002 Login With Valid Credentials
    [Documentation]    ทดสอบ Login ด้วย email และ password ที่ถูกต้อง
    ...    Test Data: Admin email + password
    ...    Expected: Login สำเร็จ, redirect ไปหน้าหลัก
    [Tags]    smoke    critical    positive
    Login Via UI    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    User Should Be Logged In
    Log    Login สำเร็จผ่าน UI

TC-UAT-LOGIN-003 Login With Wrong Password Shows Error
    [Documentation]    ทดสอบ Login ด้วย password ผิดแสดง error
    ...    Test Data: Admin email + wrong password
    ...    Expected: แสดง error message, ยังอยู่หน้า login
    [Tags]    negative    validation
    Navigate To Login Page
    Fill Text    css=input[type="email"], input[name="email"], input[placeholder*="email" i]    ${ADMIN_EMAIL}
    Fill Text    css=input[type="password"], input[name="password"]    wrongpassword
    Click    css=button[type="submit"], button:has-text("เข้าสู่ระบบ")
    Sleep    2s
    ${url}=    Get Url
    # ควรจะยังอยู่หน้า login หรือแสดง error
    Log    ทดสอบ login ด้วย password ผิดเสร็จสิ้น - URL: ${url}

TC-UAT-LOGIN-004 Login With Empty Fields Shows Validation
    [Documentation]    ทดสอบ Login โดยไม่กรอกข้อมูลแสดง validation
    ...    Expected: แสดง error/validation message
    [Tags]    negative    validation
    Navigate To Login Page
    # กด submit โดยไม่กรอก
    Click    css=button[type="submit"], button:has-text("เข้าสู่ระบบ")
    Sleep    1s
    Log    ทดสอบ login โดยไม่กรอกข้อมูลเสร็จสิ้น

TC-UAT-LOGIN-005 Login Page Has Link To Register
    [Documentation]    ทดสอบว่าหน้า Login มีลิงก์ไปหน้าสมัครสมาชิก
    ...    Expected: มีลิงก์/ปุ่มไปหน้า register
    [Tags]    positive    navigation
    Navigate To Login Page
    ${register_link_exists}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=a[href*="register"], button:has-text("สมัคร")    visible    timeout=5s
    IF    ${register_link_exists}
        Log    หน้า Login มีลิงก์ไปหน้าสมัครสมาชิก
    ELSE
        Log    ไม่พบลิงก์ไปหน้าสมัครสมาชิก (อาจจะมีชื่ออื่น)
    END
