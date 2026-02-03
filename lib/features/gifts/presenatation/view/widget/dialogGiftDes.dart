import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/colors.dart';

class DialogGiftDes extends StatelessWidget {
var data;
DialogGiftDes({required this.data});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:AppColors. backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,

        children: [
           Container(
            color: Colors.black12,
             child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [   Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text(
                  textAlign: TextAlign.start,
                  "الوصف".tr(),
                  style: GoogleFonts.cairo(
                    color:AppColors. primaryColor,
                    fontSize: 16,
                              fontWeight: FontWeight.w900
                  ),
                               ),
               ),
                 IconButton(
                  icon: Icon(Icons.close, color: AppColors.primaryColor),
                  onPressed: () => Navigator.pop(context),
                           ),
               ],
             ),
           ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
           
          
          
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: AppColors.accentColor,fontSize: 12,fontWeight: FontWeight.w800),
                ),
              ),
          
          
             SizedBox(height: 10,)
            ],
          ),

         
        ],
      ),
    );
  }
}
