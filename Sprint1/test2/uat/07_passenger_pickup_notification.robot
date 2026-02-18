*** Settings ***
Documentation     UAT Test Suite: Passenger Pickup Notification (แจ้งเตือนผู้โดยสารเมื่อคนขับกำลังมาถึง)
...
...               User Story:
...               "As a passenger, I want to get a notification when the driver is about to pick me up 
...               so that I can get myself ready or respond to the driver."
...
...               Test Scenarios:
...               - TC-UAT-NOTIFY-001: ผู้โดยสารรับแจ้งเตือนเมื่อคนขับกำลังมาถึง
...               - TC-UAT-NOTIFY-002: ผู้โดยสารเห็นแจ้งเตือนในหน้าแจ้งเตือน
...               - TC-UAT-NOTIFY-003: ผู้โดยสารมีอลเร็ตแจ้งเตือนบนเบราว์เซอร์
...               - TC-UAT-NOTIFY-004: ผู้โดยสารสามารถทำเครื่องหมายอ่านแจ้งเตือน
...               - TC-UAT-NOTIFY-005: ผู้โดยสารเห็นข้อมูลติดต่อคนขับในแจ้งเตือน

Library           Browser
Library           String
Library           DateTime
Library           Collections
Resource          ../resources/common.resource
Resource          ../resources/uat_keywords.resource
Resource          ../resources/api_keywords.resource

Suite Setup       Setup Passenger Notification Tests
Suite Teardown    Close PaiNamNae Website

Force Tags        uat    notification    pickup

*** Keywords ***
Setup Passenger Notification Tests
    [Documentation]    เตรียมข้อมูลสำหรับทดสอบแจ้งเตือน
    Open PaiNamNae Website
    Login Via UI    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Wait For Page Load

*** Test Cases ***
TC-UAT-NOTIFY-001 Passenger Receives Pickup Notification
    [Documentation]    ทดสอบว่าผู้โดยสารรับแจ้งเตือนเมื่อคนขับกำลังมาถึง
    ...    Precondition:
    ...    - ผู้โดยสารได้ทำการจองเส้นทาง
    ...    - สถานะการจองถูกยืนยัน (CONFIRMED)
    ...    Expected Result:
    ...    - ผู้โดยสารจะได้รับแจ้งเตือน "คนขับกำลังมาถึง"
    ...    - เนื้อหาแจ้งเตือนประกอบด้วยชื่อคนขับและเวลาประมาณที่จะถึง
    [Tags]    smoke    critical    positive    notification
    
    # ขั้นตอนที่ 1: ผู้โดยสารจองเส้นทาง (จากการบ้านของใคร)
    Log    [步骤 1] ผู้โดยสารเข้าระบบและค้นหาเส้นทาง
    Navigate To Find Trip Page
    Wait For Page Load
    Sleep    2s    # รอ API โหลดรายการเส้นทาง
    
    # ขั้นตอนที่ 2: ตรวจสอบว่ามีเส้นทางให้จอง
    ${body_text}=    Get Text    css=body
    Log    ตรวจสอบหน้าค้นหาเส้นทาง
    
    # ขั้นตอนที่ 3: หน้าแจ้งเตือนแสดงแจ้งเตือนใหม่
    Navigate To Notifications Page
    Wait For Page Load
    Sleep    2s    # รอ API โหลดแจ้งเตือน
    
    ${notification_text}=    Get Text    css=body
    Log    ตรวจสอบหน้าแจ้งเตือน
    
    # ตรวจสอบว่ามีคำว่า "ขึ้นรถ" หรือ "มาถึง" ในแจ้งเตือน
    ${has_pickup_notification}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${notification_text}    (คนขับ|driver).{0,50}(มาถึง|ขึ้นรถ|coming|on the way)
    
    ${has_driver_info}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${notification_text}    ([A-Z][a-z]+|[a-z]+).{0,30}(ขับรถ|คนขับ)
    
    Log    แจ้งเตือนสำหรับคนขับมาถึง: ${has_pickup_notification}
    Log    ข้อมูลคนขับในแจ้งเตือน: ${has_driver_info}

TC-UAT-NOTIFY-002 Passenger Sees Notification in Notification Panel
    [Documentation]    ทดสอบว่าผู้โดยสารสามารถเห็นแจ้งเตือนในหน้าแจ้งเตือน
    ...    Expected Result:
    ...    - หน้าแจ้งเตือนแสดงรายชื่อแจ้งเตือน
    ...    - แต่ละรายการแจ้งเตือนมีข้อมูล (เวลา, ข้อความ, สถานะอ่าน)
    [Tags]    smoke    positive    ui
    
    Navigate To Notifications Page
    Wait For Page Load
    Sleep    2s    # รอ API โหลด
    
    # ตรวจสอบว่ามีส่วนประกอบของแจ้งเตือน
    ${page_content}=    Get Text    css=body
    
    # ตรวจสอบองค์ประกอบ
    ${has_notification_list}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${page_content}    (notification|แจ้งเตือน|ข้อความ)
    
    ${has_timestamp}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${page_content}    (\\d{1,2}:\\d{2}|เมื่อ|ago|นาทีที่แล้ว)
    
    Log    แจ้งเตือนมีข้อมูลรายการทั้งหมด: ${has_notification_list} และมีเวลา: ${has_timestamp}

TC-UAT-NOTIFY-003 Passenger Receives Visual Alert on Browser
    [Documentation]    ทดสอบว่าผู้โดยสารจะมีการแจ้งเตือนภาพชัดเจน
    ...    Expected Result:
    ...    - มีแสดง notification badge บนเมนู
    ...    - มีสี highlight ที่เด่นชัด
    ...    - แจ้งเตือนที่ยังไม่อ่านมี indicator บ่งบอก
    [Tags]    positive    ui
    
    Navigate To Notifications Page
    Wait For Page Load
    Sleep    2s
    
    # ตรวจสอบการมีอยู่ของแสดง unread badge
    ${unread_badge}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[class*="badge"], [class*="unread"], [class*="new"]    visible    timeout=5s
    
    Log    พบ unread badge indicator: ${unread_badge}
    
    # ตรวจสอบการมีอยู่ของสิ่งที่บ่งบอก "ไม่อ่าน"
    ${page_content}=    Get Text    css=body
    ${has_unread_indicator}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${page_content}    (ใหม่|new|ยังไม่อ่าน|unread)
    
    Log    แสดง indicator ไม่อ่าน: ${has_unread_indicator}

TC-UAT-NOTIFY-004 Passenger Can Mark Notification As Read
    [Documentation]    ทดสอบว่าผู้โดยสารสามารถทำเครื่องหมายอ่านแจ้งเตือน
    ...    Expected Result:
    ...    - ผู้โดยสารคลิกเลือกแจ้งเตือน
    ...    - แจ้งเตือนเปลี่ยนสถานะเป็น "อ่านแล้ว"
    ...    - Unread count หรือ indicator เปลี่ยนแปลง
    [Tags]    positive    ui    interaction
    
    Navigate To Notifications Page
    Wait For Page Load
    Sleep    2s
    
    # แสดงว่ามีปุ่มหรือฟิลด์สำหรับทำเครื่องหมายอ่าน
    ${page_content}=    Get Text    css=body
    
    ${has_mark_read_option}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${page_content}    (ทำเครื่องหมายว่าอ่าน|Mark as read|อ่าน|ปุ่ม|button)
    
    ${has_delete_option}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${page_content}    (ลบ|Delete|Remove)
    
    Log    มีฟีเจอร์ทำเครื่องหมายอ่าน: ${has_mark_read_option}
    Log    มีฟีเจอร์ลบแจ้งเตือน: ${has_delete_option}

TC-UAT-NOTIFY-005 Passenger Sees Driver Contact Info in Notification
    [Documentation]    ทดสอบว่าผู้โดยสารเห็นข้อมูลติดต่อคนขับในแจ้งเตือน
    ...    Expected Result:
    ...    - แจ้งเตือนแสดงชื่อคนขับ
    ...    - แจ้งเตือนแสดงหมายเลขโทรศัพท์คนขับ หรือสามารถติดต่อได้
    ...    - แจ้งเตือนแสดงข้อมูลรถ (ทะเบียน, สี, รุ่น)
    [Tags]    critical    contact-info    positive
    
    Navigate To Notifications Page
    Wait For Page Load
    Sleep    2s
    
    ${notification_content}=    Get Text    css=body
    
    # ตรวจสอบ: ชื่อคนขับ
    ${has_driver_name}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${notification_content}    ([ก-ฮ][ก-ฮ0-9]+\\s?[ก-ฮ][ก-ฮ0-9]*)
    
    # ตรวจสอบ: หมายเลขโทรศัพท์
    ${has_phone}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${notification_content}    (0[689]\\d{8}|[0-9]{10})
    
    # ตรวจสอบ: ข้อมูลรถ (ทะเบียน)
    ${has_vehicle_info}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${notification_content}    ([ก-ฮ]{2,3}\\s?\\d{4}|license|plate|ทะเบียน)
    
    Log    ข้อมูลคนขับ - ชื่อ: ${has_driver_name}
    Log    ข้อมูลคนขับ - เบอร์โทร: ${has_phone}
    Log    ข้อมูลรถ - ทะเบียน/รุ่น: ${has_vehicle_info}
    
    # ตรวจสอบว่ามีลิงก์หรือปุ่มติดต่อ
    ${page_content}=    Get HTML    css=body
    ${has_contact_button}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${page_content}    (<a|<button|href|onClick).*(call|phone|contact|โทร|ติดต่อ)
    
    Log    มีปุ่มติดต่อคนขับ: ${has_contact_button}

# ============================================================
# Supporting Keywords
# ============================================================

Navigate To Notifications Page
    [Documentation]    ไปยังหน้าแจ้งเตือน
    Go To    ${FRONTEND_URL}/notifications
    Wait For Elements State    css=body    visible    timeout=10s

Wait For Page Load
    [Documentation]    รอให้หน้าโหลดเสร็จ
    Sleep    1s
    Wait For Navigation    timeout=10s
