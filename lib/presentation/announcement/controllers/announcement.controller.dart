import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/Announcement_model.dart';

class AnnouncementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list to hold announcements
  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Announcement')
          .orderBy('date', descending: true)
          .get(); // Order by date if available

      final List<Announcement> fetchedAnnouncements = querySnapshot.docs
          .map((doc) => Announcement.fromFirestore(doc))
          .toList();

      announcements.assignAll(fetchedAnnouncements); // Update the RxList
      if (announcements.isEmpty) {
        errorMessage.value = 'No announcements found.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load announcements: $e';
      print('Error fetching announcements: $e'); // For debugging
    } finally {
      isLoading.value = false;
    }
  }
}
