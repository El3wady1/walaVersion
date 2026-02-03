import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/colors.dart';

class Availablepoints extends StatelessWidget {
  String avilablepoints;
  Availablepoints({required this.avilablepoints});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.credit_score, color: Colors.white, size: 15),
          ),
          SizedBox(width: 10),
          Text(
            "نقاطك الحالية :".tr() + " ",
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          ),

          SizedBox(height: 3),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Text(
              maxLines: 2,
              textAlign: TextAlign.center,
              avilablepoints,
              style: GoogleFonts.cairo(
                color: AppColors.accentColor,
                fontSize: 11,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            " " + 'نقطة'.tr(),
            style: GoogleFonts.cairo(
              color: AppColors.accentColor,
              fontSize: 12,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
