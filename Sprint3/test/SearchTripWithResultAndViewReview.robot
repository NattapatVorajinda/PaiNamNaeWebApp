*** Settings ***
Library    SeleniumLibrary
Suite Teardown   Close All Browsers

*** Variables ***
${URL}        https://csse4569.cpkku.com/
${BROWSER}    Chrome
${VALID_EMAIL}      Namping@gmail.com
${VALID_PASSWORD}   55555555Np

* Test Cases *
TC-001 Report Incident Multiple Problems
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

    # กด ค้นหาเส้นทาง (ระบุให้ชัดเจนขึ้น)
    Wait Until Element Is Visible    xpath=//a[@href='/findTrip']    15s
    Click Link    xpath=//a[@href='/findTrip']
    
    # ตรวจสอบหน้าปลายทาง
    Wait Until Page Contains    จุดเริ่มต้น    5s

    Input Text    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    ขอนแก่น
    Press Keys    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    TAB

    Input Text    xpath=//input[@placeholder='เช่น เชียงใหม่']    นราธิวาส
    Press Keys    xpath=//input[@placeholder='เช่น เชียงใหม่']    TAB

    Input Text    xpath=//input[@type='date']    2026-12-31
    Select From List By Value    xpath=//select    1

    Click Button    xpath=//button[normalize-space()='ค้นหา']

    Wait Until Element Is Visible    xpath=//span[contains(text(),'รีวิว')]    15s
    Capture Page Screenshot
    Click Element    xpath=//span[contains(text(),'รีวิว')]

    Wait Until Element Is Visible    xpath=//div[contains(@class,'fixed')]    10s
    Sleep    5s
    Capture Page Screenshot