import 'package:get/get.dart';

import '../../../../presentation/IncomeSummary/controllers/income_summary.controller.dart';

class IncomeSummaryControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeSummaryController>(
      () => IncomeSummaryController(),
    );
  }
}
