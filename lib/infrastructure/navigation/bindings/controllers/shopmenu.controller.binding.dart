import 'package:get/get.dart';
import 'package:new_order/domain/Services/Productservices.dart';
import 'package:new_order/presentation/Cart/controllers/cart.controller.dart';

import '../../../../presentation/Shopmenu/controllers/shopmenu.controller.dart';

class ShopmenuControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopmenuController>(() => ShopmenuController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<ProductService>(() => ProductService());
  }
}
