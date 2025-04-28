import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SignupPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final role = 'user'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sign Up', style: TextStyle(fontSize: 24)),
              TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: fullNameController, decoration: InputDecoration(labelText: 'Full Name')),
              Obx(() => DropdownButton<String>(
                value: role.value,
                items: ['user', 'admin'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  role.value = newValue!;
                },
              )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AuthController.to.signup(
                    usernameController.text,
                    passwordController.text,
                    emailController.text,
                    fullNameController.text,
                    role.value,
                  );
                },
                child: Text('Sign Up'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
