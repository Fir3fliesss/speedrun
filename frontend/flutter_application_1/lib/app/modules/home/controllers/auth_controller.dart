import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final storage = FlutterSecureStorage();
  var isLoggedIn = false.obs;
  var token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() async {
    String? storedToken = await storage.read(key: 'token');
    if (storedToken != null) {
      token.value = storedToken;
      isLoggedIn.value = true;
      Get.offAll(() => HomePage());
    }
  }

  void signup(String username, String password, String email, String fullName, String role) async {
    bool success = await ApiService.signup(username, password, email, fullName, role);
    if (success) {
      Get.snackbar('Success', 'Sign Up successful');
      Get.offAll(() => LoginPage());
    } else {
      Get.snackbar('Error', 'Sign Up failed');
    }
  }

  void login(String username, String password) async {
    bool success = await ApiService.login(username, password);
    if (success) {
      isLoggedIn.value = true;
      token.value = await storage.read(key: 'token') ?? '';
      Get.offAll(() => HomePage());
    } else {
      Get.snackbar('Error', 'Login failed');
    }
  }

  void logout() async {
    await storage.delete(key: 'token');
    isLoggedIn.value = false;
    token.value = '';
    Get.offAll(() => LoginPage());
  }
}
