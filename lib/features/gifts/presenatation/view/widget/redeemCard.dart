import 'package:easy_localization/easy_localization.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/colors.dart';
import 'package:saladafactory/features/gifts/presenatation/view/widget/dialogGiftDes.dart';
class Redeemcard extends StatelessWidget {
  final GlobalKey<FlipCardState> imageKey = GlobalKey<FlipCardState>();
  static const Color primaryColor = Color(0xFF74826A);
  static const Color accentColor = Color(0xFFEDBE2C);
  static const Color secondaryColor = Color(0xFFCDBCA2);

  final String name;
  final String desc;
  final String? redeemPhoto; // ممكن تكون null
  final VoidCallback? onTap;
  final String pointToReedem;
  final bool lockedRedeemBtn;
  final bool isloadingbtn;

  Redeemcard({
    required this.name,
    required this.desc,
    required this.onTap,
    required this.pointToReedem,
    this.redeemPhoto,
    required this.lockedRedeemBtn,
    required this.isloadingbtn,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.45;
    double cardHeight = screenHeight * 0.27;
    double fontScale = screenWidth / 500; // بالنسبة للهواتف العادية 400 px width

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          FlipCard(
            key: imageKey,
            flipOnTouch: true,
            direction: FlipDirection.HORIZONTAL,
            front: _frontImage(cardHeight * 0.6, fontScale),
            back: _backImage(context, cardHeight * 0.6, fontScale),
          ),
          const SizedBox(height: 8),
          _buildRedeemButton(fontScale),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _frontImage(double height, double fontScale) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: secondaryColor.withOpacity(0.2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: redeemPhoto != null && redeemPhoto!.isNotEmpty
                ? Image.network(
                    redeemPhoto!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _placeholderImage();
                    },
                  )
                : _placeholderImage(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: const Color.fromARGB(255, 78, 106, 43).withOpacity(0.5),
              child: Center(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: GoogleFonts.cairo(
                    fontSize: 10 * fontScale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: accentColor, size: 12 * fontScale),
                  const SizedBox(width: 4),
                  Text(
                    pointToReedem,
                    style: GoogleFonts.cairo(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backImage(BuildContext context, double height, double fontScale) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => DialogGiftDes(data: desc),
        );
      },
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          color: secondaryColor.withOpacity(0.15),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: Icon(Icons.info, size: 26 * fontScale, color: primaryColor),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.cairo(
                    fontSize: 12 * fontScale,
                    color: primaryColor.withOpacity(0.7),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: secondaryColor.withOpacity(0.2),
      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }

  Widget _buildRedeemButton(double fontScale) {
    if (lockedRedeemBtn) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.red),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              child: Text(
                "غير كافي".tr(),
                style: GoogleFonts.cairo(
                  fontSize: 12 * fontScale,
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: SizedBox(
          width: 90,
          height: 32,
          child: !isloadingbtn
              ? ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'استبدال'.tr(),
                    style: GoogleFonts.cairo(
                      fontSize: 11 * fontScale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 12 * fontScale),
                      const SizedBox(width: 6),
                      Text(
                        "Can not click".tr(),
                        style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 10 * fontScale,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }
  }
}
