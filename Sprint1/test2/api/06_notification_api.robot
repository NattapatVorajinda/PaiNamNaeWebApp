*** Settings ***
Documentation     API Test Suite: Notification Management (การจัดการแจ้งเตือน)
...
...               Test Design:
...               - TC-API-NOTI-001: ดูรายการแจ้งเตือนสำเร็จ
...               - TC-API-NOTI-002: ดูจำนวนแจ้งเตือนที่ยังไม่อ่าน
...               - TC-API-NOTI-003: อ่านทั้งหมด
...               - TC-API-NOTI-004: ดูแจ้งเตือนโดยไม่มี token
...               - TC-API-NOTI-005: ดูแจ้งเตือนตาม ID
...               - TC-API-NOTI-006: Admin สร้างแจ้งเตือนให้ผู้ใช้
...               - TC-API-NOTI-007: ดูแจ้งเตือนด้วย filter

Library           RequestsLibrary
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Teardown    Delete All Sessions

Force Tags        api    notification

*** Test Cases ***
# =============================================================
# Positive Tests
# =============================================================

TC-API-NOTI-001 Get My Notifications Successfully
    [Documentation]    ทดสอบดูรายการแจ้งเตือนของตัวเอง
    ...    Expected: HTTP 200
    [Tags]    smoke    critical    positive
    Login As Admin
    ${response}=    Get My Notifications
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    ดูรายการแจ้งเตือนสำเร็จ

TC-API-NOTI-002 Get Unread Notification Count
    [Documentation]    ทดสอบดูจำนวนแจ้งเตือนที่ยังไม่อ่าน
    ...    Expected: HTTP 200
    [Tags]    smoke    positive
    Login As Admin
    ${response}=    Get Unread Count
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Log    จำนวนแจ้งเตือนที่ยังไม่อ่าน: ${json}

TC-API-NOTI-003 Mark All Notifications As Read
    [Documentation]    ทดสอบทำเครื่องหมายอ่านทั้งหมด
    ...    Expected: HTTP 200
    [Tags]    positive
    Login As Admin
    ${response}=    Mark All Notifications Read
    Response Status Should Be    ${response}    ${HTTP_OK}
    Log    ทำเครื่องหมายอ่านทั้งหมดสำเร็จ

TC-API-NOTI-004 Get Notification By Id
    [Documentation]    ทดสอบดูแจ้งเตือนตาม ID
    ...    Precondition: ต้องมีแจ้งเตือนในระบบ
    ...    Expected: HTTP 200
    [Tags]    positive
    Login As Admin
    ${response}=    Get My Notifications
    ${json}=    Get Response JSON    ${response}
    ${data}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${data}
    Skip If    ${count} == 0    ไม่มีแจ้งเตือนในระบบสำหรับทดสอบ
    ${first_notif}=    Set Variable    ${data}[0]
    ${notif_id}=    Set Variable    ${first_notif}[id]
    ${detail_response}=    GET On Session    painamnae_auth    /notifications/${notif_id}    expected_status=any
    Response Status Should Be    ${detail_response}    ${HTTP_OK}
    Log    ดูแจ้งเตือนตาม ID สำเร็จ: ${notif_id}

TC-API-NOTI-005 Get Notifications With Filter
    [Documentation]    ทดสอบดูแจ้งเตือนด้วย filter
    ...    Test Data: limit=5, read=false
    ...    Expected: HTTP 200
    [Tags]    positive
    Login As Admin
    ${params}=    Create Dictionary    limit=5    read=false
    ${response}=    GET On Session    painamnae_auth    /notifications    params=${params}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    Log    ดูแจ้งเตือนด้วย filter สำเร็จ

# =============================================================
# Negative Tests
# =============================================================

TC-API-NOTI-006 Get Notifications Without Token
    [Documentation]    ทดสอบดูแจ้งเตือนโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${response}=    GET On Session    painamnae    /notifications    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ดูแจ้งเตือนโดยไม่มี token ถูกปฏิเสธ

TC-API-NOTI-007 Get Unread Count Without Token
    [Documentation]    ทดสอบดูจำนวนแจ้งเตือนโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${response}=    GET On Session    painamnae    /notifications/unread-count    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    ดูจำนวนแจ้งเตือนโดยไม่มี token ถูกปฏิเสธ

# =============================================================
# Admin Tests
# =============================================================

TC-API-NOTI-008 Admin List All Notifications
    [Documentation]    ทดสอบ Admin ดูแจ้งเตือนทั้งหมด
    ...    Expected: HTTP 200
    [Tags]    positive    admin
    Login As Admin
    ${response}=    GET On Session    painamnae_auth    /notifications/admin    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    Admin ดูแจ้งเตือนทั้งหมดสำเร็จ

TC-API-NOTI-009 Admin Create Notification For User
    [Documentation]    ทดสอบ Admin สร้างแจ้งเตือนให้ผู้ใช้
    ...    Expected: HTTP 201
    [Tags]    positive    admin
    Login As Admin
    # ดึง user id แรก
    ${users_response}=    GET On Session    painamnae_auth    /users/admin    expected_status=any
    ${users_json}=    Get Response JSON    ${users_response}
    ${users}=    Set Variable    ${users_json}[data]
    ${count}=    Get Length    ${users}
    Skip If    ${count} == 0    ไม่มีผู้ใช้ในระบบ
    ${first_user}=    Set Variable    ${users}[0]
    ${user_id}=    Set Variable    ${first_user}[id]
    ${notif_data}=    Create Dictionary
    ...    userId=${user_id}
    ...    title=การทดสอบแจ้งเตือน
    ...    body=นี่คือแจ้งเตือนจากระบบทดสอบ Robot Framework
    ${response}=    POST On Session    painamnae_auth    /notifications/admin    json=${notif_data}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_CREATED}
    Log    Admin สร้างแจ้งเตือนสำเร็จ
