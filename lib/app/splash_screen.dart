import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/splash_controller.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/utils/network_image_widget.dart';
import '../themes/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          body: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                width: Responsive.width(100, context),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.5, -1.0),
                    end: const Alignment(0.5, 1.0),
                    colors: [
                      Color.lerp(AppThemeData.primary, AppThemeData.secondary, _backgroundAnimation.value)!,
                      Color.lerp(AppThemeData.secondary, AppThemeData.yellow, _backgroundAnimation.value)!,
                      Color.lerp(AppThemeData.yellow, AppThemeData.accent, _backgroundAnimation.value)!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CirclesPainter(_backgroundAnimation.value),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Opacity(
                                  opacity: _logoFadeAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppThemeData.primary.withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: AppThemeData.secondary.withOpacity(0.2),
                                          blurRadius: 50,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: NetworkImageWidget(
                                      imageUrl: Constant.appLogo,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      errorWidget: Constant.svgPictureShow(
                                        "assets/images/ic_logo.svg",
                                        null,
                                        120,
                                        120,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return SlideTransition(
                                position: _textSlideAnimation,
                                child: FadeTransition(
                                  opacity: _textFadeAnimation,
                                  child: Column(
                                    children: [
                                      Text(
                                        Constant.applicationName.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppThemeData.grey10,
                                          fontSize: 36,
                                          fontFamily: AppThemeData.extraBold,
                                          letterSpacing: 2.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.25),
                                              offset: const Offset(0, 3),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Discover Local Businesses".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppThemeData.grey10.withOpacity(0.95),
                                          fontSize: 17,
                                          fontFamily: AppThemeData.medium,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 50),
                          AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _textFadeAnimation,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppThemeData.grey10,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CirclesPainter extends CustomPainter {
  final double animationValue;

  CirclesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppThemeData.primaryLight.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppThemeData.secondaryLight.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = AppThemeData.accentLight.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final circle1Radius = 180.0 * animationValue;
    final circle2Radius = 220.0 * animationValue;
    final circle3Radius = 140.0 * animationValue;

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      circle1Radius,
      paint1,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      circle2Radius,
      paint2,
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.15),
      circle3Radius,
      paint3,
    );
  }

  @override
  bool shouldRepaint(CirclesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
