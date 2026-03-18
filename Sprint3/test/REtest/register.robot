*** Settings ***
Library    SeleniumLibrary
Suite Teardown   Close All Browsers

*** Keywords ***
Step
    [Arguments]    ${keyword}    @{args}
    Run Keyword    ${keyword}    @{args}
    Capture Page Screenshot
Snap
    [Arguments]    ${name}
    Capture Page Screenshot    ${name}.png

*** Variables ***
${URL}          https://csse4569.cpkku.com/
${BROWSER}      Chrome

${USERNAME}     testuser01
${EMAIL}        test01@gmail.com
${PASSWORD}     55555555Np
${FIRSTNAME}    Test
${LASTNAME}     User
${PHONE}        0891234567
${IDNUMBER}     1234567890123
${EXPIRY}       31/12/2030

*** Test Cases ***
TC01 Register Success
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # เปิดหน้า Register
    Wait Until Element Is Visible    xpath=//a[@href="/register"]    5s
    Snap    Home_Page
    Click Element    xpath=//a[@href="/register"]

    # ===== Step 1 : Account Info =====
    Input Text       id=username          ${USERNAME}
    Input Text       id=email             ${EMAIL}
    Input Password   id=password          ${PASSWORD}
    Input Password   id=confirmPassword   ${PASSWORD}
    Step    Click Button     xpath=//button[normalize-space()='ถัดไป']

    # ===== Step 2 : Personal Info =====
    Input Text       id=firstName         ${FIRSTNAME}
    Input Text       id=lastName          ${LASTNAME}
    Input Text       id=phoneNumber       ${PHONE}
    Click Element    xpath=//input[@name='gender' and @value='female']
    Step    Click Button     xpath=//button[normalize-space()='ถัดไป']

    # ===== Step 3 : Identity =====
    Input Text       id=idNumber          ${IDNUMBER}
    Input Text       id=expiryDate        ${EXPIRY}

    Wait Until Page Contains Element    xpath=(//input[@type='file'])[1]    5s
    Choose File    xpath=(//input[@type='file'])[1]    ${CURDIR}\\pic\\test.png

    Wait Until Page Contains Element    xpath=(//input[@type='file'])[2]    10s
    Choose File    xpath=(//input[@type='file'])[2]    ${CURDIR}\\pic\\test.png


    Select Checkbox  xpath=//input[@type='checkbox']
    Step    Click Button     xpath=//button[normalize-space()='สมัครสมาชิก']

    Wait Until Location Contains    csse4569.cpkku.com    5s








