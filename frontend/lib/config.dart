import 'package:flutter/foundation.dart';

class Config {
  // ฟังก์ชันเช็ค Platform และส่ง URL ที่ถูกต้องกลับไป
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000'; // สำหรับรันบน Web Browser
    } else {
      return 'http://10.0.2.2:3000';   // สำหรับรันบน Android Emulator
    }
  }
}