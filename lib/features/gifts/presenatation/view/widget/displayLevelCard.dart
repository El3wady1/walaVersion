import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftCubit.dart';
import 'package:saladafactory/features/gifts/presenatation/controller/giftState.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/giftCard.dart';

class Displaylevelcard extends StatelessWidget {
  final Color primaryColor = Color(0xFF74826A);
  final Color accentColor = Color(0xFFEDBE2C);
  final Color secondaryColor = Color(0xFFCDBCA2);
  final Color backgroundColor = Color(0xFFF3F4EF);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Giftcubit, GiftState>(
      builder: (BuildContext context, state) {
        if (state is LoadingUserDataState) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: CardLoading(
              cardLoadingTheme: CardLoadingTheme(
                colorOne: secondaryColor.withOpacity(0.3),
                colorTwo: secondaryColor.withOpacity(0.2),
              ),
              height: 120,
              width: double.infinity,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          );
        }
        if (state is LoadedUserDataState) {
          return Giftcard(
            name: state.userData.name,
            avilablePoint: state.userData.currentpoints.toString(),
            rechedPoint: state.userData.pointsRLevel.toString(),
            levelName: state.userData.nextLevel.levelName.toString(),
            levelpoint: state.userData.nextLevel.levelPoint.toString(),
          );
        }
        if (state is FailurUserDataState) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                state.erorrMassage.toString(),
                style: GoogleFonts.cairo(),
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
