import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:saladafactory/core/Widgets/custom_text.dart';
import 'package:saladafactory/core/utils/Strings.dart';
import 'package:saladafactory/core/utils/assets.dart';
import 'package:saladafactory/core/utils/styles.dart';

class SplashBodyView extends StatefulWidget {
  @override
  _SplashBodyViewState createState() => _SplashBodyViewState();
}

class _SplashBodyViewState extends State<SplashBodyView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _gradientAnimation = ColorTween(
      begin: const Color(0xFFF3F4EF),
      end: const Color(0xFFCDBCA2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));


    _controller.forward();


    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600; // Threshold for mobile vs desktop
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _gradientAnimation.value ?? const Color(0xFFF3F4EF),
                  const Color(0xFFCDBCA2),
                ],
              ),
            ),
            child: Stack(
              children: [

                if (!isMobile) 
                ...[
                  Positioned(
                    top: screenSize.height * 0.1,
                    right: screenSize.width * 0.1,
                    child: _buildFloatingCircle(0.3, screenSize),
                  ),
                  Positioned(
                    bottom: screenSize.height * 0.2,
                    left: screenSize.width * 0.1,
                    child: _buildFloatingCircle(0.2, screenSize),
                  ),
                  if (isDesktop)
                    Positioned(
                      top: screenSize.height * 0.3,
                      left: screenSize.width * 0.2,
                      child: _buildFloatingCircle(0.4, screenSize),
                    ),
                ] else
                  Positioned(
                    top: screenSize.height * 0.15,
                    right: screenSize.width * 0.05,
                    child: _buildFloatingCircle(0.3, screenSize),
                  ),

                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop
                          ? 600
                          : isTablet
                          ? 500
                          : 400,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20.0 : 40.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with responsive sizing
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 15.0 : 20.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF74826A,
                                      ).withOpacity(0.3 * _controller.value),
                                      blurRadius: isMobile ? 15.0 : 20.0,
                                      spreadRadius: isMobile ? 1.0 : 2.0,
                                    ),
                                  ],
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: [
                                        const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ).withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      AssetIcons.logo,
                                      width: _getLogoSize(screenSize),
                                      height: _getLogoSize(screenSize),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: _getSpacingSize(screenSize, isMobile),
                          ),

                          // App Name with responsive font size
                          SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 0.5),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _controller,
                                    curve: const Interval(
                                      0.5,
                                      0.8,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: const Interval(
                                    0.5,
                                    0.8,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: Custom_Text(
                                text: Strings.appName.tr(),
                                style: _getAppNameStyle(
                                  isMobile,
                                  isTablet,
                                  isDesktop,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: _getSpacingSize(screenSize, isMobile) * 0.5,
                          ),

                          // Version with responsive styling
                          SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _controller,
                                    curve: const Interval(
                                      0.7,
                                      1.0,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: const Interval(
                                    0.7,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Custom_Text(
                                  text: "${"اصدار".tr()} ${Strings.appVersion}",
                                  style: _getVersionStyle(
                                    isMobile,
                                    isTablet,
                                    isDesktop,
                                  ),
                                ),
                              ),
                            ),
                          ),


                          SizedBox(
                            height: _getSpacingSize(screenSize, isMobile) * 1.3,
                          ),
                          _buildLoadingIndicator(screenSize, isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  double _getLogoSize(Size screenSize) {
    if (screenSize.width < 350) return screenSize.width * 0.45;
    if (screenSize.width < 600) return screenSize.width * 0.4;
    if (screenSize.width < 1024) return screenSize.width * 0.3;
    return screenSize.width * 0.2;
  }

  double _getSpacingSize(Size screenSize, bool isMobile) {
    if (screenSize.height < 600) return 20;
    if (screenSize.height < 800) return 25;
    return isMobile ? 30 : 40;
  }

  TextStyle _getAppNameStyle(bool isMobile, bool isTablet, bool isDesktop) {
    double fontSize = isMobile
        ? 24
        : isTablet
        ? 32
        : 36;
    double letterSpacing = isMobile ? 1.0 : 1.5;

    return TextAppStyles.cairo20.copyWith(
      color: const Color(0xFF74826A),
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  TextStyle _getVersionStyle(bool isMobile, bool isTablet, bool isDesktop) {
    double fontSize = isMobile
        ? 14
        : isTablet
        ? 16
        : 18;

    return TextAppStyles.cairo15.copyWith(
      color: const Color(0xFF74826A).withOpacity(0.8),
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
    );
  }

  Widget _buildFloatingCircle(double delay, Size screenSize) {
    final isMobile = screenSize.width < 600;
    final circleSize = isMobile ? 60.0 : 100.0;

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 0.1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, 1.0, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF74826A).withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Size screenSize, bool isMobile) {
    final loadingSize = isMobile
        ? screenSize.width * 0.35
        : screenSize.width < 1024
        ? screenSize.width * 0.25
        : screenSize.width * 0.15;

    return SizedBox(
      width: loadingSize,
      child: Lottie.asset(
        "assets/animations/SandyLoading.json",
        fit: BoxFit.contain,
      ),
    );
  }
}
