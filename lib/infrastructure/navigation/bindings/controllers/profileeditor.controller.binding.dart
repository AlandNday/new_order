import 'package:get/get.dart';

import '../../../../presentation/profileeditor/controllers/profileeditor.controller.dart';

class ProfileeditorControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditorController>(() => ProfileEditorController());
  }
}
