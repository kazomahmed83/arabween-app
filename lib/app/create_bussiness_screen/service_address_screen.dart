import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/edit_service_address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/text_field_widget.dart';
import 'package:arabween/utils/dark_theme_provider.dart';

class EditServiceAddressScreen extends StatelessWidget {
  const EditServiceAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<EditServiceAddressController>(
      init: EditServiceAddressController(),
      builder: (controller) {
        final isDark = themeChange.getThem();

        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
          appBar: AppBar(
            backgroundColor: isDark ? AppThemeData.greyDark10 : AppThemeData.grey10,
            centerTitle: true,
            leadingWidth: 120,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: InkWell(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/icon_close.svg",
                      width: 20,
                      colorFilter: ColorFilter.mode(
                        isDark ? AppThemeData.greyDark01 : AppThemeData.grey01,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Close".tr,
                      style: TextStyle(
                        color: isDark ? AppThemeData.greyDark01 : AppThemeData.grey01,
                        fontSize: 14,
                        fontFamily: AppThemeData.semiboldOpenSans,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: isDark ? AppThemeData.greyDark08 : AppThemeData.grey08,
                height: 2.0,
              ),
            ),
            title: Text(
              "Select Area".tr,
              style: TextStyle(
                color: isDark ? AppThemeData.greyDark01 : AppThemeData.grey01,
                fontSize: 16,
                fontFamily: AppThemeData.semiboldOpenSans,
              ),
            ),
            actions: [
              if (controller.argumentData == null)
                TextButton(
                  onPressed: () {
                    if (controller.selectedServiceAarea.isEmpty) {
                      ShowToastDialog.showToast("Please select service area");
                    } else {
                      Get.back(result: controller.selectedServiceAarea);
                    }
                  },
                  child: Text(
                    "Save".tr,
                    style: TextStyle(
                      color: isDark ? AppThemeData.tealDark02 : AppThemeData.teal02,
                      fontSize: 14,
                      fontFamily: AppThemeData.boldOpenSans,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
                child: TextFieldWidget(
                  controller: controller.searchTextFieldController.value,
                  hintText: 'Search service area...',
                  prefix: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset("assets/icons/icon_search.svg", colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03, BlendMode.srcIn)),
                  ),
                  suffix: InkWell(
                    onTap: () {
                      controller.searchTextFieldController.value.clear();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        "assets/icons/close-one.svg",
                        colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),

              // Selected Service Areas
              if (controller.selectedServiceAarea.isNotEmpty)
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: controller.selectedServiceAarea.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final area = controller.selectedServiceAarea[index];
                    final isDark = themeChange.getThem();

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 8), // spacing between items
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.greyDark10 : AppThemeData.grey10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            area,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemeData.boldOpenSans,
                            ),
                          ),
                          const Icon(Icons.delete, color: AppThemeData.redDark03)
                        ],
                      ),
                    );
                  },
                ),

              // Predictions List
              Expanded(
                child: ListView.builder(
                  itemCount: controller.getAllServiceArea.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final prediction = controller.getAllServiceArea[index];

                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(prediction['structured_formatting']?['main_text']),
                      onTap: () {
                        if (controller.argumentData == null) {
                          if (!controller.selectedServiceAarea.contains(prediction['structured_formatting']?['main_text'])) {
                            controller.selectedServiceAarea.add(prediction['structured_formatting']?['main_text']);
                          }
                        } else {
                          if (controller.argumentData['type'] == 'home') {
                            ShowToastDialog.showLoader("Please wait");
                            Constant.currentAddress = prediction['structured_formatting']?['main_text'];
                            controller.getPlaceDetails(prediction['place_id']);
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
