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

  Future<bool> login(String email, String password) async {
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

        if (data['defaultPixKey'] != null) {
          await prefs.setString('default_pix', data['defaultPixKey']);
        }
        if (data['defaultTradeName'] != null) {
          await prefs.setString('default_name', data['defaultTradeName']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Erro Login: $e");
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String pixKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": name,
          "email": email,
          "password": password,
          "defaultTradeName": name,
          "defaultPixKey": pixKey,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Erro Register: $e");
      return false;
    }
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
      print("Erro Get Invoices: $e");
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
      "user": {"id": userId},
      "clientName": receiptData['client'],
      "issuerNameSnapshot": receiptData['issuer'],
      "pixKeySnapshot": receiptData['pix'],
      "totalValue": double.tryParse(cleanValue) ?? 0.0,
      "issueDate": DateTime.now().toIso8601String().substring(0, 10),
      "styleCode": receiptData['style'] ?? 0,
      "type": receiptData['isProduct'] == true ? 1 : 0,
      "description": receiptData['service']
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoice'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erro Create Invoice: $e");
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/invoice/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print("Erro Delete: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
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
      print("Erro Update Profile: $e");
      return false;
    }
  }
}
