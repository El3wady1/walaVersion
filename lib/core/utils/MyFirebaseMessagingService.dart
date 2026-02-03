// lib/firebase/MyFirebaseMessagingService.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyFirebaseMessagingService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> setup() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // إعدادات التهيئة لنظام Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات التهيئة العامة
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // تهيئة إعدادات الإشعارات مع المعلمات الصحيحة
    await flutterLocalNotificationsPlugin.initialize(
     settings:  initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // معالجة النقر على الإشعار
        if (details.payload != null) {
          print('تم النقر على الإشعار: ${details.payload}');
        }
      },
    );

    // معالجة الإشعارات في الواجهة الأمامية
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // معالجة النقر على الإشعار عند فتح التطبيق
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // عرض الإشعار مع ID فريد
    await flutterLocalNotificationsPlugin.show(
    title:   message.notification?.title ?? 'إشعار جديد',
     body:  message.notification?.body ?? 'لديك إشعار جديد',
     notificationDetails:  platformChannelSpecifics,
      payload: message.data.toString(), id: 0,
    );
  }

  static void _handleNotificationClick(RemoteMessage message) {
    // معالجة النقر على الإشعار
    print('تم النقر على إشعار: ${message.notification?.title}');
    
    // يمكنك إضافة التنقل هنا
    // Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
  }
}