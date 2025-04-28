import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/home/controllers/auth_controller.dart';
import 'app/modules/home/views/home_page.dart';
import 'app/modules/home/views/login_page.dart';
import 'app/modules/home/views/signup_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Bind AuthController
  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return GetMaterialApp(
      title: 'Flutter CRUD Auth',
      initialRoute: '/signup',
      getPages: [
        GetPage(name: '/signup', page: () => SignupPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
      ],
    );
  }
}
