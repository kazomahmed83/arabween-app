import 'package:get/get.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class UserViewController extends GetxController {
  var userMap = <String, UserModel>{}.obs;

  Future<void> fetchUser(String userId) async {

    if (!userMap.containsKey(userId)) {
      UserModel? user = await FireStoreUtils.getUserProfile(userId);
      if (user != null) {

        userMap[userId] = user;
      }
    }
  }

}
