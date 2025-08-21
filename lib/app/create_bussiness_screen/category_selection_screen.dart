import 'dart:developer';

import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/category_selection_controller.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/text_field_widget.dart';
import 'package:arabween/utils/dark_theme_provider.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: CategorySelectionController(),
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
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4.0),
                  child: Container(
                    color: themeChange.getThem() ? AppThemeData.greyDark08 : AppThemeData.grey08,
                    height: 2.0,
                  ),
                ),
                title: Text(
                  "Select Categories".tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                    fontSize: 16,
                    fontFamily: AppThemeData.semiboldOpenSans,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      if (controller.selectedCategories.isEmpty) {
                        ShowToastDialog.showToast("Please select at least one category.");
                      } else {
                        log("controller.selectedCategories :: ${controller.selectedCategories.length}");
                        Get.back(result: controller.selectedCategories);
                      }
                    },
                    icon: Text(
                      "Add".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02,
                        fontSize: 14,
                        fontFamily: AppThemeData.boldOpenSans,
                      ),
                    ),
                  )
                ],
              ),
              body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(children: [
                    TextFieldWidget(
                      controller: controller.searchController.value,
                      hintText: 'Search a category...',
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset("assets/icons/icon_search.svg", colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03, BlendMode.srcIn)),
                      ),
                      suffix: InkWell(
                        onTap: () {
                          controller.searchController.value.clear();
                          controller.categories.clear();
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
                    Expanded(
                      child: controller.isLoading.value
                          ? Constant.loader()
                          : controller.searchCategoriesList.isEmpty
                              ? Constant.showEmptyView(message: "Categories Not available".tr)
                              : ListView.builder(
                                  shrinkWrap: true,
                                  // physics: NeverScrollableScrollPhysics(),
                                  itemCount: controller.searchCategoriesList.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    CategoryModel categoryModel = controller.searchCategoriesList[index];
                                    return categoryModel.children != null && categoryModel.children!.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              ShowToastDialog.showLoader("Please wait");
                                              await controller.getSubCategory(categoryModel).then(
                                                (value) {
                                                  ShowToastDialog.closeLoader();
                                                  showCategoryBottomSheet(themeChange, controller, categoryModel);
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                child: Row(
                                                  children: [
                                                    ClipOval(
                                                      child: NetworkImageWidget(
                                                        imageUrl: categoryModel.icon.toString(),
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "${categoryModel.name}".tr,
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                          fontSize: 16,
                                                          fontFamily: AppThemeData.regularOpenSans,
                                                        ),
                                                      ),
                                                    ),
                                                    categoryModel.children != null && categoryModel.children!.isNotEmpty
                                                        ? SizedBox(
                                                            width: 40,
                                                            height: 40,
                                                            child: Center(
                                                              child: Constant.svgPictureShow(
                                                                "assets/icons/content.svg",
                                                                themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                                20,
                                                                20,
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox()
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
                                            child: Obx(
                                              () => Container(
                                                color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  child: CheckboxListTile(
                                                    value: isSelected(controller, categoryModel),
                                                    dense: true,
                                                    contentPadding: EdgeInsets.zero,
                                                    onChanged: (bool? value) {
                                                      if (isSelected(controller, categoryModel)) {
                                                        controller.selectedCategories.remove(categoryModel);
                                                      } else {
                                                        controller.selectedCategories.add(categoryModel);
                                                      }
                                                    },
                                                    title: Row(
                                                      children: [
                                                        NetworkImageWidget(
                                                          width: 30,
                                                          height: 30,
                                                          fit: BoxFit.cover,
                                                          imageUrl: categoryModel.icon.toString(),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          categoryModel.name ?? '',
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                            fontSize: 16,
                                                            fontFamily: AppThemeData.regularOpenSans,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    controlAffinity: ListTileControlAffinity.trailing,
                                                    // Checkbox on the left
                                                    activeColor: AppThemeData.red02, // Change color as needed
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                    ),
                  ])));
        });
  }

  bool isSelected(
    CategorySelectionController controller,
    CategoryModel model,
  ) {
    final index = controller.selectedCategories.indexWhere((e) => e.name == model.name);
    if (index == -1) return false;
    return controller.selectedCategories[index].name == model.name;
  }

  void showCategoryBottomSheet(themeChange, CategorySelectionController controller, CategoryModel parentCategoryModel) {
    Get.bottomSheet(
      Container(
        height: Responsive.height(80, Get.context!),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  "assets/icons/icon_close.svg",
                  width: 20,
                  colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            ClipOval(
                              child: NetworkImageWidget(
                                imageUrl: parentCategoryModel.icon.toString(),
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                "${parentCategoryModel.name}".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                  fontSize: 14,
                                  fontFamily: AppThemeData.boldOpenSans,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "or something more specific...".tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                      fontSize: 14,
                      fontFamily: AppThemeData.boldOpenSans,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: controller.subCategoryList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          CategoryModel categoryModel = controller.subCategoryList[index];
                          return categoryModel.children != null && categoryModel.children!.isNotEmpty
                              ? InkWell(
                                  onTap: () async {
                                    ShowToastDialog.showLoader("Please wait");
                                    await controller.getSubCategory(categoryModel).then(
                                      (value) {
                                        ShowToastDialog.closeLoader();
                                        showCategoryBottomSheet(themeChange, controller, categoryModel);
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              NetworkImageWidget(
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.cover,
                                                imageUrl: categoryModel.icon.toString(),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                categoryModel.name ?? '',
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                  fontSize: 16,
                                                  fontFamily: AppThemeData.regularOpenSans,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        categoryModel.children != null && categoryModel.children!.isNotEmpty
                                            ? SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Center(
                                                  child: Constant.svgPictureShow(
                                                    "assets/icons/content.svg",
                                                    themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                    20,
                                                    20,
                                                  ),
                                                ),
                                              )
                                            : SizedBox()
                                      ],
                                    ),
                                  ),
                                )
                              : Obx(
                                  () => Container(
                                    color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                      child: CheckboxListTile(
                                        value: isSelected(controller, categoryModel),
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (bool? value) {
                                          if (isSelected(controller, categoryModel)) {
                                            controller.selectedCategories.remove(categoryModel);
                                          } else {
                                            controller.selectedCategories.add(categoryModel);
                                          }
                                        },
                                        title: Row(
                                          children: [
                                            NetworkImageWidget(
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              imageUrl: categoryModel.icon.toString(),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              categoryModel.name ?? '',
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                fontSize: 16,
                                                fontFamily: AppThemeData.regularOpenSans,
                                              ),
                                            ),
                                          ],
                                        ),
                                        controlAffinity: ListTileControlAffinity.trailing,
                                        // Checkbox on the left
                                        activeColor: AppThemeData.red02, // Change color as needed
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true, // Allows BottomSheet to take full height
    );
  }
}
