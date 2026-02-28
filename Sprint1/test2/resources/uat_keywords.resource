*** Settings ***
Documentation     Keywords เฉพาะสำหรับ UAT (User Acceptance Testing) ด้วย Browser Library
Library           Browser
Library           String
Library           DateTime
Resource          common.resource

*** Keywords ***
# =========================================================
# Browser Setup / Teardown
# =========================================================
Open PaiNamNae Website
    [Documentation]    เปิดเบราว์เซอร์ไปยังหน้าแรกของเว็บ
    New Browser    ${BROWSER}    headless=${True}
    New Page    ${FRONTEND_URL}

Close PaiNamNae Website
    [Documentation]    ปิดเบราว์เซอร์
    Close Browser

# =========================================================
# Navigation Keywords
# =========================================================
Navigate To Login Page
    [Documentation]    ไปยังหน้า Login
    Go To    ${FRONTEND_URL}/login
    Wait For Elements State    text=เข้าสู่ระบบ    visible    timeout=10s

Navigate To Register Page
    [Documentation]    ไปยังหน้าสมัครสมาชิก
    Go To    ${FRONTEND_URL}/register
    Wait For Elements State    text=สมัครสมาชิก    visible    timeout=10s

Navigate To Find Trip Page
    [Documentation]    ไปยังหน้าค้นหาเส้นทาง
    Go To    ${FRONTEND_URL}/findTrip
    Wait For Elements State    css=body    visible    timeout=10s

Navigate To My Trip Page
    [Documentation]    ไปยังหน้าทริปของฉัน
    Go To    ${FRONTEND_URL}/myTrip
    Wait For Elements State    css=body    visible    timeout=10s

Navigate To My Route Page
    [Documentation]    ไปยังหน้าเส้นทางของฉัน
    Go To    ${FRONTEND_URL}/myRoute
    Wait For Elements State    css=body    visible    timeout=10s

Navigate To Create Trip Page
    [Documentation]    ไปยังหน้าสร้างเส้นทาง
    Go To    ${FRONTEND_URL}/createTrip
    Wait For Elements State    css=body    visible    timeout=10s

Navigate To Profile Page
    [Documentation]    ไปยังหน้าโปรไฟล์
    Go To    ${FRONTEND_URL}/profile
    Wait For Elements State    css=body    visible    timeout=10s

# =========================================================
# Authentication Keywords
# =========================================================
Login Via UI
    [Documentation]    เข้าสู่ระบบผ่าน UI
    [Arguments]    ${email}    ${password}
    Navigate To Login Page
    Fill Text    input[type="email"], input[name="email"], input[placeholder*="email" i]    ${email}
    Fill Text    input[type="password"], input[name="password"]    ${password}
    Click    button[type="submit"], button:has-text("เข้าสู่ระบบ")
    Wait For Navigation

Register Via UI
    [Documentation]    สมัครสมาชิกผ่าน UI
    [Arguments]    ${username}    ${email}    ${password}    ${firstName}    ${lastName}    ${phone}
    Navigate To Register Page
    Fill Text    input[name="username"]    ${username}
    Fill Text    input[name="email"], input[type="email"]    ${email}
    Fill Text    input[name="password"], input[type="password"]    ${password}
    Fill Text    input[name="firstName"]    ${firstName}
    Fill Text    input[name="lastName"]    ${lastName}
    Fill Text    input[name="phoneNumber"], input[name="phone"]    ${phone}

Logout Via UI
    [Documentation]    ออกจากระบบผ่าน UI
    Click    button:has-text("ออกจากระบบ"), a:has-text("ออกจากระบบ")
    Wait For Navigation

User Should Be Logged In
    [Documentation]    ตรวจสอบว่าผู้ใช้เข้าสู่ระบบแล้ว
    Wait For Elements State    css=body    visible    timeout=10s
    ${url}=    Get Url
    Should Not Contain    ${url}    /login

# =========================================================
# Contact Info Verification Keywords
# =========================================================
Verify Driver Contact Info Visible
    [Documentation]    ตรวจสอบว่าข้อมูลติดต่อคนขับแสดงอยู่
    Wait For Elements State    text=email    visible    timeout=10s
    Wait For Elements State    text=โทร    visible    timeout=10s

Verify Passenger Contact Info Visible
    [Documentation]    ตรวจสอบว่าข้อมูลติดต่อผู้โดยสารแสดงอยู่
    Wait For Elements State    text=โทร    visible    timeout=10s

Page Should Contain Contact Email
    [Documentation]    ตรวจสอบว่าหน้ามี email แสดง
    [Arguments]    ${email}
    Get Text    css=body    contains    ${email}

Page Should Contain Contact Phone
    [Documentation]    ตรวจสอบว่าหน้ามีเบอร์โทรแสดง
    [Arguments]    ${phone}
    Get Text    css=body    contains    ${phone}

# =========================================================
# Toast / Alert Keywords
# =========================================================
Toast Should Show Success
    [Documentation]    ตรวจสอบว่ามี Toast แจ้งสำเร็จ
    Wait For Elements State    css=.toast-success, [class*="success"]    visible    timeout=10s

Toast Should Show Error
    [Documentation]    ตรวจสอบว่ามี Toast แจ้ง error
    Wait For Elements State    css=.toast-error, [class*="error"]    visible    timeout=10s

# =========================================================
# Wait Keywords
# =========================================================
Wait For Page Load
    [Documentation]    รอให้หน้าโหลดเสร็จ
    Wait For Elements State    css=body    visible    timeout=15s

Wait For API Response
    [Documentation]    รอให้ API response กลับมา
    Sleep    1s
