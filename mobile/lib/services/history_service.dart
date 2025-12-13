// lib/services/history_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_attempt.dart';

class HistoryService {
  static const String _historyKey = 'exam_history_v1';
  static const int _maxItems = 200;

  static Future<void> addAttempt(ExamAttempt attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);

    List<ExamAttempt> list = [];
    if (raw != null) {
      list = ExamAttempt.decodeList(raw);
    }

    list.insert(0, attempt);

    if (list.length > _maxItems) {
      list = list.sublist(0, _maxItems);
    }

    await prefs.setString(_historyKey, ExamAttempt.encodeList(list));
  }

  static Future<List<ExamAttempt>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    return ExamAttempt.decodeList(raw);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
