import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/assets.dart';

class DecoratedAnimatedButton extends StatefulWidget {
  final Function ontap; // تغيير النوع إلى دالة

  DecoratedAnimatedButton({required this.ontap});

  @override
  _DecoratedAnimatedButtonState createState() =>
      _DecoratedAnimatedButtonState();
}

class _DecoratedAnimatedButtonState extends State<DecoratedAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isButtonDisabled = false; // متغير لتعطيل الزر

  static Color primaryColor = Color(0xFF74826A);
  static Color accentColor = Color(0xFFEDBE2C);
  static Color secondaryColor = Color(0xFFCDBCA2);
  static Color backgroundColor = Color(0xFFF3F4EF);
  static Color textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();

    // تهيئة الأنيميشن
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _shadowAnimation = Tween<double>(
      begin: 2,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: primaryColor,
      end: Colors.orange[700], // لون مختلف للأنيميشن
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: _shadowAnimation.value,
                  spreadRadius: _shadowAnimation.value * 0.5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isButtonDisabled
                  ? null
                  : () async {
                      if (!mounted) return;
                      setState(() {
                        _isButtonDisabled = true;
                      });

                      widget.ontap();

                      await Future.delayed(Duration(seconds: 6));

                      if (!mounted) return;
                      setState(() {
                        _isButtonDisabled = false;
                      });

                      if (!mounted) return;
                      _controller.forward(from: 0).then((_) {
                        _controller.repeat(reverse: true);
                      });
                    },

              style: ElevatedButton.styleFrom(
                backgroundColor: _colorAnimation.value,
                foregroundColor: Colors.white,
                elevation: _shadowAnimation.value,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(70, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // تأثير توهج للنص
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.yellow[200]!,
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "اكسب".tr(),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // أيقونة متحركة
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    child: Image.asset(AssetIcons.gift, width: 18, height: 18),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
