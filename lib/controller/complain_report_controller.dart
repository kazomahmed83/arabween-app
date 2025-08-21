import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/constant/collection_name.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/report_list_model.dart';
import 'package:arabween/models/report_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class ComplainReportController extends GetxController {
  RxBool isLoading = true.obs;
  RxString reportType = ''.obs;
  Rx<TextEditingController> reportTextFieldController = TextEditingController().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxList<String> reportCategories = <String>[].obs;
  Rx<String> selectedReason = ''.obs;
  Rx<String> givenBy = ''.obs;
  Rx<String> postId = ''.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      reportType.value = argumentData['type'];
      givenBy.value = argumentData['givenBy'];
      postId.value = argumentData['postId'];
      await getReportSettings();
    }
    isLoading.value = false;
    update();
  }

  getReportSettings() async {
    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("complain_and_report").get().then(
      (value) {
        if (value.exists) {
          ReportListModel reportListModel = ReportListModel.fromJson(value.data()!);

          reportCategories.value = reportListModel.reportCategories!.firstWhere((element) => element.category == reportType.value).reports ?? [];
        }
      },
    );
  }

  submitReport() async {
    ShowToastDialog.showLoader("Please wait.");
    ReportModel reportModel = ReportModel();
    reportModel.id = Constant.getUuid();
    reportModel.title = selectedReason.value;
    reportModel.description = reportTextFieldController.value.text;
    reportModel.type = reportType.value;
    reportModel.status = 'pending';
    reportModel.from = FireStoreUtils.getCurrentUid();
    reportModel.to = givenBy.value;
    reportModel.postId = postId.value;
    reportModel.createdAt = Timestamp.now();

    await FireStoreUtils.setComplain(reportModel);
    ShowToastDialog.closeLoader();
    Get.back();
  }
}
