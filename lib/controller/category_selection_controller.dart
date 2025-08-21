import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class CategorySelectionController extends GetxController {
  final Rx<TextEditingController> searchController = TextEditingController().obs;

  RxBool isSearchShow = true.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  RxList<CategoryModel> categories = <CategoryModel>[].obs; // Observable category list
  RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs; // Observable category list
  RxList<CategoryModel> searchCategoriesList = <CategoryModel>[].obs;

  getArgument() async {
    getParentCategory();
    searchControllerLister();
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      selectedCategories.value = argumentData['selectedCategories'];
      if (selectedCategories.isNotEmpty) {
        isSearchShow.value = false;
      }
    }

    update();
  }

  var isLoading = false.obs;

  getParentCategory() async {
    await FireStoreUtils.categoryParentList().then(
      (value) {
        categories.value = value;
        searchCategoriesList.value = categories;
      },
    );
    isLoading.value = false;
  }

  void searchControllerLister() {
    searchController.value.addListener(() {
      final text = searchController.value.text.toLowerCase();
      if (text.isEmpty) {
        searchCategoriesList.value = categories;
      } else {
        final filteredList = categories.where((b) => b.name?.toLowerCase().contains(text) ?? false).toList()..sort((a, b) => (b.name ?? '').toLowerCase().compareTo((a.name ?? '').toLowerCase()));
        searchCategoriesList.value = filteredList;
      }
    });
  }

  RxList<CategoryModel> subCategoryList = <CategoryModel>[].obs;
  getSubCategory(CategoryModel model) async {
    await FireStoreUtils.subCategoryParentList(model).then(
      (value) {
        subCategoryList.value = value;
        print("===>${subCategoryList.length}");
      },
    );
    isLoading.value = false;
  }
}
