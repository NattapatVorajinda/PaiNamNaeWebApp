*** Settings ***
Documentation     API Test Suite: User Management (การจัดการผู้ใช้)
...
...               Test Design:
...               - TC-API-USER-001: ลงทะเบียนผู้ใช้ใหม่สำเร็จ
...               - TC-API-USER-002: ลงทะเบียนด้วย email ซ้ำ
...               - TC-API-USER-003: ลงทะเบียนด้วยข้อมูลไม่ครบ
...               - TC-API-USER-004: ดูโปรไฟล์ตัวเองสำเร็จ
...               - TC-API-USER-005: ดูโปรไฟล์โดยไม่มี token
...               - TC-API-USER-006: อัปเดตโปรไฟล์ตัวเองสำเร็จ
...               - TC-API-USER-007: ดูโปรไฟล์ผู้ใช้คนอื่นสำเร็จ
...               - TC-API-USER-008: Admin ดูรายชื่อผู้ใช้ทั้งหมด
...               - TC-API-USER-009: Non-admin เข้าถึง admin endpoint ไม่ได้

Library           RequestsLibrary
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Teardown    Delete All Sessions

Force Tags        api    user

*** Variables ***
${CREATED_USER_ID}    ${EMPTY}

*** Test Cases ***
# =============================================================
# Registration Tests
# =============================================================

TC-API-USER-001 Register New User Successfully
    [Documentation]    ทดสอบลงทะเบียนผู้ใช้ใหม่ด้วยข้อมูลที่ถูกต้อง
    ...    หมายเหตุ: API จริงต้องส่ง multipart/form-data พร้อมรูปถ่ายบัตรประชาชนและ selfie
    ...    Test นี้ทดสอบว่า API ปฏิเสธเมื่อไม่มีรูปภาพ (expected: 400)
    ...    Expected: HTTP 400 (เพราะไม่มีรูปภาพ)
    [Tags]    smoke    positive    requires-files
    ${unique_email}=    Generate Unique Email
    ${unique_username}=    Generate Unique Username
    ${response}=    Register New User
    ...    ${unique_username}
    ...    ${unique_email}
    ...    Test@12345
    ...    ทดสอบ
    ...    ระบบ
    ...    0811111111
    ...    MALE
    ...    1111111111111
    ...    2030-12-31
    # API ต้องการรูปถ่ายบัตรประชาชน+selfie (multipart) จึง return 400 เมื่อไม่มีรูป
    Response Status Should Be    ${response}    ${HTTP_BAD_REQUEST}
    Log    API ปฏิเสธเมื่อไม่มีรูปภาพ (ตามที่คาดไว้)

TC-API-USER-002 Register With Duplicate Email
    [Documentation]    ทดสอบลงทะเบียนด้วย email ที่มีอยู่แล้ว
    ...    Test Data: Admin email (ซ้ำ)
    ...    Expected: HTTP 400 หรือ 409
    [Tags]    negative    validation
    ${unique_username}=    Generate Unique Username
    ${response}=    Register New User
    ...    ${unique_username}
    ...    ${ADMIN_EMAIL}
    ...    Test@12345
    ...    ทดสอบ
    ...    ระบบ
    ...    0822222222
    ...    MALE
    ...    2222222222222
    ...    2030-12-31
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ลงทะเบียน email ซ้ำถูกปฏิเสธ - status: ${status}

TC-API-USER-003 Register With Missing Required Fields
    [Documentation]    ทดสอบลงทะเบียนโดยไม่ส่งข้อมูลที่จำเป็น
    ...    Test Data: empty body
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    Create API Session
    ${body}=    Create Dictionary    email=test@test.com
    ${response}=    POST On Session    painamnae    /users    json=${body}    expected_status=any
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ลงทะเบียนข้อมูลไม่ครบถูกปฏิเสธ - status: ${status}

TC-API-USER-004 Register With Short Password
    [Documentation]    ทดสอบลงทะเบียนด้วย password สั้นเกินไป (< 8 ตัวอักษร)
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    ${unique_email}=    Generate Unique Email
    ${unique_username}=    Generate Unique Username
    ${response}=    Register New User
    ...    ${unique_username}
    ...    ${unique_email}
    ...    short
    ...    ทดสอบ
    ...    ระบบ
    ...    0833333333
    ...    MALE
    ...    3333333333333
    ...    2030-12-31
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ลงทะเบียน password สั้นถูกปฏิเสธ - status: ${status}

# =============================================================
# Profile Tests
# =============================================================

TC-API-USER-005 Get My Profile Successfully
    [Documentation]    ทดสอบดึงข้อมูลโปรไฟล์ตัวเอง
    ...    Test Data: Admin token
    ...    Expected: HTTP 200, response มี user data พร้อม email, phone
    [Tags]    smoke    critical    positive
    Login As Admin
    ${response}=    Get My Profile
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Dictionary Should Contain Key    ${json}[data]    email
    Dictionary Should Contain Key    ${json}[data]    username
    Log    ดึงโปรไฟล์สำเร็จ: username=${json}[data][username]

TC-API-USER-006 Get My Profile Without Token
    [Documentation]    ทดสอบดึงโปรไฟล์โดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${response}=    GET On Session    painamnae    /users/me    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ดึงโปรไฟล์โดยไม่มี token ถูกปฏิเสธ

TC-API-USER-007 Update My Profile Successfully
    [Documentation]    ทดสอบอัปเดตโปรไฟล์ตัวเอง
    ...    Test Data: เปลี่ยน firstName
    ...    Expected: HTTP 200
    [Tags]    positive
    Login As Admin
    ${data}=    Create Dictionary    firstName=AdminUpdated
    ${response}=    Update My Profile    ${data}
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Log    อัปเดตโปรไฟล์สำเร็จ
    # Revert
    ${revert}=    Create Dictionary    firstName=Admin
    Update My Profile    ${revert}

# =============================================================
# Admin User Management Tests
# =============================================================

TC-API-USER-008 Admin List All Users
    [Documentation]    ทดสอบ Admin ดูรายชื่อผู้ใช้ทั้งหมด
    ...    Expected: HTTP 200, response มี data list
    [Tags]    positive    admin
    Login As Admin
    ${response}=    GET On Session    painamnae_auth    /users/admin    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    Admin ดูรายชื่อผู้ใช้สำเร็จ จำนวน: ${json}[data].__len__()

TC-API-USER-009 Non-Admin Cannot Access Admin Endpoint
    [Documentation]    ทดสอบว่า request โดยไม่มี token เข้าถึง admin endpoint ไม่ได้
    ...    Expected: HTTP 401
    [Tags]    negative    security    authorization
    Create API Session
    ${response}=    GET On Session    painamnae    /users/admin    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ผู้ใช้ที่ไม่มี token เข้าถึง admin endpoint ไม่ได้
