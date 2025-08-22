import 'dart:convert';
import 'dart:developer';

import 'package:arabween/models/business_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:arabween/app/home_screen/business_list_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/business_history_model.dart';
import 'package:arabween/models/category_history_model.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/utils/business_history_storage.dart';
import 'package:arabween/utils/category_history_storage.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:http/http.dart' as http;

class SearchControllers extends GetxController {
  Rx<TextEditingController> categoryTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> locationTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> tempRadiusController = TextEditingController().obs;

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  RxBool isLocationSearch = false.obs;
  RxBool isSearchClose = true.obs;

  RxList<CategoryModel> categories = <CategoryModel>[].obs; // Observable category list
  LatLng? latLng; // Observable category list
  Rx<CategoryModel> selectedCategory = CategoryModel().obs;
  RxBool isLoading = true.obs;
  RxBool isCategoryLoading = false.obs;

  searchLocation() {
    locationTextFieldController.value.addListener(() {
      searchPlaces(locationTextFieldController.value.text);
    });
  }

  @override
  void onInit() {
    super.onInit();
    focusNode1.addListener(
      () {
        if (focusNode1.hasFocus) {
          isLocationSearch.value = false;
          isSearchClose.value = false;
        }
        if (!focusNode1.hasFocus && !focusNode2.hasFocus) {
          isSearchClose.value = true;
        }
      },
    );
    focusNode2.addListener(
      () {
        if (focusNode2.hasFocus) {
          isLocationSearch.value = true;
          isSearchClose.value = false;
        }
        if (!focusNode2.hasFocus && !focusNode1.hasFocus) {
          isSearchClose.value = true;
        }
      },
    );

    searchLocation();
    getArgument();
    getSearchHistory();
    isLoading.value = false;
  }

  RxBool isZipCode = true.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      if (argumentData['categoryModel'] != null) {
        selectedCategory.value = argumentData['categoryModel'];
      }
      isZipCode.value = argumentData['isZipCode'];
      if (argumentData['latLng'] != null) {
        latLng = argumentData['latLng'];
      } else {
        if (Constant.currentLocationLatLng?.latitude != null) {
          latLng = LatLng(Constant.currentLocationLatLng!.latitude, Constant.currentLocationLatLng!.longitude);
        } else {
          latLng = LatLng(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
        }
      }
      categoryTextFieldController.value.text = selectedCategory.value.name ?? '';
    } else {
      if (Constant.currentLocationLatLng?.latitude != null) {
        latLng = LatLng(Constant.currentLocationLatLng!.latitude, Constant.currentLocationLatLng!.longitude);
      } else {
        latLng = LatLng(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
      }
    }
    tempRadiusController.value.text = Constant.radios;
    isLoading.value = false;
    update();
  }

  // Fetch categories based on search query
  searchCategories(String query) async {
    if (query.isEmpty) {
      categories.clear();
      categories.assignAll([]); // Clear the list and update UI
    } else {
      isCategoryLoading.value = true;
      if (Constant.currentLocationLatLng?.latitude.isNaN == false) {
        FireStoreUtils.getAllNearestBusinessName(LatLng(Constant.currentLocationLatLng!.latitude, Constant.currentLocationLatLng!.longitude), query,
                searchRadius: double.parse(Constant.radios), isFetchPopularBusiness: false)
            .listen((value) {
          searchBusinessList.clear();
          if (value.isNotEmpty) {
            searchBusinessList.addAll(value);
            if (searchBusinessList.isNotEmpty) {
              recentSearchHistory.clear();
            }
          } else {
            // searchBusinessList.clear();
          }

          log("searchBusinessList :: ${searchBusinessList.length}");
        });
      }
      await FireStoreUtils.getCategory(query.replaceAll(" ", "_").toLowerCase()).then(
        (value) async {
          categories.value = value;
        },
      );
      isCategoryLoading.value = false;
    }
    update();
  }

  RxList<dynamic> predictions = <dynamic>[].obs;

  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.isEmpty) {
      predictions.clear();
      return [];
    }

    if (Constant.isNumeric(query.trim())) {
      predictions.clear();
      await getCoordinatesFromZip(query.trim());
    } else {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${Constant.mapAPIKey}",
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        predictions.value = data['predictions'];
      }
    }
    return predictions;
  }

  Future<void> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Constant.mapAPIKey}",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      locationTextFieldController.value.text = data['result']['formatted_address'];
      latLng = LatLng(location['lat'], location['lng']);
      navigateBusinessScree();
    }
  }

  navigateBusinessScree() {
    if (selectedCategory.value.slug != null && latLng != null) {
      setSearchHistory();
      Get.off(BusinessListScreen(), arguments: {
        "categoryModel": selectedCategory.value,
        "latLng": latLng,
        "isZipCode": Constant.isNumeric(locationTextFieldController.value.text.trim()),
      });
    } else {
      if (latLng != null) {
        Get.off(BusinessListScreen(), arguments: {
          "categoryModel": selectedCategory.value,
          "latLng": latLng,
          "isZipCode": Constant.isNumeric(locationTextFieldController.value.text.trim()),
        });
      }
    }

    /* if (selectedCategory.value.slug != null && latLng != null) {
      setSearchHistory();
      Get.off(BusinessListScreen(), arguments: {
        "categoryModel": selectedCategory.value,
        "latLng": latLng,
        "isZipCode":
            Constant.isNumeric(locationTextFieldController.value.text.trim()),
      });
    }*/
  }

  /// **📍 Get Latitude & Longitude from ZIP Code**
  Future<void> getCoordinatesFromZip(String zipCode) async {
    try {
      List<Location> locations = await locationFromAddress(zipCode);
      if (locations.isNotEmpty) {
        latLng = LatLng(locations.first.latitude, locations.first.longitude);
        navigateBusinessScree();
      } else {
        ShowToastDialog.showToast("Zip code is Invalid");
      }
    } catch (e) {
      ShowToastDialog.showToast("Zip code is Invalid");
      print("Error getting coordinates: $e");
    }
  }

  RxList<CategoryHistoryModel> categoryHistory = <CategoryHistoryModel>[].obs;
  RxList<BusinessHistoryModel> recentSearchHistory = <BusinessHistoryModel>[].obs;
  RxList<BusinessModel> searchBusinessList = <BusinessModel>[].obs;

  getSearchHistory() async {
    await CategoryHistoryStorage.getCategoryHistoryList().then(
      (value) {
        if (value.isNotEmpty) {
          categoryHistory.value = value;
        }
      },
    );

    await BusinessHistoryStorage.getCategoryHistoryList().then(
      (value) {
        if (value.isNotEmpty) {
          recentSearchHistory.value = value;
        }
      },
    );
  }

  setSearchHistory() {
    CategoryHistoryModel model = CategoryHistoryModel();
    model.id = Constant.getUuid();
    model.category = selectedCategory.value;
    model.createdAt = Timestamp.now();

    CategoryHistoryStorage.addCategoryHistoryItem(model);
  }
}
