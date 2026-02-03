import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cradgiftbuilder {
  static const Color primaryColor = Color(0xFF74826A);
  static const Color accentColor = Color(0xFFEDBE2C);
  static const Color secondaryColor = Color(0xFFCDBCA2);
  static const Color backgroundColor = Color(0xFFF3F4EF);

  EdgeInsets buildCardMargin(double screenWidth) {
    if (screenWidth < 350) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 10);
    }
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 10);
    }
    if (screenWidth < 900) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 10);
  }

  EdgeInsets buildCardPadding(double screenWidth) {
    if (screenWidth < 350) return const EdgeInsets.all(16);
    if (screenWidth < 600) return const EdgeInsets.all(20);
    if (screenWidth < 900) return const EdgeInsets.all(24);
    return const EdgeInsets.all(28);
  }

  double calculateCardHeight(double screenWidth, double screenHeight) {
    final calculatedHeight = screenHeight * 0.2;
    return calculatedHeight.clamp(170.0, 300.0);
  }

  BoxDecoration buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
           Color.fromARGB(255, 164, 123, 10).withOpacity(0.6),
                    primaryColor.withOpacity(0.9),

        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.25),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
  Widget buildCardContent(
    String recahedPoint,
    String levelname,
    String avilablePoint,
    String name,
    double screenWidth,
    String levelpoint,
  ) {
    final isExtraSmall = screenWidth < 350;
    final isSmall = screenWidth < 600;
    final isMedium = screenWidth < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildUserInfoSection(name, levelname, isExtraSmall, isSmall, isMedium),
        SizedBox(height: 5,)
       , buildPointsAndProgressSection(
          recahedPoint,
          avilablePoint,
          levelname,
          levelpoint,
          isExtraSmall,
          isSmall,
          isMedium,
        ),
      ],
    );
  }

  Widget buildUserInfoSection(
    String name,
    String levelname,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
  ) {
    final fontSize = isExtraSmall
        ? 8.0
        : isSmall
            ? 14.0
            : isMedium
                ? 14.0
                : 14.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            name,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        buildLevelBadge(levelname, isExtraSmall, isSmall),
      ],
    );
  }

  Widget buildLevelBadge(String levelname, bool isExtraSmall, bool isSmall) {
    final padding = isExtraSmall
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 7, vertical: 4);

    final iconSize = isExtraSmall ? 12.0 : (isSmall ? 14.0 : 16.0);
    final fontSize = isExtraSmall ? 9.0 : (isSmall ? 11.0 : 13.0);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, color: accentColor, size: iconSize),
          const SizedBox(width: 4),
          Text(
            levelname,
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.95),
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPointsAndProgressSection(
    String recahedPoint,
    String avilablePoint,
    String levelname,
    String levelpoint,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
  ) {
    return Column(
      children: [
        buildPointsDisplay(
          recahedPoint,
          avilablePoint,
          levelpoint,
          isExtraSmall,
          isSmall,
          isMedium,
        ),
        SizedBox(height: isExtraSmall ? 5 : 7),
        buildProgressBar(
          recahedPoint,
          levelname,
          levelpoint,
          isExtraSmall,
          isSmall,
        ),
      ],
    );
  }

  Widget buildPointsDisplay(
    String recahedPoint,
    String avilablePoint,
    String levelpoint,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
  ) {
    final iconSize = isExtraSmall
        ? 15.0
        : isSmall
            ? 18.0
            : isMedium
                ? 19.0
                : 20.0;

    final pointsFontSize = isExtraSmall
        ? 11.0
        : isSmall
            ? 12.0
            : isMedium
                ? 15.0
                : 17.0;

    final labelFontSize = isExtraSmall
        ? 10.0
        : isSmall
            ? 11.0
            : isMedium
                ? 12.0
                : 13.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         
          Row(children: [
            Icon(Icons.star_rounded, color: accentColor, size: iconSize),
            const SizedBox(width: 6),
            Text(
              avilablePoint,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: pointsFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ]),
        ]),
        buildProgressInfo(recahedPoint, levelpoint, isExtraSmall, isSmall),
      ],
    );
  }

  Widget buildProgressInfo(
      String recahedPoint, String levelpoint, bool isExtraSmall, bool isSmall) {
    final fontSize = isExtraSmall ? 10.0 : (isSmall ? 11.0 : 13.0);

    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.trending_up, color: accentColor, size: 14),
          const SizedBox(width: 6),
          Text(
            '$recahedPoint / $levelpoint',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget buildProgressBar(
    String reachedPoint,
    String levelName,
    String levelPoint,
    bool isExtraSmall,
    bool isSmall,
  ) {
    final barHeight = isExtraSmall ? 5.0 : (isSmall ? 6.0 : 8.0);
    final fontSize = isExtraSmall ? 10.0 : (isSmall ? 11.0 : 12.0);

    final int reached = int.tryParse(reachedPoint) ?? 0;
    final int level = int.tryParse(levelPoint) ?? 1000;
    final double progress = (reached / level).clamp(0.0, 1.0);

    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: barHeight,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
      ),
     
    ]);
  }
}
