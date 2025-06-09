import 'package:get/get.dart';

import '../../../../presentation/announcement/controllers/announcement.controller.dart';

class AnnouncementControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnouncementController>(
      () => AnnouncementController(),
    );
  }
}
