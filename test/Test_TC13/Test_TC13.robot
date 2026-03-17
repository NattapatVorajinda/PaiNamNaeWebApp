*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close All Browsers
Test Teardown    Capture Screenshot With Test Name

*** Variables ***
${URL}                 https://csse4569.cpkku.com/
${BROWSER}             chrome
${PASSENGER_EMAIL}     Namping@gmail.com
${PASSENGER_PASS}      55555555Np
${SLIP_FILE}           C:/PaiNamNaeWebApp/selenium-screenshot-1.png

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

Open My Trip Page
	Go To    ${URL}myTrip
	Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'การเดินทางของฉัน')]    20s
	Wait Until Element Is Visible    xpath=//div[contains(@class,'trip-card')] | //p[contains(normalize-space(.),'ไม่พบรายการเดินทางในหมวดหมู่นี้')]    20s

Open Payable PromptPay Page
	${pay_button_base}=    Set Variable    //div[contains(@class,'trip-card')][.//a[contains(normalize-space(.),'ชำระเงิน')]]//a[contains(normalize-space(.),'ชำระเงิน')]
	${found_page}=    Set Variable    ${False}

	FOR    ${tab_name}    IN    ยืนยันแล้ว    ทั้งหมด
		Go To    ${URL}myTrip
		Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'การเดินทางของฉัน')]    20s
		Click Element    xpath=//button[contains(@class,'tab-button') and contains(normalize-space(.),'${tab_name}')]
		Sleep    1s
		${has_any_card}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class,'trip-card')]    10s
		IF    not ${has_any_card}
			CONTINUE
		END
		${pay_count}=    Get Element Count    xpath=${pay_button_base}
		IF    ${pay_count} == 0
			CONTINUE
		END
		${loop_end}=    Evaluate    ${pay_count} + 1

		FOR    ${index}    IN RANGE    1    ${loop_end}
			Go To    ${URL}myTrip
			Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'การเดินทางของฉัน')]    20s
			Click Element    xpath=//button[contains(@class,'tab-button') and contains(normalize-space(.),'${tab_name}')]
			Sleep    1s
			${button_xpath}=    Set Variable    (${pay_button_base})[${index}]
			${has_button}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${button_xpath}    5s
			IF    not ${has_button}
				CONTINUE
			END
			Click Element    xpath=${button_xpath}
			Wait Until Element Is Visible    xpath=//h1[contains(normalize-space(.),'ชำระเงิน')]    15s

			${has_methods}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'เลือกวิธีชำระเงิน')]    5s
			IF    not ${has_methods}
				CONTINUE
			END

			Click Element    xpath=//button[.//span[contains(normalize-space(.),'โอนเงิน')]]
			${has_promptpay_section}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'QR พร้อมเพย์คนขับ')]    5s
			IF    not ${has_promptpay_section}
				CONTINUE
			END
			${not_configured}=    Run Keyword And Return Status    Page Should Contain    คนขับยังไม่ได้ตั้งค่าพร้อมเพย์
			IF    ${not_configured}
				CONTINUE
			END
			${has_qr}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//img[@alt='QR พร้อมเพย์']    5s
			${has_number}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//p[contains(normalize-space(.),'เบอร์พร้อมเพย์')]    5s
			IF    ${has_qr} or ${has_number}
				${found_page}=    Set Variable    ${True}
				Exit For Loop
			END
		END
		IF    ${found_page}
			Exit For Loop
		END
	END

	IF    not ${found_page}
		Fail    ไม่พบหน้าชำระเงินที่ยังจ่ายด้วยพร้อมเพย์ได้
	END

Pay By PromptPay And Verify Waiting Driver Confirm
	Wait Until Element Is Visible    xpath=//span[contains(normalize-space(.),'ยอดรวม')]    15s
	Click Element    xpath=//button[.//span[contains(normalize-space(.),'โอนเงิน')]]
	Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'QR พร้อมเพย์คนขับ')]    10s
	${has_qr}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//img[@alt='QR พร้อมเพย์']    5s
	${has_number}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//p[contains(normalize-space(.),'เบอร์พร้อมเพย์')]    5s
	IF    not ${has_qr} and not ${has_number}
		Fail    ไม่พบ QR code หรือเบอร์พร้อมเพย์ของคนขับ
	END

	Choose File    xpath=//input[@type='file']    ${SLIP_FILE}
	Wait Until Element Is Visible    xpath=//button[contains(normalize-space(.),'ยืนยันโอนเงินแล้ว')]    10s
	Click Button    xpath=//button[contains(normalize-space(.),'ยืนยันโอนเงินแล้ว')]

	${toast_transfer}=    Run Keyword And Return Status    Wait Until Page Contains    แจ้งโอนเงินแล้ว รอคนขับยืนยัน    20s
	${wait_driver_label}=    Run Keyword And Return Status    Wait Until Page Contains    รอคนขับยืนยันรับเงิน    20s
	IF    not ${toast_transfer} and not ${wait_driver_label}
		Fail    ไม่พบผลลัพธ์รอคนขับยืนยันหลังยืนยันโอนเงิน
	END
	Page Should Contain    รอคนขับยืนยันรับเงิน

*** Test Cases ***
TC13 Passenger Pay PromptPay Successfully
	Open Browser    ${URL}    ${BROWSER}
	Maximize Browser Window
	Set Selenium Speed    0.2s

	Clear Session And Go To Login
	Login With    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
	Open My Trip Page
	Open Payable PromptPay Page
	Pay By PromptPay And Verify Waiting Driver Confirm
