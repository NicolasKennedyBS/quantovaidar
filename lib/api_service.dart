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
        if (data['fullName'] != null) await prefs.setString('userName', data['fullName']);
        
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

  Future<List<dynamic>> getInvoices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/invoice'));

      if (response.statusCode == 200) {
        final List<dynamic> allInvoices = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (userId == null) return [];

        return allInvoices.where((inv) => inv['user']['id'] == userId).toList();
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

    String cleanValue = receiptData['value'].toString()
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
}