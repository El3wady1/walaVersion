// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saladafactory/core/utils/assets.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

// static Future<void> init() async {

//   if (Platform.isAndroid) {
//     final status = await Permission.notification.status;
//     if (!status.isGranted) {
//       await Permission.notification.request();
//     }
//   }

//   const androidInit =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   const iosInit = DarwinInitializationSettings(
//     requestAlertPermission: true,
//     requestBadgePermission: true,
//     requestSoundPermission: true,
//   );

//   const initSettings = InitializationSettings(
//     android: androidInit,
//     iOS: iosInit,
//   );

//   await _notificationsPlugin.initialize(
//     settings: initSettings,
//     onDidReceiveNotificationResponse: (response) {
//       debugPrint('Tapped notification');
//     },
//   );
// }


//   static Future<String> _copyAssetToTemp(String assetPath, String filename) async {
//     final byteData = await rootBundle.load(assetPath);
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$filename');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//     return file.path;
//   }

//   static Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     if (Platform.isAndroid) {
//       final imagePath = await _copyAssetToTemp(AssetIcons.logo, 'ic_launcher.png');
//       final bigPictureStyle = BigPictureStyleInformation(
//         FilePathAndroidBitmap(imagePath),
//         largeIcon: FilePathAndroidBitmap(imagePath),
//         contentTitle: title,
//         summaryText: body,
//         hideExpandedLargeIcon: false,
//       );

//    final androidDetails = AndroidNotificationDetails(
//   'main_channel_id',
//   'Main Channel',
//   channelDescription: 'App notifications',
//   importance: Importance.high,
//   priority: Priority.high,
//   playSound: true,

//   enableVibration: true,
// );


//       final notificationDetails = NotificationDetails(android: androidDetails);
//  final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       await _notificationsPlugin.show(
//         id: notificationId,
//         title: title,
//         body: body,
//         notificationDetails: notificationDetails,
//       );
//     } else if (Platform.isIOS) {

//       final imagePath = await _copyAssetToTemp(AssetIcons.logo, 'opreationLogo.png');

      
//       final iosAttachment = DarwinNotificationAttachment(imagePath);

//       final iosDetails = DarwinNotificationDetails(
//         attachments: [iosAttachment],
//       );

//       final notificationDetails = NotificationDetails(iOS: iosDetails);
//  final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       await _notificationsPlugin.show(
//         id: notificationId*2,
//         title: title,
//         body: body,
//         notificationDetails: notificationDetails,
//       );
//     }
//   }
// }
