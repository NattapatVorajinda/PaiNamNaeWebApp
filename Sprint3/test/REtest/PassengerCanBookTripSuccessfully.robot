*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}        https://csse4569.cpkku.com/
${BROWSER}    Chrome
${VALID_EMAIL}      Namping@gmail.com
${VALID_PASSWORD}   55555555Np

* Test Cases *
TC-001 Passenger can book trip success
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    
    # เข้าสู่ระบบ
    Wait Until Page Contains    เข้าสู่ระบบ    10s
    Click Element    xpath=//a[contains(.,'เข้าสู่ระบบ')]

    # กรอก Login
    Wait Until Element Is Visible    xpath=//input[contains(@placeholder,'อีเมล')]    15s
    Input Text    xpath=//input[contains(@placeholder,'อีเมล')]    ${VALID_EMAIL}
    Input Text    xpath=//input[contains(@placeholder,'รหัสผ่าน')]    ${VALID_PASSWORD}
    Click Element    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    # * จุดสำคัญ: รอจนกว่าจะเห็นไอคอนโปรไฟล์ หรือ ข้อความ 'Sindy' เพื่อยืนยันว่า Login ติดแล้วจริงๆ *
    Wait Until Page Contains Element    xpath=//span[contains(.,'Sindy')]    15s

    # ไปที่เมนูค้นหาเส้นทาง
    Wait Until Element Is Visible    xpath=//a[@href='/findTrip']    10s
    Click Element    xpath=//a[@href='/findTrip']
    Sleep    5s
    Capture Page Screenshot

    # กรอกจุดเริ่มต้น
    Wait Until Element Is Visible    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    10s
    Input Text    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    ขอนแก่น
    Press Keys    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    TAB

    # กรอกปลายทาง
    Input Text    xpath=//input[@placeholder='เช่น เชียงใหม่']    นราธิวาส
    Press Keys    xpath=//input[@placeholder='เช่น เชียงใหม่']    TAB

    # เลือกวันที่
    Input Text    xpath=//input[@type='date']    2026-12-31

    # เลือกจำนวนที่นั่งค้นหา
    Select From List By Value    xpath=//select    1

    # กดค้นหา
    Click Button    xpath=//button[normalize-space()='ค้นหา']
    

    # เลือก route card ที่ต้องการ
    Wait Until Element Is Visible    xpath=//div[contains(@class,'route-card')]    15s
    Click Element    xpath=//div[contains(@class,'route-card')]

    # กดปุ่มจองที่นั่ง
    Wait Until Element Is Visible    xpath=//button[contains(text(),'จองที่นั่ง')]    10s
    Click Element    xpath=//button[contains(text(),'จองที่นั่ง')]
    

    # เลือกจำนวนที่นั่ง
    Wait Until Element Is Visible    xpath=//select    10s
# รอ dropdown
    Wait Until Element Is Visible    xpath=(//select)[2]    10s

# คลิก dropdown
    Click Element    xpath=(//select)[2]

# เลือก 2 ที่นั่ง
    Select From List By Value    xpath=(//select)[2]    2    # กรอกจุดขึ้นรถ
    Input Text    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]    Khon Kaen
    Press Keys    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]    TAB

    # กรอกจุดลงรถ
    Input Text    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[2]    Narathiwat

    Press Keys    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[2]    TAB

    # ยืนยันการจอง
    #Wait Until Element Is Visible    xpath=//button[contains(text(),'ยืนยันการจอง')]    10s
    #Click Element    xpath=//button[contains(text(),'ยืนยันการจอง')]
    #Wait Until Page Contains    ยืนยันการจอง    10s
    #Sleep    5s
    #Capture Page Screenshot

    #Sleep    10s
    #Wait Until Page Contains Element    xpath=//span[contains(.,'รอดำเนินการ')]    15s
    #Capture Page Screenshot
    
