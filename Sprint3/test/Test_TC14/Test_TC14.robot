*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close All Browsers
Test Teardown    Capture Screenshot With Test Name

*** Variables ***
${URL}                 https://csse4569.cpkku.com/
${BROWSER}             chrome
${DRIVER_EMAIL}        sitananyjjk13@gmail.com
${DRIVER_PASS}         Ching13082547
${PROMPTPAY_NUMBER}    0812345678
${QR_FILE}             C:/PaiNamNaeWebApp/Sprint2/test/pic/test.png

*** Keywords ***
Capture Screenshot With Test Name
	${testname}=    Set Variable    ${TEST NAME}
	Capture Page Screenshot    ${testname}.png

Clear Session And Go To Login
	Go To    ${URL}
	Delete All Cookies
	Execute JavaScript    window.localStorage.clear(); window.sessionStorage.clear();
	Go To    ${URL}login
	Wait Until Element Is Visible    id=identifier    15s

Login With
	[Arguments]    ${email}    ${password}
	Input Text    id=identifier    ${email}
	Input Text    id=password    ${password}
	Click Button    xpath=//form[@id='loginForm']//button[@type='submit']
	Wait Until Keyword Succeeds    8x    2s    Assert Current URL Is Not Login

Assert Current URL Is Not Login
	${current_url}=    Get Location
	Should Not Contain    ${current_url}    /login

Open Account Page
	${has_account_menu}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=(//a[contains(normalize-space(.),'บัญชีของฉัน')])[1]    8s
	IF    ${has_account_menu}
		Click Element    xpath=(//a[contains(normalize-space(.),'บัญชีของฉัน')])[1]
	ELSE
		Go To    ${URL}profile
	END
	Wait Until Element Is Visible    xpath=//h1[contains(normalize-space(.),'โปรไฟล์ของฉัน') or contains(normalize-space(.),'โปรไฟล์และการตั้งค่า')]    15s

Open PromptPay Settings Page
	${has_promptpay_link}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//a[contains(@href,'/profile/promptpay') and contains(normalize-space(.),'ตั้งค่าพร้อมเพย์')]    8s
	IF    ${has_promptpay_link}
		Click Element    xpath=//a[contains(@href,'/profile/promptpay') and contains(normalize-space(.),'ตั้งค่าพร้อมเพย์')]
	ELSE
		Go To    ${URL}profile/promptpay
	END
	Wait Until Element Is Visible    xpath=//h1[contains(normalize-space(.),'ตั้งค่าพร้อมเพย์')]    15s

Set PromptPay And Save
	Wait Until Element Is Visible    xpath=//label[contains(normalize-space(.),'เบอร์พร้อมเพย์')]    10s
	Input Text    xpath=//input[@type='tel']    ${PROMPTPAY_NUMBER}

	Wait Until Page Contains Element    xpath=//input[@type='file']    10s
	Choose File    xpath=//input[@type='file']    ${QR_FILE}

	Wait Until Element Is Visible    xpath=//button[contains(normalize-space(.),'บันทึก')]    10s
	Click Button    xpath=//button[contains(normalize-space(.),'บันทึก')]

	Wait Until Page Contains    บันทึกข้อมูลพร้อมเพย์แล้ว    15s

*** Test Cases ***
TC14 Driver Set PromptPay Successfully
	Open Browser    ${URL}    ${BROWSER}
	Maximize Browser Window
	Set Selenium Speed    0.2s

	Clear Session And Go To Login
	Login With    ${DRIVER_EMAIL}    ${DRIVER_PASS}
	Open Account Page
	Open PromptPay Settings Page
	Set PromptPay And Save
