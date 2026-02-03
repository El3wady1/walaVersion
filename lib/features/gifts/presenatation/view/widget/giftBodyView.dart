import 'package:card_loading/card_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:saladafactory/core/utils/app_router.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftCubit.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftState.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/displayLevelCard.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/giftCard.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/giftsDisplay.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/redeemCard.dart';

import '../../../../redeemHistory/presentayion/view/redeemHistoryView.dart';
class Giftbodyview extends StatelessWidget {
  final Color primaryColor = Color(0xFF74826A);
  final Color accentColor = Color(0xFFEDBE2C);
  final Color secondaryColor = Color(0xFFCDBCA2);
  final Color backgroundColor = Color(0xFFF3F4EF);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Giftcubit()..startAutoRefresh(), 
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Displaylevelcard(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المكافآت المتاحة'.tr(),
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'اختر واستبدل نقاطك'.tr(),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: primaryColor.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            BlocBuilder<Giftcubit, GiftState>(
              builder: (context, state) {
                if (state is LoadedUserDataState) {
                  return Giftsdisplay(
                    currentpoints: double.parse(
                      state.userData.currentpoints.toString(),
                    ),
                  );
                }
                if (state is LoadingUserDataState) {
                  return SizedBox();
                }
                if (state is FailurUserDataState) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(state.erorrMassage.toString(),style: GoogleFonts.cairo(),),

                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
