*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close All Browsers
Test Teardown    Capture Screenshot With Test Name

*** Variables ***
${URL}                 https://csse4569.cpkku.com/
${BROWSER}             chrome
${PASSENGER_EMAIL}     Namping@gmail.com
${PASSENGER_PASS}      55555555Np

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
	Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'การเดินทางของฉัน')]    15s

Open Payment From My Trip
	${pay_button_base}=    Set Variable    //div[contains(@class,'trip-card')][.//a[contains(normalize-space(.),'ชำระเงิน')]]//a[contains(normalize-space(.),'ชำระเงิน')]
	${found_payment_page}=    Set Variable    ${False}

	FOR    ${tab_name}    IN    ยืนยันแล้ว    ทั้งหมด
		Go To    ${URL}myTrip
		Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'การเดินทางของฉัน')]    15s
		Click Element    xpath=//button[contains(@class,'tab-button') and contains(normalize-space(.),'${tab_name}')]
		${tab_loaded}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class,'trip-card')] | //p[contains(normalize-space(.),'ไม่พบรายการเดินทางในหมวดหมู่นี้')]    10s
		IF    not ${tab_loaded}
			CONTINUE
		END

		${pay_count}=    Get Element Count    xpath=${pay_button_base}
		IF    ${pay_count} == 0
			CONTINUE
		END
		${loop_end}=    Evaluate    ${pay_count} + 1

		FOR    ${index}    IN RANGE    1    ${loop_end}
			Go To    ${URL}myTrip
			Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'การเดินทางของฉัน')]    15s
			Click Element    xpath=//button[contains(@class,'tab-button') and contains(normalize-space(.),'${tab_name}')]
			Wait Until Element Is Visible    xpath=//div[contains(@class,'trip-card')] | //p[contains(normalize-space(.),'ไม่พบรายการเดินทางในหมวดหมู่นี้')]    10s
			${button_xpath}=    Set Variable    (${pay_button_base})[${index}]
			${has_button}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${button_xpath}    5s
			IF    not ${has_button}
				CONTINUE
			END

			Click Element    xpath=${button_xpath}
			Wait Until Element Is Visible    xpath=//h1[contains(normalize-space(.),'ชำระเงิน')]    15s
			${has_methods}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'เลือกวิธีชำระเงิน')]    15s
			IF    ${has_methods}
				${found_payment_page}=    Set Variable    ${True}
				Exit For Loop
			END
		END

		IF    ${found_payment_page}
			Exit For Loop
		END
	END

	IF    not ${found_payment_page}
		Fail    ไม่พบหน้าชำระเงินที่ยังสามารถเลือกวิธีชำระเงินได้
	END

Pay By Cash And Verify Waiting Driver Confirm
	Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'เลือกวิธีชำระเงิน')]    15s
	Wait Until Element Is Visible    xpath=//span[contains(normalize-space(.),'ยอดรวม')]    15s
	Click Element    xpath=//button[.//span[contains(normalize-space(.),'เงินสด')]]

	${confirm_cash_xpath}=    Set Variable    //button[contains(normalize-space(.),'ยืนยัน') and (contains(normalize-space(.),'เงินสด') or contains(normalize-space(.),'จ่ายเงิน'))]
	Wait Until Element Is Visible    xpath=${confirm_cash_xpath}    10s
	Click Button    xpath=${confirm_cash_xpath}

	${toast_cash}=    Run Keyword And Return Status    Wait Until Page Contains    แจ้งจ่ายเงินสดแล้ว รอคนขับยืนยัน    20s
	${wait_driver_label}=    Run Keyword And Return Status    Wait Until Page Contains    รอคนขับยืนยันรับเงิน    20s
	IF    not ${toast_cash} and not ${wait_driver_label}
		Fail    ไม่พบผลลัพธ์รอคนขับยืนยันหลังยืนยันการจ่ายเงินสด
	END
	Page Should Contain    รอคนขับยืนยันรับเงิน

*** Test Cases ***
TC12 Passenger Pay Cash Successfully
	Open Browser    ${URL}    ${BROWSER}
	Maximize Browser Window
	Set Selenium Speed    0.2s

	Clear Session And Go To Login
	Login With    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
	Open My Trip Page
	Open Payment From My Trip
	Pay By Cash And Verify Waiting Driver Confirm
