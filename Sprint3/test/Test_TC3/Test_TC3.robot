*** Settings ***
Library    SeleniumLibrary
Test Teardown    Capture Screenshot With Test Name
Suite Teardown   Close All Browsers

*** Variables ***
${URL}           https://csse4569.cpkku.com/
${BROWSER}       chrome
${DRIVER_EMAIL}    sitananyjjk13@gmail.com
${DRIVER_PASS}     Ching13082547
${TRIP_DATE_UI}    10/12/2026
${TRIP_DATE_ISO}   2026-10-12

*** Keywords ***
Capture Screenshot With Test Name
    ${testname}=    Set Variable    ${TEST NAME}
    Capture Page Screenshot    ${testname}.png

Step
    [Arguments]    ${keyword}    @{args}
    Run Keyword    ${keyword}    @{args}
    Capture Page Screenshot

Snap
    [Arguments]    ${name}
    Capture Page Screenshot    ${name}.png

*** Test Cases ***
TC3 Driver Create Route Successfully
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.2s

    # --- Go to login page and Login as Driver ---
    Wait Until Element Is Visible    xpath=//a[@href='/login' or contains(.,'เข้าสู่ระบบ')]    10s
    Click Element    xpath=//a[@href='/login' or contains(.,'เข้าสู่ระบบ')]
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${DRIVER_EMAIL}
    Input Text    id=password    ${DRIVER_PASS}
    Click Button    xpath=//form[@id='loginForm']//button[@type='submit']
    Wait Until Page Contains Element    xpath=//a[@href='/createTrip' and contains(.,'สร้างเส้นทาง')]    10s

    # --- Go to create route page ---
    Click Element    xpath=//a[@href='/createTrip' and contains(.,'สร้างเส้นทาง')]
    Wait Until Element Is Visible    id=startPoint    10s

    # --- Fill route basic info ---
    Input Text    id=startPoint    ขอนแก่น
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Press Keys    id=startPoint    TAB
    Input Text    id=endPoint    โคราช
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Press Keys    id=endPoint    TAB

    # เพิ่มจุดแวะหลายจุด
    Click Element    xpath=//form[@id='postRouteForm']//button[@type='button' and contains(.,'เพิ่มจุดแวะ')]
    Input Text    xpath=//form[@id='postRouteForm']//input[contains(@placeholder,'(#1)')]    ชัยภูมิ
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Press Keys    xpath=//form[@id='postRouteForm']//input[contains(@placeholder,'(#1)')]    TAB
    Click Element    xpath=//form[@id='postRouteForm']//button[@type='button' and contains(.,'เพิ่มจุดแวะ')]
    Input Text    xpath=//form[@id='postRouteForm']//input[contains(@placeholder,'(#2)')]    นครราชสีมา
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Press Keys    xpath=//form[@id='postRouteForm']//input[contains(@placeholder,'(#2)')]    TAB

    # รายละเอียดการเดินทาง
    ${date_status}    ${date_msg}=    Run Keyword And Ignore Error    Input Text    id=travelDate    ${TRIP_DATE_UI}
    Run Keyword If    '${date_status}'=='FAIL'    Input Text    id=travelDate    ${TRIP_DATE_ISO}
    Input Text    id=travelTime    17:00

    Input Text    id=seatCount    4
    Input Text    id=pricePerSeat    250

    # --- Add vehicle ---
    Wait Until Element Is Visible    xpath=//button[@type='button' and contains(.,'เพิ่ม / จัดการข้อมูล')]    8s
    Click Element    xpath=//button[@type='button' and contains(.,'เพิ่ม / จัดการข้อมูล')]
    Wait Until Element Is Visible    xpath=//button[contains(.,'เพิ่มรถยนต์คันใหม่')]    8s
    Click Element    xpath=//button[contains(.,'เพิ่มรถยนต์คันใหม่')]

    Wait Until Element Is Visible    xpath=//input[contains(@placeholder,'Toyota Camry')]    8s
    Input Text    xpath=//input[contains(@placeholder,'Toyota Camry')]    Toyota Camry
    Input Text    xpath=//input[contains(@placeholder,'กก 1234 ขอนแก่น')]    กก 1234 ขอนแก่น
    Select From List By Label    xpath=//select[contains(@class,'form-input')]    Sedan
    Input Text    xpath=//input[contains(@placeholder,'เช่น สีดำ')]    สีดำ
    Input Text    xpath=//input[@type='number' and contains(@placeholder,'เช่น 4')]    3

    # สิ่งอำนวยความสะดวก (คั่นด้วยจุลภาค)
    Input Text    xpath=//input[contains(@placeholder,'Air Conditioner')]    Air, Music

    # อัพโหลดรูปภาพ 3 รูป (ใช้ไฟล์ตัวอย่างใน repo)
    Wait Until Page Contains Element    xpath=(//div[contains(@class,'modal-overlay')]//input[@type='file'])[1]    8s
    Choose File    xpath=(//div[contains(@class,'modal-overlay')]//input[@type='file'])[1]    ${CURDIR}/pic/test.png
    Choose File    xpath=(//div[contains(@class,'modal-overlay')]//input[@type='file'])[2]    ${CURDIR}/pic/test.png
    Choose File    xpath=(//div[contains(@class,'modal-overlay')]//input[@type='file'])[3]    ${CURDIR}/pic/test.png

    # ติ๊กเป็นรถยนต์คันหลัก
    Select Checkbox    id=isDefault

    # บันทึกข้อมูลรถยนต์และยืนยัน
    Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[@type='submit' and contains(.,'บันทึก')]
    ${has_confirm}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]//button[contains(.,'ยืนยัน')]    5s
    IF    ${has_confirm}
        Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[contains(.,'ยืนยัน')]
    ELSE
        ${has_back}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]//button[.//*[name()='path' and contains(@d,'M15 19l-7-7 7-7')]]    2s
        IF    ${has_back}
            Click Element    xpath=//div[contains(@class,'modal-overlay')]//button[.//*[name()='path' and contains(@d,'M15 19l-7-7 7-7')]]
        END
        Run Keyword And Ignore Error    Click Button    xpath=//div[contains(@class,'modal-overlay')]//button[contains(.,'ปิด')]
    END
    Run Keyword And Ignore Error    Click Element At Coordinates    xpath=//div[contains(@class,'modal-overlay')]    5    5
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//div[contains(@class,'modal-overlay')]    8s
    Sleep    1s

    # กลับเข้าหน้าสร้างเส้นทางใหม่เพื่อหลีกเลี่ยง state ค้างจาก modal
    Go To    ${URL}createTrip
    Wait Until Element Is Visible    id=startPoint    12s
    Wait Until Element Is Visible    id=travelDate    12s

    ${has_vehicle_select}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=vehicle    5s
    Run Keyword If    ${has_vehicle_select}    Select From List By Index    id=vehicle    1

    # กรอกข้อมูลเส้นทางอีกครั้งบนหน้า clean state
    Clear Element Text    id=startPoint
    Input Text    id=startPoint    ขอนแก่น
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Press Keys    id=startPoint    TAB

    Clear Element Text    id=endPoint
    Input Text    id=endPoint    โคราช
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Press Keys    id=endPoint    TAB

    Click Element    xpath=//form[@id='postRouteForm']//button[@type='button' and contains(.,'เพิ่มจุดแวะ')]
    Input Text    xpath=//form[@id='postRouteForm']//input[contains(@placeholder,'(#1)')]    ชัยภูมิ
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]

    Click Element    xpath=//form[@id='postRouteForm']//button[@type='button' and contains(.,'เพิ่มจุดแวะ')]
    Input Text    xpath=//form[@id='postRouteForm']//input[contains(@placeholder,'(#2)')]    นครราชสีมา
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    3s
    Run Keyword And Ignore Error    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]

    ${date_status_2}    ${date_msg_2}=    Run Keyword And Ignore Error    Input Text    id=travelDate    ${TRIP_DATE_UI}
    Run Keyword If    '${date_status_2}'=='FAIL'    Input Text    id=travelDate    ${TRIP_DATE_ISO}
    Input Text    id=travelTime    17:00
    Input Text    id=seatCount    4
    Input Text    id=pricePerSeat    250
    Run Keyword And Ignore Error    Input Text    id=terms    ห้ามสูบบุหรี่, ห้ามนำสัตว์เลี้ยงขึ้นมา

    # --- สร้างการเดินทาง ---
    Wait Until Element Is Visible    xpath=//form[@id='postRouteForm']//button[@type='submit']    12s
    ${submit_btn}=    Get WebElement    xpath=//form[@id='postRouteForm']//button[@type='submit']
    Execute JavaScript    arguments[0].scrollIntoView({block: 'center'});    ARGUMENTS    ${submit_btn}
    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${submit_btn}

    # ตรวจสอบผลลัพธ์
    ${success_toast}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    20s
    ${redirected}=       Run Keyword And Return Status    Wait Until Location Contains    /findTrip    20s
    Capture Page Screenshot
    IF    not ${success_toast} and not ${redirected}
        ${current_url}=    Get Location
        Fail    ไม่พบข้อความสำเร็จและไม่ redirect ไป /findTrip | URL ปัจจุบัน: ${current_url}
    END
