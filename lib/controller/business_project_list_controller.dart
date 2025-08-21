import 'package:get/get.dart';
import 'package:arabween/constant/collection_name.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/pricing_request_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class BusinessProjectListController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<BusinessModel> businessModel = BusinessModel().obs;
  RxList<PricingRequestModel> activeSentRequest = <PricingRequestModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      businessModel.value = argumentData['businessModel'];
      await getProjectList();
    }
    isLoading.value = false;
    update();
  }

  getProjectList() async {
    await FireStoreUtils.getProjectList(businessModel.value).then(
      (value) {
        activeSentRequest.value = value;
      },
    );
  }


  Stream<bool> checkStatus(PricingRequestModel projectRequestModel) {
    return FireStoreUtils.fireStore
        .collection(CollectionName.projectRequest)
        .doc(projectRequestModel.id)
        .collection("chat")
        .where("senderId", isEqualTo: businessModel.value.id)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty?true:false);
  }

  Stream<int> getUnreadChatCount(PricingRequestModel projectRequestModel) {
    return FireStoreUtils.fireStore
        .collection(CollectionName.projectRequest)
        .doc(projectRequestModel.id)
        .collection("chat")
        .where("receiverId", isEqualTo: businessModel.value.id)
        .where("isRead", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
