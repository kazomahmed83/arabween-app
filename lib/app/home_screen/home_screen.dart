import 'package:arabween/app/business_details_screen/business_details_screen.dart';

import 'package:arabween/app/create_bussiness_screen/service_address_screen.dart';
import 'package:arabween/app/home_screen/all_business_list_screen.dart';
import 'package:arabween/app/more_category_screen/more_category_screen.dart';
import 'package:arabween/models/banner_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:arabween/app/search_screen/search_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/controller/home_controller.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/service/ad_manager.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:arabween/widgets/debounced_inkwell.dart';

import 'business_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
          body: controller.isLoading.value
              ? Padding(padding: const EdgeInsets.only(top: 50), child: Constant.loader())
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leading: SizedBox(),
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark50 : AppThemeData.surface50,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            FutureBuilder<List<BannerModel>>(
                              future: FireStoreUtils.getBanners(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return SizedBox(height: 270, child: SizedBox());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Text('No banners available');
                                }

                                final banners = snapshot.data!;

                                return CarouselSlider.builder(
                                  itemCount: banners.length,
                                  itemBuilder: (context, index, realIndex) {
                                    final banner = banners[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 28),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: CachedNetworkImageProvider(banner.photo), fit: BoxFit.cover),
                                      ),
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${'Welcome'.tr} ${Constant.userModel?.firstName ?? ''}',
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 14, color: AppThemeData.greyDark01.withAlpha(190), fontFamily: AppThemeData.semibold),
                                        ),
                                      ),
                                    );
                                  },
                                  options: CarouselOptions(
                                    height: 270,
                                    autoPlay: true,
                                    enlargeCenterPage: true,
                                    viewportFraction: 1,
                                    aspectRatio: 16 / 9,
                                    autoPlayInterval: Duration(seconds: 8),
                                    autoPlayAnimationDuration: Duration(milliseconds: 400),
                                    enableInfiniteScroll: true,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 10,
                              child: SafeArea(
                                child: controller.isLoading.value
                                    ? SizedBox()
                                    : InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          Get.to(() => const EditServiceAddressScreen(), arguments: {'type': 'home'});
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: AppThemeData.grey10),
                                            SizedBox(width: 5),
                                            Text(
                                              Constant.currentAddress.tr,
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(fontSize: 14, color: AppThemeData.greyDark01, fontFamily: AppThemeData.medium),
                                            ),
                                            SizedBox(width: 5),
                                            Icon(Icons.keyboard_arrow_down_outlined, color: AppThemeData.grey10),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(10),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10, borderRadius: BorderRadius.circular(8)),
                            child: DebouncedInkWell(
                              onTap: () {
                                Get.to(SearchScreen());
                              },
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.sentences,
                                controller: controller.searchController.value,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.medium),
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(color: Colors.red),
                                  enabled: false,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.search, color: AppThemeData.red02),
                                  ),
                                  prefixIconConstraints: BoxConstraints(minHeight: 20, minWidth: 20),
                                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                  fillColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06, width: 1),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06, width: 1),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06, width: 1),
                                  ),
                                  hintText: "Search for nail salons".tr,
                                  hintStyle: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.greyDark04 : AppThemeData.grey04, fontFamily: AppThemeData.regularOpenSans),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            AdManager.bannerAdWidget(),
                            Padding(
                              padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Categories'.tr,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.semibold),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(MoreCategoryScreen());
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppThemeData.redDark02, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        "More".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontFamily: AppThemeData.medium, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(0),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.categoryList.length > 7 ? 7 : controller.categoryList.length,
                                  itemBuilder: (context, index) {
                                    CategoryModel categoryModel = controller.categoryList[index];
                                    return DebouncedInkWell(
                                      onTap: () {
                                        controller.setSearchHistory(categoryModel);
                                        Get.to(BusinessListScreen(), arguments: {"categoryModel": categoryModel, "latLng": null, "isZipCode": false});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06),
                                            borderRadius: BorderRadius.circular(8),
                                            color: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(child: NetworkImageWidget(imageUrl: categoryModel.icon.toString(), width: 45, height: 45)),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  categoryModel.name.toString(),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontFamily: AppThemeData.medium),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Constant.currentLocationLatLng?.latitude != null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(0),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: controller.categoryList.length,
                                      itemBuilder: (context, index) {
                                        CategoryModel categoryModel = controller.categoryList[index];
                                        return StreamBuilder<List<BusinessModel>>(
                                          stream: FireStoreUtils.getAllRestaurantByCategoryIdForHomePage(
                                            LatLng(Constant.currentLocationLatLng!.latitude, Constant.currentLocationLatLng!.longitude),
                                            categoryModel,
                                            searchRadius: double.parse(Constant.radios),
                                            isFetchPopularBusiness: true,
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return SizedBox();
                                            } else {
                                              final List<BusinessModel> businessList = snapshot.data!;

                                              return SizedBox(
                                                height: businessList.isEmpty
                                                    ? 0
                                                    : businessList.length > 2
                                                        ? 555
                                                        : 300,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 16, top: 0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            categoryModel.name.toString(),
                                                            textAlign: TextAlign.start,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                                                              fontFamily: AppThemeData.semibold,
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Get.to(AllBusinessListScreen(), arguments: {'businessModels': businessList, 'categoryService': categoryModel});
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                                              decoration: BoxDecoration(color: AppThemeData.redDark02, borderRadius: BorderRadius.circular(4)),
                                                              child: Text(
                                                                "More".tr,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontFamily: AppThemeData.medium, color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (categoryModel.name != null)
                                                      Expanded(
                                                        child: GridView.builder(
                                                          physics: NeverScrollableScrollPhysics(),
                                                          itemCount: businessList.length >= 4 ? 4 : businessList.length,
                                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            crossAxisSpacing: 10,
                                                            mainAxisSpacing: 10,
                                                            mainAxisExtent: 240,
                                                          ),
                                                          itemBuilder: (context, index) {
                                                            final business = businessList[index];
                                                            return DebouncedInkWell(
                                                              onTap: () {
                                                                Constant.setRecentBusiness(business);
                                                                Get.to(BusinessDetailsScreen(), arguments: {"businessModel": business, "categoryModel": categoryModel});
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: themeChange.getThem() ? AppThemeData.grey03 : AppThemeData.greyDark06),
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
                                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
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
                                                                          flex: 3,
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(left: 12, right: 12, top: 18, bottom: 8),
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
                                                                                    SizedBox(width: 5),
                                                                                    business.businessType == 'Service Business'
                                                                                        ? Expanded(
                                                                                            child: SingleChildScrollView(
                                                                                              scrollDirection: Axis.horizontal,
                                                                                              child: Text(
                                                                                                business.serviceArea?.join(', ') ?? "", // Converts list to comma-separated string
                                                                                                maxLines: 1,
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
                                                                      bottom: 55,
                                                                      left: 10,
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(50),
                                                                        child: NetworkImageWidget(
                                                                          imageUrl: business.profilePhoto ?? '',
                                                                          width: 55,
                                                                          height: 55,
                                                                          fit: BoxFit.cover,
                                                                          errorWidget: Constant.svgPictureShow("assets/icons/ic_placeholder_bussiness.svg", null, 45, 45),
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
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Constant.showEmptyView(message: "Required Location Permission".tr),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget categoryChip(themeChange, CategoryModel label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeChange.getThem() ? AppThemeData.greyDark05 : AppThemeData.grey05),
      ),
      child: Text(
        label.name.toString(),
        style: TextStyle(color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, fontSize: 14, fontFamily: AppThemeData.semiboldOpenSans),
      ),
    );
  }

  double getContentHeight() {
    return 200; // Calculate based on the actual content dynamically
  }
}
