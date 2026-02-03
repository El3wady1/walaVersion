import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as f ;
import 'package:google_fonts/google_fonts.dart';

class Pendingcard extends StatelessWidget {
  final String title;
  final int points;
  final String userName;
  final String status;
  final String trxId;
  final String createdAt;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  Pendingcard({
    required this.title,
    required this.points,
    required this.userName,
    required this.status,
    required this.trxId,
    required this.createdAt,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 6),
      elevation: 0.5,
      color: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: العنوان والنقاط والحالة
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentColor.withOpacity(0.8),
                        AppColors.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "$points ${"نقطة".tr()}",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // معلومات المستخدم والمعاملة في صف واحد
            SizedBox(height: 10),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.person_rounded,
                  iconColor: Colors.grey.shade600,
                  title: 'مستخدم',
                  value: userName,
                ),
                SizedBox(width: 16),
                _buildInfoItem(
                  icon: Icons.receipt_long_rounded,
                  iconColor: Colors.blue.shade600,
                  title: 'رقم العملية',
                  value: trxId,
                ),
              ],
            ),

            // التاريخ والحالة
            SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_month_rounded,
                  iconColor: Colors.purple.shade600,
                  title: 'التاريخ',
                  value: _formatDate(createdAt),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status.tr(),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),

            if (status.toLowerCase() == 'pending') ...[
              SizedBox(height: 12),
              Row(
                children: [
                      Expanded(
                    child: _buildActionButton(
                      onPressed: onAccept,
                      color: Colors.green.shade600,
                      icon: Icons.check,
                      
                      text: 'قبول'.tr(),
                    ),
                  ),
                                    SizedBox(width: 8),

                  Expanded(
                    child: _buildActionButton(
                      onPressed: onReject,
                      color: Colors.red.shade600,
                      icon: Icons.close,
                      text: 'رفض'.tr(),
                    ),
                  ),
              
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr(),
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'completed':
        return Colors.green.shade600;
      case 'failed':
        return Colors.red.shade600;
      case 'processing':
        return Colors.blue.shade600;
      default:
        return AppColors.primaryColor;
    }
  }

  String _formatDate(String date) {
    // يمكنك إضافة منطق تنسيق التاريخ هنا
    if (date.length > 10) return date.substring(0, 10);
    return date;
  }
}

class AppColors {
  static Color primaryColor = Color(0xFF74826A);
  static Color accentColor = Color(0xFFEDBE2C);
  static Color secondaryColor = Color(0xFFCDBCA2);
  static Color backgroundColor = Color(0xFFF3F4EF);
}