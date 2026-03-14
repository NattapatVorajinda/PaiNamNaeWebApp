const multer = require('multer');
const ApiError = require('../utils/ApiError');

const storage = multer.memoryStorage();

const ALLOWED_MIMETYPES = [
    'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp',
    'audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/webm',
    'video/mp4', 'video/webm', 'video/quicktime', 'video/x-msvideo',
];

const reviewUpload = multer({
    storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50 MB per file
    fileFilter: (req, file, cb) => {
        if (ALLOWED_MIMETYPES.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new ApiError(400, `ไม่รองรับไฟล์ประเภท ${file.mimetype} — รองรับเฉพาะรูปภาพ, เสียง, หรือวิดีโอ`), false);
        }
    },
});

module.exports = reviewUpload;
