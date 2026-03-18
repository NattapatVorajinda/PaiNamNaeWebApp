*** Settings ***
Library    SeleniumLibrary
Suite Teardown   Close All Browsers

*** Variables ***
${URL}        https://csse4569.cpkku.com/
${BROWSER}    Chrome
${VALID_EMAIL}      Namping@gmail.com
${VALID_PASSWORD}   55555555Np

* Test Cases *
TC-001 Passenger write review later
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    
    # เข้าสู่ระบบ
    Wait Until Page Contains    เข้าสู่ระบบ    10s
    Click Element    xpath=//a[contains(.,'เข้าสู่ระบบ')]

    # กรอก Login
    Wait Until Element Is Visible    xpath=//input[contains(@placeholder,'อีเมล')]    15s
    Input Text    xpath=//input[contains(@placeholder,'อีเมล')]    ${VALID_EMAIL}
    Input Text    xpath=//input[contains(@placeholder,'รหัสผ่าน')]    ${VALID_PASSWORD}
    Click Element    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    # * จุดสำคัญ: รอจนกว่าจะเห็นไอคอนโปรไฟล์ หรือ ข้อความ 'Sindy' เพื่อยืนยันว่า Login ติดแล้วจริงๆ *
    Wait Until Page Contains Element    xpath=//span[contains(.,'Sindy')]    15s


# ไปที่เมนู "การเดินทางของฉัน"
    Wait Until Element Is Visible    xpath=//a[@href='/myTrip']    15s
    Click Element    xpath=//a[@href='/myTrip']

    Wait Until Location Contains    myTrip    10s
    Capture Page Screenshot    my_trip_page.png

    # กดแท็บ "ยืนยันแล้ว"
    Wait Until Element Is Visible    xpath=//button[contains(.,'ยืนยันแล้ว')]    10s
    Click Element    xpath=//button[contains(.,'ยืนยันแล้ว')]

    Wait Until Page Contains    ยืนยันแล้ว    10s
    Sleep    5s
    Capture Page Screenshot    confirmed_trip_list.png

    # กดปุ่ม "เขียนรีวิว"
    Wait Until Element Is Visible    xpath=//button[contains(.,'เขียนรีวิว')]    10s
    Click Element    xpath=//button[contains(.,'เขียนรีวิว')]

    Wait Until Page Contains    ให้คะแนนการเดินทาง    20s
    Sleep    5s
    Capture Page Screenshot    review_page.png

    # ให้คะแนนดาว (เลือกดาวที่ 5)
    Wait Until Element Is Visible    xpath=//button[contains(@class,'star-btn')]    10s
    Click Element    xpath=(//button[contains(@class,'star-btn')])[5]

    # กรอกความคิดเห็น
    Input Text
    ...    xpath=//textarea[@placeholder='เล่าประสบการณ์ของคุณ...']
    ...    สกปรก
    Sleep    5s
    Capture Page Screenshot    review.png


    # ส่งรีวิว
    #Click Button    xpath=//button[contains(.,'ส่งรีวิว')]

    #Wait Until Location Contains    myTrip    10s
    #Capture Page Screenshot    review_success.png