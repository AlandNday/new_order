import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/Review_model.dart'; // Import the Review model

class ReviewController extends GetxController {
  final TextEditingController reviewerNameController = TextEditingController();
  final TextEditingController reviewTextController = TextEditingController();
  final RxInt starRating = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setStarRating(int rating) {
    starRating.value = rating;
  }

  Future<void> submitReview() async {
    if (reviewerNameController.text.isEmpty ||
        reviewTextController.text.isEmpty ||
        starRating.value == 0) {
      errorMessage.value = 'Please fill in all fields and give a star rating.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final newReview = Review(
        id: '', // Firestore will generate this
        reviewerName: reviewerNameController.text.trim(),
        reviewText: reviewTextController.text.trim(),
        starRating: starRating.value,
        timestamp: Timestamp.now(),
      );

      await _firestore.collection('reviews').add(newReview.toFirestore());

      Get.back(); // Go back to the previous screen (Homepage)
      Get.snackbar(
        'Success',
        'Your review has been submitted!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // You might want to refresh reviews on the homepage after submission
      // Get.find<HomepageController>().fetchReviews(); // If you need instant refresh
    } catch (e) {
      errorMessage.value = 'Failed to submit review: $e';
      print('Error submitting review: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    reviewerNameController.dispose();
    reviewTextController.dispose();
    super.onClose();
  }
}
