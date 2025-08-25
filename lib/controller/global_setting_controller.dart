import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/models/country_model.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/notification_service.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getSettings();
    super.onInit();
  }

  getSettings() async {
    await FireStoreUtils.getSettings();
    await loadCountries();
  }

  loadCountries() async {
    // Load the JSON string from assets
    final String response = await rootBundle.loadString('assets/currency-codes.json');

    // Decode the JSON string
    final Map<String, dynamic> data = json.decode(response);

    // Parse the data into the model
    Constant.countryModel = CountryModel.fromJson(data);
  }

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        String token = await NotificationService.getToken();
        UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
        userModel!.fcmToken = token;
        await FireStoreUtils.updateUser(userModel);
      }
    });
  }
}
