*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close All Browsers
Test Teardown    Capture Screenshot With Test Name

*** Variables ***
${URL}                https://csse4569.cpkku.com/
${BROWSER}            chrome
${DRIVER_EMAIL}       sitananyjjk13@gmail.com
${DRIVER_PASS}        Ching13082547

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

Start Available Route As Driver
	Go To    ${URL}myRoute
	Wait Until Element Is Visible    xpath=//h2[contains(.,'คำขอจองเส้นทางของฉัน')]    15s

	Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เส้นทางของฉัน')]

	${open_route_xpath}=    Set Variable    (//div[contains(@class,'trip-card')][.//span[contains(@class,'status-badge') and contains(normalize-space(.),'เปิดรับผู้โดยสาร')] and .//button[contains(normalize-space(.),'เริ่มเดินทาง')]])[1]
	${has_open_route}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${open_route_xpath}    25s
	IF    not ${has_open_route}
		Fail    ไม่พบเส้นทางสถานะเปิดรับผู้โดยสารที่สามารถกดเริ่มเดินทางได้
	END

	${route_title}=    Get Text    xpath=(${open_route_xpath}//h4)[1]

	# คลิกพื้นที่ว่างของ route card ก่อนกดเริ่มเดินทาง
	Click Element    xpath=${open_route_xpath}
	Click Element    xpath=(${open_route_xpath}//button[contains(normalize-space(.),'เริ่มเดินทาง')])[1]

	# ยืนยันครั้งที่ 2 ใน ConfirmModal
	Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='เริ่มเดินทาง' or normalize-space()='ยืนยันคำขอ' or normalize-space()='ยืนยัน']    10s
	Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='เริ่มเดินทาง' or normalize-space()='ยืนยันคำขอ' or normalize-space()='ยืนยัน']

	${toast_ok}=    Run Keyword And Return Status    Wait Until Page Contains    เริ่มเดินทางแล้ว    20s
	${toast_success}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    20s
	IF    not ${toast_ok} and not ${toast_success}
		Fail    ไม่พบข้อความสำเร็จหลังยืนยันเริ่มเดินทาง
	END

	Wait Until Element Is Not Visible    xpath=${open_route_xpath}    25s
	${in_transit_xpath}=    Set Variable    (//div[contains(@class,'trip-card')][.//h4[contains(normalize-space(.),"${route_title}")] and .//span[contains(@class,'status-badge') and contains(normalize-space(.),'กำลังเดินทาง')]])[1]
	Wait Until Element Is Visible    xpath=${in_transit_xpath}    25s
	Page Should Contain    กำลังเดินทาง

*** Test Cases ***
TC5 Driver Start Route Successfully
	Open Browser    ${URL}    ${BROWSER}
	Maximize Browser Window
	Set Selenium Speed    0.2s

	Clear Session And Go To Login
	Login With    ${DRIVER_EMAIL}    ${DRIVER_PASS}
	Start Available Route As Driver
