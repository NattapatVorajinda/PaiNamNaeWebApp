*** Settings ***
Library    SeleniumLibrary
Test Teardown    Capture Screenshot With Test Name
Suite Teardown   Close All Browsers

*** Variables ***
${URL}           https://csse4569.cpkku.com/
${BROWSER}       chrome
${DRIVER_EMAIL}    driver@test.com
${DRIVER_PASS}     123456

*** Keywords ***
Capture Screenshot With Test Name
    ${testname}=    Set Variable    ${TEST NAME}
    Capture Page Screenshot    ${testname}.png

Step
    [Arguments]    ${keyword}    @{args}
    Run Keyword    ${keyword}    @{args}
    Capture Page Screenshot

Snap
    [Arguments]    ${name}
    Capture Page Screenshot    ${name}.png

*** Test Cases ***
TC4 Driver Accept Booking Successfully
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.2s

    # --- Login as Driver ---
    Wait Until Element Is Visible    xpath=//a[@href='/login' or contains(.,'เข้าสู่ระบบ')]    10s
    Click Element    xpath=//a[@href='/login' or contains(.,'เข้าสู่ระบบ')]
    Wait Until Element Is Visible    xpath=//input[@type='email' or contains(@placeholder,'อีเมล') or @id='identifier' or @id='email']    10s
    # fill login fields (support common attribute variations)
    Run Keyword And Ignore Error    Input Text    id=email    ${DRIVER_EMAIL}
    Run Keyword And Ignore Error    Input Text    id=identifier    ${DRIVER_EMAIL}
    Run Keyword And Ignore Error    Input Text    xpath=//input[@type='email' or contains(@placeholder,'อีเมล')]    ${DRIVER_EMAIL}
    Run Keyword And Ignore Error    Input Text    id=password    ${DRIVER_PASS}
    Run Keyword And Ignore Error    Input Text    xpath=//input[@type='password' or contains(@placeholder,'รหัสผ่าน')]    ${DRIVER_PASS}
    Run Keyword And Ignore Error    Click Button    id=loginBtn
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ') or contains(.,'ลงชื่อเข้าใช้')]
    Wait Until Page Contains    เมนู    10s

    # --- Go to booking request menu ---
    # Click "การเดินทางทั้งหมด" (My Trips menu)
    Wait Until Element Is Visible    xpath=//a[contains(.,'การเดินทางทั้งหมด') or contains(.,'My Trips') or @id='tripsMenu']    10s
    Click Element    xpath=//a[contains(.,'การเดินทางทั้งหมด') or contains(.,'My Trips') or @id='tripsMenu']
    Wait Until Element Is Visible    xpath=//button[contains(.,'คำขอจองเส้นทางของฉัน') or contains(.,'Booking Requests')]    5s
    Click Element    xpath=//button[contains(.,'คำขอจองเส้นทางของฉัน') or contains(.,'Booking Requests')]

    # --- Click "รอดำเนินการ" (Pending) tab ---
    Wait Until Element Is Visible    xpath=//button[contains(.,'รอดำเนินการ') or contains(.,'Pending')]    5s
    Click Element    xpath=//button[contains(.,'รอดำเนินการ') or contains(.,'Pending')]
    Wait Until Page Contains Element    xpath=//button[contains(.,'ยืนยัน') or contains(.,'Confirm') or contains(.,'Accept')]    5s

    # --- Confirm first booking request (First confirmation) ---
    Click Element    xpath=(//button[contains(.,'ยืนยัน') or contains(.,'Confirm') or contains(.,'Accept')])[1]
    Sleep    2s

    # --- Second confirmation popup (if appears, click confirmation again) ---
    ${is_popup_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//button[contains(.,'ยืนยันคำขอ') or contains(.,'Confirm Request') or contains(.,'ยืนยัน')]    5s
    Run Keyword If    ${is_popup_visible}    Click Element    xpath=//button[contains(.,'ยืนยันคำขอ') or contains(.,'Confirm Request') or contains(.,'ยืนยัน')]
    Sleep    2s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'ตกลง') or contains(.,'OK') or contains(.,'ปิด')]

    # --- Verify passenger confirmed (check "เส้นทางของฉัน" or passenger list) ---
    Wait Until Page Contains    ผู้โดยสารที่ยืนยัน    15s
    Capture Page Screenshot

    [Teardown]    Close All Browsers