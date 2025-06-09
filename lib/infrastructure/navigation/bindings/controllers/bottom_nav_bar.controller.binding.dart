import 'package:get/get.dart';
import 'package:new_order/domain/Services/Productservices.dart';
import 'package:new_order/presentation/Cart/controllers/cart.controller.dart';
import 'package:new_order/presentation/Homepage/controllers/homepage.controller.dart';
import 'package:new_order/presentation/Shopmenu/controllers/shopmenu.controller.dart';
import 'package:new_order/presentation/announcement/controllers/announcement.controller.dart';
import 'package:new_order/presentation/profile/controllers/profile.controller.dart';

import '../../../../presentation/BottomNavBar/controllers/bottom_nav_bar.controller.dart';

class BottomNavBarControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
    Get.lazyPut<HomepageController>(() => HomepageController());
    Get.lazyPut<ShopmenuController>(() => ShopmenuController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut(() => ProductService());
    Get.lazyPut(() => AnnouncementController());
  }
}
