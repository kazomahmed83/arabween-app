import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/bookmarks_model.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/widgets/geoflutterfire/src/geoflutterfire.dart';
import 'package:arabween/widgets/geoflutterfire/src/models/point.dart';

class CollectionViewController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> collectionNameTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> collectionDescriptionTextFieldController = TextEditingController().obs;

  RxBool isPublic = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<BookmarksModel> bookmarkModel = BookmarksModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookmarkModel.value = argumentData['bookmarkModel'];
      collectionNameTextFieldController.value.text = bookmarkModel.value.name.toString();
      collectionDescriptionTextFieldController.value.text = bookmarkModel.value.description.toString();
      isPublic.value = bookmarkModel.value.isPrivate == true ? false : true;
      await getUser();
    }
    isLoading.value = false;
    update();
  }

  getCollection() async {
    await FireStoreUtils.getBookmarksById(bookmarkModel.value.id.toString()).then(
      (value) {
        if (value != null) {
          bookmarkModel.value = value;
        }
      },
    );
  }

  getUser() async {
    await FireStoreUtils.getUserProfile(bookmarkModel.value.ownerId.toString()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
  }

  updateMyBookmark() async {
    ShowToastDialog.showLoader("Please wait");
    bookmarkModel.value.name = collectionNameTextFieldController.value.text;
    bookmarkModel.value.description = collectionDescriptionTextFieldController.value.text;
    bookmarkModel.value.ownerId = FireStoreUtils.getCurrentUid();
    bookmarkModel.value.isDefault = false;
    bookmarkModel.value.isPrivate = isPublic.value == true ? false : true;
    bookmarkModel.value.updatedAt = Timestamp.now();
    bookmarkModel.value.location = LatLngModel(latitude: Constant.currentLocationLatLng!.latitude.toString(), longitude: Constant.currentLocationLatLng!.longitude.toString());
    GeoFirePoint position =
        Geoflutterfire().point(latitude: double.parse(Constant.currentLocationLatLng!.latitude.toString()), longitude: double.parse(Constant.currentLocationLatLng!.longitude.toString()));

    bookmarkModel.value.position = Positions(geoPoint: position.geoPoint, geoHash: position.hash);

    await FireStoreUtils.createBookmarks(bookmarkModel.value);
    await getCollection();
    Get.back();
    ShowToastDialog.closeLoader();
  }
}
