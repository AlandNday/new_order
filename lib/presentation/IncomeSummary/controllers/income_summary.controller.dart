import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart'; // For date formatting and week calculation

// A unique identifier for your application for structuring Firestore paths.
// You can change this string if you need a different identifier for your local data.
// Since 'orders' is a root collection, _app_id is no longer used in the collection path,
// but kept here in case it's used elsewhere in your application logic.
const String _app_id = 'neworder-c5d5c';

class IncomeSummaryController extends GetxController {
  // Observables to store the calculated income summaries
  final RxDouble dailyIncome = 0.0.obs;
  final RxDouble weeklyIncome = 0.0.obs;
  final RxDouble monthlyIncome = 0.0.obs;

  // RxMap to store historical income data for charting
  final RxMap<String, double> historicalDailyIncome = <String, double>{}.obs;
  final RxMap<String, double> historicalWeeklyIncome = <String, double>{}.obs;
  final RxMap<String, double> historicalMonthlyIncome = <String, double>{}.obs;

  // Firestore and Auth instances
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  // RxBool to indicate if Firebase authentication is ready
  final RxBool isAuthReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirebaseAndAuth();
  }

  // Initializes Firebase and handles authentication.
  // This method now assumes Firebase.initializeApp() has already been called
  // in main.dart using DefaultFirebaseOptions.currentPlatform.
  Future<void> _initializeFirebaseAndAuth() async {
    try {
      print('Initializing Firebase and Authentication...');
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        print(
          'Warning: Firebase not initialized before controller. Attempting to initialize.',
        );
        Get.snackbar(
          'Error',
          'Firebase not initialized. Please ensure Firebase.initializeApp() is called in main.dart.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      print('FirebaseFirestore and FirebaseAuth instances obtained.');

      // Listen to authentication state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user == null) {
          // User is signed out or not signed in yet.
        } else {
          print('User signed in: ${user.uid}');
          isAuthReady.value = true; // Set auth ready when a user is signed in
          _listenToOrders(); // Start listening to orders only after successful authentication
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize Firebase services: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Firebase services initialization error: $e');
    }
  }

  // Sets up a real-time listener for orders in Firestore.
  void _listenToOrders() {
    // Ensure authentication is ready before attempting to fetch data
    if (!isAuthReady.value) {
      print('Authentication not ready, cannot listen to orders yet.');
      return;
    }

    // Construct the collection path. Based on the new information,
    // 'orders' is a top-level collection.
    final String collectionPath =
        'orders'; // Changed to direct 'orders' collection
    print('Attempting to listen to Firestore path: $collectionPath');

    _firestore
        .collection(collectionPath)
        .where(
          'status',
          isEqualTo: 'completed',
        ) // Filter for 'completed' status
        .where(
          'paymentstatus',
          isEqualTo: 'verified',
        ) // Filter for 'verified' payment
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            print('Received ${snapshot.docs.length} documents from Firestore.');
            if (snapshot.docs.isEmpty) {
              print(
                'No documents found matching "status: completed" and "paymentstatus: verified".',
              );
            }
            _calculateIncomeSummaries(snapshot.docs);
          },
          onError: (error) {
            Get.snackbar(
              'Error',
              'Failed to fetch orders: $error',
              snackPosition: SnackPosition.BOTTOM,
            );
            print('Error fetching orders: $error');
          },
        );
  }

  // Calculates daily, weekly, and monthly income summaries from a list of documents.
  void _calculateIncomeSummaries(List<DocumentSnapshot> documents) {
    print('Calculating income summaries for ${documents.length} documents.');
    // Reset all income totals and historical data before recalculating
    dailyIncome.value = 0.0;
    weeklyIncome.value = 0.0;
    monthlyIncome.value = 0.0;
    historicalDailyIncome.clear();
    historicalWeeklyIncome.clear();
    historicalMonthlyIncome.clear();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Start of today

    final int weekday = now.weekday;
    final DateTime startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: weekday - 1));

    final DateTime startOfMonth = DateTime(now.year, now.month, 1);

    for (var doc in documents) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final Timestamp? timestamp = data['timestamp'] as Timestamp?;

        print('Processing document ID: ${doc.id}');
        print('  totalAmount: $totalAmount');
        print('  timestamp: $timestamp');

        if (timestamp == null) {
          print(
            'Warning: Order document ${doc.id} has no timestamp. Skipping.',
          );
          continue; // Skip this document if timestamp is missing
        }
        final DateTime orderDate = timestamp.toDate();
        print('  orderDate (converted): $orderDate');

        // Check if the order is from today
        if (_isSameDay(orderDate, today)) {
          dailyIncome.value += totalAmount;
        }

        // Check if the order is from the current week
        if (_isSameWeek(orderDate, startOfWeek)) {
          weeklyIncome.value += totalAmount;
        }

        // Check if the order is from the current month
        if (_isSameMonth(orderDate, startOfMonth)) {
          monthlyIncome.value += totalAmount;
        }

        // --- Populate historical data for charts ---

        // Daily historical
        final dailyKey = DateFormat('yyyy-MM-dd').format(orderDate);
        historicalDailyIncome.update(
          dailyKey,
          (value) => value + totalAmount,
          ifAbsent: () => totalAmount,
        );

        // Weekly historical (using year and week number)
        final weekOfYear = _getWeekOfYear(orderDate);
        final weeklyKey =
            '${orderDate.year}-${weekOfYear.toString().padLeft(2, '0')}';
        historicalWeeklyIncome.update(
          weeklyKey,
          (value) => value + totalAmount,
          ifAbsent: () => totalAmount,
        );

        // Monthly historical
        final monthlyKey = DateFormat('yyyy-MM').format(orderDate);
        historicalMonthlyIncome.update(
          monthlyKey,
          (value) => value + totalAmount,
          ifAbsent: () => totalAmount,
        );
      } catch (e) {
        print('Error processing order document ${doc.id}: $e');
      }
    }
    print('Daily Income: ${dailyIncome.value}');
    print('Weekly Income: ${weeklyIncome.value}');
    print('Monthly Income: ${monthlyIncome.value}');
    print('Historical Daily Income: ${historicalDailyIncome.value}');
    print('Historical Weekly Income: ${historicalWeeklyIncome.value}');
    print('Historical Monthly Income: ${historicalMonthlyIncome.value}');
  }

  // Helper function to check if two DateTimes are on the same day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Helper function to check if two DateTimes are in the same week.
  // This considers Monday as the first day of the week.
  bool _isSameWeek(DateTime date, DateTime startOfWeek) {
    // Normalize dates to start of their respective weeks (Monday)
    final normalizedDate = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
    final normalizedStartOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).subtract(Duration(days: startOfWeek.weekday - 1));
    return normalizedDate == normalizedStartOfWeek;
  }

  // Helper function to check if two DateTimes are in the same month.
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  // Helper function to get the week number of the year for a given date.
  // This implementation uses the ISO 8601 standard where week 1 starts with the first Thursday of the year.
  int _getWeekOfYear(DateTime date) {
    // Adjust date to be within its own week, Monday as first day
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    // January 4th is always in the first week according to ISO 8601
    DateTime jan4 = DateTime(monday.year, 1, 4);
    // Find the Monday of the week containing Jan 4
    DateTime firstMondayOfJan4Week = jan4.subtract(
      Duration(days: jan4.weekday - 1),
    );

    // Calculate the difference in days from the first Monday of the year (or the week containing Jan 4)
    int diff = monday.difference(firstMondayOfJan4Week).inDays;
    return (diff / 7).floor() + 1;
  }
}
