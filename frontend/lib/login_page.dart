import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // เพื่อใช้ buildInput
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _login() async {
    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3000/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": _user.text, "password": _pass.text}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: data['user'])),
        );
      } else {
        _showDialog("พลาด", data['message']);
      }
    } catch (e) {
      _showDialog("Error", "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้");
    }
  }

  void _showDialog(String t, String m) => showDialog(
      context: context,
      builder: (ctx) => AlertDialog(title: Text(t), content: Text(m), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ตกลง"))
      ]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.meeting_room_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 10),
              const Text("ระบบจองห้องประชุม", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              buildInput(_user, "Username", icon: Icons.person_outline),
              buildInput(_pass, "Password", obscure: true, icon: Icons.lock_outline),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text("LOGIN"),
                ),
              ),
              TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterPage())),
                  child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"))
            ]),
          ),
        ),
      ),
    );
  }
}