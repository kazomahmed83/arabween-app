import 'dart:convert';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EditAddressController extends GetxController {
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
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${Constant.mapAPIKey}",
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

  Future<AddressModel> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Constant.mapAPIKey}",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'];

      // String? name = result['name'];
      String? formattedAddress = result['formatted_address'];

      // Parse address components
      List components = result['address_components'] ?? [];

      String? street;
      String? country;
      String? isoCountryCode;
      String? postalCode;
      String? administrativeArea;
      String? subAdministrativeArea;
      String? locality;
      String? subLocality;
      String? thoroughfare;
      String? subThoroughfare;

      for (var comp in components) {
        List types = comp['types'];
        if (types.contains('street_number')) {
          subThoroughfare = comp['long_name'];
        }
        if (types.contains('route')) {
          thoroughfare = comp['long_name'];
          street = comp['long_name'];
        }
        if (types.contains('locality')) {
          locality = comp['long_name'];
        }
        if (types.contains('sublocality') || types.contains('sublocality_level_1')) {
          subLocality = comp['long_name'];
        }
        if (types.contains('administrative_area_level_1')) {
          administrativeArea = comp['long_name'];
        }
        if (types.contains('administrative_area_level_2')) {
          subAdministrativeArea = comp['long_name'];
        }
        if (types.contains('postal_code')) {
          postalCode = comp['long_name'];
        }
        if (types.contains('country')) {
          country = comp['long_name'];
          isoCountryCode = comp['short_name']; // e.g. IN, US
        }
      }
      final location = data['result']['geometry']['location'];
      AddressModel addressModel = AddressModel(
          name: street,
          street: street,
          country: country,
          isoCountryCode: isoCountryCode,
          postalCode: postalCode,
          administrativeArea: administrativeArea,
          subAdministrativeArea: subAdministrativeArea,
          locality: locality,
          subLocality: subLocality,
          thoroughfare: thoroughfare,
          subThoroughfare: subThoroughfare,
          lat: location['lat'].toString(),
          lng: location['lng'].toString(),
          formattedAddress: formattedAddress);

      ShowToastDialog.closeLoader();
      return addressModel;
    } else {
      ShowToastDialog.closeLoader();
      return AddressModel();
    }
  }
}
