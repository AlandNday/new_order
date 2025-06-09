import 'package:get/get.dart';

import '../../../../presentation/checkoutpayment/controllers/checkoutpayment.controller.dart';

class CheckoutpaymentControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutpaymentController>(
      () => CheckoutpaymentController(),
    );
  }
}
