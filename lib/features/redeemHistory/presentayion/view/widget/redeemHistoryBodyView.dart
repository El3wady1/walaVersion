import 'package:card_loading/card_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/colors.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/controller/redeemHistoryCubit.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/controller/redeemHistoryState.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/availablePoints.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/displayHistoryredeemCard.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/displayredeemHistory.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/redeemHistoryCard.dart';

import '../../../../../core/utils/getLangState.dart';
import '../../../data/services/earnRedeemHistoryServices.dart';

class Redeemhistorybodyview extends StatelessWidget {
  static Color primaryColor = Color(0xFF74826A);
  static Color accentColor = Color(0xFFEDBE2C);
  static Color secondaryColor = Color(0xFFCDBCA2);
  static Color backgroundColor = Color(0xFFF3F4EF);
  static Color textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BlocProvider(create: (BuildContext context) { return Redeemhistorycubit()..fetchAvailablePoints(); },
            // child: Displayhistoryredeemcard()),
            // SizedBox(height: 6),
            Text(
              "عمليات الاستبدال السابقة :".tr(),
              style: GoogleFonts.cairo(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
    
            SizedBox(height: 5),
            BlocProvider(create: (BuildContext context) { return Redeemhistorycubit()..fetchRedeemHistoryData(); },
              child: Displayredeemhistory()),
          ],
        ),
      ),
    );
  }
}
