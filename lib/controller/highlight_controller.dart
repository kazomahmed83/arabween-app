import 'package:get/get.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/highlight_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class HighLightController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getArgument();
    // TODO: implement onInit
    super.onInit();
  }

  Rx<BusinessModel> businessModel = BusinessModel().obs;
  Rx<String> type = ''.obs;

  RxList<HighlightModel> highLightList = <HighlightModel>[].obs;
  RxList<HighlightModel> selectedHighLightList = <HighlightModel>[].obs;
  dynamic argumentData = Get.arguments;
  getArgument() async {
    if (argumentData != null) {
      if (argumentData['businessModel'] != null) {
        businessModel.value = argumentData['businessModel'];
      } else if (argumentData['type'] != null) {
        type.value = argumentData['type'] ?? '';
      }
      await getSpecification();
    }
    isLoading.value = false;
    update();
  }

  getSpecification() async {
    await FireStoreUtils.getBusinessHighLight().then(
      (value) {
        highLightList.value = value;
        if (type.value == 'signup') {
          if (argumentData['highLightsList'].isNotEmpty == true) {
            selectedHighLightList.value = highLightList.where((element) => argumentData['highLightsList'].contains(element.id)).toList();
          }
        } else {
          businessModel.value.highLights = selectedHighLightList.value = highLightList.where((element) => businessModel.value.highLights!.contains(element.id)).toList();
        }
      },
    );

    update();
  }

  saveDetails() async {
    if (selectedHighLightList.isEmpty) {
      ShowToastDialog.showToast("Please select highlight ");
    } else {
      ShowToastDialog.showLoader("Please wait");
      businessModel.value.highLights = selectedHighLightList.map((e) => e.id).toList();
      if (type.value == 'signup') {
        ShowToastDialog.closeLoader();
        Get.back(result: businessModel.value.highLights);
      } else {
        await FireStoreUtils.addBusiness(businessModel.value);
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Business highlight save successfully ");
        Get.back(result: true);
      }
    }
  }
}
