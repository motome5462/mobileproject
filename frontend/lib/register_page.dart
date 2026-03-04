import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'main.dart'; // เพื่อใช้ buildInput

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

  void _showMsg(String msg) {
    showDialog(context: context, builder: (ctx) => AlertDialog(content: Text(msg), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ตกลง"))
    ]));
  }

  Future<void> _register() async {
    if (_u.text.isEmpty || _p.text.isEmpty || _f.text.isEmpty || _ph.text.isEmpty) {
      _showMsg("กรุณากรอกข้อมูลให้ครบถ้วน"); return;
    }
    if (_p.text != _cp.text) { _showMsg("รหัสผ่านไม่ตรงกัน"); return; }
    
    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _u.text, "password": _p.text, "firstName": _f.text,
          "lastName": _l.text, "phone": _ph.text, "email": _e.text, "image": _base64Image
        }),
      );
      if (res.statusCode == 200) Navigator.pop(context);
      else _showMsg(jsonDecode(res.body)['message'] ?? "ล้มเหลว");
    } catch (e) { _showMsg("Error เชื่อมต่อไม่ได้"); }
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
            child: CircleAvatar(
                radius: 55, backgroundColor: Colors.blue[50],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.add_a_photo, size: 35, color: Colors.blue) : null),
          ),
          const SizedBox(height: 25),
          buildInput(_u, "Username", icon: Icons.account_circle_outlined),
          buildInput(_p, "Password", obscure: true, icon: Icons.vpn_key_outlined),
          buildInput(_cp, "Confirm Password", obscure: true, icon: Icons.check_circle_outline),
          buildInput(_f, "ชื่อ", icon: Icons.badge_outlined),
          buildInput(_l, "นามสกุล", icon: Icons.badge_outlined),
          buildInput(_ph, "เบอร์โทร", keyboard: TextInputType.phone, icon: Icons.phone_android_outlined),
          buildInput(_e, "อีเมล", keyboard: TextInputType.emailAddress, icon: Icons.mail_outline),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 55,
            child: ElevatedButton(onPressed: _register, child: const Text("ยืนยันการสมัคร")),
          )
        ]),
      ),
    );
  }
}