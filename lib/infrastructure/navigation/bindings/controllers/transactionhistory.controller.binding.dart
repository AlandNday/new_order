import 'package:get/get.dart';

import '../../../../presentation/transactionhistory/controllers/transactionhistory.controller.dart';

class TransactionhistoryControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionhistoryController>(
      () => TransactionhistoryController(),
    );
  }
}
