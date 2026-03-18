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

Open My Routes Tab
	Go To    ${URL}myRoute
	Wait Until Element Is Visible    xpath=//h2[contains(.,'คำขอจองเส้นทางของฉัน')]    15s
	Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เส้นทางของฉัน')]

Ensure Route Is In Transit
	[Documentation]    Prefer an in-transit route; if none exists, start one from available/full status.
	${in_transit_card}=    Set Variable    (//div[contains(@class,'trip-card')][.//span[contains(@class,'status-badge') and contains(normalize-space(.),'กำลังเดินทาง')] and .//button[contains(normalize-space(.),'ถึงปลายทางแล้ว')]])[1]
	${has_in_transit}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${in_transit_card}    10s
	IF    ${has_in_transit}
		RETURN
	END

	${startable_card}=    Set Variable    (//div[contains(@class,'trip-card')][.//span[contains(@class,'status-badge') and (contains(normalize-space(.),'เปิดรับผู้โดยสาร') or contains(normalize-space(.),'ผู้โดยสารเต็ม'))] and .//button[contains(normalize-space(.),'เริ่มเดินทาง')]])[1]
	${has_startable}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${startable_card}    20s
	IF    not ${has_startable}
		Fail    ไม่พบเส้นทางที่เป็น กำลังเดินทาง หรือเส้นทางที่สามารถเริ่มเดินทางได้
	END

	Click Element    xpath=${startable_card}
	Click Element    xpath=(${startable_card}//button[contains(normalize-space(.),'เริ่มเดินทาง')])[1]
	Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='เริ่มเดินทาง' or normalize-space()='ยืนยันคำขอ' or normalize-space()='ยืนยัน']    10s
	Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='เริ่มเดินทาง' or normalize-space()='ยืนยันคำขอ' or normalize-space()='ยืนยัน']
	Wait Until Element Is Visible    xpath=${in_transit_card}    25s

Complete In Transit Route
	${in_transit_card}=    Set Variable    (//div[contains(@class,'trip-card')][.//span[contains(@class,'status-badge') and contains(normalize-space(.),'กำลังเดินทาง')] and .//button[contains(normalize-space(.),'ถึงปลายทางแล้ว')]])[1]
	Wait Until Element Is Visible    xpath=${in_transit_card}    25s
	${route_title}=    Get Text    xpath=(${in_transit_card}//h4)[1]

	Click Element    xpath=${in_transit_card}
	Click Element    xpath=(${in_transit_card}//button[contains(normalize-space(.),'ถึงปลายทางแล้ว')])[1]

	# ยืนยันครั้งที่ 2 ใน ConfirmModal
	Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='ยืนยัน' or normalize-space()='ยืนยันคำขอ']    10s
	Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[normalize-space()='ยืนยัน' or normalize-space()='ยืนยันคำขอ']

	${toast_ok}=    Run Keyword And Return Status    Wait Until Page Contains    ยืนยันถึงปลายทางแล้ว    20s
	${toast_success}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    20s
	IF    not ${toast_ok} and not ${toast_success}
		Fail    ไม่พบข้อความสำเร็จหลังยืนยันสิ้นสุดการเดินทาง
	END

	Wait Until Element Is Not Visible    xpath=${in_transit_card}    25s
	${completed_xpath}=    Set Variable    (//div[contains(@class,'trip-card')][.//h4[contains(normalize-space(.),"${route_title}")] and .//span[contains(@class,'status-badge') and contains(normalize-space(.),'สิ้นสุดการเดินทาง')]])[1]
	Wait Until Element Is Visible    xpath=${completed_xpath}    25s
	Page Should Contain    สิ้นสุดการเดินทาง

*** Test Cases ***
TC6 Driver Complete Route Successfully
	Open Browser    ${URL}    ${BROWSER}
	Maximize Browser Window
	Set Selenium Speed    0.2s

	Clear Session And Go To Login
	Login With    ${DRIVER_EMAIL}    ${DRIVER_PASS}
	Open My Routes Tab
	Ensure Route Is In Transit
	Complete In Transit Route
