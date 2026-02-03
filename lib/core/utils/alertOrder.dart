import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:saladafactory/core/utils/assets.dart';
import 'package:saladafactory/core/utils/colors.dart';

class FullScreenOrderConfirmationDialog extends StatelessWidget {
  final String title;
  final String orderNumber;
  final String message;
  final int autoCloseSeconds;
  final VoidCallback? onClose;

  const FullScreenOrderConfirmationDialog({
    super.key,
    required this.title,
    required this.orderNumber,
    required this.message,
    this.autoCloseSeconds = 5,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _FullScreenOrderConfirmationDialogContent(
      title: title,
      orderNumber: orderNumber,
      message: message,
      autoCloseSeconds: autoCloseSeconds,
      onClose: onClose,
    );
  }
}

class _FullScreenOrderConfirmationDialogContent extends StatefulWidget {
  final String title;
  final String orderNumber;
  final String message;
  final int autoCloseSeconds;
  final VoidCallback? onClose;

  const _FullScreenOrderConfirmationDialogContent({
    required this.title,
    required this.orderNumber,
    required this.message,
    required this.autoCloseSeconds,
    this.onClose,
  });

  @override
  State<_FullScreenOrderConfirmationDialogContent> createState() =>
      _FullScreenOrderConfirmationDialogContentState();
}

class _FullScreenOrderConfirmationDialogContentState
    extends State<_FullScreenOrderConfirmationDialogContent>
    with SingleTickerProviderStateMixin {
  late int _seconds;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _seconds = widget.autoCloseSeconds;
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.autoCloseSeconds),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _animationController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_seconds > 1) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
        _animationController.stop();
        widget.onClose?.call();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPortrait ? 24.0 : size.width * 0.1,
            vertical: isPortrait ? 20.0 : size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isPortrait ? 14 : 16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryColor,
                      size: isPortrait ? 28 : 32,
                    ),
                    SizedBox(width: isPortrait ? 12 : 16),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.cairo(
                          fontSize: isPortrait ? 20 * textScaleFactor : 22 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isPortrait ? 32 : 40),

              Expanded(
                child: Center(
                  child: Lottie.asset(
                    AssetIcons.giftanimation,
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isPortrait ? 16 : 20),
                margin: EdgeInsets.symmetric(vertical: isPortrait ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: isPortrait ? 22 : 24,
                          color: AppColors.accentColor,
                        ),
                        SizedBox(width: isPortrait ? 10 : 12),
                        Expanded(
                          child: Text(
                            "رقم الطلب:".tr(),
                            style: GoogleFonts.cairo(
                              fontSize: isPortrait ? 14 * textScaleFactor : 15 * textScaleFactor,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isPortrait ? 6 : 8),
                    Padding(
                      padding: EdgeInsets.only(left: isPortrait ? 32 : 36),
                      child: Text(
                        widget.orderNumber,
                        style: GoogleFonts.cairo(
                          fontSize: isPortrait ? 24 * textScaleFactor : 26 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(height: isPortrait ? 20 : 24),

                    // Message
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: isPortrait ? 22 : 24,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: isPortrait ? 10 : 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: GoogleFonts.cairo(
                              fontSize: isPortrait ? 14 * textScaleFactor : 15 * textScaleFactor,
                              height: 1.5,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Circular Timer Section
              Container(
                padding: EdgeInsets.all(isPortrait ? 14 : 16),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      "سيتم الإغلاق خلال".tr(),
                      style: GoogleFonts.cairo(
                        fontSize: isPortrait ? 14 * textScaleFactor : 15 * textScaleFactor,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: isPortrait ? 12 : 16),
                    
                    // Circular Timer
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        Container(
                          width: isPortrait ? 120 : 140,
                          height: isPortrait ? 120 : 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(
                          width: isPortrait ? 120 : 140,
                          height: isPortrait ? 120 : 140,
                          child: CircularProgressIndicator(
                            value: 1.0 - _animation.value, 
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        
                        Container(
                          width: isPortrait ? 80 : 100,
                          height: isPortrait ? 80 : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "$_seconds\n${"ثانية".tr()}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: isPortrait ? 18 * textScaleFactor : 20 * textScaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                 
                  ],
                ),
              ),

              SizedBox(height: isPortrait ? 16 : 20),

            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showFullScreenOrderConfirmationDialog({
  required BuildContext context,
  required String title,
  required String orderNumber,
  required String message,
  int autoCloseSeconds = 5,
  VoidCallback? onClose,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          FullScreenOrderConfirmationDialog(
        title: title,
        orderNumber: orderNumber,
        message: message,
        autoCloseSeconds: autoCloseSeconds,
        onClose: onClose,
      ),
      transitionDuration: const Duration(milliseconds: 125),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}