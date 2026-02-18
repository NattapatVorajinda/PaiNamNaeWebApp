*** Settings ***
Documentation     ข้อมูลทดสอบ Test Data สำหรับ PaiNamNae WebApp
...               ประกอบด้วยตัวแปรที่ใช้ร่วมกันทุก Test Suite

*** Variables ***
# =========================================================
# Environment Configuration
# =========================================================
${BASE_URL}                 http://localhost:3000/api
${FRONTEND_URL}             http://localhost:3001
${BROWSER}                  chromium

# =========================================================
# Admin Credentials
# =========================================================
${ADMIN_USERNAME}           admin123
${ADMIN_PASSWORD}           123456789
${ADMIN_EMAIL}              admin@example.com

# =========================================================
# Test Driver Data
# =========================================================
${DRIVER_USERNAME}          testdriver01
${DRIVER_PASSWORD}          Test@12345
${DRIVER_EMAIL}             testdriver01@test.com
${DRIVER_FIRSTNAME}         ทดสอบ
${DRIVER_LASTNAME}          คนขับ
${DRIVER_PHONE}             0812345678
${DRIVER_GENDER}            MALE
${DRIVER_NATIONAL_ID}       1234567890123
${DRIVER_NATIONAL_ID_EXP}   2030-12-31

# =========================================================
# Test Passenger Data
# =========================================================
${PASSENGER_USERNAME}       testpassenger01
${PASSENGER_PASSWORD}       Test@12345
${PASSENGER_EMAIL}          testpassenger01@test.com
${PASSENGER_FIRSTNAME}      ทดสอบ
${PASSENGER_LASTNAME}       ผู้โดยสาร
${PASSENGER_PHONE}          0898765432
${PASSENGER_GENDER}         FEMALE
${PASSENGER_NATIONAL_ID}    9876543210987
${PASSENGER_NATIONAL_ID_EXP}  2030-12-31

# =========================================================
# Test Vehicle Data
# =========================================================
${VEHICLE_MODEL}            Toyota Yaris 2024
${VEHICLE_LICENSE_PLATE}    กข 1234 กรุงเทพ
${VEHICLE_TYPE}             SEDAN
${VEHICLE_COLOR}            WHITE
${VEHICLE_SEATS}            4
@{VEHICLE_AMENITIES}        AIR_CONDITIONING    MUSIC

# =========================================================
# Test Route Data
# =========================================================
${ROUTE_START_LAT}          13.7563
${ROUTE_START_LNG}          100.5018
${ROUTE_START_NAME}         กรุงเทพมหานคร
${ROUTE_END_LAT}            14.8821
${ROUTE_END_LNG}            102.0156
${ROUTE_END_NAME}           นครราชสีมา
${ROUTE_AVAILABLE_SEATS}    3
${ROUTE_PRICE_PER_SEAT}     250

# =========================================================
# Test Booking Data
# =========================================================
${BOOKING_SEATS}            1
${BOOKING_PICKUP_LAT}       13.7563
${BOOKING_PICKUP_LNG}       100.5018
${BOOKING_PICKUP_NAME}      จุดรับ กรุงเทพ
${BOOKING_DROPOFF_LAT}      14.8821
${BOOKING_DROPOFF_LNG}      102.0156
${BOOKING_DROPOFF_NAME}     จุดส่ง นครราชสีมา

# =========================================================
# HTTP Status Codes
# =========================================================
${HTTP_OK}                  200
${HTTP_CREATED}             201
${HTTP_BAD_REQUEST}         400
${HTTP_UNAUTHORIZED}        401
${HTTP_FORBIDDEN}           403
${HTTP_NOT_FOUND}           404
${HTTP_CONFLICT}            409
${HTTP_SERVER_ERROR}        500

# =========================================================
# Booking Status Values
# =========================================================
${STATUS_PENDING}           PENDING
${STATUS_CONFIRMED}         CONFIRMED
${STATUS_REJECTED}          REJECTED
${STATUS_CANCELLED}         CANCELLED

# =========================================================
# Route Status Values
# =========================================================
${ROUTE_AVAILABLE}          AVAILABLE
${ROUTE_FULL}               FULL
${ROUTE_COMPLETED}          COMPLETED
${ROUTE_CANCELLED}          CANCELLED
${ROUTE_IN_TRANSIT}         IN_TRANSIT

# =========================================================
# Cancel Reasons
# =========================================================
${CANCEL_CHANGE_OF_PLAN}    CHANGE_OF_PLAN
${CANCEL_FOUND_ALT}         FOUND_ALTERNATIVE
${CANCEL_DRIVER_DELAY}      DRIVER_DELAY
