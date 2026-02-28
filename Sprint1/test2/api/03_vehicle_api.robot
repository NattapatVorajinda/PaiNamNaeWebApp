*** Settings ***
Documentation     API Test Suite: Vehicle Management (การจัดการยานพาหนะ)
...
...               Test Design:
...               - TC-API-VEH-001: สร้างยานพาหนะใหม่สำเร็จ
...               - TC-API-VEH-002: ดูรายการยานพาหนะของตัวเองสำเร็จ
...               - TC-API-VEH-003: ดูยานพาหนะตาม ID สำเร็จ
...               - TC-API-VEH-004: อัปเดตยานพาหนะสำเร็จ
...               - TC-API-VEH-005: ตั้งยานพาหนะเป็นค่าเริ่มต้น
...               - TC-API-VEH-006: ลบยานพาหนะสำเร็จ
...               - TC-API-VEH-007: สร้างยานพาหนะโดยไม่มี token
...               - TC-API-VEH-008: สร้างยานพาหนะด้วยข้อมูลไม่ครบ

Library           RequestsLibrary
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Teardown    Delete All Sessions

Force Tags        api    vehicle

*** Variables ***
${TEST_VEHICLE_ID}    ${EMPTY}

*** Test Cases ***
# =============================================================
# Positive Tests - CRUD
# =============================================================

TC-API-VEH-001 Create Vehicle Successfully
    [Documentation]    ทดสอบสร้างยานพาหนะใหม่
    ...    Test Data: vehicleModel, licensePlate, vehicleType, color, seatCapacity
    ...    Expected: HTTP 201, response มี vehicle data
    [Tags]    smoke    critical    positive
    Login As Admin
    ${vehicle_data}=    Create Dictionary
    ...    vehicleModel=${VEHICLE_MODEL}
    ...    licensePlate=ทดสอบ 9999 กรุงเทพ
    ...    vehicleType=${VEHICLE_TYPE}
    ...    color=${VEHICLE_COLOR}
    ...    seatCapacity=${VEHICLE_SEATS}
    ...    amenities=${VEHICLE_AMENITIES}
    ${response}=    Create Vehicle    ${vehicle_data}
    Response Status Should Be    ${response}    ${HTTP_CREATED}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Dictionary Should Contain Key    ${json}[data]    id
    Set Suite Variable    ${TEST_VEHICLE_ID}    ${json}[data][id]
    Log    สร้างยานพาหนะสำเร็จ: ID=${json}[data][id]

TC-API-VEH-002 Get My Vehicles Successfully
    [Documentation]    ทดสอบดูรายการยานพาหนะของตัวเอง
    ...    Expected: HTTP 200, response มี data list
    [Tags]    smoke    positive
    Login As Admin
    ${response}=    Get My Vehicles
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    Log    ดูรายการยานพาหนะสำเร็จ

TC-API-VEH-003 Get Vehicle By Id Successfully
    [Documentation]    ทดสอบดูยานพาหนะตาม ID
    ...    Precondition: ต้องมี TEST_VEHICLE_ID จาก TC-API-VEH-001
    ...    Expected: HTTP 200
    [Tags]    positive
    Skip If    '${TEST_VEHICLE_ID}' == '${EMPTY}'    ไม่มี vehicle ID สำหรับทดสอบ
    Login As Admin
    ${response}=    GET On Session    painamnae_auth    /vehicles/${TEST_VEHICLE_ID}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    ${json}=    Get Response JSON    ${response}
    Should Be Equal    ${json}[data][id]    ${TEST_VEHICLE_ID}
    Log    ดูยานพาหนะตาม ID สำเร็จ

TC-API-VEH-004 Update Vehicle Successfully
    [Documentation]    ทดสอบอัปเดตข้อมูลยานพาหนะ
    ...    Test Data: เปลี่ยนสี
    ...    Expected: HTTP 200
    [Tags]    positive
    Skip If    '${TEST_VEHICLE_ID}' == '${EMPTY}'    ไม่มี vehicle ID สำหรับทดสอบ
    Login As Admin
    ${data}=    Create Dictionary    color=BLACK
    ${response}=    Update Vehicle    ${TEST_VEHICLE_ID}    ${data}
    Response Status Should Be    ${response}    ${HTTP_OK}
    Log    อัปเดตยานพาหนะสำเร็จ

TC-API-VEH-005 Set Vehicle As Default
    [Documentation]    ทดสอบตั้งยานพาหนะเป็นค่าเริ่มต้น
    ...    Expected: HTTP 200
    [Tags]    positive
    Skip If    '${TEST_VEHICLE_ID}' == '${EMPTY}'    ไม่มี vehicle ID สำหรับทดสอบ
    Login As Admin
    ${response}=    PUT On Session    painamnae_auth    /vehicles/${TEST_VEHICLE_ID}/default    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    Log    ตั้งยานพาหนะเป็นค่าเริ่มต้นสำเร็จ

TC-API-VEH-006 Delete Vehicle Successfully
    [Documentation]    ทดสอบลบยานพาหนะ
    ...    Expected: HTTP 200
    [Tags]    positive    cleanup
    Skip If    '${TEST_VEHICLE_ID}' == '${EMPTY}'    ไม่มี vehicle ID สำหรับทดสอบ
    Login As Admin
    ${response}=    Delete Vehicle    ${TEST_VEHICLE_ID}
    Response Status Should Be    ${response}    ${HTTP_OK}
    Log    ลบยานพาหนะสำเร็จ

# =============================================================
# Negative Tests
# =============================================================

TC-API-VEH-007 Create Vehicle Without Token
    [Documentation]    ทดสอบสร้างยานพาหนะโดยไม่มี token
    ...    Expected: HTTP 401
    [Tags]    negative    security
    Create API Session
    ${vehicle_data}=    Create Dictionary
    ...    vehicleModel=Test Car
    ...    licensePlate=XX 0000
    ...    vehicleType=SEDAN
    ...    color=RED
    ...    seatCapacity=4
    ${response}=    POST On Session    painamnae    /vehicles    json=${vehicle_data}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_UNAUTHORIZED}
    Log    สร้างยานพาหนะโดยไม่มี token ถูกปฏิเสธ

TC-API-VEH-008 Create Vehicle With Missing Data
    [Documentation]    ทดสอบสร้างยานพาหนะด้วยข้อมูลไม่ครบ
    ...    Test Data: ไม่มี vehicleModel
    ...    Expected: HTTP 400
    [Tags]    negative    validation
    Login As Admin
    ${vehicle_data}=    Create Dictionary    color=RED
    ${response}=    Create Vehicle    ${vehicle_data}
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    สร้างยานพาหนะข้อมูลไม่ครบถูกปฏิเสธ - status: ${status}

TC-API-VEH-009 Get Non-Existent Vehicle
    [Documentation]    ทดสอบดูยานพาหนะที่ไม่มีอยู่จริง
    ...    Expected: HTTP 404
    [Tags]    negative
    Login As Admin
    ${response}=    GET On Session    painamnae_auth    /vehicles/nonexistent_id_12345    expected_status=any
    ${status}=    Convert To Integer    ${response.status_code}
    Should Be True    ${status} >= 400
    Log    ดูยานพาหนะที่ไม่มีอยู่ถูกปฏิเสธ - status: ${status}
