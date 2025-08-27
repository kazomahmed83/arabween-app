import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
        emailController.value.text = userModel.value.email.toString();
        firstNameController.value.text = userModel.value.firstName ?? '';
        lastNameController.value.text = userModel.value.lastName ?? '';
        profileImage.value = userModel.value.profilePic ?? '';
        print("======>${profileImage.value}");
        isLoading.value = false;
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }
}
