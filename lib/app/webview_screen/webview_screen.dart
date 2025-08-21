import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/webview_controllerx.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/utils/dark_theme_provider.dart';

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: WebViewControllerX(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
            centerTitle: true,
            leadingWidth: 120,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/icon_close.svg",
                      width: 18,
                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, BlendMode.srcIn),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Close".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                        fontSize: 14,
                        fontFamily: AppThemeData.semiboldOpenSans,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: themeChange.getThem() ? AppThemeData.greyDark08 : AppThemeData.grey08,
                height: 2.0,
              ),
            ),
            title: Text(
              controller.title.value.isEmpty == true || controller.title.value == '' ? "Claim business".tr : controller.title.value,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                fontSize: 16,
                fontFamily: AppThemeData.semiboldOpenSans,
              ),
            ),
          ),
          body: controller.isLoading.value ? Constant.loader() : WebViewWidget(controller: controller.controller.value),
        );
      },
    );
  }
}
