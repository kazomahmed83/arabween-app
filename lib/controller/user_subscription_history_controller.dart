import 'package:get/get.dart';
import 'package:arabween/models/subscription_ads_history.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class UserSubscriptionHistoryController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getHistory();
    super.onInit();
  }

  RxList<SubscriptionAdsHistory> historyList = <SubscriptionAdsHistory>[].obs;

  getHistory() async {
    await FireStoreUtils.getSubscriptionAdsHistory().then(
      (value) {
        historyList.value = value;
      },
    );
    isLoading.value = false;
  }
}
