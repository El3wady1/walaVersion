import 'dart:math';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/colors.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftCubit.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftState.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/giftBodyView.dart';
import 'package:saladafactory/features/mission/presentation/view/widget/missionBodyView.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/redeemHistoryView.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../mission/presentation/view/missionView.dart';

class GiftBodyViewWithToggle extends StatelessWidget {
int ? currentindexGiftToogle;
GiftBodyViewWithToggle(currentindexGiftToogle);
  @override
  Widget build(BuildContext context) {
    
    return  Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('المكافآت'.tr(),style: GoogleFonts.cairo(color: Colors.white),),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
        ),
        body: BlocProvider(
          create: (BuildContext context) { return Giftcubit(); },
          child: BlocConsumer<Giftcubit,GiftState>(
            builder: (BuildContext context, state) {
              var cubit =BlocProvider.of<Giftcubit>(context);
      
               return Column(
              children: [
                SizedBox(height: 12),
                ToggleSwitch(
                  initialLabelIndex: cubit.selectedIndex,
                  totalSwitches: 3,
                  fontSize: 11,
                      customTextStyles: [
                GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
              ],
                  labels: ['الاستبدال'.tr(), 'السجل'.tr(), 'المهام'.tr()],
                  activeBgColor: [AppColors.primaryColor],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: AppColors.primaryColor,
                  onToggle: (i)=>cubit.togglepages( currentindexGiftToogle!=null?currentindexGiftToogle=i:i ),
                ),
                Expanded(
                  child: cubit.screens[cubit.selectedIndex], 
                ),
              ],
            );
            }, listener: (BuildContext context, state) {},
                  ),
        ),
      );
  
  }
}
