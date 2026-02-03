import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as f;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/app_router.dart';
import 'package:saladafactory/core/utils/cacheHelper.dart';
import 'package:saladafactory/core/utils/dropBoxSearch.dart';
import 'package:saladafactory/core/utils/localNotificationServices.dart';
import 'package:saladafactory/core/utils/localls.dart';
import 'package:saladafactory/features/gifts/presenatation/view/giftView.dart';
import 'package:saladafactory/features/home/presentation/view/widget/homeBodyView.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/redeemHistoryView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'firebase_options.dart';

import 'features/login/presentation/controller/logincubit.dart';
import 'features/login/presentation/view/loginView.dart';
import 'features/splash/presentation/view/widgets/animated_splash.dart';
import 'core/utils/apiEndpoints.dart';
import 'core/utils/Strings.dart';
import 'features/helperApp/UpdateScreenView.dart';
import 'package:intl/date_symbol_data_local.dart';

/// ---------- FlutterLocalNotifications تهيئة ----------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'saladafactory_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        icon: "ic_launcher",
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  await flutterLocalNotificationsPlugin.show(
    id: notificationId,
    title: message.notification?.title ?? 'إشعار جديد',
    body: message.notification?.body ?? 'لديك إشعار جديد',
    notificationDetails: platformChannelSpecifics,
    payload: jsonEncode(message.data),
  );
}

Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // إنشاء القناة
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // يجب أن يكون نفس الـ id عند الإرسال
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max, // ليظهر popup
    playSound: true,
    enableVibration: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('تم النقر على الإشعار: ${response.payload}');
    },
  );
}

// مثال إرسال إشعار
Future<void> showNotification(RemoteMessage message) async {
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'saladafactory_channel', // نفس id القناة
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high, // مهم جدًا لـ Heads-up
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: message.notification?.title ?? 'إشعار جديد',
    body: message.notification?.body ?? 'لديك إشعار جديد',
    notificationDetails: notificationDetails,
    payload: jsonEncode(message.data),
  );
}

/// ---------- BiometricController ----------
class BiometricController {
  static const _prefKey = 'useBiometrics';
  static const _lastActivityKey = 'lastActivity';
  static final BiometricController _instance = BiometricController._internal();
  static BiometricController get instance => _instance;

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(true);
  SharedPreferences? _prefs;
  bool _authInProgress = false;
  Timer? _inactivityTimer;

  BiometricController._internal();

  static Future<void> init() => _instance._init();

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs?.getBool(_prefKey) ?? false;
    enabled.value = saved;

    if (!enabled.value) {
      _isAuthenticated.value = true;
    } else {
      final last = lastActivity;
      if (last != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final diff = Duration(milliseconds: now - last);

        if (diff.inSeconds <= Strings.logoutTime) {
          _isAuthenticated.value = true;
        } else {
          _isAuthenticated.value = false;
        }
      } else {
        _isAuthenticated.value = true;
        updateLastActivity();
      }
    }
  }

  Future<void> setEnabled(bool v) async {
    if (enabled.value == v) return;

    enabled.value = v;
    await _prefs?.setBool(_prefKey, v);

    if (!v) {
      _isAuthenticated.value = true;
      _authInProgress = false;
      _stopInactivityTimer();
      try {
        await LocalAuthentication().stopAuthentication();
      } catch (e) {
        debugPrint('Error stopping auth: $e');
      }
    } else {
      _isAuthenticated.value = true;
      _authInProgress = false;
      updateLastActivity();
    }
  }

  Future<void> toggle() async => setEnabled(!enabled.value);

  bool get isAuthenticated => _isAuthenticated.value;

  void setAuthenticated(bool value) {
    _isAuthenticated.value = value;
    if (value) {
      updateLastActivity();
    }
  }

  ValueNotifier<bool> get authNotifier => _isAuthenticated;

  void setAuthInProgress(bool value) {
    _authInProgress = value;
  }

  bool get authInProgress => _authInProgress;

  Future<void> updateLastActivity() async {
    await _prefs?.setInt(
      _lastActivityKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    if (enabled.value) {
      _startInactivityTimer();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(milliseconds: Strings.logoutTime), () {
      if (enabled.value) {
        _isAuthenticated.value = false;
        debugPrint('انتهت 30 دقيقة من السكون - البصمة مطلوبة');
      }
    });
  }

  void _stopInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  int? get lastActivity => _prefs?.getInt(_lastActivityKey);

  bool get isSessionExpired {
    if (!enabled.value) return true;

    final last = lastActivity;
    if (last == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = Duration(milliseconds: now - last);
    return diff.inSeconds > Strings.logoutTime;
  }

  Future<void> logout() async {
    _isAuthenticated.value = false;
    _authInProgress = false;
    _stopInactivityTimer();
    await _prefs?.clear();
  }

  bool get shouldRequestBiometric {
    if (!enabled.value) return false;

    final last = lastActivity;
    if (last == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - last;
    return diff > Strings.logoutTime;
  }
}

/// ---------- SessionManager ----------
class SessionManager {
  static Timer? _sessionTimer;
  static final List<VoidCallback> _onTimeoutCallbacks = [];

  static void addTimeoutListener(VoidCallback callback) {
    _onTimeoutCallbacks.add(callback);
  }

  static void removeTimeoutListener(VoidCallback callback) {
    _onTimeoutCallbacks.remove(callback);
  }

  static void startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(Duration(milliseconds: Strings.logoutTime), () {
      for (final callback in _onTimeoutCallbacks) {
        callback();
      }
    });
  }

  static void resetTimer() {
    startSessionTimer();
  }

  static void stopTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  static void dispose() {
    stopTimer();
    _onTimeoutCallbacks.clear();
  }
}

/// ---------- UpdateChecker ----------
class UpdateChecker {
  static Timer? _timer;
  static bool _isUpdating = false;
  static ValueChanged<bool>? _onUpdateStatusChanged;

  static void start({required ValueChanged<bool> onUpdateStatusChanged}) {
    _onUpdateStatusChanged = onUpdateStatusChanged;
    _timer = Timer.periodic(Duration(seconds: 2), (_) async {
      await _checkAppState();
    });
  }

  static Future<void> _checkAppState() async {
    try {
      final response = await http.get(
        Uri.parse(Apiendpoints.baseUrl + Apiendpoints.settings.appstate),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool updating = !(data["data"]["open"] ?? true);

        if (updating != _isUpdating) {
          _isUpdating = updating;
          _onUpdateStatusChanged?.call(_isUpdating);
        }
      }
    } catch (e) {
      debugPrint("Update check error: $e");
    }
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static bool get isUpdating => _isUpdating;
}

/// ---------- main ----------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('ar', null);
  tz.initializeTimeZones();
  await BiometricController.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupFlutterNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  bool shouldLogout =
      BiometricController.instance.isSessionExpired &&
      !BiometricController.instance.enabled.value;

  if (shouldLogout) {
    await BiometricController.instance.logout();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: MyApp(shouldLogout: shouldLogout),
    ),
  );
}

/// ---------- MyApp ----------
class MyApp extends StatefulWidget {
  final bool shouldLogout;

  const MyApp({this.shouldLogout = false, Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> _initializeFirebaseMessaging() async {
    try {
      // الاستماع للإشعارات في الواجهة الأمامية
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 رسالة في الواجهة الأمامية: ${message.notification?.title}');
        _showNotification(message);
      });

      // معالجة النقر على الإشعار عندما يكون التطبيق في الخلفية
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('👆 تم النقر على إشعار: ${message.notification?.title}');

        _handleNotificationClick(message);
      });

      // الحصول على FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print("🔑 FCM Token: $fcmToken");

      // طلب إذن الإشعارات
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // تعيين خيارات للإشعارات على iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      print('خطأ في تهيئة Firebase Messaging: $e');
    }
  }

_handleNotificationClick(RemoteMessage message) {
  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(builder: (_) => HomeBodyView(currentIndexNav: 1, currentindexGiftToogle: 1,)),
  );
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: BiometricGateOverlay(
        child: AppContent(shouldLogout: widget.shouldLogout),
      ),
    );
  }
}

/// ---------- BiometricGateOverlay ----------
class BiometricGateOverlay extends StatefulWidget {
  final Widget child;
  const BiometricGateOverlay({required this.child, Key? key}) : super(key: key);

  @override
  _BiometricGateOverlayState createState() => _BiometricGateOverlayState();
}

class _BiometricGateOverlayState extends State<BiometricGateOverlay>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkBiometricOnStart(),
    );
  }

  Future<void> _checkBiometricOnStart() async {
    if (!BiometricController.instance.enabled.value) {
      BiometricController.instance.setAuthenticated(true);
      return;
    }

    if (BiometricController.instance.shouldRequestBiometric) {
      _authenticate();
    } else {
      BiometricController.instance.setAuthenticated(true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (BiometricController.instance.enabled.value) {
        BiometricController.instance.updateLastActivity();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (BiometricController.instance.enabled.value &&
          BiometricController.instance.shouldRequestBiometric &&
          !BiometricController.instance.authInProgress) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    if (BiometricController.instance.isAuthenticated ||
        BiometricController.instance.authInProgress ||
        !BiometricController.instance.enabled.value) {
      return;
    }

    BiometricController.instance.setAuthInProgress(true);

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        BiometricController.instance.setAuthenticated(true);
        BiometricController.instance.setAuthInProgress(false);
        return;
      }
      final bool success = await _auth.authenticate(
        localizedReason: 'سجل الدخول باستخدام البصمة'.tr(),
        biometricOnly: true, // فقط بصمة / Face ID
        persistAcrossBackgrounding: true, // بديل stickyAuth
      );

      if (!mounted) return;

      if (success) {
        BiometricController.instance.setAuthenticated(true);
        BiometricController.instance.setAuthInProgress(false);
        BiometricController.instance.updateLastActivity();
      } else {
        BiometricController.instance.setAuthInProgress(false);
        if (BiometricController.instance.enabled.value) {
          Future.delayed(const Duration(seconds: 5), _authenticate);
        }
      }
    } catch (e) {
      debugPrint('فشل المصادقة: $e');
      BiometricController.instance.setAuthInProgress(false);
      if (BiometricController.instance.enabled.value) {
        Future.delayed(const Duration(seconds: 5), _authenticate);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BiometricController.instance.authNotifier,
      builder: (context, isAuthenticated, _) {
        final showOverlay =
            BiometricController.instance.enabled.value && !isAuthenticated;
        return Scaffold(
          body: Stack(
            textDirection: f.TextDirection.rtl,
            children: [
              widget.child,
              if (showOverlay)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          color: Colors.amber,
                          size: MediaQuery.of(context).size.width * .35,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "البصمة مطلوبة".tr(),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'تم تخطي 30 دقيقة من السكون. يرجى استخدام البصمة للمتابعة'
                              .tr(),
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF74826A), Color(0xFF5A6B54)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF74826A).withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: _authenticate,
                            icon: Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              "ادخال البصمة".tr(),
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// ---------- BiometricSwitch ----------
class BiometricSwitch extends StatefulWidget {
  final String title;
  final String subtitle;
  const BiometricSwitch({
    this.title = 'استخدام البصمة',
    this.subtitle = '',
    Key? key,
  }) : super(key: key);

  @override
  _BiometricSwitchState createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<BiometricSwitch> {
  final ValueNotifier<bool> _notifier = BiometricController.instance.enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifier,
      builder: (context, enabled, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title.tr(),
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.subtitle.isNotEmpty)
                            const SizedBox(height: 4),
                          if (widget.subtitle.isNotEmpty)
                            Text(
                              widget.subtitle.tr(),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Switch(
                      value: enabled,
                      onChanged: (v) async {
                        await BiometricController.instance.setEnabled(v);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              v
                                  ? 'تم تفعيل البصمة ✅'.tr()
                                  : 'تم تعطيل البصمة ❌'.tr(),
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            backgroundColor: v ? Colors.green : Colors.blue,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: enabled ? Colors.green[50] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        enabled
                            ? Icons.fingerprint
                            : Icons.fingerprint_outlined,
                        color: enabled ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          enabled
                              ? 'البصمة مفعلة (بعد 30 دقيقة سكون)'.tr()
                              : 'البصمة معطلة (جلسة 30 دقيقة)'.tr(),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: enabled ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ---------- LoginviewSesss ----------
class LoginviewSesss extends StatefulWidget {
  final bool showSessionExpired;

  const LoginviewSesss({this.showSessionExpired = false, Key? key})
    : super(key: key);

  @override
  _LoginviewSesssState createState() => _LoginviewSesssState();
}

class _LoginviewSesssState extends State<LoginviewSesss> {
  @override
  void initState() {
    super.initState();

    if (widget.showSessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionExpiredDialog();
      });
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("انتهت الجلسة".tr(), style: GoogleFonts.cairo()),
        content: Text(
          "تم انتهاء الجلسة بعد 30 دقيقة من السكون، أعد تسجيل الدخول".tr(),
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("موافق".tr(), style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Loginview());
  }
}

/// ---------- AppContent ----------
class AppContent extends StatefulWidget {
  final bool shouldLogout;

  const AppContent({this.shouldLogout = false, Key? key}) : super(key: key);

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool isUpdating = false;
  String? version;

  Future<String?> fetchVersionDes() async {
    final url = Uri.parse(
      "https://v1110-production.up.railway.app/api/settings/695847665c09b3452ee81766",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("lkklkl" + jsonData['data']['des']);
      version = jsonData['data']['des'];
      return jsonData['data']['des'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _checkVersionFlow() async {
    version = await fetchVersionDes();

    debugPrint("App Version From API: $version");

    if (!mounted || version == null) return;

    if (version != Strings.appVersion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.update, color: Colors.green.shade900),
                  const SizedBox(width: 4),
                  Text(
                    "تحديث مطلوب".tr(),
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ],
              ),
              content: Text(
                "هذا الإصدار من التطبيق قديم.\nيرجى تحديث التطبيق الآن للاستمتاع بأحدث الميزات وتحسينات الأداء."
                    .tr(),
                style: GoogleFonts.cairo(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "لاحقًا".tr(),
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      final Uri playStoreUrl = Uri.parse(
                        "https://play.google.com/store/apps/details?id=com.rzo.operations",
                      );

                      if (await canLaunchUrl(playStoreUrl)) {
                        await launchUrl(
                          playStoreUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                  child: Text(
                    "تحديث الآن".tr(),
                    style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setupSessionManagement();
    _startUpdateChecker();
    _checkVersionFlow();
  }

  void _setupSessionManagement() {
    SessionManager.addTimeoutListener(() async {
      if (mounted && !BiometricController.instance.enabled.value) {
        _showSessionTimeoutDialog();
      }
    });

    if (!BiometricController.instance.enabled.value) {
      SessionManager.startSessionTimer();
    }
  }

  void _showSessionTimeoutDialog() {
    if (BiometricController.instance.enabled.value) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("انتهت الجلسة".tr()),
        content: Text(
          "لقد انتهت جلستك بعد 30 دقيقة من السكون. يرجى تسجيل الدخول مرة أخرى."
              .tr(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLoginWithSessionExpired();
            },
            child: Text("موافق".tr()),
          ),
        ],
      ),
    );
  }

  void _startUpdateChecker() {
    UpdateChecker.start(
      onUpdateStatusChanged: (updating) {
        if (mounted) {
          setState(() {
            isUpdating = updating;
          });
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      BiometricController.instance.updateLastActivity();

      if (!BiometricController.instance.enabled.value) {
        SessionManager.stopTimer();
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (BiometricController.instance.enabled.value) {
        if (BiometricController.instance.shouldRequestBiometric) {
          debugPrint('عودة بعد 30+ دقيقة سكون - البصمة مطلوبة');
        } else {
          BiometricController.instance.updateLastActivity();
        }
      } else {
        final last = BiometricController.instance.lastActivity;
        if (last != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final diff = now - last;

          if (diff > Strings.logoutTime) {
            await BiometricController.instance.logout();
            if (mounted) {
              _navigateToLoginWithSessionExpired();
            }
          } else {
            SessionManager.resetTimer();
          }
        } else {
          SessionManager.startSessionTimer();
          BiometricController.instance.updateLastActivity();
        }
      }
    }
  }

  void _navigateToLoginWithSessionExpired() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginviewSesss(showSessionExpired: true),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    SessionManager.dispose();
    UpdateChecker.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'سلطة فاكتوري'.tr(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (context, child) {
          return Directionality(
            textDirection: context.locale.languageCode == 'ar'
                ? f.TextDirection.rtl
                : f.TextDirection.ltr,
            child: isUpdating
                ? const UpdatingScreen()
                : Listener(
                    onPointerDown: (_) {
                      BiometricController.instance.updateLastActivity();

                      if (!BiometricController.instance.enabled.value) {
                        SessionManager.resetTimer();
                      }
                    },
                    child: child ?? const SizedBox.shrink(),
                  ),
          );
        },
        home: widget.shouldLogout
            ? const LoginviewSesss(showSessionExpired: true)
            : Animated_SplashView(),
      ),
    );
  }
}

//ِ؛××××××××××××××××××××××××××××
//---------------------------------------------------------------
// import 'package:flutter/material.dart' as flutter;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:easy_localization/easy_localization.dart';
// // import 'package:inventory/features/DashBoard/loginDash/loginDashView.dart';
// import 'package:inventory/features/login/presentation/controller/logincubit.dart';
// import 'package:inventory/features/splash/presentation/view/widgets/animated_splash.dart';

// void main() async {
//   flutter.WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//   runApp(
//     EasyLocalization(
//       supportedLocales: [ flutter.Locale('en'),  flutter.Locale('ar')],
//       path: 'assets/lang',
//       fallbackLocale:  flutter.Locale('en'),
//       child: App(),
//     ),
//   );
// }

// class App extends flutter.StatelessWidget {
//   @override
//   flutter.Widget build(flutter.BuildContext context) {
//     return BlocProvider(
//       create: (_) => LoginCubit(),
//       child: flutter.MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'سلطة فاكتوري',
//         localizationsDelegates: context.localizationDelegates,
//         supportedLocales: context.supportedLocales,
//         locale: context.locale,
//         builder: (context, child) {
//           return flutter.Directionality(
//             textDirection: context.locale.languageCode == 'ar'
//                 ? flutter.TextDirection.rtl
//                 : flutter.TextDirection.ltr,
//             child: child!,
//           );
//         },
//         // home: Logindashview(),
//       home: Animated_SplashView(),
//       ),
//       );
//   }
// }

// //Dash
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart'as flutter;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:inventory/features/DashBoard/loginDash/loginDashView.dart';
// import 'package:inventory/features/login/presentation/controller/logincubit.dart';
// import 'package:inventory/features/splash/presentation/view/widgets/animated_splash.dart';
// import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';

// void main() async{
//    flutter.WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//     await initializeDateFormatting('ar', null);

//   runApp(App());
// }

// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => LoginCubit(),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'لوحة تحكم سلطة فاكتوري',
//         builder: (context, child) {
//           return Directionality(
//             textDirection: flutter.TextDirection.ltr, // أو TextDirection.rtl لو عايز العربية
//             child: child!,
//           );
//         },
//         // home: Logindashview(),
//         home: Animated_SplashView(),
//       ),
//     );
//   }
// }

// Future updateDeviceToken({
//   required String deviceToken,
// }) async {
//   final url = Uri.parse('${Apiendpoints.baseUrl}auth/updateDToken');
//   var authToken;
//   await Localls.getToken().then((v) => authToken = v);

//   final response = await http.put(
//     url,
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $authToken',
//     },
//     body: jsonEncode({
//       "deviceToken": deviceToken,
//     }),
//   );

//   if (response.statusCode == 200) {
//     print("✅ Device token updated successfully");
//     print(response.body);
//   } else {
//     print("❌ Failed to update device token");
//     print("Status Code: ${response.statusCode}");
//     print(response.body);
//   }
// }
