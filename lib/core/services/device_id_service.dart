import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const _key = 'device_id';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_key);
    if (cached != null && cached.isNotEmpty) return cached;

    final id = await _fetchDeviceId();
    await prefs.setString(_key, id);
    return id;
  }

  static Future<String> _fetchDeviceId() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return android.id;
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return ios.identifierForVendor ?? _fallback();
      }
    } catch (_) {}
    return _fallback();
  }

  static String _fallback() =>
      'device_${DateTime.now().millisecondsSinceEpoch}';
}
