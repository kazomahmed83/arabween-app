import 'dart:developer';
import 'dart:io';
import 'package:arabween/app/create_bussiness_screen/service_address_screen.dart';
import 'package:arabween/app/highlight_screen/highlight_screen.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/highlight_model.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/create_bussiness_screen/category_selection_screen.dart';
import 'package:arabween/app/create_bussiness_screen/edit_address_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/controller/create_business_controller.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/text_field_widget.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';

class CreateBusinessScreen extends StatelessWidget {
  const CreateBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: CreateBusinessController(),
      builder: (controller) {
        return Form(
          key: controller.formKey.value,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
              centerTitle: true,
              leadingWidth: 120,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: DebouncedInkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/icon_close.svg",
                        width: 20,
                        colorFilter: ColorFilter.mode(
                          themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey01, // desired color
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Close".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 14, fontFamily: AppThemeData.semiboldOpenSans),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(color: themeChange.getThem() ? AppThemeData.greyDark08 : AppThemeData.grey08, height: 2.0),
              ),
              title: Text(
                "Add Business".tr,
                textAlign: TextAlign.start,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if (controller.formKey.value.currentState!.validate()) {
                      List<String> rawKeywords = controller.metaKeywordsController.value.text.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
                      bool hasInvalidKeyword = rawKeywords.any((k) => k.contains(' '));
                      if (hasInvalidKeyword) {
                        controller.metaKeywordsList.value = [];
                      }
                      controller.saveBusiness();
                    } else {
                      if (controller.businessModel.value.businessType == '') {
                        ShowToastDialog.showToast("Please select a business type");
                      } else if (controller.nameTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter a business name");
                      } else if (controller.arabicNameTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter a arabic business name");
                      } else if (controller.businessUrlTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter a seo slug");
                      } else if (controller.addressTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please select address");
                      } else if (controller.serviceAreaTextFieldController.value.text.isEmpty && controller.selectedBusinessType.value == 'Service Business') {
                        ShowToastDialog.showToast("Please add service area");
                      } else if (controller.selectedCategory.isEmpty) {
                        ShowToastDialog.showToast("Please select category");
                      } else if (controller.tagLineTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter a tagline");
                      } else if (controller.descriptionTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter a description");
                      } else if (controller.phoneNumberTextFieldController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter a phone no");
                      }
                    }
                  },
                  icon: Text(
                    controller.businessModel.value.id == null ? "Add" : "Update".tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 14, fontFamily: AppThemeData.boldOpenSans),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                controller: controller.scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 190,
                        decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.teal03 : AppThemeData.teal03, borderRadius: const BorderRadius.all(Radius.circular(150))),
                        child: DebouncedInkWell(
                          onTap: () {
                            buildBottomSheet(context, controller, 'profile');
                          },
                          child: controller.profileImage.isEmpty
                              ? SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Constant.svgPictureShow("assets/icons/icon_upload.svg", themeChange.getThem() ? AppThemeData.teal02 : AppThemeData.teal02, 20, 20),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Click to\nUpload Profile\nImage".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey02 : AppThemeData.grey02, fontFamily: AppThemeData.medium, fontSize: 12),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "${'Maximum\nUpload Size'.tr} ${Constant.profileCoverImageSizeMb}MB".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppThemeData.redDark02, fontFamily: AppThemeData.medium, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                )
                              : DebouncedInkWell(
                                  onTap: () {
                                    buildBottomSheet(context, controller, 'profile');
                                  },
                                  child: Constant().hasValidUrl(controller.profileImage.value) == false
                                      ? ClipOval(child: Image.file(File(controller.profileImage.value), height: 180, width: 180, fit: BoxFit.cover))
                                      : ClipOval(
                                          child: NetworkImageWidget(imageUrl: controller.profileImage.value.toString(), height: 180, width: 180, fit: BoxFit.cover),
                                        ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.teal03 : AppThemeData.teal03, borderRadius: const BorderRadius.all(Radius.circular(12))),
                      child: DebouncedInkWell(
                        onTap: () {
                          buildBottomSheet(context, controller, 'cover');
                        },
                        child: controller.coverImage.isEmpty
                            ? SizedBox(
                                height: Responsive.height(18, context),
                                width: Responsive.width(90, context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Constant.svgPictureShow("assets/icons/icon_upload.svg", themeChange.getThem() ? AppThemeData.teal02 : AppThemeData.teal02, 20, 20),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Click to \nUpload Cover Image".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey02 : AppThemeData.grey02, fontFamily: AppThemeData.medium, fontSize: 12),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "${'Maximum Upload Size'.tr} ${Constant.coverImageSizeMb}MB".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppThemeData.redDark02, fontFamily: AppThemeData.medium, fontSize: 10),
                                    ),
                                  ],
                                ),
                              )
                            : DebouncedInkWell(
                                onTap: () {
                                  buildBottomSheet(context, controller, 'cover');
                                },
                                child: Constant().hasValidUrl(controller.coverImage.value) == false
                                    ? ClipRRect(
                                        borderRadius: BorderRadiusGeometry.circular(8),
                                        child: Image.file(File(controller.coverImage.value), height: Responsive.height(18, context), width: Responsive.width(90, context), fit: BoxFit.cover),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadiusGeometry.circular(8),
                                        child: NetworkImageWidget(
                                          imageUrl: controller.coverImage.value.toString(),
                                          height: Responsive.height(18, context),
                                          width: Responsive.width(90, context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                      ),
                    ),
                    SizedBox(height: 10),
                    controller.businessModel.value.id != null
                        ? Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                              border: Border.all(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Permanently Closed?".tr,
                                      style: TextStyle(fontFamily: AppThemeData.boldOpenSans, fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.9, // Adjust the scale factor
                                    child: CupertinoSwitch(
                                      value: controller.isPermanentClosed.value,
                                      onChanged: (bool value) async {
                                        ShowToastDialog.showLoader("Please wait");
                                        controller.isPermanentClosed.value = value;
                                        controller.businessModel.value.isPermanentClosed = value;
                                        await FireStoreUtils.addBusiness(controller.businessModel.value);
                                        controller.update();
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast(value ? "Business closed" : "Business Reopened");
                                        Get.back();
                                      },
                                      activeTrackColor: AppThemeData.red02, // Color when switch is ON
                                      inactiveTrackColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, // Color when switch is OFF
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: 10),
                    Text(
                      'Required Information\'s'.tr,
                      style: TextStyle(fontFamily: AppThemeData.boldOpenSans, fontSize: 16, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFieldWidget(
                              title: 'Name',
                              controller: controller.nameTextFieldController.value,
                              hintText: 'Name',
                              onchange: (value) {
                                controller.businessSlug.value = controller.generateSlugAndUrl(input: value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                            ),
                            TextFieldWidget(
                              title: 'Name in arabic'.tr,
                              controller: controller.arabicNameTextFieldController.value,
                              hintText: 'Name in arabic'.tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                            ),
                            TextFieldWidget(
                              title: 'SEO Slug'.tr,
                              controller: controller.businessUrlTextFieldController.value,
                              hintText: 'SEO Slug'.tr,
                              textColor: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                              onchange: (value) {
                                controller.businessSlug.value = controller.generateSlugAndUrl(input: value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Note: This field applies to web based businesses.".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.regular, fontSize: 12),
                              ),
                            ),
                            Visibility(
                              visible: controller.businessSlug.value.isNotEmpty,
                              child: Column(
                                children: [
                                  Text(
                                    "${"Note: Your URL will look like :".tr} https://yoursite.com/business-detail/{RandomString}-${controller.businessSlug.value}",
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.regular, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFieldWidget(
                              title: 'Tagline'.tr,
                              controller: controller.tagLineTextFieldController.value,
                              hintText: 'Tagline'.tr,
                              maxLine: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                            ),
                            Text(
                              'Business Type'.tr,
                              style: TextStyle(fontFamily: AppThemeData.boldOpenSans, fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                            ),
                            const SizedBox(height: 5),
                            DropdownButtonFormField<String>(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                              hint: Text("Select Business Type".tr),
                              value: controller.selectedBusinessType.value == '' ? null : controller.selectedBusinessType.value,
                              onChanged: (String? newValue) {
                                controller.selectedBusinessType.value = newValue!;
                              },
                              items: controller.businessTypeList.map((String business) {
                                return DropdownMenuItem<String>(value: business, child: Text(business.toString()));
                              }).toList(),
                              style: TextStyle(color: (themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01), fontSize: 16, fontFamily: AppThemeData.medium),
                              decoration: InputDecoration(
                                filled: true,
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
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (controller.selectedBusinessType.value == 'Service Business')
                              DebouncedInkWell(
                                onTap: () {
                                  Get.to(() => const EditServiceAddressScreen())?.then((value) {
                                    ShowToastDialog.closeLoader();
                                    if (value is List<String> && value.isNotEmpty) {
                                      controller.selectedServiceArea
                                        ..clear()
                                        ..addAll(value)
                                        ..sort(); // Default alphabetical sort
                                      controller.serviceAreaTextFieldController.value.text = controller.selectedServiceArea.join(', ');
                                    }
                                  });
                                },
                                child: TextFieldWidget(
                                  title: 'Sevice Area'.tr,
                                  controller: controller.serviceAreaTextFieldController.value,
                                  hintText: 'Sevice Area'.tr,
                                  enable: false,
                                  suffix: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/icons/icon_right.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05, BlendMode.srcIn),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            TextFieldWidget(
                              title: 'Country'.tr,
                              controller: controller.countryNameTextFieldController.value,
                              hintText: 'Enter mobile number'.tr,
                              readOnly: true,
                              suffix: CountryCodePicker(
                                onChanged: (value) {
                                  controller.countryCodeController.value.text = value.dialCode.toString();
                                },
                                dialogTextStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                                dialogBackgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                initialSelection: "US",
                                comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                flagDecoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2))),
                                textStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                                searchDecoration: InputDecoration(iconColor: themeChange.getThem() ? AppThemeData.grey08 : AppThemeData.grey08),
                                searchStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                              ),
                            ),
                            DebouncedInkWell(
                              onTap: () {
                                Get.to(EditAddressScreen())?.then((value) {
                                  ShowToastDialog.closeLoader();
                                  if (value != null) {
                                    AddressModel addressModel = value;
                                    controller.location.value = LatLngModel(latitude: addressModel.lat, longitude: addressModel.lng);
                                    controller.address.value = addressModel;
                                    controller.addressTextFieldController.value.text = addressModel.formattedAddress.toString();
                                    log("addressModel :: ${addressModel.toJson()}");
                                  }
                                });
                              },
                              child: TextFieldWidget(
                                title: 'Address'.tr,
                                controller: controller.addressTextFieldController.value,
                                hintText: 'Address'.tr,
                                enable: false,
                                suffix: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    "assets/icons/icon_right.svg",
                                    colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05, BlendMode.srcIn),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '*';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            DebouncedInkWell(
                              onTap: () async {
                                final result = await Get.to(() => CategorySelectionScreen(), arguments: {"selectedCategories": controller.selectedCategory});

                                if (result is List<CategoryModel> && result.isNotEmpty) {
                                  final existingIds = controller.selectedCategory.map((e) => e.name).toSet();
                                  final newCategories = result.where((e) => !existingIds.contains(e.name)).toList();
                                  controller.selectedCategory.addAll(newCategories);
                                  controller.selectedCategory.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
                                  final text = controller.selectedCategory.map((e) => e.name ?? '').where((name) => name.isNotEmpty).join(', ');
                                  controller.categoryTextFieldController.value.text = text;
                                }
                              },
                              child: TextFieldWidget(
                                title: 'Category'.tr,
                                controller: controller.categoryTextFieldController.value,
                                enable: false,
                                hintText: 'Category'.tr,
                                suffix: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    "assets/icons/icon_right.svg",
                                    colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05, BlendMode.srcIn),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '*';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            TextFieldWidget(
                              title: 'Description'.tr,
                              controller: controller.descriptionTextFieldController.value,
                              hintText: 'Description'.tr,
                              maxLine: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                            ),
                            TextFieldWidget(
                              title: 'Phone No'.tr,
                              controller: controller.phoneNumberTextFieldController.value,
                              hintText: 'Phone No'.tr,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Optional Details'.tr,
                      style: TextStyle(fontFamily: AppThemeData.boldOpenSans, fontSize: 16, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFieldWidget(
                              title: 'SEO Meta Keywords'.tr,
                              controller: controller.metaKeywordsController.value,
                              hintText: 'SEO Meta Keywords'.tr,
                              maxLine: 4,
                              onchange: (value) {
                                if (value.trim().isNotEmpty) {
                                  List<String> rawKeywords = value.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
                                  bool hasInvalidKeyword = rawKeywords.any((k) => k.contains(' '));
                                  if (hasInvalidKeyword) {
                                    controller.metaKeywordsList.value = [];
                                    ShowToastDialog.showToast("Please enter keywords in a comma-separated list without spaces.".tr);
                                    return;
                                  }
                                  controller.metaKeywordsList.value = rawKeywords;
                                }
                              },
                            ),
                            Text(
                              "Note: This field applies to web based businesses.".tr,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.regular, fontSize: 12),
                            ),
                            SizedBox(height: 10),
                            TextFieldWidget(
                              title: 'Business Website Url'.tr,
                              controller: controller.websiteTextFieldController.value,
                              hintText: 'Business Website Url'.tr,
                              suffix: IconButton(onPressed: () {}, icon: SvgPicture.asset("assets/icons/global-line.svg", height: 20, width: 20, color: AppThemeData.red02)),
                            ),
                            TextFieldWidget(
                              title: 'Booking Website Url'.tr,
                              controller: controller.bookingLinkTextFieldController.value,
                              hintText: 'Booking Website Url'.tr,
                              suffix: IconButton(onPressed: () {}, icon: SvgPicture.asset("assets/icons/global-line.svg", height: 20, width: 20, color: AppThemeData.red02)),
                            ),
                            TextFieldWidget(
                              title: 'Facebook link'.tr,
                              controller: controller.fbLinkTextFieldController.value,
                              hintText: 'Facebook link'.tr,
                              suffix: IconButton(onPressed: () {}, icon: Image.asset("assets/images/fb.png", height: 20, width: 20)),
                            ),
                            TextFieldWidget(
                              title: 'Instagram Link'.tr,
                              controller: controller.instaLinkTextFieldController.value,
                              hintText: 'Instagram Link'.tr,
                              suffix: IconButton(onPressed: () {}, icon: Image.asset("assets/images/insta.png", height: 20, width: 20)),
                            ),
                            TextFieldWidget(
                              title: 'Notes for our team'.tr,
                              controller: controller.notesOfTheYelpTeamTextFieldController.value,
                              hintText: 'Provide any additional information so we can make this business’s information as accurate as possible.'.tr,
                              maxLine: 5,
                            ),
                            Text(
                              'Highlights from the business'.tr,
                              style: TextStyle(fontFamily: AppThemeData.boldOpenSans, fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                            ),
                            const SizedBox(height: 10),
                            TextFieldWidget(
                              onTap: () {
                                Get.to(HighlightScreen(), arguments: {'type': 'signup', 'highLightsList': controller.highLightsList})?.then((value) {
                                  if (value is List && value.isNotEmpty) {
                                    controller.highLightsList.value = value;
                                    controller.update();
                                  }
                                });
                              },
                              readOnly: true,
                              controller: controller.highlightTextFieldController.value,
                              hintText: 'Select Business Highlight'.tr,
                              suffix: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  "assets/icons/icon_right.svg",
                                  colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            if (controller.highLightsList.isNotEmpty == true)
                              SizedBox(
                                height: Responsive.height(10, Get.context!),
                                child: ListView.separated(
                                  itemCount: controller.highLightsList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    String highLightsListId = controller.highLightsList[index];

                                    return FutureBuilder<HighlightModel?>(
                                      future: FireStoreUtils.getHighlightModelById(highLightsListId),
                                      builder: (context, asyncSnapshot) {
                                        if (!asyncSnapshot.hasData) {
                                          return SizedBox();
                                        } else {
                                          HighlightModel model = asyncSnapshot.data ?? HighlightModel();
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: SizedBox(
                                              width: Responsive.width(20, Get.context!),
                                              child: Column(
                                                children: [
                                                  NetworkImageWidget(imageUrl: model.photo.toString(), width: 36, height: 36),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    model.title.toString(),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.semiboldOpenSans,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Divider(color: themeChange.getThem() ? AppThemeData.greyDark07 : AppThemeData.grey07),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Business Hours'.tr,
                              style: TextStyle(fontFamily: AppThemeData.boldOpenSans, fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Open All the Time 24/7".tr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey01, fontFamily: AppThemeData.medium),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.9, // Adjust the scale factor
                                  child: CupertinoSwitch(
                                    value: controller.isOpenBusinessAllTime.value,
                                    onChanged: (bool value) async {
                                      controller.isOpenBusinessAllTime.value = value;
                                    },
                                    activeTrackColor: AppThemeData.red02, // Color when switch is ON
                                    inactiveTrackColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, // Color when switch is OFF
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            if (controller.isOpenBusinessAllTime.value == false) const Divider(),
                            if (controller.isOpenBusinessAllTime.value == false) const SizedBox(height: 5),
                            controller.isOpenBusinessAllTime.value == true
                                ? SizedBox()
                                : ListView(
                                    primary: false,
                                    shrinkWrap: true,
                                    children: controller.businessWeek.entries.map((entry) => _buildDayEditor(context, controller, entry.key, entry.value)).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayEditor(BuildContext context, CreateBusinessController controller, String day, DayHours hours) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                day[0].toUpperCase() + day.substring(1),
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey01, fontFamily: AppThemeData.medium),
              ),
            ),
            Transform.scale(
              scale: 0.9, // Adjust the scale factor
              child: CupertinoSwitch(
                value: hours.isOpen,
                onChanged: (bool value) async {
                  controller.businessWeek[day] = DayHours(isOpen: value, timeRanges: hours.timeRanges);
                },
                activeTrackColor: AppThemeData.red02, // Color when switch is ON
                inactiveTrackColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, // Color when switch is OFF
              ),
            ),
          ],
        ),
        if (hours.isOpen)
          Column(
            children: [
              for (int i = 0; i < hours.timeRanges.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedTime = await Constant.pickTime(context: context, initialTime: hours.timeRanges[i].open);
                            if (pickedTime != null) {
                              hours.timeRanges[i].open = pickedTime;
                              controller.businessWeek.refresh();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                              border: Border.all(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Text(
                                'Open - ${hours.timeRanges[i].open.format(context)}'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: AppThemeData.semiboldOpenSans, fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedTime = await Constant.pickTime(context: context, initialTime: hours.timeRanges[i].close);
                            if (pickedTime != null) {
                              hours.timeRanges[i].close = pickedTime;
                              controller.businessWeek.refresh();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                              border: Border.all(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Text(
                                'Close: ${hours.timeRanges[i].close.format(context)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: AppThemeData.semiboldOpenSans, fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          hours.timeRanges.removeAt(i);
                          controller.businessWeek.refresh();
                        },
                        child: Constant.svgPictureShow("assets/icons/icon_delete-one.svg", themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, null, null),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    hours.timeRanges.add(TimeRange(open: const TimeOfDay(hour: 9, minute: 0), close: const TimeOfDay(hour: 17, minute: 0)));
                    controller.businessWeek.refresh();
                  },
                  icon: const Icon(Icons.add),
                  label: Text("Add Hours".tr),
                ),
              ),
            ],
          ),
        const Divider(),
      ],
    );
  }

  buildBottomSheet(BuildContext context, CreateBusinessController controller, String imageType) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.bold, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => controller.pickFile(source: ImageSource.camera, imageType: imageType).then((value) {
                                if (value is String && value.isNotEmpty) {
                                  ShowToastDialog.showToast(value.toString());
                                }
                              }),
                              icon: const Icon(Icons.camera_alt, size: 32),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 3), child: Text("Camera".tr)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => controller.pickFile(source: ImageSource.gallery, imageType: imageType).then((value) {
                                if (value is String && value.isNotEmpty) {
                                  ShowToastDialog.showToast(value.toString());
                                }
                              }),
                              icon: const Icon(Icons.photo_library_sharp, size: 32),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 3), child: Text("Gallery".tr)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
