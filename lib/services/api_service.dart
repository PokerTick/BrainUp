import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://mobile-hybrid-solution-be.vercel.app/api';

  // ─── Auth helpers ─────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// POST /auth/login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
    } catch (_) {}
    return null;
  }

  /// POST /auth/register
  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
    } catch (_) {}
    return null;
  }

  // ─── Gamification ─────────────────────────────────────────────────────────

  /// GET /gamification/dashboard  (requires auth)
  /// Returns: { xp, currentStreak, lastLoginDate, unusedCoupons, history }
  static Future<Map<String, dynamic>?> getGamificationDashboard() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/gamification/dashboard'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// POST /gamification/spin  (requires auth, costs 100 XP)
  /// Returns: { message, coupon: { discountPct, ... } }
  static Future<Map<String, dynamic>?> spinGacha() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(Uri.parse('$baseUrl/gamification/spin'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      } else {
        // Return error message so caller can surface it
        final body = jsonDecode(response.body);
        return {'error': body['message'] ?? 'Spin failed'};
      }
    } catch (_) {}
    return {'error': 'Network error, please try again'};
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  /// GET /categories
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

  // ─── Courses ──────────────────────────────────────────────────────────────

  /// GET /courses  (public endpoint)
  /// Supports: search, page, limit, categoryId, isFree, minPrice, maxPrice
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

      final uri = Uri.parse('$baseUrl/courses').replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
    } catch (_) {}
    return {};
  }

  /// GET /courses?limit=N — fetch latest courses for home feed
  static Future<List<Map<String, dynamic>>> getCourses({
    int limit = 4,
    int? categoryId,
  }) async {
    try {
      final params = <String, String>{'limit': limit.toString()};
      if (categoryId != null) params['categoryId'] = categoryId.toString();

      final uri = Uri.parse('$baseUrl/courses').replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The courses list may be nested: data['data']['courses'] or data['data']
        final inner = data['data'];
        if (inner is List) {
          return inner.cast<Map<String, dynamic>>();
        } else if (inner is Map) {
          final coursesList = inner['courses'] ?? inner['data'] ?? [];
          if (coursesList is List) {
            return coursesList.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  /// GET /courses/:id
  static Future<Map<String, dynamic>?> getCourseById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/courses/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  // ─── My Courses (Enrollment) ──────────────────────────────────────────────

  /// GET /my-courses  (requires auth)
  static Future<List<Map<String, dynamic>>> getMyCourses() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/my-courses'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  // ─── Enrollment ───────────────────────────────────────────────────────────

  /// POST /courses/:courseId/enroll  (requires auth)
  static Future<bool> enrollInCourse(int courseId) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/courses/$courseId/enroll'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {}
    return false;
  }
}
