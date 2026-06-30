import 'package:flutter/material.dart';
import 'package:brainup/services/api_service.dart';
import 'package:brainup/services/trainer_api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to get course 1 to see the payload
  final course = await ApiService.getCourseById(1);
  print('=== COURSE DETAILS ===');
  print(jsonEncode(course));
  
  // Try fetching sections directly if possible
  try {
    final token = await ApiService.getAccessToken();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/courses/1/sections'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print('=== SECTIONS API ===');
    print(response.statusCode);
    print(response.body);
  } catch(e) {
    print('Error: $e');
  }
}
