import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchService {
  static const _key = 'recent_searches';
  static const int maxItems = 10;

  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    // Remove duplicate then prepend
    current.remove(query);
    current.insert(0, query);
    if (current.length > maxItems) current.removeRange(maxItems, current.length);
    await prefs.setStringList(_key, current);
  }

  static Future<void> removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove(query);
    await prefs.setStringList(_key, current);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
