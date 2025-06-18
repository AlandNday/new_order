import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  EnvironmentsBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.LOG_IN,
      page: () => const LogInScreen(),
      binding: LogInControllerBinding(),
    ),
    GetPage(
      name: Routes.SIGN_UP,
      page: () => const SignUpScreen(),
      binding: SignUpControllerBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordControllerBinding(),
    ),
    GetPage(
      name: Routes.HOMEPAGE,
      page: () => const HomepageScreen(),
      binding: HomepageControllerBinding(),
    ),
    GetPage(
      name: Routes.BOTTOM_NAV_BAR,
      page: () => const BottomNavBarScreen(),
      binding: BottomNavBarControllerBinding(),
    ),
    GetPage(
      name: Routes.SHOPMENU,
      page: () => const ShopmenuScreen(),
      binding: ShopmenuControllerBinding(),
    ),
    GetPage(
      name: Routes.CART,
      page: () => const CartScreen(),
      binding: CartControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileControllerBinding(),
    ),
    GetPage(
      name: Routes.ACCOUNT_INFORMATION,
      page: () => const AccountInformationScreen(),
      binding: AccountInformationControllerBinding(),
    ),
    GetPage(
      name: Routes.HOMEPAGEADMIN,
      page: () => const HomepageadminScreen(),
      binding: HomepageadminControllerBinding(),
    ),
    GetPage(
      name: Routes.HOMEPAGENAVBAR,
      page: () => const HomepagenavbarScreen(),
      binding: HomepagenavbarControllerBinding(),
    ),
    GetPage(
      name: Routes.ADMINNAVBAR,
      page: () => const AdminnavbarScreen(),
      binding: AdminnavbarControllerBinding(),
    ),
    GetPage(
      name: Routes.ADMINORDERS,
      page: () => const AdminordersScreen(),
      binding: AdminordersControllerBinding(),
    ),
    GetPage(
      name: Routes.ADMINPROFILE,
      page: () => const AdminprofileScreen(),
      binding: AdminprofileControllerBinding(),
    ),
    GetPage(
      name: Routes.CHECKOUTPAYMENT,
      page: () => const CheckoutpaymentScreen(),
      binding: CheckoutpaymentControllerBinding(),
    ),
    GetPage(
      name: Routes.ANNOUNCEMENT,
      page: () => const AnnouncementScreen(),
      binding: AnnouncementControllerBinding(),
    ),
    GetPage(
      name: Routes.REVIEW,
      page: () => const ReviewScreen(),
      binding: ReviewControllerBinding(),
    ),
    GetPage(
      name: Routes.TRANSACTIONHISTORY,
      page: () => const TransactionhistoryScreen(),
      binding: TransactionhistoryControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILEEDITOR,
      page: () => const ProfileeditorScreen(),
      binding: ProfileeditorControllerBinding(),
    ),
    GetPage(
      name: Routes.INCOME_SUMMARY,
      page: () => const IncomeSummaryScreen(),
      binding: IncomeSummaryControllerBinding(),
    ),
  ];
}
