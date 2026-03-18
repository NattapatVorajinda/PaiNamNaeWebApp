*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close All Browsers
Test Teardown    Capture Screenshot With Test Name

*** Variables ***
${URL}                https://csse4569.cpkku.com/
${BROWSER}            chrome
${DRIVER_EMAIL}       sitananyjjk13@gmail.com
${DRIVER_PASS}        Ching13082547
${PASSENGER_EMAIL}    Namping@gmail.com
${PASSENGER_PASS}     55555555Np
${PICKUP_TEXT}        ขอนแก่น
${DROPOFF_TEXT}       กรุงเทพมหานคร

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

Book Driver Route As Passenger
	Go To    ${URL}findTrip
	Wait Until Element Is Visible    xpath=//h2[contains(normalize-space(.),'ค้นหาการเดินทาง')]    20s

	${driver_route_xpath}=    Set Variable    (//div[contains(@class,'route-card')])[1]
	${has_driver_route}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${driver_route_xpath}    25s
	IF    not ${has_driver_route}
		Fail    ไม่พบเส้นทางของคนขับที่สามารถจองได้สำหรับสร้างคำขอรอดำเนินการ
	END

	Click Element    xpath=${driver_route_xpath}
	Wait Until Element Is Visible    xpath=(//button[contains(normalize-space(.),'จองที่นั่ง')])[1]    10s
	Click Button    xpath=(//button[contains(normalize-space(.),'จองที่นั่ง')])[1]

	Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-content')]//h3[contains(normalize-space(.),'ยืนยันการจอง')]    10s
	Select From List By Value    xpath=//div[contains(@class,'modal-content')]//select    1
	Input Text    xpath=(//div[contains(@class,'modal-content')]//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]    ${PICKUP_TEXT}
	Press Keys    xpath=(//div[contains(@class,'modal-content')]//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]    TAB
	Input Text    xpath=(//div[contains(@class,'modal-content')]//input[@placeholder='พิมพ์ชื่อสถานที่...'])[2]    ${DROPOFF_TEXT}
	Press Keys    xpath=(//div[contains(@class,'modal-content')]//input[@placeholder='พิมพ์ชื่อสถานที่...'])[2]    TAB
	Click Button    xpath=//div[contains(@class,'modal-content')]//button[contains(normalize-space(.),'ยืนยันการจอง')]

	${booking_ok}=    Run Keyword And Return Status    Wait Until Page Contains    ส่งคำขอจองสำเร็จ    20s
	${in_mytrip}=    Run Keyword And Return Status    Wait Until Location Contains    /myTrip    20s
	IF    not ${booking_ok} and not ${in_mytrip}
		Fail    ไม่พบผลลัพธ์สำเร็จหลังผู้โดยสารกดยืนยันการจอง
	END

Confirm Pending Booking As Driver
	Go To    ${URL}myRoute
	Wait Until Element Is Visible    xpath=//h2[contains(.,'คำขอจองเส้นทางของฉัน')]    15s

	Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'รอดำเนินการ')]
	${pending_request_xpath}=    Set Variable    (//div[contains(@class,'trip-card')][.//a[contains(@href,'mailto:${PASSENGER_EMAIL}')] and .//span[contains(@class,'status-badge') and contains(normalize-space(.),'รอดำเนินการ')] and .//button[normalize-space()='ยืนยันคำขอ']])[1]
	Wait Until Element Is Visible    xpath=${pending_request_xpath}    25s

	# ยืนยันรอบที่ 1 จากรายการ
	Click Element    xpath=(${pending_request_xpath}//button[normalize-space()='ยืนยันคำขอ'])[1]

	# ยืนยันรอบที่ 2 จาก ConfirmModal
	Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='ยืนยันคำขอ']    10s
	Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='ยืนยันคำขอ']

	${confirm_ok}=    Run Keyword And Return Status    Wait Until Page Contains    ยืนยันคำขอแล้ว    20s
	${toast_title}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    20s
	IF    not ${confirm_ok} and not ${toast_title}
		Fail    ไม่พบผลลัพธ์สำเร็จหลังคนขับยืนยันคำขอ
	END

	Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
	Wait Until Page Contains    ยืนยันแล้ว    15s

*** Test Cases ***
TC4 Driver Confirm Booking Successfully
	Open Browser    ${URL}    ${BROWSER}
	Maximize Browser Window
	Set Selenium Speed    0.2s

	Clear Session And Go To Login
	Login With    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
	Book Driver Route As Passenger

	Clear Session And Go To Login
	Login With    ${DRIVER_EMAIL}    ${DRIVER_PASS}
	Confirm Pending Booking As Driver
