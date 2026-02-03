import 'package:flutter/material.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/cradGiftBuilder.dart';

class Giftcard extends StatelessWidget {

String name;
String avilablePoint;
String levelName ;
String levelpoint;
String rechedPoint;
Giftcard({required this.name,required this.avilablePoint,required this.rechedPoint,required this.levelName  ,required this.levelpoint});
  static const Color primaryColor = Color(0xFF74826A);
  static const Color accentColor = Color(0xFFEDBE2C);
  static const Color secondaryColor = Color(0xFFCDBCA2);
  static const Color backgroundColor = Color(0xFFF3F4EF);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          
          return Container(
            margin: Cradgiftbuilder().buildCardMargin(screenWidth),
            padding: Cradgiftbuilder().buildCardPadding(screenWidth),
            height:110,
            decoration: Cradgiftbuilder().buildCardDecoration(),
            child: Stack(
              children: [
                Cradgiftbuilder().buildCardContent(rechedPoint,levelName,avilablePoint,name,screenWidth,levelpoint),
              ],
            ),
          );
        },
      ),
    );
  }


}