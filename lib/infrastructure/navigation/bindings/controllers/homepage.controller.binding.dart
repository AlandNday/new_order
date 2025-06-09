import 'package:get/get.dart';
import 'package:new_order/presentation/adminorders/controllers/adminorders.controller.dart';
import 'package:new_order/presentation/announcement/controllers/announcement.controller.dart';

import '../../../../presentation/Homepage/controllers/homepage.controller.dart';

class HomepageControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomepageController>(() => HomepageController());
    Get.lazyPut<AnnouncementController>(() => AnnouncementController());
  }
}
