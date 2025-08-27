import 'dart:io';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/controller/edit_profile_controller.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/themes/responsive.dart';
import 'package:arabween/themes/round_button_fill.dart';
import 'package:arabween/themes/text_field_widget.dart';
import 'package:arabween/utils/dark_theme_provider.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<EditProfileController>(
        init: EditProfileController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                  backgroundColor: themeChange.getThem() ? AppThemeData.greyDark10 : AppThemeData.grey10,
                  centerTitle: true,
                  leadingWidth: 120,
                  title: Text(
                    "Update Profile".tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                      fontSize: 16,
                      fontFamily: AppThemeData.semiboldOpenSans,
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/icon_close.svg",
                            width: 20,
                            colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01, BlendMode.srcIn),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Close".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.greyDark01 : AppThemeData.grey01,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiboldOpenSans,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              body: Column(
                children: [
                  SizedBox(
                    height: Responsive.width(45, context),
                    width: Responsive.width(100, context),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned(
                          bottom: 50,
                          child: Center(
                            child: controller.profileImage.isEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: NetworkImageWidget(
                                      imageUrl: Constant.userPlaceHolder,
                                      fit: BoxFit.fill,
                                      height: Responsive.width(30, context),
                                      width: Responsive.width(30, context),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Constant().hasValidUrl(controller.profileImage.value) == false
                                        ? Image.file(
                                            File(controller.profileImage.value),
                                            height: Responsive.width(30, context),
                                            width: Responsive.width(30, context),
                                            fit: BoxFit.fill,
                                          )
                                        : NetworkImageWidget(
                                            imageUrl: controller.profileImage.value.toString(),
                                            fit: BoxFit.fill,
                                            height: Responsive.width(30, context),
                                            width: Responsive.width(30, context),
                                          ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 50,
                          right: Responsive.width(36, context),
                          child: InkWell(
                            onTap: () {
                              buildBottomSheet(context, controller);
                            },
                            child: ClipOval(
                              child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/ic_edit.svg',
                                    width: 22,
                                    height: 22,
                                    color: themeChange.getThem() ? AppThemeData.greyDark02 : AppThemeData.grey02,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: controller.isLoading.value
                        ? Constant.loader()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: TextFieldWidget(hintText: 'First name'.tr, controller: controller.firstNameController.value)),
                                      SizedBox(width: 10),
                                      Expanded(child: TextFieldWidget(hintText: 'Last name'.tr, controller: controller.lastNameController.value)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFieldWidget(hintText: 'Email'.tr, controller: controller.emailController.value, enable: false),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  RoundedButtonFill(
                                    height: 5.5,
                                    textColor: themeChange.getThem() ? AppThemeData.grey10 : AppThemeData.grey10,
                                    color: themeChange.getThem() ? AppThemeData.red02 : AppThemeData.red02,
                                    title: "Update Profile".tr,
                                    onPress: () async {
                                      ShowToastDialog.showLoader("Please wait".tr);
                                      print("======>${controller.profileImage.value}");

                                      if (controller.profileImage.value.isNotEmpty && Constant().hasValidUrl(controller.profileImage.value) == false) {
                                        controller.profileImage.value = await Constant.uploadUserImageToFireStorage(
                                            File(controller.profileImage.value), "profileImage/${FireStoreUtils.getCurrentUid()}", File(controller.profileImage.value).path.split('/').last);
                                      }

                                      UserModel userModel = controller.userModel.value;
                                      userModel.firstName = controller.firstNameController.value.text;
                                      userModel.lastName = controller.lastNameController.value.text;
                                      userModel.profilePic = controller.profileImage.value;

                                      FireStoreUtils.updateUser(userModel).then((value) {
                                        ShowToastDialog.closeLoader();
                                        Get.back(result: true);
                                        ShowToastDialog.showToast("Profile update successfully".tr);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ));
        });
  }

  buildBottomSheet(BuildContext context, EditProfileController controller) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text("Camera".tr),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text("Gallery".tr),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
