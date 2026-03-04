*** Settings ***
Library    SeleniumLibrary
Test Teardown    Capture Screenshot With Test Name
Suite Teardown   Close All Browsers

*** Variables ***
${URL}           https://csse4569.cpkku.com/
${BROWSER}       chrome
${DRIVER_EMAIL}    driver@test.com
${DRIVER_PASS}     123456

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
    Wait Until Element Is Visible    xpath=//input[@type='email' or contains(@placeholder,'อีเมล') or @id='identifier' or @id='email']    10s
    # fill login fields (support common attribute variations)
    Run Keyword And Ignore Error    Input Text    id=email    ${DRIVER_EMAIL}
    Run Keyword And Ignore Error    Input Text    id=identifier    ${DRIVER_EMAIL}
    Run Keyword And Ignore Error    Input Text    xpath=//input[@type='email' or contains(@placeholder,'อีเมล')]    ${DRIVER_EMAIL}
    Run Keyword And Ignore Error    Input Text    id=password    ${DRIVER_PASS}
    Run Keyword And Ignore Error    Input Text    xpath=//input[@type='password' or contains(@placeholder,'รหัสผ่าน')]    ${DRIVER_PASS}
    Run Keyword And Ignore Error    Click Button    id=loginBtn
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ') or contains(.,'ลงชื่อเข้าใช้')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'สร้างเส้นทาง') or contains(.,'สร้างการเดินทาง') or @id='createRouteMenu']    10s

    # --- Go to create route page ---
    Click Element    xpath=//a[contains(.,'สร้างเส้นทาง') or contains(.,'สร้างการเดินทาง') or @id='createRouteMenu']
    Wait Until Page Contains    จุดเริ่มต้น    10s

    # --- Fill route basic info ---
    Input Text    xpath=//input[contains(@placeholder,'เช่น กรุงเทพ') or @id='origin']    ขอนแก่น
    Input Text    xpath=//input[contains(@placeholder,'เช่น เชียงใหม่') or @id='destination']    โคราช

    # เพิ่มจุดแวะ (ถ้ามีปุ่มให้เพิ่ม)
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'เพิ่มจุดแวะ') or contains(.,'Add stop')]
    Run Keyword And Ignore Error    Input Text    xpath=//input[contains(@placeholder,'จุดแวะ') or contains(@name,'stop')]    ชัยภูมิ

    # รายละเอียดการเดินทาง
    # ใช้วันที่ 10/12/2026 (mm/dd/yyyy) — ถ้าฟิลด์เป็น date ให้ใช้ 2026-10-12
    ${DATE_INPUT_FORMAT}=    Set Variable    2026-10-12
    Run Keyword And Ignore Error    Input Text    xpath=//input[@type='date' or contains(@placeholder,'วัน')]    ${DATE_INPUT_FORMAT}
    Run Keyword And Ignore Error    Input Text    xpath=//input[contains(@placeholder,'เวลา') or @type='time']    17:00

    Input Text    xpath=//input[contains(@placeholder,'จำนวนที่นั่ง') or @id='seat' or @name='seat']    4
    Input Text    xpath=//input[contains(@placeholder,'ราคาต่อที่นั่ง') or @id='price' or @name='price']    250

    # --- Add vehicle ---
    Wait Until Element Is Visible    xpath=//button[contains(.,'เพิ่มรถ') or contains(.,'เพิ่มข้อมูลรถยนต์') or @id='addVehicle']    5s
    Click Element    xpath=//button[contains(.,'เพิ่มรถ') or contains(.,'เพิ่มข้อมูลรถยนต์') or @id='addVehicle']

    Wait Until Page Contains Element    xpath=//input[contains(@placeholder,'ยี่ห้อ') or @id='brand']    5s
    Input Text    xpath=//input[contains(@placeholder,'ยี่ห้อ') or @id='brand' or @name='brand']    Toyota Camry
    Input Text    xpath=//input[contains(@placeholder,'หมายเลขทะเบียน') or @id='license' or @name='license']    กก 1234 ขอนแก่น
    Input Text    xpath=//input[contains(@placeholder,'ชนิดของรถ') or @id='type' or @name='type']    Sedan
    Input Text    xpath=//input[contains(@placeholder,'สี') or @id='color' or @name='color']    สีดำ
    Input Text    xpath=//input[contains(@placeholder,'จำนวนที่นั่ง') and (contains(.,'ไม่รวมคนขับ') or @id='vehicleSeats') or @name='vehicleSeats']    3

    # สิ่งอำนวยความสะดวก (คั่นด้วยจุลภาค)
    Input Text    xpath=//input[contains(@placeholder,'สิ่งอำนวยความสะดวก') or @id='amenities' or @name='amenities']    Air, Music

    # อัพโหลดรูปภาพ 3 รูป (ใช้ไฟล์ตัวอย่างใน repo)
    Wait Until Page Contains Element    xpath=(//input[@type='file'])[1]    5s
    Choose File    xpath=(//input[@type='file'])[1]    ${CURDIR}\pic\test.png
    Choose File    xpath=(//input[@type='file'])[2]    ${CURDIR}\pic\test.png
    Choose File    xpath=(//input[@type='file'])[3]    ${CURDIR}\pic\test.png

    # ติ๊กเป็นรถยนต์คันหลัก ถ้ามี
    Run Keyword And Ignore Error    Select Checkbox    xpath=//input[@type='checkbox' and (contains(@name,'primary') or contains(@id,'isPrimary'))]
    Run Keyword And Ignore Error    Select Checkbox    xpath=(//input[@type='checkbox'])[1]

    # บันทึกข้อมูลรถยนต์
    Click Button    xpath=//button[contains(.,'บันทึก') or contains(.,'บันทึกข้อมูลรถ') or @id='saveVehicle']
    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(.,'ยืนยัน') or contains(.,'ตกลง')]
    Sleep    1s

    # --- สร้างการเดินทาง ---
    Wait Until Element Is Visible    xpath=//button[contains(.,'สร้างการเดินทาง') or contains(.,'สร้างเส้นทาง') or @id='submitRoute']    5s
    Click Button    xpath=//button[contains(.,'สร้างการเดินทาง') or contains(.,'สร้างเส้นทาง') or @id='submitRoute']

    # ตรวจสอบผลลัพธ์
    Wait Until Page Contains    สร้างเส้นทางสำเร็จ    15s
    Capture Page Screenshot

    [Teardown]    Close All Browsers
