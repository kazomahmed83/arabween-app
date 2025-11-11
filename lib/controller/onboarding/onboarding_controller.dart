import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  
  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: "Discover Local Businesses",
      description: "Find the best restaurants, shops, and services near you with ease",
      image: "assets/images/onboarding_1.svg",
      color: const Color(0xFFFFC107),
    ),
    OnboardingPage(
      title: "Read Reviews & Ratings",
      description: "Make informed decisions with authentic reviews from real customers",
      image: "assets/images/onboarding_2.svg",
      color: const Color(0xFFFF9800),
    ),
    OnboardingPage(
      title: "Connect & Share",
      description: "Share your experiences and help others discover great places",
      image: "assets/images/onboarding_3.svg",
      color: const Color(0xFFFF5722),
    ),
  ];

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void skipOnboarding() async {
    await _setOnboardingComplete();
  }

  void completeOnboarding() async {
    await _setOnboardingComplete();
  }

  Future<void> _setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
