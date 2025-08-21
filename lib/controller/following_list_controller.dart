import 'package:get/get.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class FollowingListController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<UserModel> userModel = UserModel().obs;
  RxList<UserModel> followingList = <UserModel>[].obs;
  RxBool myProfile = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      myProfile.value = argumentData['myProfile']?? false;

      await getUser();
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
    followingList.value = await FireStoreUtils.getFollowing(userModel.value.id.toString());
  }

  unfollow(UserModel userModel) async {
    ShowToastDialog.showLoader("Please wait");
    userModel.followers!.remove(FireStoreUtils.getCurrentUid());
    await FireStoreUtils.updateUser(userModel);
    await getUser();
    ShowToastDialog.closeLoader();
    update();
  }
}
