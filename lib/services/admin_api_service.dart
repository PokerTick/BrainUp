import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Admin-only API service.
/// Attempts real API calls first, falls back to mock data if endpoints
/// are not yet implemented on the backend.
class AdminApiService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<Map<String, String>> _authHeaders() async {
    final token = await ApiService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Dashboard Stats ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Fetch all required data concurrently from the other API endpoints
      final responses = await Future.wait([
        getAllUsers(),
        getTrainerRequests(),
        getAllCourses(),
        getAllOrders(),
      ]);

      final users = responses[0] as List<Map<String, dynamic>>;
      final trainerRequests = responses[1] as List<Map<String, dynamic>>;
      final courses = responses[2] as List<Map<String, dynamic>>;
      final orders = responses[3] as List<Map<String, dynamic>>;

      int totalUsers = users.length;
      int totalTrainers = users.where((u) => u['role'] == 'TRAINER').length;
      int totalCourses = courses.length;
      int totalOrders = orders.length;

      double totalRevenue = 0;
      for (var order in orders) {
        final price = order['netRevenue'] ?? order['coursePrice'] ?? order['price'] ?? order['amount'] ?? 0;
        totalRevenue += (price is num ? price.toDouble() : double.tryParse(price.toString()) ?? 0.0);
      }

      double platformRevenue = totalRevenue * 0.20;
      double trainerRevenue = totalRevenue * 0.80;
      double serviceFeeIncome = totalOrders * 10000.0;
      int pendingTrainerRequests = trainerRequests.where((r) => r['status'] == 'PENDING').length;

      return {
        'totalUsers': totalUsers,
        'totalTrainers': totalTrainers,
        'totalCourses': totalCourses,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'platformRevenue': platformRevenue,
        'trainerRevenue': trainerRevenue,
        'serviceFeeIncome': serviceFeeIncome,
        'pendingTrainerRequests': pendingTrainerRequests,
        'activeEnrollments': totalOrders,
      };
    } catch (e) {
      print('--- getDashboardStats ERROR: $e');
      return {};
    }
  }

  // ─── Users ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllUsers({String? roleFilter}) async {
    try {
      final headers = await _authHeaders();
      final params = <String, String>{};
      if (roleFilter != null) params['role'] = roleFilter;

      // Updated endpoint: /users
      final uri = Uri.parse('$baseUrl/users').replace(queryParameters: params.isNotEmpty ? params : null);
      print('--- getAllUsers REQUEST URI: $uri');
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      print('--- getAllUsers STATUS: ${response.statusCode}');
      print('--- getAllUsers BODY: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.cast<Map<String, dynamic>>();
        } else if (body is Map) {
          dynamic dataField = body['data'];
          if (dataField is List) {
            return dataField.cast<Map<String, dynamic>>();
          } else if (dataField is Map) {
            final List list = dataField['data'] ?? dataField['items'] ?? [];
            return list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (e) {
      print('--- getAllUsers ERROR: $e');
    }
    return [];
  }

  static Future<bool> updateUserRole(int userId, String newRole) async {
    try {
      final headers = await _authHeaders();
      // Updated endpoint: /users/:id
      final response = await http
          .patch(
            Uri.parse('$baseUrl/users/$userId'),
            headers: headers,
            body: jsonEncode({'role': newRole}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> updateUserAvatar(int userId, List<int> bytes, String filename) async {
    try {
      final token = await ApiService.getAccessToken();
      final uri = Uri.parse('$baseUrl/users/$userId/avatar');
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(http.MultipartFile.fromBytes(
        'file', // Assuming the field name is 'file' or 'avatar'
        bytes,
        filename: filename,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      return streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201;
    } catch (e) {
      print('--- updateUserAvatar ERROR: $e');
    }
    return false;
  }

  // ─── Trainer Requests ─────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTrainerRequests() async {
    try {
      final headers = await _authHeaders();
      // Updated endpoint: /admin/trainer-requests
      final response = await http
          .get(Uri.parse('$baseUrl/admin/trainer-requests'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.cast<Map<String, dynamic>>();
        } else if (body is Map) {
          dynamic dataField = body['data'];
          if (dataField is List) {
            return dataField.cast<Map<String, dynamic>>();
          } else if (dataField is Map) {
            final List list = dataField['data'] ?? dataField['items'] ?? [];
            return list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> approveTrainerRequest(int requestId) async {
    try {
      final headers = await _authHeaders();
      // Updated endpoint: /admin/trainer/:trainerRequestId/verify
      final response = await http
          .patch(
            Uri.parse('$baseUrl/admin/trainer/$requestId/verify'),
            headers: headers,
            body: jsonEncode({'status': 'APPROVED'}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> rejectTrainerRequest(int requestId) async {
    try {
      final headers = await _authHeaders();
      // Updated endpoint: /admin/trainer/:trainerRequestId/verify
      final response = await http
          .patch(
            Uri.parse('$baseUrl/admin/trainer/$requestId/verify'),
            headers: headers,
            body: jsonEncode({'status': 'REJECTED'}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ─── Courses ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/courses'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.cast<Map<String, dynamic>>();
        } else if (body is Map) {
          dynamic dataField = body['data'];
          if (dataField is List) {
            return dataField.cast<Map<String, dynamic>>();
          } else if (dataField is Map) {
            final List list = dataField['data'] ?? dataField['courses'] ?? [];
            return list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> updateCourse(int id, Map<String, dynamic> updates) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .patch(
            Uri.parse('$baseUrl/courses/$id'),
            headers: headers,
            body: jsonEncode(updates),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/orders'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.cast<Map<String, dynamic>>();
        } else if (body is Map) {
          dynamic dataField = body['data'];
          if (dataField is List) {
            return dataField.cast<Map<String, dynamic>>();
          } else if (dataField is Map) {
            final List list = dataField['data'] ?? dataField['orders'] ?? [];
            return list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> updateOrderStatus(int id, String status) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .patch(
            Uri.parse('$baseUrl/orders/$id/status'),
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/categories'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.cast<Map<String, dynamic>>();
        } else if (body is Map) {
          dynamic dataField = body['data'];
          if (dataField is List) {
            return dataField.cast<Map<String, dynamic>>();
          } else if (dataField is Map) {
            final List list = dataField['data'] ?? dataField['items'] ?? [];
            return list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> createCategory(String name) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/categories'),
            headers: headers,
            body: jsonEncode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteCategory(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/categories/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {}
    return false;
  }
}
