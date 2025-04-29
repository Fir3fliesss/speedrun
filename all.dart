// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/login_page.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';

void main() {
  Get.put(AuthController());
  Get.put(ProductController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Shop',
      home: LoginPage(),
    );
  }
}

// models.dart
class User {
  final int id;
  final String namaLengkap;
  final String name;
  final String alamat;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.namaLengkap,
    required this.name,
    required this.alamat,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      namaLengkap: json['nama_lengkap'] ?? json['nana_lengkap'],
      name: json['name'],
      alamat: json['alamat'] ?? json['alanat'] ?? json['atamat'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Product {
  final int id;
  final String nama;
  final int harga;
  int stok; // Mutable for local stock updates
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      stok: json['stok'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Emulator base URL

  static Future<http.Response> register(
      String namaLengkap, String name, String alamat, String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama_lengkap': namaLengkap,
        'name': name,
        'atamat': alamat, // As per API body example
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> getProducts(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/api/produk'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> logout(String token) async {
    return await http.post(
      Uri.parse('$baseUrl/api/logout'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }
}

// controllers/auth_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import '../models.dart';
import '../api_service.dart';
import '../pages/product_list_page.dart';
import '../pages/login_page.dart';

class AuthController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final RxString token = RxString('');

  Future<void> register(String namaLengkap, String name, String alamat, String email, String password) async {
    try {
      final response = await ApiService.register(namaLengkap, name, alamat, email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user.value = User.fromJson(data['user']);
        token.value = data['token'];
        Get.offAll(() => ProductListPage());
      } else {
        Get.snackbar('Error', 'Registrasi gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user.value = User.fromJson(data['data']['user']);
        token.value = data['token'] ?? ''; // Assuming token is included
        Get.offAll(() => ProductListPage());
      } else {
        Get.snackbar('Error', 'Login gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    }
  }

  Future<void> logout() async {
    try {
      final response = await ApiService.logout(token.value);
      if (response.statusCode == 200) {
        user.value = null;
        token.value = '';
        Get.offAll(() => LoginPage());
        Get.snackbar('Sukses', 'Logout berhasil');
      } else {
        Get.snackbar('Error', 'Logout gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    }
  }
}

// controllers/product_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import '../models.dart';
import '../api_service.dart';

class ProductController extends GetxController {
  final RxList<Product> products = RxList<Product>([]);
  final RxMap<int, int> selectedQuantities = RxMap<int, int>({});
  final RxString searchText = RxString('');
  final RxBool isAscending = RxBool(true);

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      final token = Get.find<AuthController>().token.value;
      final response = await ApiService.getProducts(token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Product> productList = (data['data'] as List).map((e) => Product.fromJson(e)).toList();
        products.value = productList;
        selectedQuantities.value = {for (var p in productList) p.id: 0};
      } else {
        Get.snackbar('Error', 'Gagal mengambil produk');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    }
  }

  List<Product> get filteredProducts {
    List<Product> filtered = products.where((p) => p.nama.toLowerCase().contains(searchText.value.toLowerCase())).toList();
    filtered.sort((a, b) => isAscending.value ? a.harga.compareTo(b.harga) : b.harga.compareTo(a.harga));
    return filtered;
  }

  void increaseQuantity(int productId) {
    final product = products.firstWhere((p) => p.id == productId);
    if (selectedQuantities[productId]! < product.stok) {
      selectedQuantities[productId] = selectedQuantities[productId]! + 1;
    } else {
      Get.snackbar('Info', 'Stok maksimum tercapai');
    }
  }

  void decreaseQuantity(int productId) {
    if (selectedQuantities[productId]! > 0) {
      selectedQuantities[productId] = selectedQuantities[productId]! - 1;
    }
  }

  int get totalPrice {
    int total = 0;
    for (var entry in selectedQuantities.entries) {
      if (entry.value > 0) {
        final product = products.firstWhere((p) => p.id == entry.key);
        total += product.harga * entry.value;
      }
    }
    return total;
  }

  void updateStock() {
    for (var entry in selectedQuantities.entries) {
      if (entry.value > 0) {
        final product = products.firstWhere((p) => p.id == entry.key);
        product.stok -= entry.value;
      }
    }
    selectedQuantities.value = {for (var p in products) p.id: 0};
    products.refresh();
  }
}

// pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/login_image.jpg', height: 200),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email wajib diisi';
                          if (!GetUtils.isEmail(value)) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password wajib diisi';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            authController.login(_emailController.text, _passwordController.text);
                          }
                        },
                        child: Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => RegisterPage()),
                child: Text('Belum punya akun? Silahkan buatkan akun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _namaLengkapController = TextEditingController();
  final _nameController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _namaLengkapController,
                  decoration: InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) => value == null || value.isEmpty ? 'Nama lengkap wajib diisi' : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nama'),
                  validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
                ),
                TextFormField(
                  controller: _alamatController,
                  decoration: InputDecoration(labelText: 'Alamat'),
                  validator: (value) => value == null || value.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email wajib diisi';
                    if (!GetUtils.isEmail(value)) return 'Format email tidak valid';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.register(
                        _namaLengkapController.text,
                        _nameController.text,
                        _alamatController.text,
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/auth_controller.dart';
import 'invoice_page.dart';
import 'user_profile_page.dart';

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Get.to(() => UserProfilePage()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => productController.searchText.value = value,
                    decoration: InputDecoration(labelText: 'Cari'),
                  ),
                ),
                IconButton(
                  icon: Obx(() => Icon(productController.isAscending.value ? Icons.arrow_upward : Icons.arrow_downward)),
                  onPressed: () => productController.isAscending.value = !productController.isAscending.value,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final products = productController.filteredProducts;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: Image.asset('assets/${product.nama}.jpg', width: 50, height: 50),
                    title: Text(product.nama),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: ${product.harga}'),
                        Text('Stok: ${product.stok}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => productController.decreaseQuantity(product.id),
                        ),
                        Obx(() => Text('${productController.selectedQuantities[product.id]}')),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => productController.increaseQuantity(product.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() {
            final total = productController.totalPrice;
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
              child: Column(
                children: [
                  Text('Total: $total', style: TextStyle(fontSize: 18)),
                  ElevatedButton(
                    onPressed: total > 0 ? () => Get.to(() => InvoicePage()) : null,
                    child: Text('Bayar'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// pages/invoice_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../controllers/product_controller.dart';

class InvoicePage extends StatelessWidget {
  Future<void> _generateAndShareInvoice(ProductController controller) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Invoice'];
    sheet.appendRow(['No', 'Nama Barang', 'Jumlah', 'Harga', 'Total']);
    int no = 1;
    int grandTotal = 0;
    for (var entry in controller.selectedQuantities.entries) {
      if (entry.value > 0) {
        final product = controller.products.firstWhere((p) => p.id == entry.key);
        final total = product.harga * entry.value;
        sheet.appendRow([no, product.nama, entry.value, product.harga, total]);
        grandTotal += total;
        no++;
      }
    }
    sheet.appendRow(['', '', '', 'Total', grandTotal]);
    final fileBytes = excel.encode();
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/invoice.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);
    Share.shareFiles([filePath], text: 'Invoice');
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('INVOICE'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final selected = productController.selectedQuantities.entries
                    .where((e) => e.value > 0)
                    .map((e) => MapEntry(
                          e.key,
                          productController.products.firstWhere((p) => p.id == e.key),
                        ))
                    .toList();
                return ListView.builder(
                  itemCount: selected.length,
                  itemBuilder: (context, index) {
                    final product = selected[index].value;
                    final quantity = selected[index].key;
                    return ListTile(
                      title: Text('${index + 1}. ${product.nama}'),
                      subtitle: Text('Jumlah: ${productController.selectedQuantities[product.id]} | Harga: ${product.harga}'),
                    );
                  },
                );
              }),
            ),
            Obx(() => Text('Total: ${productController.totalPrice}', style: TextStyle(fontSize: 18))),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _generateAndShareInvoice(productController),
              child: Text('Share'),
            ),
            ElevatedButton(
              onPressed: () {
                productController.updateStock();
                Get.back();
                Get.snackbar('Terima Kasih', 'Pembayaran selesai');
              },
              child: Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}

// pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Halo, ${authController.user.value?.namaLengkap ?? ''}')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/profile.jpg', height: 150),
            SizedBox(height: 20),
            Obx(() => Text('Email: ${authController.user.value?.email ?? ''}')),
            Obx(() => Text('Alamat: ${authController.user.value?.alamat ?? ''}')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authController.logout(),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
