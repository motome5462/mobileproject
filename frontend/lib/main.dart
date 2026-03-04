import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    ));

// -----------------------------------------------------------------------------
// 1. หน้า Login
// -----------------------------------------------------------------------------
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
        // เมื่อสำเร็จ ให้เปลี่ยนหน้าไป HomePage และส่งข้อมูล User ไปด้วย
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: data['user'])),
        );
      } else {
        _msg("พลาด", data['message']);
      }
    } catch (e) {
      _msg("Error", "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้");
    }
  }

  void _msg(String t, String m) => showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text(t),
            content: Text(m),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ตกลง"))
            ],
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.login_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 10),
              const Text("เข้าสู่ระบบ", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _input(_user, "Username", icon: Icons.person_outline),
              _input(_pass, "Password", obscure: true, icon: Icons.lock_outline),
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

// -----------------------------------------------------------------------------
// 2. หน้า Register
// -----------------------------------------------------------------------------
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(content: Text(msg), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ตกลง"))
      ]),
    );
  }

  Future<void> _register() async {
    if (_u.text.isEmpty || _p.text.isEmpty || _f.text.isEmpty || _l.text.isEmpty || _ph.text.isEmpty || _e.text.isEmpty) {
      _showMsg("กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }
    if (_p.text != _cp.text) {
      _showMsg("รหัสผ่านไม่ตรงกัน");
      return;
    }
    final namePattern = RegExp(r'^[a-zA-Zก-ฮะ-์\s]+$');
    if (!namePattern.hasMatch(_f.text) || !namePattern.hasMatch(_l.text)) {
      _showMsg("ชื่อและนามสกุลห้ามใส่ตัวเลขหรืออักขระพิเศษ");
      return;
    }
    if (int.tryParse(_ph.text) == null) {
      _showMsg("เบอร์โทรศัพท์ต้องเป็นตัวเลขเท่านั้น");
      return;
    }
    if (!_e.text.contains('@')) {
      _showMsg("รูปแบบอีเมลไม่ถูกต้อง (ต้องมี @)");
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _u.text, "password": _p.text, "firstName": _f.text,
          "lastName": _l.text, "phone": _ph.text, "email": _e.text, "image": _base64Image
        }),
      );
      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        final data = jsonDecode(res.body);
        _showMsg(data['message'] ?? "การสมัครสมาชิกล้มเหลว");
      }
    } catch (e) {
      _showMsg("เกิดข้อผิดพลาดในการเชื่อมต่อ");
    }
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
                radius: 55,
                backgroundColor: Colors.blue[50],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.add_a_photo_outlined, size: 35, color: Colors.blue) : null),
          ),
          const SizedBox(height: 25),
          _input(_u, "Username", icon: Icons.account_circle_outlined),
          _input(_p, "Password", obscure: true, icon: Icons.vpn_key_outlined),
          _input(_cp, "Confirm Password", obscure: true, icon: Icons.check_circle_outline),
          _input(_f, "ชื่อ", icon: Icons.badge_outlined),
          _input(_l, "นามสกุล", icon: Icons.badge_outlined),
          _input(_ph, "เบอร์โทร", keyboard: TextInputType.phone, icon: Icons.phone_android_outlined),
          _input(_e, "อีเมล", keyboard: TextInputType.emailAddress, icon: Icons.mail_outline),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text("ยืนยันการสมัคร", style: TextStyle(fontSize: 18))),
          )
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. หน้าแรก (HomePage) หลัง Login สำเร็จ
// -----------------------------------------------------------------------------
class HomePage extends StatelessWidget {
  final Map userData; 
  const HomePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("หน้าแรก"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Container(
                  padding: const EdgeInsets.all(20),
                  height: 250,
                  child: Column(
                    children: [
                      const Text("ข้อมูลโปรไฟล์", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text("ชื่อ: ${userData['first_name']} ${userData['last_name']}", style: const TextStyle(fontSize: 18)),
                      Text("อีเมล: ${userData['email']}"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage())),
                        child: const Text("ออกจากระบบ"),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (userData['image'] != null && userData['image'] != "")
                    ? MemoryImage(base64Decode(userData['image']))
                    : null,
                child: (userData['image'] == null || userData['image'] == "")
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              accountName: Text("${userData['first_name']} ${userData['last_name']}"),
              accountEmail: Text("${userData['email']}"),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('หน้าหลัก'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('ตั้งค่า'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('ออกจากระบบ'),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text("ยินดีต้อนรับเข้าสู่ระบบ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${userData['first_name']} ${userData['last_name']}", style: const TextStyle(fontSize: 18, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. ฟังก์ชันตัวช่วย (Helper Function)
// -----------------------------------------------------------------------------
Widget _input(TextEditingController controller, String label, {bool obscure = false, TextInputType keyboard = TextInputType.text, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  );
}