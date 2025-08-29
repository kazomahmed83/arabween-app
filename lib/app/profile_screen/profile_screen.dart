import 'package:arabween/app/auth_screen/welcome_screen.dart';
import 'package:arabween/app/profile_screen/all_review_screen.dart';
import 'package:arabween/app/profile_screen/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/add_review_screen/add_review_screen.dart';
import 'package:arabween/app/business_details_screen/business_details_screen.dart';
import 'package:arabween/app/check_in_screen/check_in_list_screen.dart';
import 'package:arabween/app/create_bussiness_screen/create_business_screen.dart';
import 'package:arabween/app/other_people_screen/compliments_list_screen.dart';
import 'package:arabween/app/other_people_screen/followers_list.dart';
import 'package:arabween/app/other_people_screen/following_list.dart';
import 'package:arabween/app/search_screen/search_screen.dart';
import 'package:arabween/app/user_photo_screen/user_photo_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/dashboard_controller.dart';
import 'package:arabween/controller/profile_controller.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/service/ad_manager.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/round_button_border.dart';
import 'package:arabween/themes/round_button_fill.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/widgets/custom_star_rating/custom_star_rating_screen.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ProfileController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
              centerTitle: false,
              leadingWidth: 70,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(
                  color: themeChange.getThem() ? AppThemeData.greyDark08 : AppThemeData.grey08,
                  height: 2.0,
                ),
              ),
              actions: [],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: Responsive.width(100, context),
                          decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Column(
                                      children: [
                                        ClipOval(
                                          child: NetworkImageWidget(
                                            imageUrl: controller.userModel.value.profilePic.toString(),
                                            width: 100,
                                            height: 100,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          controller.userModel.value.id != null ? controller.userModel.value.fullName() : '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 20, fontFamily: AppThemeData.boldOpenSans),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/icon_user-business.svg", themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05, 20, 20),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "0",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05,
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.boldOpenSans,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/review_show.svg", null, 20, 20),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${controller.reviewList.length}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05,
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.boldOpenSans,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/icon_picture.svg", themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05, 20, 20),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${controller.photoList.length}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05,
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.boldOpenSans,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              DebouncedInkWell(
                                                onTap: () {
                                                  Get.to(SearchScreen());
                                                },
                                                child: imageWidget(themeChange, "assets/icons/star.svg", "Add Review"),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    Get.to(SearchScreen());
                                                  },
                                                  child: imageWidget(themeChange, "assets/icons/icon_add-pic.svg", "Add Photo")),
                                              if (controller.userModel.value.id != null)
                                                InkWell(
                                                    onTap: () {
                                                      Get.to(CheckInListScreen(), arguments: {"userModel": controller.userModel.value});
                                                    },
                                                    child: imageWidget(themeChange, "assets/icons/icon_check-one.svg", "Check In")),
                                              InkWell(
                                                  onTap: () {
                                                    if (FireStoreUtils.getCurrentUid() == '') {
                                                      Get.offAll(WelcomeScreen());
                                                    } else {
                                                      showCustomBottomSheet(themeChange, context);
                                                    }
                                                  },
                                                  child: imageWidget(themeChange, "assets/icons/icon_shop.svg", "Add Business")),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (FireStoreUtils.getCurrentUid() != '')
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(EditProfileScreen())?.then((value) {
                                                if (value == true) {
                                                  controller.getData();
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/ic_edit.svg", themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02, null, null),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontFamily: AppThemeData.semibold,
                                                    color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.userModel.value.id != null)
                          SizedBox(
                            height: 20,
                          ),
                        if (controller.userModel.value.id != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Share your experience".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                        fontSize: 20,
                                        fontFamily: AppThemeData.boldOpenSans,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: controller.suggestedBusinessList.length > 3 ? 3 : controller.suggestedBusinessList.length,
                                      itemBuilder: (context, index) {
                                        BusinessModel businessModel = controller.suggestedBusinessList[index];
                                        return InkWell(
                                          onTap: () {
                                            Constant.setRecentBusiness(businessModel);
                                            Get.to(BusinessDetailsScreen(), arguments: {"businessModel": businessModel});
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                  child: NetworkImageWidget(
                                                    imageUrl: businessModel.profilePhoto ?? '',
                                                    width: Responsive.width(12, context),
                                                    height: Responsive.width(12, context),
                                                    fit: BoxFit.cover,
                                                    errorWidget: Constant.svgPictureShow("assets/icons/ic_placeholder_bussiness.svg", null, 50, 50),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              businessModel.businessName.toString(),
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily: AppThemeData.semiboldOpenSans,
                                                                color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              businessModel.suggestedBusinessRemovedUserId!.add(FireStoreUtils.getCurrentUid());
                                                              FireStoreUtils.addBusiness(businessModel);
                                                            },
                                                            child: Icon(
                                                              Icons.close,
                                                              color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      businessModel.recommendUserId!.contains(FireStoreUtils.getCurrentUid())
                                                          ? InkWell(
                                                              onTap: () {
                                                                Get.to(AddReviewScreen(), arguments: {"businessModel": businessModel});
                                                              },
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  CustomStarRating(
                                                                    initialRating: Constant.calculateReview(
                                                                      reviewCount: businessModel.reviewCount!,
                                                                      reviewSum: businessModel.reviewSum!,
                                                                    ),
                                                                    size: 18,
                                                                    enable: false,
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "Do you recommend this business?".tr,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04,
                                                                    fontSize: 12,
                                                                    fontFamily: AppThemeData.regularOpenSans,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    RoundedButtonBorder(
                                                                      title: 'Yes',
                                                                      height: 3,
                                                                      width: 14,
                                                                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                                                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                                      onPress: () {
                                                                        businessModel.recommendYesCount = (double.parse(businessModel.recommendYesCount.toString()) + 1).toString();
                                                                        controller.updateRecommended("yes", businessModel);
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    RoundedButtonBorder(
                                                                      title: 'No',
                                                                      height: 3,
                                                                      width: 14,
                                                                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                                                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                                      onPress: () {
                                                                        controller.updateRecommended("no", businessModel);
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    RoundedButtonBorder(
                                                                      title: 'Maybe',
                                                                      height: 3,
                                                                      width: 20,
                                                                      borderColor: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                                                                      textColor: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                                                      onPress: () {
                                                                        controller.updateRecommended("maybe", businessModel);
                                                                      },
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: AdManager.bannerAdWidget(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (controller.userModel.value.id != null)
                          SizedBox(
                            height: 20,
                          ),
                        if (controller.userModel.value.id != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        "Contributions".tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                          fontSize: 20,
                                          fontFamily: AppThemeData.boldOpenSans,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Get.to(AllReviewScreen());
                                            },
                                            child: Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/star.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Review".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                      fontSize: 16,
                                                      fontFamily: AppThemeData.semiboldOpenSans,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${controller.reviewList.length}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                    fontSize: 16,
                                                    fontFamily: AppThemeData.semiboldOpenSans,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.to(UserPhotoScreen(), arguments: {"userModel": controller.userModel.value});
                                            },
                                            child: Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/picture.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Photos".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                      fontSize: 16,
                                                      fontFamily: AppThemeData.semiboldOpenSans,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${controller.photoList.length}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                    fontSize: 16,
                                                    fontFamily: AppThemeData.semiboldOpenSans,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              DashBoardController controller = Get.put(DashBoardController());
                                              controller.selectedIndex.value = 3;
                                            },
                                            child: Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/icon_shop.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Added Business".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                      fontSize: 16,
                                                      fontFamily: AppThemeData.semiboldOpenSans,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${controller.myBusinessList.length}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                    fontSize: 16,
                                                    fontFamily: AppThemeData.semiboldOpenSans,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              DashBoardController controller = Get.put(DashBoardController());
                                              controller.selectedIndex.value = 2;
                                            },
                                            child: Row(
                                              children: [
                                                Constant.svgPictureShow("assets/icons/icon_bookmark-one.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Collections".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                      fontSize: 16,
                                                      fontFamily: AppThemeData.semiboldOpenSans,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${controller.bookMarkList.length}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                    fontSize: 16,
                                                    fontFamily: AppThemeData.semiboldOpenSans,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (controller.userModel.value.id != null)
                          SizedBox(
                            height: 20,
                          ),
                        if (controller.userModel.value.id != null)
                          controller.myBusinessList.isEmpty == true
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              "Community".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                fontSize: 20,
                                                fontFamily: AppThemeData.boldOpenSans,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Divider(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(FollowersList(), arguments: {"userModel": controller.userModel.value, "myProfile": true})!.then(
                                                      (value) {
                                                        controller.getUser();
                                                      },
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Constant.svgPictureShow("assets/icons/peoples-two.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Followers".tr,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                            fontSize: 16,
                                                            fontFamily: AppThemeData.semiboldOpenSans,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${controller.userModel.value.followers!.length}",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                          fontSize: 16,
                                                          fontFamily: AppThemeData.semiboldOpenSans,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(FollowingList(), arguments: {"userModel": controller.userModel.value, "myProfile": true})!.then(
                                                      (value) {
                                                        controller.getUser();
                                                      },
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Constant.svgPictureShow("assets/icons/peoples-two.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Following".tr,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                            fontSize: 16,
                                                            fontFamily: AppThemeData.semiboldOpenSans,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${controller.followingList.length}",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                          fontSize: 16,
                                                          fontFamily: AppThemeData.semiboldOpenSans,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(ComplimentsListScreen(), arguments: {"userModel": controller.userModel.value});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Constant.svgPictureShow("assets/icons/icon_hot-air-balloon.svg", themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, 24, 24),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Compliments".tr,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                            fontSize: 16,
                                                            fontFamily: AppThemeData.semiboldOpenSans,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${controller.complimentsList.length}",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                          fontSize: 16,
                                                          fontFamily: AppThemeData.semiboldOpenSans,
                                                        ),
                                                      )
                                                    ],
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
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
          );
        });
  }

  void showCustomBottomSheet(themeChange, BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 500,
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 5,
                            color: Color(0xFF6E6E6E),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.question_mark_sharp,
                          size: 80,
                          color: Color(0xFF6E6E6E),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: SvgPicture.asset(
                        "assets/icons/icon_close.svg",
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Add a business".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                          fontSize: 22,
                          fontFamily: AppThemeData.boldOpenSans,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Are you a customer or the owner of the business you wish to add?".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04,
                          fontSize: 16,
                          fontFamily: AppThemeData.regularOpenSans,
                        ),
                      ),
                      SizedBox(height: 15),
                      RoundedButtonFill(
                        title: 'I am a Customer',
                        color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                        textColor: themeChange.getThem() ? AppThemeData.grey02 : AppThemeData.grey02,
                        onPress: () {
                          Get.back();
                          Get.to(CreateBusinessScreen(), arguments: {"asCustomerOrWorkAtBusiness": true});
                        },
                      ),
                      SizedBox(height: 10),
                      RoundedButtonFill(
                        title: 'This is my Business',
                        color: themeChange.getThem() ? AppThemeData.greyDark06 : AppThemeData.grey06,
                        textColor: themeChange.getThem() ? AppThemeData.grey02 : AppThemeData.grey02,
                        onPress: () {
                          Get.back();
                          Get.to(CreateBusinessScreen(), arguments: {"asCustomerOrWorkAtBusiness": false});
                        },
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget imageWidget(themeChange, String imagePath, String title) {
    return Column(
      children: [
        ClipOval(
            child: Container(
          decoration: BoxDecoration(
            color: themeChange.getThem() ? AppThemeData.greyDark09 : AppThemeData.grey07,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Constant.svgPictureShow(imagePath, AppThemeData.red02, null, null),
          ),
        )),
        SizedBox(
          height: 5,
        ),
        Text(
          title.tr,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
            fontSize: 12,
            fontFamily: AppThemeData.semiboldOpenSans,
          ),
        )
      ],
    );
  }
}
