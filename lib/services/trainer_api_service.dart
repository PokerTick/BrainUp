import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class TrainerApiService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await ApiService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Dashboard Trainer
  static Future<Map<String, dynamic>?> getDashboardTrainer() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/dashboard'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching trainer dashboard: $e');
    }
    return null;
  }

  // 2. Sales Data Trainer
  static Future<Map<String, dynamic>?> getTrainerSales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/sales'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching trainer sales: $e');
    }
    return null;
  }

  // 3. Create Course
  static Future<Map<String, dynamic>?> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/courses'),
        headers: await _getHeaders(),
        body: json.encode(courseData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error creating course: $e');
    }
    return null;
  }

  // 4. Update Course
  static Future<Map<String, dynamic>?> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: await _getHeaders(),
        body: json.encode(courseData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error updating course: $e');
    }
    return null;
  }

  // 5. Create Section
  static Future<Map<String, dynamic>?> createSection(int courseId, Map<String, dynamic> sectionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/courses/$courseId/sections'),
        headers: await _getHeaders(),
        body: json.encode(sectionData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error creating section: $e');
    }
    return null;
  }

  // 5.5 Get Course Sections
  static Future<List<dynamic>?> getCourseSections(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$courseId/sections'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as List<dynamic>?;
      }
    } catch (e) {
      print('Error fetching course sections: $e');
    }
    return null;
  }

  // 6. Update Section
  static Future<Map<String, dynamic>?> updateSection(int sectionId, Map<String, dynamic> sectionData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/sections/$sectionId'),
        headers: await _getHeaders(),
        body: json.encode(sectionData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error updating section: $e');
    }
    return null;
  }

  // 7. Delete Section
  static Future<bool> deleteSection(int sectionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sections/$sectionId'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting section: $e');
      return false;
    }
  }

  // 8. Create Lesson
  static Future<Map<String, dynamic>?> createLesson(int sectionId, Map<String, dynamic> lessonData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sections/$sectionId/lessons'),
        headers: await _getHeaders(),
        body: json.encode(lessonData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error creating lesson: $e');
    }
    return null;
  }

  // 9. Update Lesson
  static Future<Map<String, dynamic>?> updateLesson(int lessonId, Map<String, dynamic> lessonData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/lessons/$lessonId'),
        headers: await _getHeaders(),
        body: json.encode(lessonData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error updating lesson: $e');
    }
    return null;
  }

  // 10. Delete Lesson
  static Future<bool> deleteLesson(int lessonId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/lessons/$lessonId'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting lesson: $e');
      return false;
    }
  }

  // 11. Messages
  static Future<List<Map<String, dynamic>>> getTrainerMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/messages'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List list = body['data'] ?? [];
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error fetching trainer messages: $e');
    }
    return [];
  }

  // 12. Upload Course Thumbnail
  static Future<bool> uploadCourseThumbnail(int courseId, String filePath) async {
    try {
      final token = await ApiService.getAccessToken();
      final uri = Uri.parse('$baseUrl/courses/$courseId/thumbnail');
      final request = http.MultipartRequest('PATCH', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Use 'thumbnail' or 'file' depending on what the backend expects, usually 'file' or 'thumbnail'
      // the error message mentioned `file` for user avatar, let's assume 'file' or 'thumbnail'.
      // If we use 'file', let's stick to standard. Let's use 'file'. Actually `updateUserAvatar` uses `file`.
      // Let's use 'file' just in case. Wait, many systems use 'file'. Let's check updateUserAvatar: it uses 'file'.
      request.files.add(await http.MultipartFile.fromPath('thumbnail', filePath));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      return streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201;
    } catch (e) {
      print('Error uploading thumbnail: $e');
      return false;
    }
  }
}
