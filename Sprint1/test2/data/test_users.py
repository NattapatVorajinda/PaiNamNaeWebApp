"""
Test Data: ข้อมูลผู้ใช้ทดสอบสำหรับ Robot Framework
ใช้เป็น Python variable file: --variablefile data/test_users.py
"""

# =========================================================
# ผู้ใช้ทดสอบ (Test Users)
# =========================================================

ADMIN_USER = {
    "username": "admin123",
    "email": "admin@painamnae.com",
    "password": "123456789",
    "role": "ADMIN"
}

DRIVER_USER = {
    "username": "testdriver01",
    "email": "testdriver01@test.com",
    "password": "Test@12345",
    "firstName": "ทดสอบ",
    "lastName": "คนขับ",
    "phoneNumber": "0812345678",
    "gender": "MALE",
    "nationalIdNumber": "1234567890123",
    "nationalIdExpiryDate": "2030-12-31",
    "role": "DRIVER"
}

PASSENGER_USER = {
    "username": "testpassenger01",
    "email": "testpassenger01@test.com",
    "password": "Test@12345",
    "firstName": "ทดสอบ",
    "lastName": "ผู้โดยสาร",
    "phoneNumber": "0898765432",
    "gender": "FEMALE",
    "nationalIdNumber": "9876543210987",
    "nationalIdExpiryDate": "2030-12-31",
    "role": "PASSENGER"
}

# =========================================================
# ข้อมูลยานพาหนะทดสอบ (Test Vehicles)
# =========================================================

TEST_VEHICLE = {
    "vehicleModel": "Toyota Yaris 2024",
    "licensePlate": "กข 1234 กรุงเทพ",
    "vehicleType": "SEDAN",
    "color": "WHITE",
    "seatCapacity": 4,
    "amenities": ["AIR_CONDITIONING", "MUSIC"]
}

# =========================================================
# ข้อมูลเส้นทางทดสอบ (Test Routes)
# =========================================================

TEST_ROUTE = {
    "startLocation": {
        "lat": 13.7563,
        "lng": 100.5018,
        "name": "กรุงเทพมหานคร"
    },
    "endLocation": {
        "lat": 14.8821,
        "lng": 102.0156,
        "name": "นครราชสีมา"
    },
    "availableSeats": 3,
    "pricePerSeat": 250,
    "conditions": "ไม่สูบบุหรี่ในรถ"
}

# =========================================================
# ข้อมูลการจองทดสอบ (Test Bookings)
# =========================================================

TEST_BOOKING = {
    "numberOfSeats": 1,
    "pickupLocation": {
        "lat": 13.7563,
        "lng": 100.5018,
        "name": "จุดรับ กรุงเทพ"
    },
    "dropoffLocation": {
        "lat": 14.8821,
        "lng": 102.0156,
        "name": "จุดส่ง นครราชสีมา"
    }
}

# =========================================================
# Invalid Test Data (สำหรับ Negative Testing)
# =========================================================

INVALID_USER = {
    "username": "ab",           # สั้นเกินไป (< 6)
    "email": "not-an-email",    # format ผิด
    "password": "short",        # สั้นเกินไป (< 8)
    "firstName": "",
    "lastName": "",
    "phoneNumber": "123",       # สั้นเกินไป (< 10)
    "gender": "INVALID",
    "nationalIdNumber": "123",  # สั้นเกินไป (< 13)
    "nationalIdExpiryDate": "invalid-date"
}

EXPIRED_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InRlc3QiLCJpYXQiOjE2MDAwMDAwMDAsImV4cCI6MTYwMDAwMDAwMX0.invalid"

NONEXISTENT_ID = "clxxxxxxxxxxxxxxxxxxxxxxxxx"
