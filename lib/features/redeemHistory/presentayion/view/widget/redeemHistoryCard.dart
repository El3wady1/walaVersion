import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as f;
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/features/redeemHistory/presentayion/view/widget/btnCollect.dart';

class RedeemHistoryCard extends StatelessWidget {
  final String giftName;
  final String status;
  final String place;
  final dynamic istatus;
  final dynamic isDeducted;
  final DateTime date;
  final dynamic id;
  final dynamic points;
  final bool iscolected;
  final VoidCallback onTap;

  RedeemHistoryCard({
    super.key,
    required this.giftName,
    required this.status,
    required this.place,
    required this.date,
    required this.id,
    required this.isDeducted,
    required this.istatus,
    required this.points,
    required this.iscolected,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF74826A);
  static const Color accentColor = Color(0xFFEDBE2C);

  Color getStatusBgColor(String status) {
    switch (status) {
      case "compelete":
        return Colors.green.withOpacity(0.1);
      case "pending":
        return Colors.orange.withOpacity(0.1);
      case "cancel":
        return Colors.red.withOpacity(0.1);
      case "collect":
        return Colors.blue.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case "compelete":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancel":
        return Colors.red;
      case "collect":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case "compelete":
        return 'مكتمل'.tr();
      case "pending":
        return 'قيد المراجعة'.tr();
      case "cancel":
        return 'مرفوض'.tr();
      case "collect":
        return "تم جمع".tr();
      default:
        return 'غير معروف'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double giftNameWidth = width * 0.6;
        double statusWidth = width * 0.3;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Directionality(
                textDirection: f. TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: giftNameWidth,
                      child: Text(
                        giftName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: accentColor,
                          fontSize: width > 400 ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    (status == 'collect' && !iscolected)
                        ? DecoratedAnimatedButton(ontap: onTap)
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            width: statusWidth,
                            decoration: BoxDecoration(
                              color: getStatusBgColor(istatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getStatusText(status),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: getStatusTextColor(status.toString()),
                                fontSize: width > 400 ? 12 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${points.toString().contains("-") ? "خصم".tr() : (place == "r" ? "استرداد".tr() : "اضافة".tr())}',
                      style: GoogleFonts.cairo(
                        color: points.toString().contains("-")
                            ? Colors.red
                            : (place == "r" ? Colors.blue : Colors.green),
                        fontSize: width > 400 ? 12 : 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${points.toString().contains("-") ? "" : "+"}$points",
                      style: GoogleFonts.cairo(
                        color: points.toString().contains("-")
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: width > 400 ? 12 : 10,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$id',
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: width > 400 ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _formatDate(date),
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: width > 400 ? 12 : 10,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
