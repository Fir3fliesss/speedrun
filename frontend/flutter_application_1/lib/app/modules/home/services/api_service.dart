import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/user'; // ganti sesuai IP kalau di device fisik
  static final storage = FlutterSecureStorage();

  // Sign Up
  static Future<bool> signup(String username, String password, String email, String fullName, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'), // endpoint signup kamu
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'full_name': fullName,
        'role': role,
      }),
    );
    return response.statusCode == 201;
  }

  // Login
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'), // endpoint login kamu
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      await storage.write(key: 'token', value: token);
      return true;
    }
    return false;
  }

  // Get All Users (butuh token)
  static Future<List<dynamic>> getAllUsers() async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Get User by ID (khusus admin)
static Future<Map<String, dynamic>> getUserById(int id) async {
  final token = await storage.read(key: 'token');
  final response = await http.get(
    Uri.parse('$baseUrl/$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load user by ID');
  }
}


  // Update User (PUT) (butuh token)
  static Future<bool> updateUser(int id, String fullName) async {
    final token = await storage.read(key: 'token');
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'full_name': fullName}),
    );
    return response.statusCode == 200;
  }

  // Delete User (DELETE) (butuh token)
  static Future<bool> deleteUser(int id) async {
    final token = await storage.read(key: 'token');
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  // Logout
  static Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
