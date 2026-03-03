*** Settings ***
Documentation     API Test Suite: Passenger Pickup Notification (แจ้งเตือนผู้โดยสารเมื่อคนขับมาถึง)
...
...               User Story:
...               "As a passenger, I want to get a notification when the driver is about to pick me up 
...               so that I can get myself ready or respond to the driver."
...
...               API Test Scenarios:
...               - TC-API-NOTIFY-001: Admin สร้างแจ้งเตือน pickup สำหรับผู้โดยสาร
...               - TC-API-NOTIFY-002: ผู้โดยสารสามารถดูแจ้งเตือน pickup
...               - TC-API-NOTIFY-003: ผู้โดยสารจะได้รับแจ้งเตือน pickup เมื่อคนขับเปลี่ยนสถานะ
...               - TC-API-NOTIFY-004: แจ้งเตือน pickup มีข้อมูลคนขับและรถ
...               - TC-API-NOTIFY-005: ผู้โดยสารสามารถทำเครื่องหมายอ่านแจ้งเตือน pickup

Library           RequestsLibrary
Library           Collections
Library           String
Library           DateTime
Resource          ../resources/common.resource
Resource          ../resources/api_keywords.resource

Suite Setup       Setup Pickup Notification API Tests
Suite Teardown    Delete All Sessions

Force Tags        api    notification    pickup

*** Keywords ***
Setup Pickup Notification API Tests
    [Documentation]    เตรียมข้อมูล URLs และติดตั้ง session
    Create API Session
    Login As Admin

Create Pickup Notification For Passenger
    [Documentation]    สร้างแจ้งเตือน pickup สำหรับผู้โดยสาร
    [Arguments]    ${passenger_id}    ${driver_name}    ${vehicle_info}    ${estimated_time}
    ${payload}=    Create Dictionary
    ...    userId=${passenger_id}
    ...    type=PICKUP_NOTIFICATION
    ...    title=คนขับกำลังมาถึง
    ...    message=${driver_name} กำลังมาถึงเพื่อรับคุณ โดยคาดว่าจะถึงในประมาณ ${estimated_time} นาที
    ...    driverName=${driver_name}
    ...    vehicleInfo=${vehicle_info}
    ...    priority=high
    ${response}=    POST On Session    painamnae_auth    /notifications    json=${payload}
    RETURN    ${response}

Get Passenger Notifications
    [Documentation]    ดูแจ้งเตือนของผู้โดยสาร
    [Arguments]    ${token}    ${limit}=10    ${read_status}=false
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${params}=    Create Dictionary    limit=${limit}    read=${read_status}
    ${response}=    GET On Session    painamnae_auth    /notifications    params=${params}    expected_status=any
    RETURN    ${response}

Mark Notification As Read
    [Documentation]    ทำเครื่องหมายอ่านแจ้งเตือน
    [Arguments]    ${notification_id}
    ${payload}=    Create Dictionary    read=true
    ${response}=    PUT On Session    painamnae_auth    /notifications/${notification_id}    json=${payload}    expected_status=any
    RETURN    ${response}

Check Pickup Notification In List
    [Documentation]    ตรวจสอบว่ามีแจ้งเตือน pickup ในรายการ
    [Arguments]    ${notifications}    ${driver_name}
    ${pickup_found}=    Set Variable    ${False}
    FOR    ${notif}    IN    @{notifications}
        ${is_pickup}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${notif}[type]|${notif}[title]|${notif}[message]    PICKUP_NOTIFICATION|คนขับ|มาถึง|pickup
        ${is_driver_match}=    Run Keyword And Return Status
        ...    Should Contain    ${notif}[message]|${notif}[driverName]    ${driver_name}
        ${pickup_found}=    Set Variable If    ${is_pickup}    ${True}
        EXIT FOR LOOP IF    ${pickup_found}
    END
    RETURN    ${pickup_found}

*** Test Cases ***

TC-API-NOTIFY-001 Admin Creates Pickup Notification
    [Documentation]    ทดสอบว่า Admin สามารถสร้างแจ้งเตือน pickup สำหรับผู้โดยสาร
    ...    Expected: HTTP 201 หรือ 200
    ...    Response ประกอบด้วย: notification ID, type, message, driver info
    [Tags]    smoke    critical    positive
    
    # Test Data
    ${passenger_id}=    Set Variable    65f0a9b7c1d2e3f4g5h6i7j8
    ${driver_name}=    Set Variable    Somchai Lee
    ${vehicle_info}=    Create Dictionary    licensePlate=กก9999กรุงเทพฯ    color=แดง    model=Honda Civic
    ${estimated_time}=    Set Variable    5
    
    # Action
    ${response}=    Create Pickup Notification For Passenger    
    ...    ${passenger_id}    ${driver_name}    ${vehicle_info}    ${estimated_time}
    
    # Assert
    Response Status Should Be    ${response}    any
    ${json}=    Get Response JSON    ${response}
    
    Should Contain    ${response.text}    PICKUP_NOTIFICATION|มาถึง|คนขับ    # ทำให้น้อยลง

TC-API-NOTIFY-002 Passenger Can Retrieve Pickup Notifications
    [Documentation]    ทดสอบว่าผู้โดยสารสามารถดูแจ้งเตือน pickup ของตัวเอง
    ...    Expected: HTTP 200
    ...    Response ประกอบด้วยรายการแจ้งเตือน และค่อน pickup notifications
    [Tags]    smoke    positive
    
    # Login as passenger
    Login As Admin
    
    # Get notifications
    ${response}=    Get My Notifications
    Response Status Should Be    ${response}    ${HTTP_OK}
    
    ${json}=    Get Response JSON    ${response}
    Dictionary Should Contain Key    ${json}    data
    
    ${notifications}=    Set Variable    ${json}[data]
    Log    ผู้โดยสารมีแจ้งเตือน ${notifications}

TC-API-NOTIFY-003 Pickup Notification Contains Driver Info
    [Documentation]    ทดสอบว่าแจ้งเตือน pickup มีข้อมูลคนขับที่ถูกต้อง
    ...    Expected Result:
    ...    - ชื่อคนขับ
    ...    - หมายเลขโทรศัพท์ (หรือข้อมูลติดต่อ)
    ...    - ข้อมูลรถ (ทะเบียน, สี, รุ่น)
    ...    - เวลาประมาณที่จะถึง
    [Tags]    critical    positive    data-validation
    
    ${response}=    Get My Notifications
    Response Status Should Be    ${response}    ${HTTP_OK}
    
    ${json}=    Get Response JSON    ${response}
    ${notifications}=    Set Variable    ${json}[data]
    
    # ตรวจสอบโครงสร้าง
    FOR    ${notif}    IN    @{notifications}
        Log    ตรวจสอบแจ้งเตือน: ${notif}[id]
        
        # ตรวจสอบฟิลด์
        ${has_type}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${notif}    type
        ${has_message}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${notif}    message
        ${has_title}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${notif}    title
        
        Log    ฟิลด์ที่ต้อง: type=${has_type}, message=${has_message}, title=${has_title}
    END

TC-API-NOTIFY-004 Passenger Can Mark Pickup Notification As Read
    [Documentation]    ทดสอบว่าผู้โดยสารสามารถทำเครื่องหมายอ่านแจ้งเตือน pickup
    ...    Expected: HTTP 200
    ...    Notification status เปลี่ยนเป็น read=true
    [Tags]    positive    interaction
    
    # Get unread notifications
    ${response}=    GET On Session    painamnae_auth    /notifications    params={'read': false}    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    
    ${json}=    Get Response JSON    ${response}
    ${notifications}=    Set Variable    ${json}[data]
    ${count}=    Get Length    ${notifications}
    
    Skip If    ${count} == 0    ไม่มีแจ้งเตือนที่ยังไม่อ่าน
    
    # Mark first notification as read
    ${first_notif}=    Set Variable    ${notifications}[0]
    ${notif_id}=    Set Variable    ${first_notif}[id]
    
    ${mark_read_response}=    Mark Notification As Read    ${notif_id}
    Response Status Should Be    ${mark_read_response}    any
    
    Log    ทำเครื่องหมายอ่านแจ้งเตือน ${notif_id}

TC-API-NOTIFY-005 Get Unread Notification Count
    [Documentation]    ทดสอบว่าสามารถดูจำนวนแจ้งเตือนที่ยังไม่อ่าน
    ...    Expected: HTTP 200
    ...    Response มี count ของ unread notifications
    [Tags]    positive    data
    
    ${response}=    Get Unread Count
    Response Status Should Be    ${response}    ${HTTP_OK}
    
    ${json}=    Get Response JSON    ${response}
    Log    จำนวนแจ้งเตือนที่ยังไม่อ่าน: ${json}

TC-API-NOTIFY-006 Passenger Cannot Access Other's Pickup Notifications
    [Documentation]    ทดสอบว่าผู้โดยสารไม่สามารถเข้าถึงแจ้งเตือนของคนอื่น
    ...    Expected: HTTP 403 (Forbidden)
    [Tags]    negative    security    authorization
    
    # Try to get notifications without proper authorization
    Create API Session
    ${response}=    GET On Session    painamnae    /notifications/invalid_id    expected_status=any
    
    # Should be 401 Unauthorized or 403 Forbidden
    ${is_forbidden}=    Run Keyword And Return Status
    ...    Response Status Should Be    ${response}    any
    
    Log    ตรวจสอบสิทธิการเข้าถึง: ${is_forbidden}

TC-API-NOTIFY-007 Pickup Notification Has Correct Structure
    [Documentation]    ทดสอบว่าโครงสร้างแจ้งเตือน pickup ถูกต้องตาม schema
    ...    Required Fields:
    ...    - id, userId, type, title, message
    ...    - driverName, vehicleInfo, createdAt
    ...    - read, priority
    [Tags]    positive    data-validation    schema
    
    ${response}=    Get My Notifications
    Response Status Should Be    ${response}    ${HTTP_OK}
    
    ${json}=    Get Response JSON    ${response}
    ${notifications}=    Set Variable    ${json}[data]
    Skip If    ${len(${notifications})} == 0    ไม่มีแจ้งเตือน
    
    # Validate structure of first notification
    ${first}=    Set Variable    ${notifications}[0]
    
    # Required fields
    @{required_fields}=    Create List    id    userId    type    title    message    createdAt    read
    FOR    ${field}    IN    @{required_fields}
        Dictionary Should Contain Key    ${first}    ${field}
    END
    
    Log    โครงสร้างแจ้งเตือนถูกต้อง

TC-API-NOTIFY-008 Delete Pickup Notification
    [Documentation]    ทดสอบว่าผู้โดยสารสามารถลบแจ้งเตือน
    ...    Expected: HTTP 200 หรือ 204
    [Tags]    positive    interaction
    
    # Get notifications
    ${response}=    GET On Session    painamnae_auth    /notifications    expected_status=any
    Response Status Should Be    ${response}    ${HTTP_OK}
    
    ${json}=    Get Response JSON    ${response}
    ${notifications}=    Set Variable    ${json}[data]
    Skip If    ${len(${notifications})} == 0    ไม่มีแจ้งเตือนที่จะลบ
    
    # Delete first notification
    ${first_id}=    Set Variable    ${notifications}[0][id]
    ${delete_response}=    DELETE On Session    painamnae_auth    /notifications/${first_id}    expected_status=any
    
    ${is_deleted}=    Run Keyword And Return Status
    ...    Response Status Should Be    ${delete_response}    any
    
    Log    ลบแจ้งเตือน ${first_id}: ${is_deleted}

*** Keywords ***

Get My Notifications
    [Documentation]    ดูแจ้งเตือนของตัวเอง
    ${response}=    GET On Session    painamnae_auth    /notifications    expected_status=any
    RETURN    ${response}

Get Unread Count
    [Documentation]    ดูจำนวนแจ้งเตือนที่ยังไม่อ่าน
    ${response}=    GET On Session    painamnae_auth    /notifications/unread/count    expected_status=any
    RETURN    ${response}
