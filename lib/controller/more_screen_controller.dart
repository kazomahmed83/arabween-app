import 'dart:async';

import 'package:get/get.dart';
import 'package:arabween/constant/collection_name.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class MoreScreenController extends GetxController {
  RxList<BusinessModel> businessList = <BusinessModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getBusiness();
    super.onInit();
  }

  getBusiness() async {
    await FireStoreUtils.getMyBusiness().then(
      (value) {
        businessList.value = value;
      },
    );

    isLoading.value = false;
    update();
  }

  Stream<int> getLiveCount(BusinessModel businessModel) async* {
    final projectRequests = await FireStoreUtils.fireStore.collection(CollectionName.projectRequest).where("businessIds", arrayContains: businessModel.id).get();

    if (projectRequests.docs.isEmpty) {
      yield 0;
      return;
    }

    yield* Stream.multi((controller) {
      List<int> counts = List.filled(projectRequests.docs.length, 0);

      for (int i = 0; i < projectRequests.docs.length; i++) {
        final docId = projectRequests.docs[i].id;

        FireStoreUtils.fireStore
            .collection(CollectionName.projectRequest)
            .doc(docId)
            .collection("chat")
            .where("receiverId", isEqualTo: businessModel.id)
            .where("isRead", isEqualTo: false)
            .snapshots()
            .listen((snapshot) {
          counts[i] = snapshot.docs.length;
          int total = counts.fold(0, (int sum, int count) => sum + count);
          controller.add(total);
        }, onError: (e) {
          counts[i] = 0;
          int total = counts.fold(0, (int sum, int count) => sum + count);
          controller.add(total);
        });
      }
    });
  }

  RxBool isShow = false.obs;
  RxBool isAdminShow = false.obs;

  Stream<int> getLiveCountUserChat() {
    return FireStoreUtils.fireStore
        .collection(CollectionName.userChat)
        .doc(FireStoreUtils.getCurrentUid())
        .collection("inbox")
        .where("receiverId", isEqualTo: FireStoreUtils.getCurrentUid())
        .where("seen", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getLiveCountAdminChat() {
    return FireStoreUtils.fireStore
        .collection(CollectionName.userChat)
        .doc(FireStoreUtils.getCurrentUid())
        .collection("inbox")
        .where("receiverId", isEqualTo: FireStoreUtils.getCurrentUid())
        .where("seen", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
