import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionhistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactionHistory();
  }

  Future<void> fetchTransactionHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final querySnapshot = await _firestore
          .collection('transactionHistory')
          .orderBy('timestamp', descending: true)
          .get();

      transactions.value = querySnapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    } on FirebaseException catch (e) {
      errorMessage.value = 'Failed to load transactions: ${e.message}';
      print('Firebase error fetching transactions: $e');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('Error fetching transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
