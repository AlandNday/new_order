import 'package:get/get.dart';
import 'package:new_order/presentation/adminorders/controllers/adminorders.controller.dart';
import 'package:new_order/presentation/adminprofile/controllers/adminprofile.controller.dart';
import 'package:new_order/presentation/announcement/controllers/announcement.controller.dart';
import 'package:new_order/presentation/homepageadmin/controllers/homepageadmin.controller.dart';
import 'package:new_order/presentation/profile/controllers/profile.controller.dart';

import '../../../../presentation/adminnavbar/controllers/adminnavbar.controller.dart';

class AdminnavbarControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminnavbarController>(() => AdminnavbarController());
    Get.lazyPut<HomepageadminController>(() => HomepageadminController());
    Get.lazyPut<AdminprofileController>(() => AdminprofileController());
    Get.lazyPut<AdminordersController>(() => AdminordersController());
    Get.lazyPut<AnnouncementController>(() => AnnouncementController());
  }
}
