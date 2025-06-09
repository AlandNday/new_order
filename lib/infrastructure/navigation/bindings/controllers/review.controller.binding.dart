import 'package:get/get.dart';

import '../../../../presentation/review/controllers/review.controller.dart';

class ReviewControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(
      () => ReviewController(),
    );
  }
}
