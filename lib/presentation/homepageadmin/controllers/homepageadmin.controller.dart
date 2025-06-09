import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart';

class HomepageadminController extends GetxController {
  //TODO: Implement HomepageadminController

  Rxn<Profile> userProfile = Rxn<Profile>();
  RxString userAvatarUrl = ''.obs; // To store the passed avatar URL
  RxString userName = ''.obs;
  final box = GetStorage();
  void onInit() {
    super.onInit();
    Map<String, dynamic>? storedProfileJson = box.read('user_profile');
    if (storedProfileJson != null) {
      print('User profile map from GetStorage: $storedProfileJson');
      // Convert the map to your Profile model and assign it to the Rxn variable
      // Ensure 'id' is part of your Profile.fromJson or handle it appropriately
      userProfile.value = Profile.fromJson(
        storedProfileJson,
        storedProfileJson['id'] ?? 'unknown_id',
      );
      print('User role from Profile model: ${userProfile.value?.role}');

      // You can also update your separate RxString variables if you prefer
      userName.value = userProfile.value?.name ?? '';
      userAvatarUrl.value = userProfile.value?.avatarUrl ?? '';
    } else {
      print('User profile not found in GetStorage.');
      userProfile.value = null; // Ensure it's null if not found
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
