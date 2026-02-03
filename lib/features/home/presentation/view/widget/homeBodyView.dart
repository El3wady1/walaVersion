import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';

import 'package:saladafactory/core/app_router.dart';
import 'package:saladafactory/core/utils/assets.dart';

import 'package:saladafactory/core/utils/cacheHelper.dart';
import 'package:saladafactory/core/utils/colors.dart';

import 'package:saladafactory/core/utils/network.dart';
import 'package:saladafactory/features/drawer/presentation/view/widget/drawerBodyView.dart';

import 'package:saladafactory/features/home/presentation/view/widget/homePage.dart';

import 'package:saladafactory/features/in/data/services/AddnewProductServices.dart';

import 'package:saladafactory/features/in/data/services/addTrancWhenNewServices.dart';

import 'package:saladafactory/features/in/data/services/makeINTracwhenaddServices.dart';
import 'package:saladafactory/features/in/data/services/makeINTransaction.dart';
import 'package:saladafactory/features/login/presentation/view/widget/settingstartView.dart';

import 'package:saladafactory/features/out/data/services/makeOUTTransaction.dart';

import 'package:saladafactory/features/out/presentation/view/widget/oflineOutTransactionsScreen.dart';

import 'package:saladafactory/features/profile/presentation/profileView.dart';
import 'package:saladafactory/features/profile/presentation/widget/profileBodyView.dart';

import '../../../../drawer/presentation/view/drawerView.dart';
import '../../../../gifts/presenatation/view/giftView.dart';

class HomeBodyView extends StatefulWidget {
var currentIndexNav;
var currentindexGiftToogle;
HomeBodyView({required this.currentIndexNav ,required this.currentindexGiftToogle});
  @override
  State<HomeBodyView> createState() => _HomeBodyViewState();
}

class _HomeBodyViewState extends State<HomeBodyView> {
  final Color primaryColor = AppColors.primaryColor;
  final Color accentColor = AppColors.accentColor;
  final Color secondaryColor = AppColors.secondaryColor;
  final Color backgroundColor = AppColors.backgroundColor;

  late int currentIndex = widget.currentIndexNav??0;
  late final List<Widget> pages = [
    HomePage(),
     GiftBodyViewWithToggle(widget.currentindexGiftToogle),

    // Profileview()
  ];

  late StreamSubscription connectivitySubscription;
  Timer? periodicSyncTimer;
  bool isSyncing = false;
  bool isConnected = true;
  bool showSyncIndicator = false;
  bool showSyncSuccess = false;

  @override
  void initState() {
    super.initState();
    checkAndSync();
    listenToConnection();
    startPeriodicSync();
  }

  Future<void> checkAndSync() async {
    try {
      var result = await Connectivity().checkConnectivity();
      bool hasInternet =
          result != ConnectivityResult.none &&
          await InternetConnectionChecker.instance.hasConnection;
      ;

      if (mounted) {
        setState(() {
          isConnected = hasInternet;
        });
      }

      if (hasInternet && !isSyncing) {
        isSyncing = true;
        if (mounted) {
          setState(() => showSyncIndicator = true);
        }
        await doSync();
        if (mounted) {
          setState(() {
            showSyncIndicator = false;
            showSyncSuccess = true;
          });
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => showSyncSuccess = false);
          }
        });
        isSyncing = false;
      }
    } catch (e) {
      print('Error in checkAndSync: $e');
    }
  }

  void listenToConnection() {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) async {
      await checkAndSync();
    });
  }

  void startPeriodicSync() {
    periodicSyncTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      await checkAndSync();

      if (!mounted) return;
      await sendPendingProducts();

      if (!mounted) return;
      final context = this.context;
      if (mounted) {
        await sendSavedTransactions(context);
      }

      if (!mounted) return;
      if (mounted) {
        await sendOfflineTransactions(context);
        sendOfflineTransactionss(context);
      }

      if (!mounted) return;
      if (mounted) {
        await syncOfflineTransactions(context);
      }

      if (!mounted) return;
      // await Cachehelper().fetchDataandStoreLocaallly();
    });
  }

  Future<void> doSync() async {
    print("🔄 جاري المزامنة...");
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    periodicSyncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            actions: [
              InkWell(
                onTap: () {
                  Routting.push(context, Settingstartview());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.settings, color: Colors.white),
                ),
              ),
            ],
            backgroundColor: const Color(0xFF74826A), 
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            centerTitle: true,
            title: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.shade900
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isConnected
                      ? Colors.black.withOpacity(0.2)
                      : Colors.red.shade900,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? Colors.green.shade600
                          : Colors.red.shade900,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    isConnected ? 'متصل'.tr() : "غير متصل".tr(),
                    style: GoogleFonts.tajawal(
                      color: isConnected ? primaryColor : Colors.red.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawer: DrawerView(),

          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            selectedFontSize: 10,
            unselectedFontSize: 8,
            currentIndex: currentIndex,
            selectedItemColor: primaryColor,
            unselectedItemColor: secondaryColor,
            backgroundColor: backgroundColor,
            onTap: (index) {
              if (mounted) {
                setState(() {
                  currentIndex = index;
                });
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: Icon(Icons.home, color: primaryColor),
                label: 'الرئيسية'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.redeem_rounded),
                activeIcon: Icon(Icons.redeem_rounded, color: primaryColor),
                label: 'المكافآت'.tr(),
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.person),
              //   activeIcon: Icon(Icons.person, color: primaryColor),
              //   label: 'الملف الشخصي'.tr(),
              // ),
            ],
          ),
        ),

        if (showSyncIndicator)
          Positioned(
            top: MediaQuery.of(context).padding.top + 120,
            right: 30,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: Lottie.asset(
                    AssetIcons.foodanimation,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
              ),
            ),
          ),

        if (showSyncSuccess)
          Positioned(
            top: MediaQuery.of(context).padding.top + 120,
            right: 30,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
