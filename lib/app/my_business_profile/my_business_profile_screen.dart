import 'package:arabween/widgets/readmore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/add_hours_screen/add_hours_screen.dart';
import 'package:arabween/app/add_menu_photos/add_menu_photos.dart';
import 'package:arabween/app/add_service_screen/add_service_screen.dart';
import 'package:arabween/app/business_details_screen/see_full_menu_screen.dart';
import 'package:arabween/app/check_in_screen/add_check_in_screen.dart';
import 'package:arabween/app/complain_report_screen/complain_report_screen.dart';
import 'package:arabween/app/create_bussiness_screen/create_business_screen.dart';
import 'package:arabween/app/highlight_screen/highlight_screen.dart';
import 'package:arabween/app/other_people_screen/other_people_screen.dart';
import 'package:arabween/app/photo_screen/photo_screen.dart';
import 'package:arabween/app/webview_screen/webview_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/controller/my_business_profile_controller.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/highlight_model.dart';
import 'package:arabween/models/item_model.dart';
import 'package:arabween/models/review_model.dart';
import 'package:arabween/models/service_model.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/service/ad_manager.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/round_button_border.dart';
import 'package:arabween/themes/round_button_fill.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/utils/utils.dart';
import 'package:arabween/widgets/bookmark_bottomsheet.dart';
import 'package:arabween/widgets/custom_star_rating/custom_star_rating_screen.dart';
import 'package:arabween/widgets/review_photo_view.dart';
import 'package:arabween/widgets/review_user_view.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';
import '../add_review_screen/add_review_screen.dart';

class MyBusinessProfileScreen extends StatelessWidget {
  const MyBusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: MyBusinessProfileController(),
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: controller.isLoading.value
                ? Constant.loader()
                : NestedScrollView(
                    controller: controller.scrollController,
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight: Responsive.height(46, context),
                          floating: false,
                          pinned: true,
                          scrolledUnderElevation: 0,
                          automaticallyImplyLeading: false,
                          leadingWidth: 120,
                          leading: DebouncedInkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Row(
                              children: [
                                Constant.svgPictureShow(
                                  "assets/icons/icon_left.svg",
                                  innerBoxIsScrolled
                                      ? themeChange.getThem()
                                          ? AppThemeData.greyDark01
                                          : AppThemeData.grey01
                                      : AppThemeData.grey10,
                                  26,
                                  26,
                                ),
                                Text(
                                  "Back".tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: innerBoxIsScrolled
                                        ? themeChange.getThem()
                                            ? AppThemeData.greyDark01
                                            : AppThemeData.grey01
                                        : AppThemeData.grey10,
                                    fontSize: 14,
                                    fontFamily: AppThemeData.semiboldOpenSans,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  DebouncedInkWell(
                                    onTap: () async {
                                      var result = await Get.bottomSheet(
                                        BookMarkBottomSheet(businessModel: controller.businessModel.value),
                                        isScrollControlled: true,
                                        backgroundColor: AppThemeData.grey10,
                                      );

                                      if (result == true) {
                                        await controller.getBusiness();
                                      }
                                    },
                                    child: Obx(
                                      () => Constant.svgPictureShow(
                                        controller.businessModel.value.bookmarkUserId!.contains(FireStoreUtils.getCurrentUid())
                                            ? "assets/icons/bookmark-one_fill.svg"
                                            : "assets/icons/icon_bookmark-one.svg",
                                        controller.businessModel.value.bookmarkUserId!.contains(FireStoreUtils.getCurrentUid())
                                            ? AppThemeData.red02
                                            : innerBoxIsScrolled
                                                ? themeChange.getThem()
                                                    ? AppThemeData.greyDark01
                                                    : AppThemeData.grey01
                                                : AppThemeData.grey10,
                                        24,
                                        24,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  DebouncedInkWell(
                                    onTap: () async {
                                      showCupertinoActionSheet(themeChange, context, controller);
                                    },
                                    child: Constant.svgPictureShow(
                                      "assets/icons/icon_more.svg",
                                      innerBoxIsScrolled
                                          ? themeChange.getThem()
                                              ? AppThemeData.greyDark01
                                              : AppThemeData.grey01
                                          : AppThemeData.grey10,
                                      24,
                                      24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Padding(
                              padding: const EdgeInsets.only(bottom: 50),
                              child: Stack(
                                children: [
                                  controller.businessModel.value.coverPhoto != null && controller.businessModel.value.coverPhoto!.isNotEmpty
                                      ? Stack(
                                          children: [
                                            NetworkImageWidget(
                                              width: Responsive.width(100, context),
                                              height: Responsive.width(100, context),
                                              imageUrl: controller.businessModel.value.coverPhoto.toString(),
                                              fit: BoxFit.cover,
                                            ),
                                            Container(width: Responsive.width(100, context), height: Responsive.width(100, context), color: Colors.black.withOpacity(0.70)),
                                          ],
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: AssetImage("assets/images/business_cover_placeholder.png"), fit: BoxFit.cover),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 24,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            controller.businessModel.value.profilePhoto != null && controller.businessModel.value.profilePhoto!.isNotEmpty
                                                ? ClipOval(
                                                    child: NetworkImageWidget(
                                                      width: Responsive.width(15, context),
                                                      height: Responsive.width(15, context),
                                                      imageUrl: controller.businessModel.value.profilePhoto.toString(),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : ClipOval(
                                                    child: Container(
                                                      width: Responsive.width(15, context),
                                                      height: Responsive.width(15, context),
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(image: AssetImage("assets/images/business_cover_placeholder.png"), fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                  ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  controller.businessModel.value.isVerified == true
                                                      ? RoundedButtonFill(
                                                          title: 'Claimed'.tr,
                                                          height: 3,
                                                          width: 28,
                                                          fontSizes: 12,
                                                          isRight: true,
                                                          isCenter: true,
                                                          icon: Icon(
                                                            Icons.info_outline,
                                                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                            size: 16,
                                                          ),
                                                          textColor: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                          color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                          onPress: () {},
                                                        )
                                                      : RoundedButtonFill(
                                                          title: 'Unclaimed'.tr,
                                                          height: 3,
                                                          width: 30,
                                                          fontSizes: 12,
                                                          isRight: true,
                                                          isCenter: true,
                                                          icon: Icon(Icons.info_outline, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, size: 16),
                                                          textColor: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                          color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                          onPress: () {
                                                            ShowToastDialog.showLoader("Please wait");
                                                            Get.to(WebviewScreen(), arguments: {'url': Constant.claimBusinessURL});
                                                          },
                                                        ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    controller.businessModel.value.businessName ?? '',
                                                    maxLines: 1,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey10, fontSize: 24, fontFamily: AppThemeData.bold),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      CustomStarRating(
                                                        size: 18,
                                                        enable: false,
                                                        bgColor: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.grey03,
                                                        emptyColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                        initialRating: Constant.calculateReview(
                                                          reviewCount: controller.businessModel.value.reviewCount!,
                                                          reviewSum: controller.businessModel.value.reviewSum!,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        Constant.calculateReview(reviewCount: controller.businessModel.value.reviewCount!, reviewSum: controller.businessModel.value.reviewSum!),
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey10,
                                                          fontSize: 14,
                                                          fontFamily: AppThemeData.semiboldOpenSans,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "(${double.parse(controller.businessModel.value.reviewCount.toString()).toStringAsFixed(0)} reviews)",
                                                        maxLines: 1,
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey10,
                                                          fontSize: 14,
                                                          fontFamily: AppThemeData.semiboldOpenSans,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Text(
                                                      Constant.getCategoryNames(controller.businessModel.value.category).tr,
                                                      maxLines: 1,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey10,
                                                        fontSize: 14,
                                                        fontFamily: AppThemeData.semiboldOpenSans,
                                                      ),
                                                    ),
                                                  ),
                                                  controller.businessModel.value.businessHours == null || controller.businessModel.value.showWorkingHours == false
                                                      ? SizedBox()
                                                      : controller.businessModel.value.isBusinessOpenAllTime == true
                                                          ? Padding(
                                                              padding: const EdgeInsets.only(top: 5),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    "Open 24/7".tr,
                                                                    textAlign: TextAlign.start,
                                                                    style: TextStyle(
                                                                      color: themeChange.getThem() ? AppThemeData.greenDark03 : AppThemeData.greenDark03,
                                                                      fontSize: 14,
                                                                      fontFamily: AppThemeData.boldOpenSans,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Padding(
                                                              padding: const EdgeInsets.only(top: 5),
                                                              child: Row(
                                                                children: [
                                                                  Constant.buildStatusText(themeChange, Constant.getBusinessStatus(controller.businessModel.value.businessHours!), false),
                                                                  SizedBox(width: 10),
                                                                  Icon(Icons.circle_rounded, size: 8, color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10),
                                                                  SizedBox(width: 10),
                                                                  DebouncedInkWell(
                                                                    onTap: () {
                                                                      seeHoursFilterBottomSheet(themeChange, controller);
                                                                    },
                                                                    child: Text(
                                                                      "See hours".tr,
                                                                      textAlign: TextAlign.start,
                                                                      style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemeData.teal02 : AppThemeData.teal02,
                                                                          fontSize: 14,
                                                                          fontFamily: AppThemeData.boldOpenSans),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        ReadMoreText(
                                          controller.businessModel.value.tagLine ?? '',
                                          trimLines: 2,
                                          colorClickableText: Colors.pink,
                                          trimMode: TrimMode.Line,
                                          trimCollapsedText: 'Show more',
                                          trimExpandedText: 'Show less',
                                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey10, fontSize: 14, fontFamily: AppThemeData.mediumOpenSans),
                                          moreStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.red02 : AppThemeData.red02, fontSize: 14, fontFamily: AppThemeData.boldOpenSans),
                                        ),
                                        SizedBox(height: 20),
                                        Obx(
                                          () => RoundedButtonFill(
                                            title: controller.allPhotos.isEmpty ? 'Upload Photo' : 'See all ${controller.allPhotos.length} images'.tr,
                                            height: 4.5,
                                            textColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                            color: themeChange.getThem() ? AppThemeData.redDark02 : AppThemeData.grey02,
                                            onPress: () {
                                              Get.to(PhotoScreen(), arguments: {"businessModel": controller.businessModel.value});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          bottom: PreferredSize(
                            preferredSize: Size.fromHeight(48),
                            child: Align(
                              alignment: Alignment.centerLeft, // 👈 Align to left
                              child: Container(
                                color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                child: TabBar(
                                  controller: controller.tabController,
                                  isScrollable: false,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  // or Tab if you want full tab width
                                  // 👈 This makes it scrollable
                                  onTap: (value) {
                                    controller.currentIndex.value = value;
                                    if (controller.hasPricing() && controller.hasMenuItem()) {
                                      if (value == 0) {
                                        controller.scrollToSection(controller.getTouch);
                                      } else if (value == 1) {
                                        controller.scrollToSection(controller.menuKey);
                                      } else if (value == 2) {
                                        controller.scrollToSection(controller.infoKey);
                                      } else {
                                        controller.scrollToSection(controller.reviewKey);
                                      }
                                    } else if (controller.hasPricing() || controller.hasMenuItem()) {
                                      if (value == 0) {
                                        if (controller.hasPricing()) {
                                          controller.scrollToSection(controller.getTouch);
                                        } else {
                                          controller.scrollToSection(controller.getTouch);
                                        }
                                      } else if (value == 1) {
                                        controller.scrollToSection(controller.infoKey);
                                      } else {
                                        controller.scrollToSection(controller.reviewKey);
                                      }
                                    } else {
                                      if (value == 0) {
                                        controller.scrollToSection(controller.infoKey);
                                      } else {
                                        controller.scrollToSection(controller.reviewKey);
                                      }
                                    }
                                  },
                                  indicatorColor: themeChange.getThem() ? AppThemeData.red02 : AppThemeData.red02,
                                  labelColor: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                  unselectedLabelColor: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 5),
                                  // 👈 Equal padding
                                  indicator: UnderlineTabIndicator(
                                    insets: EdgeInsets.symmetric(horizontal: controller.tabController.length > 3 ? -20 : -50),
                                    borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.red02 : AppThemeData.red02, width: 4),
                                  ),
                                  tabs: controller.hasPricing() && controller.hasMenuItem()
                                      ? [Tab(text: "Get in touch".tr), Tab(text: "Menu".tr), Tab(text: "Info".tr), Tab(text: "Reviews".tr)]
                                      : controller.hasPricing() || controller.hasMenuItem()
                                          ? [controller.hasPricing() ? Tab(text: "Get in touch".tr) : Tab(text: "Menu".tr), Tab(text: "Info".tr), Tab(text: "Reviews".tr)]
                                          : [Tab(text: "Info".tr), Tab(text: "Reviews".tr)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: Container(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10, child: infoPage(themeChange, controller)),
                  ),
          ),
        );
      },
    );
  }

  Widget infoPage(themeChange, MyBusinessProfileController controller) {
    return Obx(
      () => SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdManager.bannerAdWidget(),
            controller.hasPricing() == false
                ? SizedBox()
                : Container(
                    key: controller.getTouch,
                    width: Responsive.width(100, Get.context!),
                    decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10, borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Book Your Appointment".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 18, fontFamily: AppThemeData.boldOpenSans),
                          ),
                          SizedBox(height: 8),
                          RoundedButtonFill(
                            title: 'Book Now'.tr,
                            height: 5,
                            textColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                            color: themeChange.getThem() ? AppThemeData.redDark02 : AppThemeData.red02,
                            onPress: () {
                              // Get.to(PricingFormScreen(), arguments: {
                              //   "businessModel": controller.businessModel.value,
                              //   "categoryModel": controller.businessModel.value.category!.firstWhere((category) => category.getPricingForm == true),
                              // });
                              if (controller.businessModel.value.bookingWebsite?.isEmpty == true || controller.businessModel.value.bookingWebsite == '') {
                                ShowToastDialog.showToast("Book Now Website not available".tr);
                              } else {
                                ShowToastDialog.showLoader("Please wait");
                                Get.to(WebviewScreen(), arguments: {'url': controller.businessModel.value.bookingWebsite.toString(), 'title': "Book Now".tr})?.then((value) {
                                  ShowToastDialog.closeLoader();
                                });
                                // Utils.launchURL(controller.businessModel.value.website.toString());
                              }
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
            controller.hasMenuItem() == false
                ? SizedBox()
                : Container(
                    key: controller.menuKey,
                    width: Responsive.width(100, Get.context!),
                    decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10, borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Menu".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Popular dishes".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: Responsive.height(18, Get.context!),
                            child: controller.itemList.isEmpty
                                ? Constant.showEmptyView(message: "Menu Item Not available")
                                : ListView.builder(
                                    itemCount: controller.itemList.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      ItemModel itemModel = controller.itemList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          child: Stack(
                                            children: [
                                              NetworkImageWidget(imageUrl: itemModel.images!.first, width: Responsive.width(60, Get.context!), fit: BoxFit.cover),
                                              Container(width: Responsive.width(60, Get.context!), color: Colors.black.withOpacity(0.20)),
                                              Positioned(
                                                bottom: 10,
                                                child: SizedBox(
                                                  width: Responsive.width(60, Get.context!),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          itemModel.name.toString(),
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                            fontSize: 16,
                                                            fontFamily: AppThemeData.semiboldOpenSans,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          child: Text(
                                                            itemModel.description.toString(),
                                                            textAlign: TextAlign.start,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                              fontSize: 10,
                                                              fontFamily: AppThemeData.boldOpenSans,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "${controller.currency.value.symbol} ${double.parse(itemModel.price.toString()).toStringAsFixed(2)}".tr,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                                            fontSize: 14,
                                                            fontFamily: AppThemeData.boldOpenSans,
                                                          ),
                                                        ),
                                                      ],
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
                          SizedBox(height: 10),
                          controller.itemList.isEmpty
                              ? SizedBox()
                              : RoundedButtonFill(
                                  title: 'See full menu'.tr,
                                  height: 5,
                                  textColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                  color: themeChange.getThem() ? AppThemeData.redDark02 : AppThemeData.red02,
                                  onPress: () {
                                    Get.to(SeeFullMenuScreen(), arguments: {"businessModel": controller.businessModel.value});
                                  },
                                ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
            Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
            Obx(
              () => controller.businessModel.value.recommendUserId!.contains(FireStoreUtils.getCurrentUid())
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "Do you recommend this business?".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RoundedButtonBorder(
                                      title: 'Yes',
                                      height: 4,
                                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                      onPress: () {
                                        controller.businessModel.value.recommendYesCount = (double.parse(controller.businessModel.value.recommendYesCount.toString()) + 1).toString();
                                        controller.updateRecommended("yes");
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: RoundedButtonBorder(
                                      title: 'No',
                                      height: 4,
                                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                      onPress: () {
                                        controller.updateRecommended("no");
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: RoundedButtonBorder(
                                      title: 'Maybe',
                                      height: 4,
                                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                      onPress: () {
                                        controller.updateRecommended("maybe");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Container(
              key: controller.infoKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Info".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      controller.businessModel.value.businessHours == null || controller.businessModel.value.showWorkingHours == false
                          ? SizedBox()
                          : controller.businessModel.value.isBusinessOpenAllTime == true
                              ? Expanded(
                                  child: Column(
                                    children: [
                                      ClipOval(
                                          child: Container(
                                        decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey07,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Constant.svgPictureShow("assets/icons/icon_alarm-clock.svg", AppThemeData.red02, null, null),
                                        ),
                                      )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Open 24/7".tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                          fontSize: 16,
                                          fontFamily: AppThemeData.boldOpenSans,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: DebouncedInkWell(
                                    onTap: () {
                                      seeHoursFilterBottomSheet(themeChange, controller);
                                    },
                                    child: Column(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey07),
                                            child: Padding(
                                              padding: const EdgeInsets.all(14),
                                              child: Constant.svgPictureShow("assets/icons/icon_alarm-clock.svg", AppThemeData.red02, null, null),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Hours".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
                                        ),
                                        controller.businessModel.value.businessHours == null
                                            ? SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: buildStatusText(themeChange, Constant.getBusinessStatus(controller.businessModel.value.businessHours!)),
                                              ),
                                        SizedBox(height: 5),
                                        controller.businessModel.value.businessHours == null || Constant.getBusinessStatus(controller.businessModel.value.businessHours!) == 'Closed'
                                            ? SizedBox()
                                            : Text(
                                                Constant.getTodaySingleTimeSlot(controller.businessModel.value.businessHours!).tr,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03, fontSize: 12, fontFamily: AppThemeData.regularOpenSans),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                      Expanded(
                        child: DebouncedInkWell(
                          onTap: () {
                            if (controller.businessModel.value.website?.isEmpty == true || controller.businessModel.value.website == '') {
                              ShowToastDialog.showToast("Website not available".tr);
                            } else {
                              Get.to(WebviewScreen(), arguments: {'url': controller.businessModel.value.website.toString()});
                            }
                          },
                          child: Column(
                            children: [
                              ClipOval(
                                child: Container(
                                  decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey07),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Constant.svgPictureShow("assets/icons/icon_globe.svg", AppThemeData.red02, null, null),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Website".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
                              ),
                              // Text(
                              //   "${controller.businessModel.value.website}".tr,
                              //   textAlign: TextAlign.center,
                              //   style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03, fontSize: 12, fontFamily: AppThemeData.regularOpenSans),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: DebouncedInkWell(
                          onTap: () {
                            if (controller.businessModel.value.phoneNumber?.isEmpty == true) {
                              ShowToastDialog.showToast("Phone number not available ".tr);
                            } else {
                              Utils.dialPhoneNumber("${controller.businessModel.value.countryCode} ${controller.businessModel.value.phoneNumber}");
                            }
                          },
                          child: Column(
                            children: [
                              ClipOval(
                                child: Container(
                                  decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey07),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Constant.svgPictureShow("assets/icons/icon_phone-call.svg", AppThemeData.red02, null, null),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Call".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
                              ),
                              // Text(
                              //   "${controller.businessModel.value.countryCode} ${controller.businessModel.value.phoneNumber}".tr,
                              //   textAlign: TextAlign.start,
                              //   style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark03 : AppThemeData.grey03, fontSize: 12, fontFamily: AppThemeData.regularOpenSans),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09,
                      height: 14,
                    ),
                  ),
                  descWidget(controller, themeChange),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
                  ),
                  controller.businessModel.value.serviceArea?.isNotEmpty == true && controller.businessModel.value.businessType == 'Service Business'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Service Area".tr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                      fontSize: 20,
                                      fontFamily: AppThemeData.boldOpenSans,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: controller.businessModel.value.serviceArea!.map((item) {
                                      return Chip(
                                        padding: EdgeInsets.all(0),
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(item),
                                          ],
                                        ),
                                        backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06),
                                          borderRadius: BorderRadius.circular(20), // adjust radius
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            height: 200,
                            width: Responsive.width(100, Get.context!),
                            child: Obx(
                              () => GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(double.parse(controller.businessModel.value.location!.latitude ?? "0.0"), double.parse(controller.businessModel.value.location!.longitude ?? "0.0")),
                                  // Example coordinates
                                  zoom: 16,
                                ),
                                markers: controller.markers,
                                onMapCreated: controller.onMapCreated,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${Constant.getFullAddressModel(controller.businessModel.value.address!)}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(height: 1, color: themeChange.getThem() ? AppThemeData.greyDark08 : AppThemeData.grey08),
                                ),
                                DebouncedInkWell(
                                  onTap: () {
                                    Utils.openMap(
                                      label: controller.businessModel.value.businessName.toString(),
                                      lat: double.parse(controller.businessModel.value.location!.latitude.toString()),
                                      lng: double.parse(controller.businessModel.value.location!.longitude.toString()),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Get Direction".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
                                        ),
                                      ),
                                      Constant.svgPictureShow('assets/icons/icon_map-draw.svg', AppThemeData.red02, 24, 24),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ]),
                  if (controller.businessModel.value.fbLink?.isNotEmpty == true || controller.businessModel.value.instaLink?.isNotEmpty == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Social media links".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                  fontSize: 20,
                                  fontFamily: AppThemeData.boldOpenSans,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (controller.businessModel.value.fbLink?.isNotEmpty == true)
                                    DebouncedInkWell(
                                      onTap: () async {
                                        Get.to(WebviewScreen(), arguments: {'url': controller.businessModel.value.fbLink.toString()});
                                      },
                                      child: imageWidget(themeChange, "assets/images/fb.png", "Facebook link"),
                                    ),
                                  if (controller.businessModel.value.instaLink?.isNotEmpty == true)
                                    DebouncedInkWell(
                                      onTap: () {
                                        Get.to(WebviewScreen(), arguments: {'url': controller.businessModel.value.instaLink.toString()});
                                      },
                                      child: imageWidget(themeChange, "assets/images/insta.png", "Instagram link"),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
                      ],
                    ),
                ],
              ),
            ),
            if (controller.businessModel.value.fbLink?.isEmpty == true)
              if (controller.highLightList.isNotEmpty && controller.serviceList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                  child: Divider(color: themeChange.getThem() ? AppThemeData.greyDark07 : AppThemeData.grey07),
                ),
            controller.highLightList.isEmpty == true
                ? SizedBox()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: controller.businessModel.value.fbLink?.isEmpty == true ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Highlights from the business".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            itemCount: controller.highLightList.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              HighlightModel item = controller.highLightList[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: SizedBox(
                                  width: Responsive.width(20, Get.context!),
                                  child: Column(
                                    children: [
                                      NetworkImageWidget(imageUrl: item.photo.toString(), width: 36, height: 36),
                                      SizedBox(height: 10),
                                      Text(
                                        item.title.toString(),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 12, fontFamily: AppThemeData.semiboldOpenSans),
                                      ),
                                    ],
                                  ),
                                ),
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
                      ],
                    ),
                  ),
            if (controller.serviceList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                child: Divider(color: themeChange.getThem() ? AppThemeData.greyDark07 : AppThemeData.grey07),
              ),
            controller.serviceList.isEmpty
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                    child: ListView.separated(
                      itemCount: controller.serviceList.length,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final item = controller.serviceList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(item['options'].length, (index) {
                                OptionModel optionModel = item['options'][index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      NetworkImageWidget(
                                        imageUrl: optionModel.icon.toString(),
                                        width: 22,
                                        height: 22,
                                        color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        optionModel.name.toString(),
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.regularOpenSans),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Share this business".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DebouncedInkWell(
                        onTap: () async {
                          // String mobile = "${controller.businessModel.value.countryCode}${controller.businessModel.value.phoneNumber}".replaceAll('+', '');
                          // if (await Utils.isWhatsAppInstalled(mobile) == true) {
                          await Utils.sendWhatsAppMessage(
                              phoneNumber: '', message: "${controller.businessModel.value.businessName} \n ${Constant.deepLinkUrl}${Constant.businessDeepLink}${controller.businessModel.value.slug}");
                          // } else {
                          //   Utils.sendSMS(
                          //       phoneNumber: '',
                          //       message: "${controller.businessModel.value.businessName} \n ${Constant.deepLinkUrl}${Constant.businessDeepLink}${controller.businessModel.value.slug}");
                          // }
                        },
                        child: imageWidget(themeChange, "assets/icons/ic_whatapp.svg", "Message"),
                      ),
                      DebouncedInkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: "${Constant.deepLinkUrl}${Constant.businessDeepLink}${controller.businessModel.value.slug}")).then((_) {
                            ShowToastDialog.showToast("Link Copied");
                          });
                        },
                        child: imageWidget(themeChange, "assets/icons/icon_copy.svg", "Copy link"),
                      ),
                      DebouncedInkWell(
                        onTap: () {
                          Utils.shareBusiness("${controller.businessModel.value.businessName} \n ${Constant.deepLinkUrl}${Constant.businessDeepLink}${controller.businessModel.value.slug}");
                        },
                        child: imageWidget(themeChange, "assets/icons/icon_more-one.svg", "More"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
            Container(
              width: Responsive.width(100, Get.context!),
              decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Leave a review".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // soft shadow
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2), // vertical offset
                          ),
                        ],
                      ),
                      child: DebouncedInkWell(
                        onTap: () {
                          Get.to(AddReviewScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                            if (value == true) {
                              controller.getReview();
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReviewUserView(userId: Constant.userModel!.id.toString()),
                              SizedBox(height: 10),
                              CustomStarRating(
                                initialRating: "0.0",
                                enable: false,
                                bgColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                emptyColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Tap to review".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: AppThemeData.red02,
                                  fontSize: 14,
                                  fontFamily: AppThemeData.semiboldOpenSans,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
            Container(
              key: controller.reviewKey,
              child: controller.reviewList.isEmpty
                  ? Container(
                      width: Responsive.width(100, Get.context!),
                      color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No Review yet".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                            ),
                            SizedBox(height: 10),
                            DebouncedInkWell(
                              onTap: () {
                                Get.to(AddReviewScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                                  if (value == true) {
                                    controller.getReview();
                                  }
                                });
                              },
                              child: Container(
                                width: Responsive.width(100, Get.context!),
                                decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10, borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Be the first to review ".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
                                        ),
                                      ),
                                      Image.asset("assets/images/send_review.gif", height: 50, width: 50),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Recommended reviews".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                          ),
                        ),
                        overallRatingWidget(themeChange, controller.businessModel.value, controller.reviewList),
                        Container(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey09, height: 14),
                        SizedBox(height: 10),
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: controller.reviewList.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            ReviewModel reviewModel = controller.reviewList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DebouncedInkWell(
                                          onTap: () async {
                                            ShowToastDialog.showLoader("Please wait");
                                            UserModel? userModel0 = await FireStoreUtils.getUserProfile(reviewModel.userId.toString());
                                            ShowToastDialog.closeLoader();
                                            Get.to(OtherPeopleScreen(), arguments: {"userModel": userModel0});
                                          },
                                          child: ReviewUserView(userId: reviewModel.userId.toString()),
                                        ),
                                      ),
                                      DebouncedInkWell(
                                        onTap: () {
                                          showReviewCupertinoActionSheet(themeChange, context, controller, reviewModel);
                                        },
                                        child: Constant.svgPictureShow("assets/icons/icon_more.svg", AppThemeData.red02, 30, 30),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      CustomStarRating(
                                        initialRating: reviewModel.review.toString(),
                                        enable: false,
                                        bgColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                        emptyColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        Constant.timeAgo(reviewModel.createdAt!).tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04, fontSize: 12, fontFamily: AppThemeData.regularOpenSans),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${reviewModel.comment}".tr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 14, fontFamily: AppThemeData.regularOpenSans),
                                  ),
                                  SizedBox(height: 8),
                                  ReviewPhotoView(reviewId: reviewModel.id.toString()),
                                  SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DebouncedInkWell(
                                        onTap: () async {
                                          if (reviewModel.helpful!.contains(FireStoreUtils.getCurrentUid())) {
                                            reviewModel.helpful!.remove(FireStoreUtils.getCurrentUid());
                                          } else {
                                            reviewModel.helpful!.add(FireStoreUtils.getCurrentUid());
                                          }
                                          FireStoreUtils.updateReview(reviewModel);
                                          controller.updateReviewList(index, reviewModel);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: reviewModel.helpful!.contains(FireStoreUtils.getCurrentUid()) ? AppThemeData.red02 : Colors.transparent,
                                                border: Border.all(
                                                  color: reviewModel.helpful!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.red02
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark05
                                                          : AppThemeData.grey05,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                              ),
                                              child: Center(
                                                child: Constant.svgPictureShow(
                                                  "assets/icons/icon_light.svg",
                                                  reviewModel.helpful!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.grey10
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark02
                                                          : AppThemeData.grey02,
                                                  24,
                                                  24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text.rich(
                                              TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: 'Helpful ',
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.regularOpenSans,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: reviewModel.helpful!.length.toString(),
                                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 12, fontFamily: AppThemeData.semibold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DebouncedInkWell(
                                        onTap: () async {
                                          if (reviewModel.thanks!.contains(FireStoreUtils.getCurrentUid())) {
                                            reviewModel.thanks!.remove(FireStoreUtils.getCurrentUid());
                                          } else {
                                            reviewModel.thanks!.add(FireStoreUtils.getCurrentUid());
                                          }
                                          FireStoreUtils.updateReview(reviewModel);
                                          controller.updateReviewList(index, reviewModel);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: reviewModel.thanks!.contains(FireStoreUtils.getCurrentUid()) ? AppThemeData.red02 : Colors.transparent,
                                                border: Border.all(
                                                  color: reviewModel.thanks!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.red02
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark05
                                                          : AppThemeData.grey05,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                              ),
                                              child: Center(
                                                child: Constant.svgPictureShow(
                                                  "assets/icons/icon_thumbs-up.svg",
                                                  reviewModel.thanks!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.grey10
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark02
                                                          : AppThemeData.grey02,
                                                  24,
                                                  24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text.rich(
                                              TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: 'Thanks ',
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.regularOpenSans,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: reviewModel.thanks!.length.toString(),
                                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 12, fontFamily: AppThemeData.semibold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DebouncedInkWell(
                                        onTap: () async {
                                          if (reviewModel.loveThis!.contains(FireStoreUtils.getCurrentUid())) {
                                            reviewModel.loveThis!.remove(FireStoreUtils.getCurrentUid());
                                          } else {
                                            reviewModel.loveThis!.add(FireStoreUtils.getCurrentUid());
                                          }
                                          FireStoreUtils.updateReview(reviewModel);
                                          controller.updateReviewList(index, reviewModel);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: reviewModel.loveThis!.contains(FireStoreUtils.getCurrentUid()) ? AppThemeData.red02 : Colors.transparent,
                                                border: Border.all(
                                                  color: reviewModel.loveThis!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.red02
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark05
                                                          : AppThemeData.grey05,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                              ),
                                              child: Center(
                                                child: Constant.svgPictureShow(
                                                  "assets/icons/icon_like.svg",
                                                  reviewModel.loveThis!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.grey10
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark02
                                                          : AppThemeData.grey02,
                                                  24,
                                                  24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text.rich(
                                              TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: 'Love this ',
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.regularOpenSans,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: reviewModel.loveThis!.length.toString(),
                                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 12, fontFamily: AppThemeData.semibold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DebouncedInkWell(
                                        onTap: () async {
                                          if (reviewModel.ohNo!.contains(FireStoreUtils.getCurrentUid())) {
                                            reviewModel.ohNo!.remove(FireStoreUtils.getCurrentUid());
                                          } else {
                                            reviewModel.ohNo!.add(FireStoreUtils.getCurrentUid());
                                          }
                                          FireStoreUtils.updateReview(reviewModel);
                                          controller.updateReviewList(index, reviewModel);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: reviewModel.ohNo!.contains(FireStoreUtils.getCurrentUid()) ? AppThemeData.red02 : Colors.transparent,
                                                border: Border.all(
                                                  color: reviewModel.ohNo!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.red02
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark05
                                                          : AppThemeData.grey05,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                              ),
                                              child: Center(
                                                child: Constant.svgPictureShow(
                                                  "assets/icons/icon_emotion-unhappy.svg",
                                                  reviewModel.ohNo!.contains(FireStoreUtils.getCurrentUid())
                                                      ? AppThemeData.grey10
                                                      : themeChange.getThem()
                                                          ? AppThemeData.greyDark02
                                                          : AppThemeData.grey02,
                                                  24,
                                                  24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text.rich(
                                              TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: 'Oh no ',
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.regularOpenSans,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: reviewModel.ohNo!.length.toString(),
                                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 12, fontFamily: AppThemeData.semibold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Divider(color: themeChange.getThem() ? AppThemeData.greyDark07 : AppThemeData.grey07),
                            );
                          },
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: RoundedButtonBorder(
                      title: 'Add Photo',
                      height: 5.5,
                      icon: Constant.svgPictureShow("assets/icons/icon_picture.svg", themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, null, null),
                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                      isRight: false,
                      onPress: () {
                        Get.to(PhotoScreen(), arguments: {"businessModel": controller.businessModel.value});
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: RoundedButtonBorder(
                      title: 'Check in',
                      height: 5.5,
                      icon: Constant.svgPictureShow("assets/icons/icon_check-one.svg", themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, null, null),
                      isRight: false,
                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                      onPress: () {
                        Get.to(AddCheckInScreen(), arguments: {"businessModel": controller.businessModel.value});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  descWidget(MyBusinessProfileController controller, themeChange) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description".tr,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
              fontSize: 20,
              fontFamily: AppThemeData.boldOpenSans,
            ),
          ),
          SizedBox(height: 5),
          Text(
            controller.businessModel.value.description ?? '',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
              fontSize: 14,
              fontFamily: AppThemeData.semiboldOpenSans,
            ),
          ),
        ],
      ),
    );
  }

  void showCommentCupertinoActionSheet(themeChange, BuildContext context, MyBusinessProfileController controller, ReviewModel reviewModel) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Utils.shareBusiness("${controller.businessModel.value.businessName} \n\n${reviewModel.comment} \n${"Review : ${reviewModel.review}"}");
            },
            child: Text(
              "Share Review".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          if (Constant.userModel?.id != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
                Get.to(ComplainReportScreen(), arguments: {"type": Constant.reviewIssues, "givenBy": reviewModel.userId.toString(), "postId": reviewModel.id.toString()});
              },
              child: Text(
                "Complain/Report".tr,
                textAlign: TextAlign.start,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
          },
          child: Text(
            "Cancel".tr,
            textAlign: TextAlign.start,
            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
          ),
        ),
      ),
    );
  }

  void showCupertinoActionSheet(themeChange, BuildContext context, MyBusinessProfileController controller) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              Get.to(CreateBusinessScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                if (value == true) {
                  controller.getBusiness();
                }
              });
            },
            child: Text(
              "Edit Business".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.to(AddCheckInScreen(), arguments: {"businessModel": controller.businessModel.value});
            },
            child: Text(
              "Check In".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.to(AddReviewScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                if (value == true) {
                  controller.getReview();
                }
              });
            },
            child: Text(
              "Add Review".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              Get.to(AddHoursScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                if (value == true) {
                  controller.getReview();
                }
              });
            },
            child: Text(
              "Add Hours".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              Get.to(AddServiceScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                if (value == true) {
                  controller.getBusiness();
                }
              });
            },
            child: Text(
              "Add Service".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              Get.to(HighlightScreen(), arguments: {"businessModel": controller.businessModel.value})!.then((value) {
                if (value == true) {
                  controller.getBusiness();
                }
              });
            },
            child: Text(
              "Add Business Highlight".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          Visibility(
            visible: controller.hasMenuPhotos(),
            child: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
                Get.to(AddMenuPhotos(), arguments: {"businessModel": controller.businessModel.value});
              },
              child: Text(
                "Add Menu Photo".tr,
                textAlign: TextAlign.start,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Get.back();
              var result = await Get.bottomSheet(BookMarkBottomSheet(businessModel: controller.businessModel.value), isScrollControlled: true, backgroundColor: AppThemeData.grey10);

              if (result == true) {
                await controller.getBusiness();
              }
            },
            child: Text(
              "Save Business".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Utils.shareBusiness("${controller.businessModel.value.businessName} \n ${Constant.deepLinkUrl}${Constant.businessDeepLink}${controller.businessModel.value.slug}");
            },
            child: Text(
              "Share Business".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
          },
          child: Text(
            "Cancel".tr,
            textAlign: TextAlign.start,
            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
          ),
        ),
      ),
    );
  }

  Widget imageWidget(themeChange, String imagePath, String title) {
    return Column(
      children: [
        ClipOval(
          child: Container(
            decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey07),
            child: Padding(padding: const EdgeInsets.all(14), child: Constant.svgPictureShow(imagePath, AppThemeData.red02, 20, 20)),
          ),
        ),
        SizedBox(height: 5),
        Text(
          title.tr,
          textAlign: TextAlign.start,
          style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, fontSize: 12, fontFamily: AppThemeData.mediumOpenSans),
        ),
      ],
    );
  }

  seeHoursFilterBottomSheet(themeChange, MyBusinessProfileController controller) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: controller.businessModel.value.isBusinessOpenAllTime == true ? 0.1 : 0.4,
        // Starts at 30% of screen height
        minChildSize: controller.businessModel.value.isBusinessOpenAllTime == true ? 0.1 : 0.4,
        // Minimum height (30% of screen)
        maxChildSize: controller.businessModel.value.isBusinessOpenAllTime == true ? 0.2 : 0.9,
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
            child: controller.businessModel.value.isBusinessOpenAllTime == true
                ? Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Opening Hours".tr,
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                            fontSize: 20,
                            fontFamily: AppThemeData.boldOpenSans,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Text(
                              "Open 24/7".tr,
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                fontSize: 20,
                                fontFamily: AppThemeData.boldOpenSans,
                              ),
                            ),
                            SizedBox(width: 10),
                            ClipOval(
                                child: Container(
                              decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppThemeData.greyDark08 : AppThemeData.grey06,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Constant.svgPictureShow("assets/icons/icon_alarm-clock.svg", AppThemeData.red02, null, null),
                              ),
                            )),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                      DebouncedInkWell(
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
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Hours".tr,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 22, fontFamily: AppThemeData.boldOpenSans),
                            ),
                          ),
                          DebouncedInkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: SvgPicture.asset(
                                  "assets/icons/icon_close.svg",
                                  width: 22,
                                  colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, BlendMode.srcIn),
                                )),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          itemCount: controller.days.length,
                          itemBuilder: (context, index) {
                            final day = controller.days[index];
                            final isToday = day == DateFormat('EEEE').format(DateTime.now());
                            final slots = Constant.getFormattedSlots(
                              Constant.getDayHours(
                                controller.businessModel.value.businessHours ?? BusinessHours(sunday: [], monday: [], thursday: [], wednesday: [], tuesday: [], friday: [], saturday: []),
                                day,
                              ),
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                        fontSize: 16,
                                        fontFamily: isToday ? AppThemeData.boldOpenSans : AppThemeData.mediumOpenSans,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: slots
                                        .map(
                                          (slot) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
                                            child: Text(
                                              slot,
                                              style: TextStyle(
                                                color: slot == "Closed"
                                                    ? AppThemeData.red02
                                                    : themeChange.getThem()
                                                        ? AppThemeData.greyDark01
                                                        : AppThemeData.grey01,
                                                fontSize: 14,
                                                fontFamily: isToday ? AppThemeData.boldOpenSans : AppThemeData.regularOpenSans,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
      isScrollControlled: true, // Allows BottomSheet to take full height
      isDismissible: false,
    );
  }

  Widget overallRatingWidget(themeChange, BusinessModel businessModel, List<ReviewModel> reviews) {
    Map<double, double> ratingCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    // Count how many reviews are in each rating bucket
    for (var review in reviews) {
      double rating = double.parse(review.review.toString());
      if (ratingCount.containsKey(rating)) {
        ratingCount[rating] = ratingCount[rating]! + 1;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                'Overall rating',
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 14, fontFamily: AppThemeData.semiboldOpenSans),
              ),
              const SizedBox(height: 10),
              CustomStarRating(
                initialRating: Constant.calculateReview(reviewCount: businessModel.reviewCount!, reviewSum: businessModel.reviewSum!),
                enable: false,
                size: 20,
                bgColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                emptyColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
              ),
              const SizedBox(height: 10),
              Text(
                '${double.parse(businessModel.reviewCount.toString()).toStringAsFixed(0)} reviews',
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04, fontSize: 14, fontFamily: AppThemeData.semiboldOpenSans),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                int star = 5 - index;
                double count = ratingCount[star] ?? 0;
                double percent = double.parse(businessModel.reviewCount!) > 0 ? count / double.parse(businessModel.reviewCount!) : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 12, fontFamily: AppThemeData.semiboldOpenSans),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              star == 5
                                  ? Colors.orange
                                  : star == 4
                                      ? Colors.orange
                                      : Colors.amber,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showReviewCupertinoActionSheet(themeChange, BuildContext context, MyBusinessProfileController controller, ReviewModel reviewModel) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Utils.shareBusiness("${controller.businessModel.value.businessName} \n\n${reviewModel.comment} \n${"Review : ${reviewModel.review}"}");
            },
            child: Text(
              "Share Review".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              Get.to(ComplainReportScreen(), arguments: {"type": Constant.reviewIssues, "givenBy": reviewModel.userId.toString(), "postId": reviewModel.id.toString()});
            },
            child: Text(
              "Complain/Report".tr,
              textAlign: TextAlign.start,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.tealDark02 : AppThemeData.teal02, fontSize: 16, fontFamily: AppThemeData.semiboldOpenSans),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
          },
          child: Text(
            "Cancel".tr,
            textAlign: TextAlign.start,
            style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 16, fontFamily: AppThemeData.boldOpenSans),
          ),
        ),
      ),
    );
  }

  Widget buildStatusText(themeChange, String status) {
    TextStyle defaultStyle = TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04, fontFamily: AppThemeData.boldOpenSans);
    TextStyle openStyle = TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.greenDark02 : AppThemeData.green02, fontFamily: AppThemeData.boldOpenSans);
    TextStyle closedStyle = TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.greenDark02 : AppThemeData.red02, fontFamily: AppThemeData.boldOpenSans);

    if (status.startsWith("Open until")) {
      return RichText(
        text: TextSpan(
          children: [TextSpan(text: "Open Now", style: openStyle)],
        ),
      );
    } else if (status.startsWith("Closed until")) {
      return RichText(
        text: TextSpan(
          children: [TextSpan(text: "Closed", style: closedStyle)],
        ),
      );
    } else if (status == "Closed") {
      return RichText(
        text: TextSpan(text: "Closed", style: closedStyle),
      );
    } else {
      return Text(status, style: defaultStyle);
    }
  }
}
