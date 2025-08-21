import 'package:get/get.dart';
import 'package:arabween/models/photo_model.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class UserPhotoController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<PhotoModel> photosList = <PhotoModel>[].obs;
  Rx<UserModel> userModel = UserModel().obs;


  @override
  void onInit() {
    // TODO: implement onInit
    getArguments();
    super.onInit();
  }

  getArguments() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      await getUser();
      await getPhotos();
    }
    update();
    isLoading.value = false;
  }

  getUser() async {
    await FireStoreUtils.getUserProfile(userModel.value.id.toString()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
  }

  getPhotos() async {
    await FireStoreUtils.getAllPhotosByUserId(userModel.value.id.toString()).then(
      (value) {
        photosList.value = value;
        update();
      },
    );
  }

  updateMenuPhoto(int index, PhotoModel reviewModel) {
    photosList.removeAt(index);
    photosList.insert(index, reviewModel);
  }
}
