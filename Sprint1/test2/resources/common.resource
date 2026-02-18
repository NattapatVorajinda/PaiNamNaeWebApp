*** Settings ***
Documentation     Common Keywords สำหรับทุก Test Suite
Library           RequestsLibrary
Library           Collections
Library           String
Library           DateTime
Resource          ../data/test_data.resource

*** Keywords ***
# =========================================================
# Session Management
# =========================================================
Create API Session
    [Documentation]    สร้าง HTTP session สำหรับเรียก API
    Create Session    painamnae    ${BASE_URL}    verify=${False}

Create Authenticated Session
    [Documentation]    สร้าง session พร้อม JWT token
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}    Content-Type=application/json
    Create Session    painamnae_auth    ${BASE_URL}    headers=${headers}    verify=${False}

# =========================================================
# Authentication Helpers
# =========================================================
Login And Get Token
    [Documentation]    เข้าสู่ระบบแล้วคืน JWT token
    [Arguments]    ${email}    ${password}
    Create API Session
    ${body}=    Create Dictionary    email=${email}    password=${password}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    ${token}=    Set Variable    ${json}[data][token]
    RETURN    ${token}

Login And Get Token By Username
    [Documentation]    เข้าสู่ระบบด้วย username แล้วคืน JWT token
    [Arguments]    ${username}    ${password}
    Create API Session
    ${body}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    ${token}=    Set Variable    ${json}[data][token]
    RETURN    ${token}

Login As Admin
    [Documentation]    เข้าสู่ระบบด้วย Admin แล้วสร้าง Authenticated Session
    ${token}=    Login And Get Token By Username    ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}
    Create Authenticated Session    ${token}
    RETURN    ${token}

Login As Driver
    [Documentation]    เข้าสู่ระบบด้วย Driver แล้วสร้าง Authenticated Session
    ${token}=    Login And Get Token    ${DRIVER_EMAIL}    ${DRIVER_PASSWORD}
    Create Authenticated Session    ${token}
    RETURN    ${token}

Login As Passenger
    [Documentation]    เข้าสู่ระบบด้วย Passenger แล้วสร้าง Authenticated Session
    ${token}=    Login And Get Token    ${PASSENGER_EMAIL}    ${PASSENGER_PASSWORD}
    Create Authenticated Session    ${token}
    RETURN    ${token}

# =========================================================
# Response Validation Helpers
# =========================================================
Response Status Should Be
    [Documentation]    ตรวจสอบ HTTP status code
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Strings    ${response.status_code}    ${expected_status}

Response Should Contain Key
    [Documentation]    ตรวจสอบว่า JSON response มี key ที่ระบุ
    [Arguments]    ${response}    ${key}
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    ${key}

Response Should Have Data List
    [Documentation]    ตรวจสอบว่า response มี data เป็น list
    [Arguments]    ${response}
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    data
    Should Not Be Empty    ${json}[data]

Get Response JSON
    [Documentation]    แปลง response เป็น JSON
    [Arguments]    ${response}
    ${json}=    Set Variable    ${response.json()}
    RETURN    ${json}

# =========================================================
# Data Generation Helpers
# =========================================================
Generate Unique Email
    [Documentation]    สร้าง email ที่ไม่ซ้ำสำหรับการทดสอบ
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${email}=    Set Variable    test_${timestamp}@test.com
    RETURN    ${email}

Generate Unique Username
    [Documentation]    สร้าง username ที่ไม่ซ้ำสำหรับการทดสอบ
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${username}=    Set Variable    testuser_${timestamp}
    RETURN    ${username}

Generate Future Datetime
    [Documentation]    สร้าง datetime ในอนาคต (วันพรุ่งนี้ 09:00)
    ${tomorrow}=    Get Current Date    increment=1 day    result_format=%Y-%m-%dT09:00:00.000Z
    RETURN    ${tomorrow}

# =========================================================
# Cleanup Helpers
# =========================================================
Delete Resource If Exists
    [Documentation]    ลบ resource ถ้ามีอยู่ (ไม่ error ถ้าไม่มี)
    [Arguments]    ${session}    ${url}
    ${response}=    DELETE On Session    ${session}    ${url}    expected_status=any
    Log    Delete ${url}: status=${response.status_code}
