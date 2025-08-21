import 'package:get/get.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class BusinessViewController extends GetxController {
  var businessMap = <String, BusinessModel>{}.obs;

  Future<void> fetchUser(String userId) async {
    if (!businessMap.containsKey(userId)) {
      BusinessModel? businessModel = await FireStoreUtils.getBusinessById(userId);
      if (businessModel != null) {
        businessMap[userId] = businessModel;
      }
    }
  }
}
