*** Settings ***
Documentation     API Test Suite: Authentication (การยืนยันตัวตน)
...
...               Test Design:
...               - TC-API-AUTH-001: Login ด้วย email สำเร็จ
...               - TC-API-AUTH-002: Login ด้วย username สำเร็จ
...               - TC-API-AUTH-003: Login ด้วย password ผิด
...               - TC-API-AUTH-004: Login โดยไม่ส่ง email/username
...               - TC-API-AUTH-005: Login ด้วย email ที่ไม่มีในระบบ
...               - TC-API-AUTH-006: เปลี่ยนรหัสผ่านสำเร็จ
...               - TC-API-AUTH-007: เปลี่ยนรหัสผ่านด้วย current password ผิด
...               - TC-API-AUTH-008: เปลี่ยนรหัสผ่านโดยไม่มี token

Library           RequestsLibrary
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Setup       Create API Session
Suite Teardown    Delete All Sessions

Force Tags        api    auth

*** Test Cases ***
# =============================================================
# Positive Tests
# =============================================================

TC-API-AUTH-001 Login With Email Successfully
    [Documentation]    ทดสอบการ Login ด้วย email ที่ถูกต้อง
    ...    Test Data: Admin email + password
    ...    Expected: HTTP 200, response มี data.token
    [Tags]    smoke    critical    positive
    ${response}=    Login User    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Dictionary Should Contain Key    ${json}[data]    token
    Should Not Be Empty    ${json}[data][token]
    Log    Login สำเร็จ ได้รับ token

TC-API-AUTH-002 Login With Username Successfully
    [Documentation]    ทดสอบการ Login ด้วย username ที่ถูกต้อง
    ...    Test Data: Admin username + password
    ...    Expected: HTTP 200, response มี data.token
    [Tags]    smoke    positive
    Create API Session
    ${body}=    Create Dictionary    username=${ADMIN_USERNAME}    password=${ADMIN_PASSWORD}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Dictionary Should Contain Key    ${json}[data]    token
    Log    Login ด้วย username สำเร็จ

# =============================================================
# Negative Tests
# =============================================================

TC-API-AUTH-003 Login With Wrong Password
    [Documentation]    ทดสอบการ Login ด้วย password ที่ผิด
    ...    Test Data: Admin email + wrong password
    ...    Expected: HTTP 400 หรือ 401
    [Tags]    negative    security
    ${response}=    Login User    ${ADMIN_EMAIL}    wrongpassword123
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    Login ด้วย password ผิดถูกปฏิเสธ - status: ${status}

TC-API-AUTH-004 Login Without Email Or Username
    [Documentation]    ทดสอบการ Login โดยไม่ส่ง email หรือ username
    ...    Test Data: password only
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    Create API Session
    ${body}=    Create Dictionary    password=${ADMIN_PASSWORD}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}    expected_status=any
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ถูกปฏิเสธเมื่อไม่ส่ง email/username - status: ${status}

TC-API-AUTH-005 Login With Non-Existent Email
    [Documentation]    ทดสอบการ Login ด้วย email ที่ไม่มีในระบบ
    ...    Test Data: non-existent email
    ...    Expected: HTTP 400 หรือ 401 หรือ 404
    [Tags]    negative
    ${response}=    Login User    nonexistent@notreal.com    somepassword123
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    Login ด้วย email ที่ไม่มีถูกปฏิเสธ - status: ${status}

TC-API-AUTH-006 Login With Empty Password
    [Documentation]    ทดสอบการ Login ด้วย password ว่าง
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    Create API Session
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${EMPTY}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}    expected_status=any
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ถูกปฏิเสธเมื่อ password ว่าง - status: ${status}

# =============================================================
# Change Password Tests
# =============================================================

TC-API-AUTH-007 Change Password Without Token
    [Documentation]    ทดสอบเปลี่ยนรหัสผ่านโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${body}=    Create Dictionary
    ...    currentPassword=oldpass
    ...    newPassword=newpass123
    ...    confirmNewPassword=newpass123
    ${response}=    PUT On Session    painamnae    /auth/change-password    json=${body}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    เปลี่ยนรหัสผ่านโดยไม่มี token ถูกปฏิเสธ

TC-API-AUTH-008 Change Password With Mismatched Confirmation
    [Documentation]    ทดสอบเปลี่ยนรหัสผ่านเมื่อ confirm ไม่ตรง
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    ${token}=    Login And Get Token By Username    ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}
    Create Authenticated Session    ${token}
    ${body}=    Create Dictionary
    ...    currentPassword=${ADMIN_PASSWORD}
    ...    newPassword=NewPassword123
    ...    confirmNewPassword=DifferentPassword123
    ${response}=    PUT On Session    painamnae_auth    /auth/change-password    json=${body}    expected_status=any
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ถูกปฏิเสธเมื่อ confirm password ไม่ตรง - status: ${status}
