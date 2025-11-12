import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/auth_screen/singup_screen.dart';
import 'package:arabween/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/login_controller.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/round_button_border.dart';
import 'package:arabween/themes/round_button_fill.dart';
import 'package:arabween/themes/text_field_widget.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';
import 'package:arabween/widgets/modern_ui/modern_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.surface50,
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.surface50,
            elevation: 0,
            centerTitle: true,
            leadingWidth: 120,
            leading: DebouncedInkWell(
              onTap: () {
                Get.back();
              },
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppThemeData.greyDark09 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeData.primary.withOpacity(0.06),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                  ),
                ],
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppThemeData.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: NetworkImageWidget(
                    imageUrl: Constant.appLogo,
                    height: 28,
                    width: 28,
                    fit: BoxFit.cover,
                    errorWidget: Icon(Icons.business, color: Colors.white, size: 28),
                  ),
                ),
                SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) => AppThemeData.primaryGradient.createShader(bounds),
                  child: Text(
                    Constant.applicationName.tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: AppThemeData.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.surface50,
                  themeChange.getThem() ? AppThemeData.greyDark10 : Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppThemeData.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppThemeData.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(Icons.lock_rounded, size: 48, color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Text(
                            "Welcome Back!".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                              fontSize: 32,
                              fontFamily: AppThemeData.extraBold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Login with email".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey03,
                              fontSize: 16,
                              fontFamily: AppThemeData.regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        TextFieldWidget(controller: controller.emailTextFieldController.value, hintText: 'Email'.tr),
                        TextFieldWidget(
                          controller: controller.passwordTextFieldController.value,
                          hintText: 'Password'.tr,
                          obscureText: controller.passwordVisible.value,
                          suffix: Padding(
                            padding: const EdgeInsets.all(12),
                            child: DebouncedInkWell(
                              onTap: () {
                                controller.passwordVisible.value = !controller.passwordVisible.value;
                              },
                              child: controller.passwordVisible.value
                                  ? SvgPicture.asset(
                                      "assets/icons/ic_password_show.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey01, BlendMode.srcIn),
                                    )
                                  : SvgPicture.asset(
                                      "assets/icons/ic_password_close.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey01, BlendMode.srcIn),
                                    ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: ShaderMask(
                              shaderCallback: (bounds) => AppThemeData.primaryGradient.createShader(bounds),
                              child: Text(
                                "Forgot Password?".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: AppThemeData.semibold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ModernButton(
                          text: 'Log in'.tr,
                          onPressed: () {
                            controller.signInWithEmailPassword();
                          },
                          width: double.infinity,
                          height: 56,
                          borderRadius: 28,
                          gradient: AppThemeData.primaryGradient,
                          icon: Icons.login_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        text: "${'By continuing, you agree to ${Constant.applicationName}'.tr} ",
                        style: TextStyle(fontSize: 13, fontFamily: AppThemeData.regular, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04),
                        children: <TextSpan>[
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(const TermsAndConditionScreen(type: "terms"));
                              },
                            text: 'Terms of Service'.tr,
                            style: TextStyle(color: AppThemeData.primary, fontSize: 13, fontFamily: AppThemeData.semibold),
                          ),
                          TextSpan(
                            text: " ${"and acknowledge ${Constant.applicationName}".tr} ",
                            style: TextStyle(fontSize: 13, fontFamily: AppThemeData.regular, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04),
                          ),
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(const TermsAndConditionScreen(type: "privacy"));
                              },
                            text: 'Privacy Policy.'.tr,
                            style: TextStyle(
                              color: AppThemeData.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: AppThemeData.semibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeChange.getThem() ? AppThemeData.greyDark10 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppThemeData.grey05)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or continue with".tr,
                          style: TextStyle(
                            color: AppThemeData.grey04,
                            fontSize: 14,
                            fontFamily: AppThemeData.medium,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppThemeData.grey05)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ModernButton(
                    text: 'Continue with Google'.tr,
                    onPressed: () {
                      controller.loginWithGoogle();
                    },
                    width: double.infinity,
                    height: 56,
                    borderRadius: 28,
                    backgroundColor: Colors.white,
                    textColor: AppThemeData.grey01,
                    isOutlined: true,
                    icon: Icons.g_mobiledata_rounded,
                  ),
                  SizedBox(height: 12),
                  Platform.isIOS
                      ? ModernButton(
                          text: 'Continue with Apple'.tr,
                          onPressed: () {
                            controller.loginWithApple();
                          },
                          width: double.infinity,
                          height: 56,
                          borderRadius: 28,
                          backgroundColor: AppThemeData.grey01,
                          textColor: Colors.white,
                          icon: Icons.apple_rounded,
                        )
                      : SizedBox(),
                  SizedBox(height: Platform.isIOS ? 16 : 0),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: 'dont_have_account'.trParams({'appName': Constant.applicationName}),
                      style: TextStyle(fontSize: 14, fontFamily: AppThemeData.regular, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(SingUpScreen());
                            },
                          text: ' Sign up'.tr,
                          style: TextStyle(color: AppThemeData.primary, fontSize: 14, fontFamily: AppThemeData.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildButton(String text, bool isSelected, bool isLeft, LoginController controller) {
    return GestureDetector(
      onTap: () {
        controller.isEmailSelected.value = isLeft;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(color: isSelected ? AppThemeData.grey01 : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Text(
          text,
          style: TextStyle(color: isSelected ? AppThemeData.grey10 : AppThemeData.grey03, fontSize: 14, fontFamily: AppThemeData.mediumOpenSans),
        ),
      ),
    );
  }
}
