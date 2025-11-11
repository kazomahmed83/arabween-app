import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/app/location_permission_screen/location_permission_screen.dart';
import 'package:arabween/controller/onboarding/onboarding_controller.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  void dispose() {
    _pageController.dispose();
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
                    controller.pages[controller.currentPage.value].color.withOpacity(0.3),
                    controller.pages[controller.currentPage.value].color.withOpacity(0.1),
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
                            ? TextButton(
                                onPressed: () {
                                  controller.previousPage();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      size: 16,
                                      color: AppThemeData.grey01,
                                    ),
                                    Text(
                                      "Back".tr,
                                      style: TextStyle(
                                        color: AppThemeData.grey01,
                                        fontSize: 16,
                                        fontFamily: AppThemeData.semibold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(width: 80);
                      }),
                      TextButton(
                        onPressed: () {
                          controller.skipOnboarding();
                          Get.offAll(() => const LocationPermissionScreen());
                        },
                        child: Text(
                          "Skip".tr,
                          style: TextStyle(
                            color: AppThemeData.grey01,
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
                        return SizedBox(
                          width: Responsive.width(100, context),
                          height: 56,
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeData.red02,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLastPage ? "Get Started".tr : "Next".tr,
                              style: TextStyle(
                                color: AppThemeData.grey10,
                                fontSize: 18,
                                fontFamily: AppThemeData.bold,
                              ),
                            ),
                          ),
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
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getIconForPage(page),
                    size: 120,
                    color: page.color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            page.title.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeData.grey01,
              fontSize: 28,
              fontFamily: AppThemeData.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeData.grey02,
              fontSize: 16,
              fontFamily: AppThemeData.regular,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(OnboardingPage page) {
    if (page.title.contains("Discover")) {
      return Icons.explore;
    } else if (page.title.contains("Reviews")) {
      return Icons.star_rate_rounded;
    } else {
      return Icons.people;
    }
  }

  Widget _buildDot(int index) {
    return Obx(() {
      final isActive = controller.currentPage.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: isActive ? 24 : 8,
        decoration: BoxDecoration(
          color: isActive ? AppThemeData.red02 : AppThemeData.grey04,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }
}
