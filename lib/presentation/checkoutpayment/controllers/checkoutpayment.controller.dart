import 'dart:convert'; // Required for jsonEncode for better print readability
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CheckoutpaymentController extends GetxController {
  // Reactive variables for UI and data management
  RxMap<String, dynamic> orderDetails = RxMap<String, dynamic>({});
  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  RxDouble totalAmount = 0.0.obs;
  RxString tableNumber = ''.obs;
  String paymentstatus = 'unverified';
  Rx<File?> selectedImage = Rx<File?>(null);
  RxBool isSubmitting = false.obs;
  RxString errorMessage = ''.obs;

  // Cloudinary configuration
  final String _cloudinaryCloudName =
      'dh1btqzox'; // Replace with your Cloudinary Cloud Name
  final String _cloudinaryUploadPreset =
      'NewOrder'; // Replace with your Cloudinary Upload Preset

  // Firebase and Image Picker instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Retrieve arguments passed to this controller
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      orderDetails.value = Map<String, dynamic>.from(Get.arguments);

      // DEBUG: Print the raw orderDetails received via Get.arguments
      print(
        'DEBUG: orderDetails.value in onInit (raw arguments): ${jsonEncode(orderDetails.value)}',
      );

      // Populate reactive variables from orderDetails for easier access
      // Ensure 'items' key exists and is a List<dynamic>
      items.value = List<Map<String, dynamic>>.from(
        orderDetails['items'] ?? [], // Use null-aware operator for safety
      );
      // Ensure 'totalAmount' exists and convert to double
      totalAmount.value =
          (orderDetails['totalAmount'] as num?)?.toDouble() ?? 0.0;
      // Ensure 'tableNumber' exists
      tableNumber.value = orderDetails['tableNumber'] ?? '';

      // DEBUG: Print the content of 'items' after it's been populated
      print('DEBUG: items.value in onInit after population (parsed):');
      if (items.value.isEmpty) {
        print('  Items list is empty in onInit.');
      } else {
        for (var i = 0; i < items.value.length; i++) {
          // Print the full map of each item to see all its keys and values
          print('  Item $i (from items.value): ${jsonEncode(items.value[i])}');
          // These prints correctly access the expected keys: 'productName' and 'pricePerItem'
          print('  Item $i productName: ${items.value[i]['productName']}');
          print('  Item $i pricePerItem: ${items.value[i]['pricePerItem']}');
          print('  Item $i quantity: ${items.value[i]['quantity']}');

          // Add warnings if critical fields are null at this stage
          if (items.value[i]['productName'] == null) {
            print(
              '!!!! WARNING: productName is null for Item $i in onInit !!!!',
            );
          }
          if (items.value[i]['pricePerItem'] == null) {
            print(
              '!!!! WARNING: pricePerItem is null for Item $i in onInit !!!!',
            );
          }
        }
      }
    } else {
      // Handle case where no arguments are received
      print('Error: No order data received in CheckoutPaymentController');
      Get.snackbar(
        'Error',
        'No order data found. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Method to pick an image from the gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        errorMessage.value = ''; // Clear any previous error message
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
      print('Error picking image: $e');
    }
  }

  // Private method to upload the selected image to Cloudinary
  Future<String?> _uploadImageToCloudinary() async {
    if (selectedImage.value == null) {
      print('No image selected for Cloudinary upload.');
      return null;
    }

    try {
      final uploadUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uploadUrl)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            selectedImage.value!.path,
            filename: selectedImage.value!.path.split('/').last,
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        final secureUrl = data['secure_url'] as String?;
        if (secureUrl != null) {
          print('Image uploaded to Cloudinary successfully: $secureUrl');
          return secureUrl;
        } else {
          print(
            'Cloudinary response did not contain a secure_url: $responseData',
          );
          errorMessage.value =
              'Cloudinary upload failed: secure URL not found.';
          return null;
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        print(
          'Cloudinary upload failed! Status: ${response.statusCode}, Error: $errorBody',
        );
        errorMessage.value =
            'Image upload failed. Cloudinary error: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      print('An error occurred during Cloudinary upload: $e');
      errorMessage.value = 'Error uploading image: $e';
      return null;
    }
  }

  // Method to submit the order to Firestore
  Future<void> submitOrder() async {
    if (isSubmitting.value) return; // Prevent multiple submissions

    isSubmitting.value = true;
    errorMessage.value = ''; // Clear previous error

    try {
      String? paymentProofUrl;

      // Upload image to Cloudinary if selected
      if (selectedImage.value != null) {
        paymentProofUrl = await _uploadImageToCloudinary();
        if (paymentProofUrl == null) {
          // If upload fails, show snackbar and stop submission
          Get.snackbar(
            'Upload Failed',
            'Could not upload payment proof. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          return;
        }
      }

      // Prepare order data for Firestore
      Map<String, dynamic> orderData = {
        'tableNumber': tableNumber.value,
        'totalAmount': totalAmount.value,
        'items': items.value
            .map(
              (item) => {
                'name': item['productName'],
                'price': item['pricePerItem'],
                'quantity': item['quantity'],
              },
            )
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
        'paymentProofUrl': paymentProofUrl,
        'paymentstatus': paymentstatus,
        'status': 'pending',
      };

      // Add the order data to the 'orders' collection in Firestore
      await _firestore.collection('orders').add(orderData);

      // Add the transaction to history after successful order submission
      await _addTransactionToHistory(
        paymentProofUrl: paymentProofUrl!,
        totalAmount: totalAmount.value,
        items: items.value,
        tableNumber: tableNumber.value,
      );
      // Show success snackbar
      Get.snackbar(
        'Success',
        'Order submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      // Clear selected image after successful submission
      selectedImage.value = null;
    } on FirebaseException catch (e) {
      // Handle Firebase specific errors
      errorMessage.value = 'Firebase error: ${e.message}';
      print('Firebase error during order submission: $e');
      Get.snackbar(
        'Error',
        'Failed to submit order: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      // Handle any other unexpected errors
      errorMessage.value = 'An unexpected error occurred: $e';
      print('Unexpected error during order submission: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSubmitting.value = false; // Reset submission status
    }
  }

  Future<void> _addTransactionToHistory({
    required String paymentProofUrl,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    required String tableNumber,
  }) async {
    try {
      await _firestore.collection('transactionHistory').add({
        'paymentProofUrl': paymentProofUrl,
        'totalAmount': totalAmount,
        'items': items,
        'tableNumber': tableNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed', // You might want a different status for history
      });
      print('Transaction added to history successfully!');
    } on FirebaseException catch (e) {
      print('Firebase error adding transaction to history: ${e.message}');
      // You might want to log this error or show a silent snackbar
    } catch (e) {
      print('Error adding transaction to history: $e');
      // Handle other errors
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
