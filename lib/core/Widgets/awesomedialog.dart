import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
void CustomAwesomeDialog({
  required BuildContext context,
  required DialogType dialogType,
 required String title,
 required String desc,
  Function()? btnOkOnPress,
  Function()? btnCancelOnPress,
}) {
  AwesomeDialog(
    titleTextStyle: GoogleFonts.cairo(),
        descTextStyle: GoogleFonts.cairo(),

    btnCancelText: "الغاء",
    btnOkText: "موافق",
    context: context,
    animType: AnimType.bottomSlide,
    dialogType: dialogType,
    title: title,
    desc: desc,
    btnCancelOnPress: btnCancelOnPress,
    btnOkOnPress: btnOkOnPress,
  )..show();
}
