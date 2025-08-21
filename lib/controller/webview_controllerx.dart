import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewControllerX extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  Rx<WebViewController> controller = WebViewController().obs;
  RxString url = ''.obs;
  RxString title = ''.obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      url.value = argumentData['url'];
      title.value = argumentData['title'] ?? "Claim Business";

      controller.value = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {
              ShowToastDialog.closeLoader();
            },
            onPageFinished: (String url) {
              ShowToastDialog.closeLoader();
            },
            onHttpError: (HttpResponseError error) {
              ShowToastDialog.closeLoader();
            },
            onWebResourceError: (WebResourceError error) {
              ShowToastDialog.closeLoader();
            },
            // onNavigationRequest: (NavigationRequest request) {
            //   if (request.url.startsWith('https://www.youtube.com/')) {
            //     return NavigationDecision.prevent;
            //   }
            //   return NavigationDecision.navigate;
            // },
          ),
        )
        ..loadRequest(Uri.parse(url.value));
    }
    isLoading.value = false;
    update();
  }
}
