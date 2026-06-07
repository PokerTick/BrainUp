import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

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
}
