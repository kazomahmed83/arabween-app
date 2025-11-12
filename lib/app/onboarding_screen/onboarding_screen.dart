import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/app/location_permission_screen/location_permission_screen.dart';
import 'package:arabween/controller/onboarding/onboarding_controller.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/widgets/modern_ui/modern_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final OnboardingController controller = Get.put(OnboardingController());
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _iconScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
    );

    _iconRotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    controller.pages[controller.currentPage.value].color.withOpacity(0.15),
                    controller.pages[controller.currentPage.value].color.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
            );
          }),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        return controller.currentPage.value > 0
                            ? ModernIconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onPressed: () {
                                  controller.previousPage();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                size: 48,
                                iconSize: 20,
                                backgroundColor: Colors.white,
                                iconColor: AppThemeData.grey01,
                                elevation: 2,
                              )
                            : const SizedBox(width: 48);
                      }),
                      TextButton(
                        onPressed: () {
                          controller.skipOnboarding();
                          Get.offAll(() => const LocationPermissionScreen());
                        },
                        child: Text(
                          "Skip".tr,
                          style: TextStyle(
                            color: AppThemeData.grey02,
                            fontSize: 16,
                            fontFamily: AppThemeData.semibold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      controller.currentPage.value = index;
                    },
                    itemCount: controller.pages.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(controller.pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: [
                      Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.pages.length,
                            (index) => _buildDot(index),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      Obx(() {
                        final isLastPage = controller.currentPage.value == controller.pages.length - 1;
                        return ModernButton(
                          text: isLastPage ? "Get Started".tr : "Next".tr,
                          onPressed: () {
                            if (isLastPage) {
                              controller.completeOnboarding();
                              Get.offAll(() => const LocationPermissionScreen());
                            } else {
                              controller.nextPage();
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          width: Responsive.width(100, context),
                          height: 60,
                          borderRadius: 30,
                          gradient: AppThemeData.primaryGradient,
                          icon: isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _iconAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconScaleAnimation.value,
                child: Transform.rotate(
                  angle: _iconRotationAnimation.value,
                  child: Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          page.color.withOpacity(0.2),
                          page.color.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: page.color.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        height: 260,
                        width: 260,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page.color.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  page.color.withOpacity(0.8),
                                  page.color,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForPage(page),
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          Text(
            page.title.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeData.grey01,
              fontSize: 32,
              fontFamily: AppThemeData.extraBold,
              height: 1.2,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeData.grey03,
              fontSize: 17,
              fontFamily: AppThemeData.regular,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(OnboardingPage page) {
    if (page.title.contains("Discover")) {
      return Icons.explore_rounded;
    } else if (page.title.contains("Reviews")) {
      return Icons.star_rounded;
    } else {
      return Icons.people_rounded;
    }
  }

  Widget _buildDot(int index) {
    return Obx(() {
      final isActive = controller.currentPage.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: 10,
        width: isActive ? 32 : 10,
        decoration: BoxDecoration(
          gradient: isActive ? AppThemeData.primaryGradient : null,
          color: isActive ? null : AppThemeData.grey05,
          borderRadius: BorderRadius.circular(5),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppThemeData.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      );
    });
  }
}
