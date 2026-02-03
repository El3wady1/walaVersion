import 'package:firebase_messaging/firebase_messaging.dart';

Future  getTokenDevices() async {
  try {
    var token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    return token;
  } catch (e) {
    print('Error getting token: $e');
    return null;
  }
}
