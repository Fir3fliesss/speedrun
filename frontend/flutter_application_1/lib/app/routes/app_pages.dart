import 'package:get/get.dart';

import '../modules/home/views/signup_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => SignupPage(),
    ),
  ];
}
