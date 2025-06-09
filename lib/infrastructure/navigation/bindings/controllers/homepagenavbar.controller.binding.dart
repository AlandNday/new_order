import 'package:get/get.dart';

import '../../../../presentation/homepagenavbar/controllers/homepagenavbar.controller.dart';

class HomepagenavbarControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomepagenavbarController>(
      () => HomepagenavbarController(),
    );
  }
}
