import 'package:get/get.dart';

import '../../../../presentation/adminorders/controllers/adminorders.controller.dart';

class AdminordersControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminordersController>(
      () => AdminordersController(),
    );
  }
}
