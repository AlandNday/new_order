import 'package:get/get.dart';
import 'package:new_order/presentation/adminorders/controllers/adminorders.controller.dart';
import 'package:new_order/presentation/screens.dart';

import '../../../../presentation/homepageadmin/controllers/homepageadmin.controller.dart';

class HomepageadminControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomepageadminController>(() => HomepageadminController());
    Get.lazyPut<AdminordersController>(() => AdminordersController());
    Get.lazyPut<AdminordersScreen>(() => AdminordersScreen());
    Get.lazyPut<AnnouncementScreen>(() => AnnouncementScreen());
  }
}
