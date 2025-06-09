import 'package:get/get.dart';

import '../../../../presentation/adminprofile/controllers/adminprofile.controller.dart';

class AdminprofileControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminprofileController>(
      () => AdminprofileController(),
    );
  }
}
