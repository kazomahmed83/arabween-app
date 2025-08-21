import 'package:arabween/app/home_screen/business_list_screen.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/business_details_screen/business_details_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/search_controller.dart';
import 'package:arabween/models/business_history_model.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/text_field_widget.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: SearchControllers(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
            body: SafeArea(
              child: InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFieldWidget(
                          fillColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                          borderColor: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06,
                          controller: controller.categoryTextFieldController.value,
                          hintText: 'Cleaner, movers, sushi, delivery, etc.',
                          focusNode: controller.focusNode1,
                          onchange: (value) {
                            if (value.isEmpty) {
                              controller.searchBusinessList.clear();
                            }
                            controller.searchCategories(value.toLowerCase());
                          },
                          prefix: DebouncedInkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 5),
                              child: SvgPicture.asset(
                                "assets/icons/icon_left.svg",
                                colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          suffix: controller.categoryTextFieldController.value.text.isNotEmpty
                              ? DebouncedInkWell(
                                  onTap: () {
                                    controller.categoryTextFieldController.value.clear();
                                    controller.categories.clear();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 10),
                                    child: SvgPicture.asset(
                                      "assets/icons/close-one.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, BlendMode.srcIn),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFieldBorderWidget(
                                focusNode: controller.focusNode2,
                                fillColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                borderColor: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06,
                                controller: controller.locationTextFieldController.value,
                                hintText: 'Neighbourhood, city, state or postal code',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppThemeData.red02, // Yellow background
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.map_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    ShowToastDialog.showLoader("Please wait");
                                    Position? positions = await Utils.getCurrentLocation();
                                    ShowToastDialog.closeLoader();
                                    if (positions?.latitude != null) {
                                      Constant.currentLocationLatLng = LatLng(positions!.latitude, positions.longitude);
                                      Get.to(BusinessListScreen(), arguments: {
                                        "categoryModel": controller.selectedCategory.value,
                                        "latLng": Constant.currentLocationLatLng,
                                        "isZipCode": Constant.isNumeric(controller.locationTextFieldController.value.text.trim()),
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                        controller.isLocationSearch.value
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: controller.predictions.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    var prediction = controller.predictions[index];
                                    return ListTile(
                                      leading: Icon(Icons.location_on),
                                      title: Text(prediction['description']),
                                      onTap: () {
                                        controller.getPlaceDetails(prediction['place_id']);
                                      },
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    controller.categoryHistory.isEmpty
                                        ? SizedBox()
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10, bottom: 5),
                                                child: Text(
                                                  "Recently searched".tr,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.boldOpenSans,
                                                  ),
                                                ),
                                              ),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 0,
                                                children: controller.categoryHistory.map((item) {
                                                  return DebouncedInkWell(
                                                    onTap: () {
                                                      controller.categoryTextFieldController.value.text = item.category!.name.toString();
                                                      controller.selectedCategory.value = item.category!;
                                                      controller.navigateBusinessScree();
                                                    },
                                                    child: Chip(
                                                      label: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          NetworkImageWidget(
                                                            imageUrl: item.category!.icon.toString(),
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(item.category?.name ?? 'Unnamed'),
                                                        ],
                                                      ),
                                                      backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06),
                                                        borderRadius: BorderRadius.circular(20), // adjust radius
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                    controller.isCategoryLoading.value
                                        ? Constant.loader()
                                        : controller.categories.isEmpty
                                            ? controller.recentSearchHistory.isEmpty
                                                ? SizedBox()
                                                : controller.searchBusinessList.isNotEmpty
                                                    ? SizedBox()
                                                    : Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 20),
                                                          child: ListView(
                                                            padding: EdgeInsets.zero,
                                                            children: [
                                                              Text(
                                                                "Recently viewed businesses".tr,
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                  color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                                  fontSize: 16,
                                                                  fontFamily: AppThemeData.boldOpenSans,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                                child: Divider(),
                                                              ),
                                                              GridView.builder(
                                                                shrinkWrap: true,
                                                                physics: NeverScrollableScrollPhysics(),
                                                                itemCount: controller.recentSearchHistory.length,
                                                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                  crossAxisCount: 2,
                                                                  crossAxisSpacing: 10,
                                                                  mainAxisSpacing: 10,
                                                                  mainAxisExtent: 240,
                                                                ),
                                                                itemBuilder: (context, index) {
                                                                  BusinessHistoryModel businessHistoryModel = controller.recentSearchHistory[index];
                                                                  BusinessModel business = businessHistoryModel.business!;
                                                                  return DebouncedInkWell(
                                                                    onTap: () {
                                                                      Constant.setRecentBusiness(business);
                                                                      Get.to(BusinessDetailsScreen(), arguments: {"businessModel": business});
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
                                                                                          color: Constant.getBusinessStatus(business.businessHours).toLowerCase() == 'open'
                                                                                              ? AppThemeData.greenDark02
                                                                                              : AppThemeData.red01,
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
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                            : Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: ListView.builder(
                                                      itemCount: controller.categories.length > 4 ? 4 : controller.categories.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (context, index) {
                                                        CategoryModel category = controller.categories[index];
                                                        return FutureBuilder<List<CategoryModel>?>(
                                                          future: FireStoreUtils.getCategoryHierarchy(category),
                                                          builder: (context, snapshot) {
                                                            if (!snapshot.hasData) return SizedBox();
                                                            List<CategoryModel> parentCategory = snapshot.data!;
                                                            return DebouncedInkWell(
                                                              onTap: () {
                                                                controller.categoryTextFieldController.value.text = category.name.toString();
                                                                controller.selectedCategory.value = category;
                                                                controller.navigateBusinessScree();
                                                              },
                                                              child: SizedBox(
                                                                width: Responsive.width(100, context),
                                                                height: 35,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(Icons.search),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child: Wrap(
                                                                        spacing: 1, // Space between items
                                                                        runSpacing: 3, // Space between lines
                                                                        children: parentCategory.map((subcategory) {
                                                                          return Row(
                                                                            mainAxisSize: MainAxisSize.min, // Prevent unnecessary stretching
                                                                            children: [
                                                                              Text(
                                                                                subcategory.name.toString(),
                                                                                style: TextStyle(
                                                                                  color: parentCategory.indexOf(subcategory) == 0
                                                                                      ? (themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03)
                                                                                      : (themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                                                                                  fontSize: 14,
                                                                                  fontFamily: parentCategory.indexOf(subcategory) == 0 ? AppThemeData.regularOpenSans : AppThemeData.boldOpenSans,
                                                                                ),
                                                                              ),
                                                                              if (parentCategory.indexOf(subcategory) != parentCategory.length - 1)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                  child: SvgPicture.asset(
                                                                                    "assets/icons/icon_right.svg",
                                                                                    width: 20,
                                                                                    colorFilter: ColorFilter.mode(
                                                                                      themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03,
                                                                                      BlendMode.srcIn,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                    if (controller.searchBusinessList.isNotEmpty)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            itemCount: controller.searchBusinessList.length,
                                            padding: const EdgeInsets.symmetric(horizontal: 0),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              mainAxisExtent: 240,
                                            ),
                                            itemBuilder: (context, index) {
                                              BusinessModel business = controller.searchBusinessList[index];
                                              return DebouncedInkWell(
                                                onTap: () {
                                                  Constant.setRecentBusiness(business);
                                                  Get.to(BusinessDetailsScreen(), arguments: {"businessModel": business});
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
                                                            flex: 6,
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
                                                            flex: 3,
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
                                        ),
                                      ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }
}
//controller.searchBusinessList.length
