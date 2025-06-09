// controllers/homepage.controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_order/domain/core/Models/Announcement_model.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart';
import 'package:new_order/domain/core/Models/Review_model.dart'; // Import the new Review model
import 'dart:async'; // Import for StreamSubscription

class HomepageController extends GetxController {
  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxList<Review> reviews = <Review>[].obs; // New RxList for reviews
  RxInt currentIndex = 0.obs;
  RxString userAvatarUrl = ''.obs;
  RxString userName = ''.obs;
  Rxn<Profile> userProfile = Rxn<Profile>();
  final box = GetStorage();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // StreamSubscription to manage the real-time listener
  StreamSubscription<QuerySnapshot>? _reviewsSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    fetchAnnouncements();
    listenToReviews(); // Changed to listen to reviews instead of just fetching once
  }

  Future<void> _loadUserProfile() async {
    Map<String, dynamic>? storedProfileJson = box.read('user_profile');
    if (storedProfileJson != null) {
      print('User profile map from GetStorage: $storedProfileJson');
      userProfile.value = Profile.fromJson(
        storedProfileJson,
        storedProfileJson['id'] ?? 'unknown_id',
      );
      print('User role from Profile model: ${userProfile.value?.role}');
      userName.value = userProfile.value?.name ?? '';
      userAvatarUrl.value = userProfile.value?.avatarUrl ?? '';
    } else {
      print('User profile not found in GetStorage.');
      userProfile.value = null;
    }
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection('Announcement')
          .orderBy('date', descending: true)
          .get();

      final List<Announcement> fetchedAnnouncements = querySnapshot.docs
          .map((doc) => Announcement.fromFirestore(doc))
          .toList();

      announcements.assignAll(fetchedAnnouncements);
      if (announcements.isEmpty) {
        errorMessage.value = 'No announcements found.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load announcements: $e';
      print('Error fetching announcements: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // New method to listen for real-time reviews
  void listenToReviews() {
    isLoading.value = true;
    errorMessage.value = '';

    // Cancel any previous subscription to avoid duplicate listeners
    _reviewsSubscription?.cancel();

    _reviewsSubscription = firestore
        .collection('reviews') // Ensure this matches your collection name
        .orderBy('timestamp', descending: true) // Order by timestamp
        .limit(4) // Fetch a limited number of reviews for homepage
        .snapshots() // <--- THIS IS THE KEY CHANGE for real-time updates
        .listen(
          (QuerySnapshot snapshot) {
            final List<Review> fetchedReviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();

            reviews.assignAll(fetchedReviews); // Update the RxList

            if (reviews.isEmpty) {
              errorMessage.value = 'No reviews found.';
            } else {
              errorMessage.value = ''; // Clear error if reviews are found
            }
            isLoading.value =
                false; // Set loading to false once data is received
          },
          onError: (e) {
            errorMessage.value = 'Failed to load reviews: $e';
            print('Error listening to reviews: $e');
            isLoading.value = false; // Set loading to false on error
          },
          cancelOnError:
              false, // Keep listening even if there's an error (optional)
        );
  }

  @override
  void onClose() {
    _reviewsSubscription
        ?.cancel(); // Cancel the subscription when the controller is closed
    super.onClose();
  }

  // Other methods remain the same
  final List<String> horizontalList1Data = List.generate(
    20,
    (index) => 'Item A $index',
  ).obs;
  final List<String> horizontalList2Data = List.generate(
    15,
    (index) => 'Item B $index',
  ).obs;
  final count = 0.obs;

  @override
  void onReady() {
    super.onReady();
  }

  void increment() => count.value++;
}
