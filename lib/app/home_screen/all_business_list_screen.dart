import 'dart:developer';

import 'package:arabween/controller/all_business_list_controller%20copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/business_details_screen/business_details_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/business_list_controller.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/models/service_model.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/round_button_fill.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';

class AllBusinessListScreen extends StatelessWidget {
  const AllBusinessListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: AllBusinessListController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
              centerTitle: true,
              leadingWidth: 120,
              leading: DebouncedInkWell(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/icon_left.svg",
                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, BlendMode.srcIn),
                    ),
                    Text(
                      "Back".tr,
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(55.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: controller.searchController.value,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.medium),
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(color: Colors.red),
                      prefixIcon: Padding(padding: const EdgeInsets.all(8.0), child: Constant.svgPictureShow("assets/icons/ic_search.svg", null, null, null)),
                      prefixIconConstraints: BoxConstraints(minHeight: 20, minWidth: 20),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                      fillColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.redDark02 : AppThemeData.red02, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                      ),
                      hintText: "Search Business".tr,
                      hintStyle: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04, fontFamily: AppThemeData.regularOpenSans),
                    ),
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GridView.builder(
                itemCount: controller.searchBusinessList.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 240,
                ),
                itemBuilder: (context, index) {
                  log("controller.searchBusinessList.length :: ${controller.searchBusinessList.length}");
                  final business = controller.searchBusinessList[index];
                  return DebouncedInkWell(
                    onTap: () {
                      Constant.setRecentBusiness(business);
                      Get.to(
                        BusinessDetailsScreen(),
                        arguments: {
                          "businessModel": business,
                          "categoryModel": controller.categoryService.value,
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: themeChange.getThem() ? 6 : 2,
                            offset: Offset(0, themeChange.getThem() ? 3 : 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                      child: NetworkImageWidget(
                                        imageUrl: business.coverPhoto ?? '',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorWidget: Constant.svgPictureShow(
                                          "assets/icons/ic_placeholder_bussiness.svg",
                                          null,
                                          double.infinity,
                                          double.infinity,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(120),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset("assets/icons/ic_star.svg"),
                                            const SizedBox(width: 2),
                                            Text(
                                              "${Constant.calculateReview(reviewCount: business.reviewCount.toString(), reviewSum: business.reviewSum.toString())} (${business.reviewCount})",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04,
                                                fontFamily: AppThemeData.medium,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: Constant.getBusinessStatus(business.businessHours).toLowerCase() == 'open' ? AppThemeData.greenDark02 : AppThemeData.red01,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        ),
                                        child: Text(
                                          Constant.getBusinessStatus(business.businessHours),
                                          style: TextStyle(
                                            color: AppThemeData.grey10,
                                            fontSize: 12,
                                            fontFamily: AppThemeData.mediumOpenSans,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        business.businessName ?? 'Unnamed',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                          fontSize: 14,
                                          fontFamily: AppThemeData.boldOpenSans,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (business.businessType == 'Service Business' && business.serviceArea?.isEmpty != true)
                                            Constant.svgPictureShow(
                                              "assets/icons/icon_local-two.svg",
                                              themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                              16,
                                              16,
                                            ),
                                          if (business.businessType != 'Service Business')
                                            Constant.svgPictureShow(
                                              "assets/icons/icon_local-two.svg",
                                              themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                              16,
                                              16,
                                            ),
                                          const SizedBox(width: 5),
                                          business.businessType == 'Service Business'
                                              ? Expanded(
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Text(
                                                      business.serviceArea?.join(', ') ?? "", // Converts list to comma-separated string
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                        fontSize: 12,
                                                        fontFamily: AppThemeData.regular,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Expanded(
                                                  child: Text(
                                                    '${business.address?.locality}',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.regular,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 60,
                            left: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: NetworkImageWidget(
                                imageUrl: business.profilePhoto ?? '',
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                                errorWidget: Constant.svgPictureShow(
                                  "assets/icons/ic_placeholder_bussiness.svg",
                                  null,
                                  45,
                                  45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ));
      },
    );
  }

  sortFilterBottomSheet(themeChange, BusinessListController controller) {
    Get.bottomSheet(
      Container(
        height: Responsive.height(32, Get.context!),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Sort".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                        fontSize: 18,
                        fontFamily: AppThemeData.boldOpenSans,
                      ),
                    ),
                  ),
                  DebouncedInkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset(
                      "assets/icons/icon_close.svg",
                      width: 20,
                      colorFilter: ColorFilter.mode(
                        themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              RadioListTile<String>(
                title: Text(
                  'Recommended'.tr,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                    fontSize: 16,
                    fontFamily: AppThemeData.mediumOpenSans,
                  ),
                ),
                value: 'recommended',
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
                dense: true,
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) {
                  controller.selectedSortOption.value = value ?? '';
                  Get.back();
                  controller.getAllFilteredLists();
                },
              ),
              RadioListTile<String>(
                title: Text(
                  'Distance'.tr,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                    fontSize: 16,
                    fontFamily: AppThemeData.mediumOpenSans,
                  ),
                ),
                value: 'distance',
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
                dense: true,
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) {
                  controller.selectedSortOption.value = value ?? '';
                  Get.back();
                  controller.getAllFilteredLists();
                },
              ),
              RadioListTile<String>(
                title: Text(
                  'Rating'.tr,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                    fontSize: 16,
                    fontFamily: AppThemeData.mediumOpenSans,
                  ),
                ),
                value: 'rating',
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
                dense: true,
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) {
                  controller.selectedSortOption.value = value ?? '';
                  Get.back();
                  controller.getAllFilteredLists();
                },
              ),
              RadioListTile<String>(
                title: Text(
                  'Reviewed'.tr,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                    fontSize: 16,
                    fontFamily: AppThemeData.mediumOpenSans,
                  ),
                ),
                value: 'reviewed',
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
                dense: true,
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) {
                  controller.selectedSortOption.value = value ?? '';
                  Get.back();
                  controller.getAllFilteredLists();
                },
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Allows BottomSheet to take full height
    );
  }

  moreFilterBottomSheet(themeChange, BusinessListController controller) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.4,
        // Starts at 30% of screen height
        minChildSize: 0.4,
        // Minimum height (30% of screen)
        maxChildSize: 0.9,
        // Can expand up to
        shouldCloseOnMinExtent: false,
        builder: (context, scrollController) {
          return Container(
            height: Responsive.height(32, Get.context!),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      DebouncedInkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/icon_close.svg",
                              width: 20,
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
                      Expanded(
                        child: Text(
                          "Filters".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                            fontSize: 18,
                            fontFamily: AppThemeData.boldOpenSans,
                          ),
                        ),
                      ),
                      DebouncedInkWell(
                        onTap: () {
                          controller.isOpenBusiness.value = false;
                          controller.selectedSortOption.value = '';
                          controller.selectedOptionsByServiceId.clear();
                        },
                        child: Text(
                          "Reset".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.teal02 : AppThemeData.teal02,
                            fontSize: 16,
                            fontFamily: AppThemeData.boldOpenSans,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sort".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                              fontSize: 18,
                              fontFamily: AppThemeData.boldOpenSans,
                            ),
                          ),
                          Column(
                            children: [
                              RadioListTile<String>(
                                title: Text(
                                  'Recommended',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.mediumOpenSans,
                                  ),
                                ),
                                value: 'recommended',
                                controlAffinity: ListTileControlAffinity.trailing,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                groupValue: controller.selectedSortOption.value,
                                visualDensity: VisualDensity.compact,
                                // Reduces vertical & horizontal space

                                onChanged: (value) {
                                  controller.selectedSortOption.value = value ?? '';
                                  controller.getAllFilteredLists();
                                },
                              ),
                              RadioListTile<String>(
                                title: Text(
                                  'Distance',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.mediumOpenSans,
                                  ),
                                ),
                                value: 'distance',
                                controlAffinity: ListTileControlAffinity.trailing,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                groupValue: controller.selectedSortOption.value,
                                visualDensity: VisualDensity.compact,
                                // Reduces vertical & horizontal space

                                onChanged: (value) {
                                  controller.selectedSortOption.value = value ?? '';
                                  controller.getAllFilteredLists();
                                },
                              ),
                              RadioListTile<String>(
                                title: Text(
                                  'Rating',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.mediumOpenSans,
                                  ),
                                ),
                                value: 'rating',
                                controlAffinity: ListTileControlAffinity.trailing,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                groupValue: controller.selectedSortOption.value,
                                visualDensity: VisualDensity.compact,
                                // Reduces vertical & horizontal space

                                onChanged: (value) {
                                  controller.selectedSortOption.value = value ?? '';
                                  controller.getAllFilteredLists();
                                },
                              ),
                              RadioListTile<String>(
                                title: Text(
                                  'Reviewed',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.mediumOpenSans,
                                  ),
                                ),
                                value: 'reviewed',
                                controlAffinity: ListTileControlAffinity.trailing,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                groupValue: controller.selectedSortOption.value,
                                visualDensity: VisualDensity.compact,
                                // Reduces vertical & horizontal space
                                onChanged: (value) {
                                  controller.selectedSortOption.value = value ?? '';
                                  controller.getAllFilteredLists();
                                },
                              )
                            ],
                          ),
                          Divider(),
                          Obx(
                            () => ListView.separated(
                              shrinkWrap: true,
                              controller: scrollController,
                              itemCount: controller.categoryService.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                ServiceModel serviceModel = controller.categoryService[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      serviceModel.name.toString().tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                        fontSize: 18,
                                        fontFamily: AppThemeData.boldOpenSans,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: serviceModel.options!.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index0) {
                                        return Obx(
                                          () => CheckboxListTile(
                                            title: Text(
                                              serviceModel.options![index0].name.toString(),
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                fontSize: 16,
                                                fontFamily: AppThemeData.mediumOpenSans,
                                              ),
                                            ),
                                            value: controller.selectedOptionsByServiceId[serviceModel.id]?.contains(serviceModel.options![index0]) ?? false,
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            visualDensity: VisualDensity.compact,
                                            // Reduces vertical & horizontal space
                                            onChanged: (value) {
                                              final id = serviceModel.id!;
                                              OptionModel option = serviceModel.options![index0];
                                              if (value == true) {
                                                List<OptionModel> updatedList = controller.selectedOptionsByServiceId[id] ?? [];
                                                updatedList.add(option);
                                                controller.selectedOptionsByServiceId[id] = updatedList;
                                              } else {
                                                final updatedList = controller.selectedOptionsByServiceId[id] ?? [];
                                                updatedList.remove(option);
                                                if (updatedList.isEmpty) {
                                                  controller.selectedOptionsByServiceId.remove(id);
                                                } else {
                                                  controller.selectedOptionsByServiceId[id] = updatedList;
                                                }
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Divider();
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  RoundedButtonFill(
                    title: 'Apply'.tr,
                    height: 5,
                    textColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                    color: themeChange.getThem() ? AppThemeData.redDark02 : AppThemeData.red02,
                    onPress: () {
                      Get.back();
                      controller.getAllFilteredLists();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true, // Allows BottomSheet to take full height
    );
  }

  Widget emptyView(themeChange, ScrollController scrollController, BusinessListController controller) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: controller.selectedCategory.value.name != null,
                child: Text(
                  'no_results_near'.trParams({
                    'category': controller.selectedCategory.value.name.toString(),
                  }).tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                    fontSize: 16,
                    fontFamily: AppThemeData.boldOpenSans,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Try using different or fewer keywords, or move the map and redo your search.".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                  fontSize: 14,
                  fontFamily: AppThemeData.regularOpenSans,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            thickness: 10,
            color: themeChange.getThem() ? AppThemeData.greyDark07 : AppThemeData.grey07,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notice something missing here?".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                        fontSize: 16,
                        fontFamily: AppThemeData.boldOpenSans,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RoundedButtonFill(
                      title: 'Add business'.tr,
                      height: 5.5,
                      textColor: themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03,
                      color: themeChange.getThem() ? AppThemeData.greyDark07 : AppThemeData.grey07,
                      onPress: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
              ),
              Image.asset(
                "assets/images/business_image.png",
                height: 140,
                width: 140,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget categoryChip(themeChange, CategoryModel label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05,
        ),
      ),
      child: Text(
        label.name.toString(),
        style: TextStyle(
          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
          fontSize: 14,
          fontFamily: AppThemeData.semiboldOpenSans,
        ),
      ),
    );
  }

  double getContentHeight() {
    return 200; // Calculate based on the actual content dynamically
  }
}
