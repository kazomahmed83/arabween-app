import 'package:arabween/models/banner_model.dart';
import 'package:arabween/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/models/bookmarks_model.dart';
import 'package:arabween/models/category_history_model.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/utils/category_history_storage.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  Rx<TextEditingController> searchController = TextEditingController().obs;

  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<BookmarksModel> bookMarkList = <BookmarksModel>[].obs;

  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getParentCategory();
  }

  getParentCategory() async {
    await getCurrentLocation();

    await FireStoreUtils.categoryParentListHome().then(
      (value) {
        categoryList.value = value;
      },
    );

    isLoading.value = false;
    FireStoreUtils.getAllNearestBookMark(LatLng(Constant.currentLocationLatLng!.latitude, Constant.currentLocationLatLng!.longitude)).listen(
      (value) {
        bookMarkList.clear();
        bookMarkList.value = value;
      },
    );
  }

  getCurrentLocation() async {
    if (Constant.currentLocationLatLng?.latitude == null) {
      await FireStoreUtils.getCurrentUserModel();
      Constant.currentLocation = await Utils.getCurrentLocation();
      Constant.currentLocationLatLng = LatLng(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
      Constant.currentAddress = await Constant.getAddressFromLatLng(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
    }
  }

  setSearchHistory(CategoryModel category) {
    CategoryHistoryModel model = CategoryHistoryModel();
    model.id = Constant.getUuid();
    model.category = category;
    model.createdAt = Timestamp.now();

    CategoryHistoryStorage.addCategoryHistoryItem(model);
  }
}
