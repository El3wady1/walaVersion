import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/Strings.dart';
import 'package:saladafactory/features/managWala/presntation/controller/managewalaa_Cubit.dart';
import 'package:saladafactory/features/managWala/presntation/controller/managewalaa_State.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../../../core/utils/colors.dart';

class Managewalaabodyview extends StatelessWidget {
  const Managewalaabodyview({super.key});
  @override
  Widget build(BuildContext context) {
    var cubit =BlocProvider.of<ManagewalaaCubit>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        title: Text(AppbarStrings.managewalaa.tr(),style: GoogleFonts.cairo(color: Colors.white),),
        centerTitle: true,
      ),
            backgroundColor: AppColors.backgroundColor,

      body: BlocConsumer<ManagewalaaCubit,ManagewalaaState>(
      builder: (BuildContext context, state) { 
        return Column(
                children: [
                  SizedBox(height: 12),
                  ToggleSwitch(
                    initialLabelIndex: cubit.selectedIndex,
                    totalSwitches:cubit.screens.length ,
                    fontSize: 11,
                    minWidth: MediaQuery.of(context).size.width*.35,
                        customTextStyles: [
                  GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                  GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                  GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                ],
                    labels: ['الطلبات'.tr(), 'ادارة النقاط'.tr() ],
                    activeBgColor: [AppColors.primaryColor],
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.white,
                    inactiveFgColor: AppColors.primaryColor,
                    onToggle: (i)=>cubit.togglepages(i),
                  ),
                  Expanded(
                    child: cubit.screens[cubit.selectedIndex], 
                  ),
                ],
              );
       }, listener: (BuildContext context, state) {  },
        ));
  }
}