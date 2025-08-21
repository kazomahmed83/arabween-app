import 'dart:convert';
import 'package:arabween/app/dashboard_screen/dashboard_screen.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class EditServiceAddressController extends GetxController {
  RxList<dynamic> getAllServiceArea = <dynamic>[].obs;
  RxList<String> selectedServiceAarea = <String>[].obs;

  Rx<TextEditingController> searchTextFieldController = TextEditingController().obs;
  dynamic argumentData = Get.arguments;
  @override
  void onInit() {
    searchLocation();
    super.onInit();
  }

  searchLocation() {
    if (argumentData == null) {
      ShowToastDialog.showLoader("Please wait");
      searchPlaces('', isGetAllCity: true);
    }
    searchTextFieldController.value.addListener(() {
      searchPlaces(searchTextFieldController.value.text);
    });
  }

  Future<void> searchPlaces(String query, {bool isGetAllCity = false}) async {
    try {
      String input = query;

      if (isGetAllCity) {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        input = placemarks.first.administrativeArea ?? '';
        if (input.isEmpty) return;
      }

      if (input.isEmpty) {
        return;
      }

      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&types=(cities)"
        "&key=${Constant.mapAPIKey}",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('Google Places API Error: ${response.statusCode}');
        return;
      }

      final data = json.decode(response.body);
      getAllServiceArea.value = data['predictions'] as List<dynamic>;

      // final areaSet = rawPredictions.map((p) => p['structured_formatting']?['main_text'] as String?).whereType<String>().toSet();
      // getAllServiceArea.value = areaSet.toList()..sort((a, b) => a.compareTo(b));
      // log("getAllServiceArea :: ${getAllServiceArea.length}");
      update();
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Constant.mapAPIKey}",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      Constant.currentLocationLatLng = LatLng(location['lat'], location['lng']);
      ShowToastDialog.closeLoader();
      Get.offAll(DashBoardScreen());
    } else {
      ShowToastDialog.closeLoader();
    }
  }
}
