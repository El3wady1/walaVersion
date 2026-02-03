import 'package:card_loading/card_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/features/drawer/presentation/controller/drawerCubit.dart';
import 'package:saladafactory/features/drawer/presentation/controller/drawerState.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/Widgets/showsnackbar.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/getLangState.dart';
import '../../../../login/presentation/view/loginView.dart';
import '../../../../login/presentation/view/widget/settingstartView.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../profile/presentation/widget/languageDropdown.dart';

class Drawerbodyview extends StatelessWidget {
  const Drawerbodyview({super.key});

  static const Color primaryColor = Color(0xFF74826A);
  static const Color accentColor = Color(0xFFEDBE2C);
  static const Color secondaryColor = Color(0xFFCDBCA2);
  static const Color backgroundColor = Color(0xFFF3F4EF);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<DrawerCubit, DrawerState>(
            builder: (context, state) {
              if (state is DrawerLoadingState) {
                return Center(
                  child: CardLoading(
                    cardLoadingTheme: CardLoadingTheme(
                      colorOne: primaryColor.withOpacity(0.5),
                      colorTwo: secondaryColor.withOpacity(0.2),
                    ),
                    height: 200,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                );
              }

              if (state is DrawerLoaded) {
                var langState = LocallizationHelper.get(context);
                print(state.userData.name);
                print(state.userData.slug);

                return Stack(
                  children: [
                    
                      UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(color: primaryColor),
                      currentAccountPicture: const CircleAvatar(
                        backgroundColor: accentColor,
                        child: Icon(Icons.person, size: 35, color: Colors.white),
                      ),
                      accountName: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                langState.toString() != "en"
                                    ? state.userData.name ?? ""
                                    : state.userData.slug ?? "",
                                style: GoogleFonts.cairo(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      accountEmail: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "${state.userData.role}".tr() + "  |  ",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            state.userData.phone,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                                        ),
                      ),
                    ],
                );
              }

              if (state is DrawerFailState) {
                return Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      state.errorMessage.toString(),
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Container(
                child: _drawerItem(
                  context,
                  Icons.settings,
                  "الإعدادات".tr(),
                  onTap: () {
                    Navigator.pop(context);
                    Routting.push(context, Settingstartview());
                  },
                ),
              ),
              SizedBox(width: 20,), 
                         LanguageDropdown(),

            ],
          ),

           Divider(color: secondaryColor),
          _drawerItem(
            context,
            Icons.logout,
            "تسجيل الخروج".tr(),
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final useBiometric = prefs.getBool('useBiometric') ?? false;
              await FirebaseMessaging.instance.deleteToken();

              await prefs.clear();
              await prefs.setBool('useBiometric', useBiometric);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Loginview()),
              );

              showTrueSnackBar(
                context: context,
                message: "تم تسجيل الخروج".tr(),
                icon: Icons.logout,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? iconColor,
    Color textColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
           children: [
         Icon(icon, color: iconColor),
           Text(title, style: GoogleFonts.cairo(color: textColor)),
        ]),
      ),
    );
  }
}
