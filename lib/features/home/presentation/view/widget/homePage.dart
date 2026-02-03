import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:saladafactory/core/Widgets/showsnackbar.dart';
import 'package:saladafactory/core/app_router.dart';
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'package:saladafactory/core/utils/Strings.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/assets.dart';
import 'package:saladafactory/core/utils/localls.dart';
import 'package:saladafactory/features/compilations/presentation/view/compilationsView.dart';
import 'package:saladafactory/features/home/data/repo/ReturnLastloginRepo.dart';
import 'package:saladafactory/features/home/data/services/getDailyPandSexist.dart';
import 'package:saladafactory/features/home/presentation/view/widget/bannnerHome.dart';
import 'package:saladafactory/features/home/presentation/view/widget/cardhome.dart';
import 'package:saladafactory/features/login/presentation/view/loginView.dart';
import 'package:saladafactory/features/orderProduction/data/services/active_30minOrderProductionServices.dart';
import 'package:saladafactory/features/orderSupply/data/services/active_30minOrderSupplyServices.dart';
import 'package:saladafactory/features/production/data/services/getnumberofBranchsSPOrder.dart';
import 'package:saladafactory/features/recive/presentation/view/reciveView.dart';
import 'package:saladafactory/features/scanBarCode/presentation/view/scanbarCodeView.dart';
import 'package:saladafactory/features/send/presentation/view/sendView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../../core/utils/getLangState.dart';
import '../../../../../core/utils/localNotificationServices.dart';
import '../../../../managWala/presntation/view/managewalaaview.dart';
import '../../../../orderProduction/presentation/view/orderProduction.dart';
import '../../../../orderSupply/presentation/view/widget/orderSupplyBody.dart';
import '../../../../out/presentation/view/widget/outBodyView.dart';
import '../../../../production/presentation/view/productionView.dart';
import 'package:saladafactory/features/compilations/presentation/view/widget/allWasted.dart';

import '../../../../rezo/presentation/view/widget/allrezoCasher.dart';
import '../../../../rezo/presentation/view/widget/rezoBodyView.dart';
import '../../../../rezo/presentation/view/widget/rezoPhoto.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isloading = false;

  Map<String, dynamic>? userData;
  final String _userDataKey = 'cached_user_data';
  var valueSP;
  Timer? _refreshTimer;
  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  var numSP;
  @override
  void initState() {
    super.initState();
    // _init();
    _initConnectivity();
    _startConnectivityListener();
    loadUserData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      loadUserData();
    });
  }

  // void _init() async {
  //   await NotificationService.init();
  // }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  _startConnectivityListener() {
    StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

    _startConnectivityListener() {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) {
        final newOnlineStatus = results.any(
          (r) => r != ConnectivityResult.none,
        );

        if (newOnlineStatus != _isOnline) {
          setState(() {
            _isOnline = newOnlineStatus;
          });

          // إظهار رسالة عند تغيير حالة الاتصال
          if (newOnlineStatus) {
            showTrueSnackBar(
              context: context,
              message: "تم الاتصال بالإنترنت".tr(),
              icon: Icons.wifi,
            );
          } else {
            showfalseSnackBar(
              context: context,
              message: "لا يوجد اتصال بالإنترنت".tr(),
              icon: Icons.wifi_off,
            );
          }
        }
      });
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var x = await getDailyProductionAndSupplyExist();

    numSP = x;
    if (_isOnline) {
      try {
        final data = await ReturnLastloginRepo.featchData();
        await prefs.setString(_userDataKey, jsonEncode(data));
        if (mounted) {
          setState(() {
            userData = data;
          });
        }
      } catch (e) {
        // في حالة الخطأ، استخدام البيانات المخزنة محلياً
        final cached = prefs.getString(_userDataKey);
        if (cached != null && mounted) {
          setState(() {
            userData = jsonDecode(cached);
          });
        }
      }
    } else {
      // لا يوجد اتصال، استخدام البيانات المخزنة محلياً فقط
      final cached = prefs.getString(_userDataKey);
      if (cached != null && mounted) {
        setState(() {
          userData = jsonDecode(cached);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final userName = userData?["name"] ?? "مستخدم";
    final canAddProduct = userData?["canAddProduct"] ?? false;
    final canRemoveProduct = userData?["canRemoveProduct"] ?? false;
    final canProduction = userData?["canProduction"] ?? false;
    final canOrderProduction = userData?["canOrderProduction"] ?? false;
    final canReceive = userData?["canReceive"] ?? false;
    final canSend = userData?["canSend"] ?? false;
    final canSupply = userData?["canSupply"] ?? false;
    final canDamaged = userData?["canDamaged"] ?? false;
    final canEditLastSupply = userData?["canEditLastSupply"] ?? false;
    final canEditLastOrderProduction =
        userData?["canEditLastOrderProduction"] ?? false;
    final canShowTawalf = userData?["canShowTawalf"] ?? false;
    final canaddRezoCahser = userData?["canaddRezoCahser"] ?? false;
    final canshowCahserRezoPhoto = userData?["canshowCahserRezoPhoto"] ?? false;
    final canshowRezoCahser = userData?["canshowRezoCahser"] ?? false;
    final canshowManageWalaa = userData?["canshowManageWalaa"] ?? false;
    const Color primaryDark = Color(0xFF74826A);
    const Color accent = Color(0xFFEDBE2C);
    const Color neutral = Color(0xFFCDBCA2);
    const Color background = Color(0xFFF3F4EF);
    return ModalProgressHUD(
      inAsyncCall: isloading,
      color: Colors.black,
      opacity: 0.6,
      progressIndicator: Loadingwidget(),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          leading: InkWell(
            onTap: () async {
              var langState = LocallizationHelper.get(context);
              print(langState);
              //   await NotificationService.init();

              // await NotificationService.showNotification(
              //   title: "مكافات سلطة فاكتوري".tr(),
              //   body: "تم اضافه 200 نقطه !",
              // );
            },
            child: Icon(Icons.notifications, color: Colors.amber.shade800),
          ),

          automaticallyImplyLeading: false,
          backgroundColor: background,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  AssetIcons.logo,
                  width: 28,
                  height: 28,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                Strings.appName.tr(),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            // مؤشر حالة الاتصال
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                color: _isOnline ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج'.tr(),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                bool useBiometric = prefs.getBool('useBiometric') ?? false;
                await prefs.clear();
                await FirebaseMessaging.instance.deleteToken();

                await prefs.setBool('useBiometric', useBiometric);

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Loginview()),
                  );
                  showTrueSnackBar(
                    context: context,
                    message: "تم تسجيل الخروج".tr(),
                    icon: Icons.logout,
                  );
                }
              },
            ),
          ],
        ),
        body: !_isOnline
            ? Container(
                child: Center(
                  child: Text(
                    "لا يوجد اتصال بالإنترنت".tr(),
                    style: GoogleFonts.cairo(),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isOnline) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "لا يوجد اتصال بالإنترنت".tr(),
                                style: GoogleFonts.cairo(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    Center(
                      child: Text(
                        "الرئيسية".tr(),
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Bannnerhome(),
                    SizedBox(height: height * 0.02),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: width < 600 ? 4 : 4,
                        childAspectRatio: 0.65,
                        mainAxisSpacing: width * 0.01,
                        crossAxisSpacing: width * 0.01,
                        children: [
                          if (canAddProduct)
                            Cardhome(
                              icon: Icons.add_box,
                              title: 'إدخال صنف'.tr(),
                              color: Colors.green.shade700,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(
                                  context,
                                  ScanbarcodeInview(mainProduct: ""),
                                );
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canRemoveProduct)
                            Cardhome(
                              icon: Icons.indeterminate_check_box,
                              title: 'إخراج صنف'.tr(),
                              color: Colors.red.shade700,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, Outbodyview());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canReceive)
                            Cardhome(
                              icon: Icons.inventory,
                              title: 'استلام'.tr(),
                              color: Colors.blue.shade700,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }

                                Routting.push(context, Reciveview());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canSend)
                            Cardhome(
                              icon: Icons.send_and_archive_outlined,
                              title: 'ارسال'.tr(),
                              color: Colors.purple.shade700,
                              onTap: () async {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                var orderSdata;
                                var orderPdata;
                                setState(() {
                                  isloading = true;
                                });
                                await GetnumberofBranchsSPOrder(
                                  endpointsSorP: Apiendpoints
                                      .orderProduction
                                      .getOrderPof2Days,
                                ).then((v) => orderPdata = v);
                                await GetnumberofBranchsSPOrder(
                                  endpointsSorP:
                                      Apiendpoints.orderSupply.getOrderSof2Days,
                                ).then((v) => orderSdata = v);
                                setState(() {
                                  isloading = false;
                                });
                                Routting.push(
                                  context,
                                  Sendview(
                                    numberofBranchPRequest: orderPdata ?? 0,
                                    numberofBranchSRequest: orderSdata ?? 0,
                                  ),
                                );
                              },
                              showbadge:
                                  (numSP.toString() == "" ||
                                      numSP.toString() == null ||
                                      numSP.toString() == "0")
                                  ? false
                                  : true,
                              numberofNot: numSP.toString(),
                            ),
                          if (canSupply)
                            Cardhome(
                              icon: Icons.local_shipping,
                              title: "توريد".tr(),
                              color: Colors.purple.shade700,
                              onTap: () async {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                var usercanedite;
                                await Active30minordersupplyservices.get().then(
                                  (v) => usercanedite = v["data"]?["open"],
                                );
                                Routting.push(
                                  context,
                                  OrderSupplyBody(
                                    canedit: canEditLastSupply,
                                    usercanedite: usercanedite,
                                  ),
                                );
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canOrderProduction)
                            Cardhome(
                              icon: Icons.receipt_long,
                              title: "طلب إنتاج".tr(),
                              color: Colors.orange.shade700,
                              onTap: () async {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                var usercanedite;
                                await Active30minorderproductionservices.get()
                                    .then(
                                      (v) => usercanedite = v["data"]?["open"],
                                    );
                                print(usercanedite);
                                if (usercanedite != null) {
                                  Routting.push(
                                    context,
                                    Orderproduction(
                                      canedit: canEditLastOrderProduction,
                                      usercanedite: usercanedite,
                                    ),
                                  );
                                } else {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.network_wifi_1_bar,
                                  );
                                }
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canProduction)
                            Cardhome(
                              icon: Icons.precision_manufacturing,
                              title: "إنتاج".tr(),
                              numberofNot: numSP.toString(),
                              color: Colors.teal.shade700,
                              onTap: () async {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                var role;
                                await Localls.getrole().then(
                                  (value) => role = value,
                                );
                                print(role);
                                var orderSdata;
                                var orderPdata;
                                setState(() {
                                  isloading = true;
                                });
                                await GetnumberofBranchsSPOrder(
                                  endpointsSorP: Apiendpoints
                                      .orderProduction
                                      .getOrderPof2Days,
                                ).then((v) => orderPdata = v);
                                await GetnumberofBranchsSPOrder(
                                  endpointsSorP:
                                      Apiendpoints.orderSupply.getOrderSof2Days,
                                ).then((v) => orderSdata = v);
                                setState(() {
                                  isloading = false;
                                });
                                Routting.push(
                                  context,
                                  Productionview(
                                    role: role,
                                    numberofBranchPRequest: orderPdata ?? "",
                                    numberofBranchSRequest: orderSdata ?? "",
                                  ),
                                );
                              },
                              showbadge:
                                  (numSP.toString() == "" ||
                                      numSP.toString() == null ||
                                      numSP.toString() == "0")
                                  ? false
                                  : true,
                            ),
                          if (canDamaged)
                            Cardhome(
                              icon: Icons.delete_forever,
                              title: "التوالف".tr(),
                              color: Colors.grey.shade800,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, Compilationsview());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canShowTawalf)
                            Cardhome(
                              icon: Icons.cleaning_services,
                              title: "صورالتوالف".tr(),
                              color: Colors.grey.shade800,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, Allwasted());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canaddRezoCahser)
                            Cardhome(
                              icon: Icons.calculate,
                              title: "كاشير ريزو".tr(),
                              color: Colors.grey.shade800,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, Rezobodyview());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                          if (canshowCahserRezoPhoto)
                            Cardhome(
                              icon: Icons.photo,
                              title: "صور كاشير ريزو".tr(),
                              color: Colors.grey.shade800,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, RezophotoMain());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),

                          if (canshowRezoCahser)
                            Cardhome(
                              icon: Icons.where_to_vote,
                              title: "تقرير كاشير ريزو".tr(),
                              color: Colors.red.shade800,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, RezoallsumBody());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),

                          if (canshowManageWalaa)
                            Cardhome(
                              icon: Icons.wallet_giftcard_rounded,
                              title: AppbarStrings.managewalaa.tr(),
                              color: Colors.red.shade800,
                              onTap: () {
                                if (!_isOnline) {
                                  showfalseSnackBar(
                                    context: context,
                                    message: "لا يوجد اتصال بالإنترنت".tr(),
                                    icon: Icons.wifi_off,
                                  );
                                  return;
                                }
                                Routting.push(context, Managewalaaview());
                              },
                              showbadge: false,
                              numberofNot: '',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
