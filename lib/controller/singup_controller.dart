import 'package:arabween/app/create_bussiness_screen/create_business_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/notification_service.dart';
import '../app/dashboard_screen/dashboard_screen.dart';

class SignupController extends GetxController {
  Rx<TextEditingController> firstNameTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> lastNameTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: "+1").obs;
  Rx<TextEditingController> emailTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> passwordTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> zipCodeFieldController = TextEditingController().obs;
  RxString profileImage = "".obs;
  RxBool passwordVisible = true.obs;

  RxString loginType = Constant.emailLoginType.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  RxBool isAddAbusinessBtn = false.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      if (argumentData['userModel'] != null) {
        userModel.value = argumentData['userModel'];
        loginType.value = userModel.value.loginType.toString();
        if (loginType.value == Constant.phoneLoginType) {
          phoneNumberTextFieldController.value.text = userModel.value.phoneNumber.toString();
          countryCodeController.value.text = userModel.value.countryCode.toString();
        } else {
          emailTextFieldController.value.text = userModel.value.email.toString();
          firstNameTextFieldController.value.text = userModel.value.firstName ?? '';
        }
      } else if (argumentData['type'] == 'Add a business') {
        isAddAbusinessBtn.value = true;
      }
    }
    update();
  }

  signUpWithEmailPassword({themeChange, context}) async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextFieldController.value.text.trim(),
        password: passwordTextFieldController.value.text.trim(),
      );
      if (credential.user != null) {
        userModel.value.id = credential.user!.uid;
        userModel.value.loginType = Constant.emailLoginType;
        await createAccount(themeChange: themeChange, context: context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ShowToastDialog.showToast("The password provided is too weak.".tr);
      } else if (e.code == 'email-already-in-use') {
        ShowToastDialog.showToast("The account already exists for that email.".tr);
      } else if (e.code == 'invalid-email') {
        ShowToastDialog.showToast("Enter email is Invalid".tr);
      }
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  createAccount({themeChange, context}) async {
    try {
      String fcmToken = await NotificationService.getToken();
      ShowToastDialog.showLoader("Please wait".tr);
      UserModel userModelData = userModel.value;
      userModelData.firstName = firstNameTextFieldController.value.text;
      userModelData.lastName = lastNameTextFieldController.value.text;
      userModelData.email = emailTextFieldController.value.text;
      userModelData.countryCode = countryCodeController.value.text;
      userModelData.phoneNumber = num.parse(phoneNumberTextFieldController.value.text);
      userModelData.profilePic = profileImage.value;
      userModelData.zipCode = zipCodeFieldController.value.text;
      userModelData.fcmToken = fcmToken;
      userModelData.createdAt = Timestamp.now();
      userModelData.isActive = true;
      await FireStoreUtils.updateUser(userModelData).then((value) {
        ShowToastDialog.closeLoader();
        if (value == true) {
          if (isAddAbusinessBtn.value == true) {
            ShowToastDialog.showToast("Account is created");
            Get.to(CreateBusinessScreen(), arguments: {"asCustomerOrWorkAtBusiness": false})?.then((value) {
              Get.offAll(const DashBoardScreen());
            });
          } else {
            ShowToastDialog.showToast("Account is created");
            Get.offAll(const DashBoardScreen());
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
