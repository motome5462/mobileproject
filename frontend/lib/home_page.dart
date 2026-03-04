import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final Map userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List> getRooms() async {
    try {
      final res = await http.get(Uri.parse('${Config.baseUrl}/rooms-status'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงค่ามาพักไว้และเช็ค Null เบื้องต้น
    final String firstName = widget.userData['first_name']?.toString() ?? 'User';
    final String lastName = widget.userData['last_name']?.toString() ?? '';
    final String email = widget.userData['email']?.toString() ?? '-';
    final dynamic imageBase64 = widget.userData['image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการห้องประชุม"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              // แก้ไข: ใช้ ?? เพื่อป้องกันค่าว่าง
              accountName: Text("$firstName $lastName"),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                // แก้ไข: เช็คเงื่อนไขรูปภาพอย่างละเอียด
                backgroundImage: (imageBase64 != null && imageBase64.toString().isNotEmpty)
                    ? MemoryImage(base64Decode(imageBase64.toString()))
                    : null,
                child: (imageBase64 == null || imageBase64.toString().isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.blue)
                    : null,
              ),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('หน้าหลัก'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("ออกจากระบบ"),
              onTap: () => _logout(context),
            )
          ],
        ),
      ),
      body: FutureBuilder<List>(
        future: getRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ไม่มีข้อมูลห้องประชุม"));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var room = snapshot.data![index];
              // แก้ไข: เช็คค่า is_busy ป้องกัน null
              int busyCount = room['is_busy'] ?? 0;
              bool isBusy = busyCount > 0;
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.meeting_room, 
                    color: isBusy ? Colors.red : Colors.green,
                    size: 35,
                  ),
                  title: Text(
                    room['room_name']?.toString() ?? 'ไม่ระบุชื่อห้อง',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("ความจุ: ${room['capacity'] ?? '-'} คน"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isBusy ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      isBusy ? 'ไม่ว่าง' : 'ว่าง',
                      style: TextStyle(
                        color: isBusy ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (c) => const LoginPage()),
    );
  }
}