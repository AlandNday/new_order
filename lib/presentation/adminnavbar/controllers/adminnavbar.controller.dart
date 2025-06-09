import 'package:get/get.dart';

class AdminnavbarController extends GetxController {
  //TODO: Implement AdminnavbarController
  final RxInt currentIndex = 0.obs;

  // List of all the screens for your tabs
  final List<String> pageTitles = ['Home', 'Explore', 'Favorites', 'Profile'];

  void changePage(int index) {
    currentIndex.value = index;
    // You can add logic here for specific tab changes,
    // like resetting scroll position, fetching data, etc.
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
