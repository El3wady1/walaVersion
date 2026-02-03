import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:saladafactory/core/utils/assets.dart';

class Loadingwidget extends StatelessWidget {

  final Color primaryColor = Color(0xFF74826A);

  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,  boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child:  Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Lottie.asset(AssetIcons.foodanimation,width: MediaQuery.of(context).size.width*0.4,),
              )),
    );
  }
}