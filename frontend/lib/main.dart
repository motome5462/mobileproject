import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false));

// --- หน้า Login ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _login() async {
    final res = await http.post(
      Uri.parse('http://10.0.2.2:3000/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": _user.text, "password": _pass.text}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      _msg("สำเร็จ", "ยินดีต้อนรับ ${data['user']['first_name']}");
    } else {
      _msg("พลาด", data['message']);
    }
  }

  void _msg(String t, String m) => showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t), content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("เข้าสู่ระบบ", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _user, decoration: const InputDecoration(labelText: "Username")),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _login, child: const Text("Login")),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterPage())), 
                     child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"))
        ]),
      ),
    );
  }
}

// --- หน้า Register ---
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _u = TextEditingController(), _p = TextEditingController(), _cp = TextEditingController();
  final _f = TextEditingController(), _l = TextEditingController(), _ph = TextEditingController(), _e = TextEditingController();
  File? _image;
  String _base64Image = "";

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (img != null) {
      setState(() {
        _image = File(img.path);
        _base64Image = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  Future<void> _register() async {
    if (_p.text != _cp.text) return; // เช็ครหัสผ่านตรงกัน
    final res = await http.post(
      Uri.parse('http://10.0.2.2:3000/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _u.text, "password": _p.text, "firstName": _f.text,
        "lastName": _l.text, "phone": _ph.text, "email": _e.text, "image": _base64Image
      }),
    );
    if (res.statusCode == 200) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สมัครสมาชิก")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(radius: 50, backgroundImage: _image != null ? FileImage(_image!) : null, child: _image == null ? const Icon(Icons.camera_alt) : null),
          ),
          TextField(controller: _u, decoration: const InputDecoration(labelText: "Username")),
          TextField(controller: _p, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          TextField(controller: _cp, decoration: const InputDecoration(labelText: "Confirm Password"), obscureText: true),
          TextField(controller: _f, decoration: const InputDecoration(labelText: "ชื่อ")),
          TextField(controller: _l, decoration: const InputDecoration(labelText: "นามสกุล")),
          TextField(controller: _ph, decoration: const InputDecoration(labelText: "เบอร์โทร")),
          TextField(controller: _e, decoration: const InputDecoration(labelText: "อีเมล")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _register, child: const Text("ยืนยันการสมัคร"))
        ]),
      ),
    );
  }
}