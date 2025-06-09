import 'package:get/get.dart';

import '../../../../presentation/Cart/controllers/cart.controller.dart';

class CartControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(
      () => CartController(),
    );
  }
}
