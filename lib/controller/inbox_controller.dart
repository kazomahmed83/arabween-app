import 'package:get/get.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class InboxController extends GetxController{

  RxBool isLoading = true.obs;
  Rx<UserModel> senderUserModel = UserModel().obs;

  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  getUser() async {
    await FireStoreUtils.getCurrentUserModel().then((value) {
      senderUserModel.value = value!;
    });
    isLoading.value = false;
  }
}