import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final Map userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List> getRooms() async {
    final res = await http.get(Uri.parse('http://10.0.2.2:3000/rooms-status'));
    return jsonDecode(res.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการห้องประชุม"),
        actions: [IconButton(icon: const Icon(Icons.account_circle), onPressed: () => _logout(context))],
      ),
      drawer: Drawer(
        child: ListView(children: [
          UserAccountsDrawerHeader(
            accountName: Text("${widget.userData['first_name']} ${widget.userData['last_name']}"),
            accountEmail: Text("${widget.userData['email']}"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: (widget.userData['image'] != "") ? MemoryImage(base64Decode(widget.userData['image'])) : null,
              child: (widget.userData['image'] == "") ? const Icon(Icons.person) : null,
            ),
          ),
          ListTile(leading: const Icon(Icons.logout), title: const Text("Logout"), onTap: () => _logout(context))
        ]),
      ),
      body: FutureBuilder<List>(
        future: getRooms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var room = snapshot.data![index];
              bool isBusy = room['is_busy'] > 0;
              return Card(
                child: ListTile(
                  leading: Icon(Icons.meeting_room, color: isBusy ? Colors.red : Colors.green),
                  title: Text(room['room_name']),
                  subtitle: Text("Status: ${isBusy ? 'ไม่ว่าง' : 'ว่าง'}"),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()));
  }
}