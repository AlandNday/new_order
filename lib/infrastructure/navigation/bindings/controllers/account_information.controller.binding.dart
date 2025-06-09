import 'package:get/get.dart';

import '../../../../presentation/Account_information/controllers/account_information.controller.dart';

class AccountInformationControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountInformationController>(
      () => AccountInformationController(),
    );
  }
}
