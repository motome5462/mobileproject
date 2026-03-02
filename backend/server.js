const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// 1. ตั้งค่าการเชื่อมต่อ MySQL (แก้ตามเครื่องของคุณ)
const db = mysql.createConnection({
    host: 'localhost',      // หรือ 127.0.0.1
    user: 'root',           // User ของ MySQL Workbench
    password: 'your_password', // รหัสผ่าน MySQL ของคุณ
    database: 'mobile_db'   // ชื่อ Database ที่สร้างไว้
});

db.connect((err) => {
    if (err) throw err;
    console.log('เชื่อมต่อ MySQL สำเร็จแล้ว!');
});

// 2. สร้าง API สำหรับ Login
app.post('/login', (req, res) => {
    const { username, password } = req.body;

    const query = "SELECT * FROM users WHERE username = ? AND password = ?";
    db.query(query, [username, password], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "เกิดข้อผิดพลาดในระบบ" });
        }

        if (results.length > 0) {
            res.status(200).json({ message: "Login Success", user: results[0] });
        } else {
            res.status(401).json({ message: "Username หรือ Password ไม่ถูกต้อง" });
        }
    });
});

// 3. เริ่มรัน Server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server กำลังรันที่ http://localhost:${PORT}`);
});