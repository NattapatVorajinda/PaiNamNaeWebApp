*** Settings ***
Library    SeleniumLibrary
Test Teardown    Capture Screenshot With Test Name
Suite Teardown   Close All Browsers

*** Variables ***
${URL}        https://csse4569.cpkku.com/
${BROWSER}    Chrome
${VALID_EMAIL}      Namping@gmail.com
${VALID_PASSWORD}   55555555Np
${WRONG_PASSWORD}   12345678

*** Keywords ***
Open Login Page
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    xpath=//a[@href="/login"]    10s
    Click Element    xpath=//a[@href="/login"]
    Wait Until Page Contains Element    id=identifier    10s

Capture Screenshot With Test Name
    ${testname}=    Set Variable    ${TEST NAME}
    Capture Page Screenshot    ${testname}.png

*** Test Cases ***
TC01 Login Success
    Open Login Page
    Input Text       id=identifier    ${VALID_EMAIL}
    Input Password   id=password      ${VALID_PASSWORD}
    Click Button     xpath=//button[normalize-space()='เข้าสู่ระบบ']
    Wait Until Location Contains    csse4569.cpkku.com    5s

TC02 Login Wrong Password
    Open Login Page
    Input Text       id=identifier    ${VALID_EMAIL}
    Input Password   id=password      ${WRONG_PASSWORD}
    Click Button     xpath=//button[normalize-space()='เข้าสู่ระบบ']
    Wait Until Location Contains    login    5s

TC03 Login Empty Field
    Open Login Page
    Click Button     xpath=//button[normalize-space()='เข้าสู่ระบบ']
    Wait Until Location Contains    login    5s

TC04 Login Invalid Format
    Open Login Page
    Input Text       id=identifier    invalid-email
    Input Password   id=password      ${VALID_PASSWORD}
    Click Button     xpath=//button[normalize-space()='เข้าสู่ระบบ']
    Wait Until Page Contains    เข้าสู่ระบบไม่สำเร็จ    5s

