import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiService {
  // Use the deployed backend URL instead of localhost, since localhost might not be running
  static const String baseUrl = 'https://mobile-hybrid-solution-be.vercel.app/api';
  static const String prodBaseUrl = 'https://mobile-hybrid-solution-be.vercel.app/api';

  // Helper to save auth tokens from a successful response
  static Future<Map<String, dynamic>> _saveAuthTokens(Map<String, dynamic> authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', authData['accessToken'] ?? '');
    await prefs.setString('refreshToken', authData['refreshToken'] ?? '');
    await prefs.setString('userRole', authData['user']?['role'] ?? 'USER');
    await prefs.setString('userName', authData['user']?['name'] ?? '');
    await prefs.setString('userEmail', authData['user']?['email'] ?? '');
    return {'success': true, 'role': authData['user']?['role'] ?? 'USER'};
  }

  // Fetch categories (used as trending topics)
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/categories'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  // Search courses by keyword with optional filters
  static Future<Map<String, dynamic>> searchCourses(
    String query, {
    int page = 1,
    int limit = 10,
    int? categoryId,
    bool? isFree,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final params = <String, String>{
        'search': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (categoryId != null) params['categoryId'] = categoryId.toString();
      if (isFree != null) params['isFree'] = isFree.toString();
      if (minPrice != null) params['minPrice'] = minPrice.toStringAsFixed(0);
      if (maxPrice != null) params['maxPrice'] = maxPrice.toStringAsFixed(0);

      final uri =
          Uri.parse('$baseUrl/courses').replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
    } catch (_) {}
    return {};
  }

  // Register a new user
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // Login a user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return await _saveAuthTokens(data['data']);
      }
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // Google Sign-In
  static Future<Map<String, dynamic>> googleSignIn() async {
    try {
      // Initialize the Google Sign-In instance with the required Client IDs
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb
            ? '270829782979-gt5m92no3pqckk9np3ciqnmu901k9bl8.apps.googleusercontent.com'
            : null,
        serverClientId: '270829782979-gt5m92no3pqckk9np3ciqnmu901k9bl8.apps.googleusercontent.com',
      );

      // Trigger the native Google Sign-In flow
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();

      // Get the authentication tokens from Google (no longer a Future in 7.x.x)
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'Failed to get Google token'};
      }

      // Send the Google ID token to the backend for verification
      final response = await http.post(
        Uri.parse('$prodBaseUrl/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final authData = data['data'] ?? data;
        return await _saveAuthTokens(authData);
      }

      // Fallback: If backend doesn't have a /mobile endpoint,
      // use the Google account info directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', account.displayName ?? '');
      await prefs.setString('userEmail', account.email);
      await prefs.setString('userRole', 'USER');
      return {'success': true, 'role': 'USER'};
    } catch (e) {
      return {'success': false, 'message': 'Google sign-in failed: ${e.toString()}'};
    }
  }
}
