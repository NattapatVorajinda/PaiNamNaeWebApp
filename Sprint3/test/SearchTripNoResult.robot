*** Settings ***
Library    SeleniumLibrary
Test Teardown    Capture Screenshot With Test Name
Suite Teardown   Close All Browsers

*** Variables ***
${URL}        https://csse4569.cpkku.com/
${BROWSER}    Chrome

*** Keywords ***
Open Find Trip Page
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    xpath=//a[@href="/findTrip"]    10s
    Click Element                    xpath=//a[@href="/findTrip"]
    Wait Until Location Contains     findTrip    10s
    Wait Until Page Contains Element    xpath=//form    10s

Capture Screenshot With Test Name
    # รอให้หน้า render เสร็จจริงก่อนแคป
    Wait Until Page Contains Element    xpath=//body    5s
    Sleep    0.5s
    ${testname}=    Set Variable    ${TEST NAME}
    Capture Page Screenshot    ${testname}.png

*** Test Cases ***
TC01 Search Trip No Result
    Open Find Trip Page

    Input Text    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    ทดสอบต้นทาง
    Press Keys    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    TAB

    Input Text    xpath=//input[@placeholder='เช่น เชียงใหม่']    ทดสอบปลายทาง
    Press Keys    xpath=//input[@placeholder='เช่น เชียงใหม่']    TAB

    Input Text    xpath=//input[@type='date']    2026-12-31
    Select From List By Value    xpath=//select    1

    Click Button    xpath=//button[normalize-space()='ค้นหา']

    Wait Until Location Contains    findTrip    5s
    Wait Until Page Contains Element    xpath=//form    5s
    Page Should Not Contain Element    xpath=//div[contains(@class,'trip-card')]


