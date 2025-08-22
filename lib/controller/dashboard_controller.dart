import 'package:get/get.dart';
import 'package:arabween/app/collection_screen/collection_screen.dart';
import 'package:arabween/app/home_screen/home_screen.dart';
import 'package:arabween/app/more_screen/more_screen.dart';
import 'package:arabween/app/profile_screen/profile_screen.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    pageList.value = [
      const HomeScreen(),
      // const ProjectScreen(),
      const ProfileScreen(),
      const CollectionScreen(),
      const MoreScreen(),
    ];

    super.onInit();
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
}
