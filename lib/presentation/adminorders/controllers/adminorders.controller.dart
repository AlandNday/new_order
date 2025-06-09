import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../../domain/core/models/order_model.dart'; // Ensure this path is correct

class AdminordersController extends GetxController {
  // Observable list to hold all fetched orders
  RxList<Order> orders = <Order>[].obs;
  // Observable boolean to show loading state
  RxBool isLoading = true.obs;
  // Observable string to hold error messages
  RxString errorMessage = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // Start listening to orders when the controller is initialized
    _fetchOrders();
  }

  // Fetches orders from Firestore and listens for real-time updates
  void _fetchOrders() {
    isLoading.value = true;
    errorMessage.value = '';

    // Order by timestamp to show most recent orders first
    _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            // Clear previous errors on successful data fetch
            errorMessage.value = '';
            if (snapshot.docs.isNotEmpty) {
              orders.value = snapshot.docs
                  .map((doc) => Order.fromFirestore(doc))
                  .toList();
            } else {
              orders.clear(); // Clear the list if no orders are found
              print("No orders found in Firestore.");
            }
            isLoading.value = false;
          },
          onError: (error) {
            isLoading.value = false;
            errorMessage.value = 'Failed to load orders: $error';
            print('Error fetching orders: $error');
            Get.snackbar(
              'Error',
              'Failed to load orders: $error',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
            );
          },
        );
  }

  // Method to update the payment status of a specific order
  Future<void> updatePaymentStatus(
    String orderId,
    String newPaymentStatus,
  ) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'paymentstatus': newPaymentStatus, // Update paymentstatus field
      });
      Get.snackbar(
        'Success',
        'Payment status for Order ID: $orderId updated to "$newPaymentStatus" successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      errorMessage.value = 'Failed to update payment status: $e';
      print('Error updating payment status: $e');
      Get.snackbar(
        'Error',
        'Failed to update payment status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Method to update the overall order status
  Future<void> updateOrderStatus(String orderId, String newOrderStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newOrderStatus, // Update overall status field
      });
      Get.snackbar(
        'Success',
        'Order ID: $orderId status updated to "$newOrderStatus" successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      errorMessage.value = 'Failed to update order status: $e';
      print('Error updating order status: $e');
      Get.snackbar(
        'Error',
        'Failed to update order status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
