import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8080/api";
    } else {
      return "http://10.0.2.2:8080/api";
    }
  }

  Future<int> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if (data['id'] != null) await prefs.setString('userId', data['id']);
        if (data['fullName'] != null)
          await prefs.setString('userName', data['fullName']);
        if (data['defaultPixKey'] != null)
          await prefs.setString('default_pix', data['defaultPixKey']);
        if (data['defaultTradeName'] != null)
          await prefs.setString('default_name', data['defaultTradeName']);

        return 200;
      }
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) print("Erro Login: $e");
      return 500;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String? pixKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/registrar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": name,
          "email": email,
          "password": password,
          "defaultTradeName": name,
          "defaultPixKey": pixKey ?? "",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("Erro Register: $e");
      return false;
    }
  }

  Future<bool> confirmRegister(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/confirmar-registro'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "codigo": code.replaceAll(" ", "")}),
      );
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      if (kDebugMode) print("Erro Confirm Register: $e");
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/esqueci-senha'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      if (kDebugMode) print("Erro Forgot Password: $e");
      return false;
    }
  }

  Future<bool> redefinirSenha(String email, String novaSenha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/redefinir-senha'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "novaSenha": novaSenha}),
      );
      return jsonDecode(response.body)['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfile(String tradeName, String pixKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "defaultTradeName": tradeName,
          "defaultPixKey": pixKey,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print("Erro Update Profile: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
  }

  Future<List<dynamic>> getInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return [];

      final response =
          await http.get(Uri.parse('$baseUrl/invoice/user/$userId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("Erro Get Invoices: $e");
      return [];
    }
  }

  Future<bool> createInvoice(Map<String, dynamic> receiptData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return false;

    String cleanValue = receiptData['value']
        .toString()
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    final Map<String, dynamic> body = {
      if (receiptData['id'] != null) "id": receiptData['id'],
      "user": {"id": userId},
      "clientName": receiptData['client'],
      "issuerNameSnapshot": receiptData['issuer'],
      "pixKeySnapshot": receiptData['pix'],
      "totalValue": double.tryParse(cleanValue) ?? 0.0,
      "issueDate": DateTime.now().toIso8601String().substring(0, 10),
      "styleCode": receiptData['style'] ?? 0,
      "type": receiptData['type'] ?? 0,
      "description": receiptData['description'],
      "rawDescription": receiptData['rawDescription'],
      "itemUnit": receiptData['itemUnit'],
      "itemQty": receiptData['itemQty']?.toString(),
      "itemPrice": receiptData['itemPrice']?.toString(),
      "itemCode": receiptData['itemCode']
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoice'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print("Erro Create Invoice: $e");
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/invoice/$id'));
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print("Erro Delete: $e");
      return false;
    }
  }
}
