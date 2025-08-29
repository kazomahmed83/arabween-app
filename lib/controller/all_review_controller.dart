import 'dart:developer';

import 'package:arabween/models/review_model.dart';
import 'package:get/get.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class AllReviewController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;

  @override
  void onInit() {
    getAllReview();
    super.onInit();
  }

  getAllReview() async {
    log(":::::::GetAllReview:::::::::");
    await FireStoreUtils.getReviewsNyUserId(FireStoreUtils.getCurrentUid()).then(
      (value) {
        reviewList.value = value;
      },
    );
    isLoading.value = false;
  }
}
