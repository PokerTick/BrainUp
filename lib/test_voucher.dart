import 'package:flutter/material.dart';
import 'package:brainup/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final token = await ApiService.getAccessToken();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/vouchers'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print('=== VOUCHERS API ===');
    print(response.statusCode);
    print(response.body);
  } catch(e) {
    print('Error: $e');
  }
}
