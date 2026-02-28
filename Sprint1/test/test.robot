* Settings *
Library    SeleniumLibrary

* Variables *
${URL}        https://cs-se4g5-68.cpkku.com
${BROWSER}    Chrome
${EMAIL}      test@kkumail.com
${PASSWORD}   12345678

* Test Cases *
TC-001 Report Incident Multiple Problems
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    เข้าสู่ระบบ    10s
    Click Element    xpath=//a[contains(.,'เข้าสู่ระบบ')]

    Wait Until Element Is Visible    xpath=//input[contains(@placeholder,'อีเมล')]    15s
    Input Text    xpath=//input[contains(@placeholder,'อีเมล')]    ${EMAIL}
    Input Text    xpath=//input[contains(@placeholder,'รหัสผ่าน')]    ${PASSWORD}
    Click Element    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    Wait Until Page Does Not Contain    เข้าสู่ระบบ    10s
    Sleep    3s 
    
    Capture Page Screenshot

TC-002 Report 
    Wait Until Element Is Visible    xpath=//button[@aria-haspopup='true']    15s
    Click Element                   xpath=//button[@aria-haspopup='true']
    Sleep    1s
    Wait Until Element Is Visible    xpath=//a[@href='/notifications']    10s
    Click Element                   xpath=//a[@href='/notifications']
    
    Wait Until Page Contains        การแจ้งเตือน    15s
    Capture Page Screenshot

TC-003 Check Notification Messages
    Wait Until Page Contains    รายการแจ้งเตือน    10s
    Page Should Contain         การแจ้งเตือน
    Page Should Contain         รายการแจ้งเตือน
    Capture Page Screenshot

    Close Browser
