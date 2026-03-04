import 'package:flutter/material.dart';
import 'login_page.dart';

void main() => runApp(const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    ));

// ฟังก์ชัน Helper ส่วนกลางสำหรับหน้าต่างๆ
Widget buildInput(TextEditingController controller, String label,
    {bool obscure = false, TextInputType keyboard = TextInputType.text, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    ),
  );
}