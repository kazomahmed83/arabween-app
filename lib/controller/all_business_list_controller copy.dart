import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/category_model.dart';

class AllBusinessListController extends GetxController {
  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<CategoryModel> categoryService = CategoryModel().obs;
  RxList<BusinessModel> allBusinessList = <BusinessModel>[].obs;
  Rx<TextEditingController> searchController = TextEditingController().obs;
  RxList<BusinessModel> searchBusinessList = <BusinessModel>[].obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      allBusinessList.value = argumentData['businessModels'];
      categoryService.value = argumentData['categoryService'];
    }
    searchBusinessList.value = allBusinessList;
    searchControllerLister();
    update();
  }

  void searchControllerLister() {
    searchController.value.addListener(() {
      final text = searchController.value.text.toLowerCase();

      if (text.isEmpty) {
        searchBusinessList.value = allBusinessList;
      } else {
        final filteredList = allBusinessList.where((b) => b.businessName?.toLowerCase().contains(text) ?? false).toList()
          ..sort((a, b) => (b.businessName ?? '').toLowerCase().compareTo((a.businessName ?? '').toLowerCase()));

        searchBusinessList.value = filteredList;
      }
    });
  }
}
