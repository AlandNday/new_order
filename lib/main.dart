import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage

import 'package:new_order/firebase_options.dart';
import 'package:new_order/infrastructure/navigation/navigation.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init(); // Initialize GetStorage

  String initialRoute = Routes.LOG_IN; // Default to login route
  final box = GetStorage(); // Create an instance of GetStorage

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // User is logged in, now fetch their role from Firestore
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        // Store the entire user profile (map) in GetStorage
        // It's good practice to use a key that identifies the current user,
        // though for a single logged-in user, a generic key might suffice.
        // Using a key like 'user_profile_${currentUser.uid}' is robust.
        final userData = userDoc.data()!;
        await box.write('user_profile', userData); // Store the entire map
        await box.write(
          'user_uid',
          currentUser.uid,
        ); // Store UID for easy access
        print('User profile stored in GetStorage: ${userData}');

        String? role =
            userData['role'] as String?; // Assuming 'role' field in Firestore

        if (role == 'admin') {
          initialRoute =
              Routes.ADMINNAVBAR; // Define your admin bottom nav bar route
          print('User is admin. Redirecting to admin dashboard.');
        } else if (role == 'customer') {
          initialRoute =
              Routes.BOTTOM_NAV_BAR; // Your regular user bottom nav bar route
          print('User is customer. Redirecting to customer dashboard.');
        } else {
          initialRoute = Routes.LOG_IN;
          print('User role unknown or missing. Redirecting to login.');
          await FirebaseAuth.instance.signOut();
          // Clear potentially invalid profile data if role is unknown
          await box.remove('user_profile');
          await box.remove('user_uid');
        }
      } else {
        // User document not found in Firestore, despite being authenticated
        initialRoute = Routes.HOME;
        print('User document not found in Firestore. Redirecting to login.');
        await FirebaseAuth.instance
            .signOut(); // Sign out orphaned authenticated user
        await box.remove('user_profile'); // Clear profile if document not found
        await box.remove('user_uid');
      }
    } catch (e) {
      print('Error fetching user role from Firestore: $e');
      initialRoute = Routes.LOG_IN; // Fallback to login on error
      await FirebaseAuth.instance.signOut(); // Sign out on error
      await box.remove('user_profile'); // Clear profile on error
      await box.remove('user_uid');
    }
  } else {
    print('No user logged in. Redirecting to login.');
    // Ensure profile is cleared if no user is logged in
    await box.remove('user_profile');
    await box.remove('user_uid');
  }

  runApp(MainApp(initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "New Order App",
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: Nav
          .routes, // Assuming Nav.routes is where your GetX pages are defined
    );
  }
}
