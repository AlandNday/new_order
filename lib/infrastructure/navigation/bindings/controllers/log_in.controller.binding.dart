import 'package:get/get.dart';
import 'package:new_order/presentation/BottomNavBar/controllers/bottom_nav_bar.controller.dart';

import '../../../../presentation/log_in/controllers/log_in.controller.dart';

class LogInControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LogInController>(() => LogInController());
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
  }
}
