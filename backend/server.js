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
    password: '1234', // รหัสผ่าน MySQL ของคุณ
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

// เพิ่ม API สำหรับ Register
app.post('/register', (req, res) => {
    const { username, password, firstName, lastName, phone, email, image } = req.body;

    // ตรวจสอบว่ามี User ซ้ำหรือไม่
    const checkUser = "SELECT * FROM users WHERE username = ?";
    db.query(checkUser, [username], (err, results) => {
        if (results.length > 0) {
            return res.status(400).json({ message: "Username นี้ถูกใช้ไปแล้ว" });
        }
        // เช็คชื่อ-นามสกุลห้ามมีตัวเลข
    const namePattern = /^[a-zA-Zก-ฮะ-์\s]+$/;
    if (!namePattern.test(firstName) || !namePattern.test(lastName)) {
        return res.status(400).json({ message: "ชื่อและนามสกุลห้ามมีตัวเลข" });
    }

    // เช็คเบอร์โทรต้องเป็นตัวเลข
    if (isNaN(phone)) {
        return res.status(400).json({ message: "เบอร์โทรต้องเป็นตัวเลขเท่านั้น" });
    }

    // เช็คอีเมลมี @
    if (!email.includes('@')) {
        return res.status(400).json({ message: "อีเมลไม่ถูกต้อง" });
    }

        // เพิ่มข้อมูลลงฐานข้อมูล (อย่าลืมสร้างคอลัมน์ใน MySQL ให้ครบนะครับ)
        const query = "INSERT INTO users (username, password, first_name, last_name, phone, email, image) VALUES (?, ?, ?, ?, ?, ?, ?)";
        db.query(query, [username, password, firstName, lastName, phone, email, image || null], (err, result) => {
            if (err) {
                console.error(err);
                return res.status(500).json({ message: "เกิดข้อผิดพลาดในการบันทึกข้อมูล" });
            }
            res.status(200).json({ message: "สมัครสมาชิกสำเร็จ!" });
        });
    });
});

// 3. เริ่มรัน Server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server กำลังรันที่ http://localhost:${PORT}`);
});