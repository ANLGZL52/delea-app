// lib/models/exam_attempt.dart
import 'dart:convert';

import 'exam_question.dart';

class ExamAttempt {
  final String id;

  /// Tek soru için: gerçek soru id
  /// Session için: "session"
  final String questionId;

  /// Tek soru için: soru metni
  /// Session için: "Exam Simulation" gibi başlık
  final String questionText;

  /// "general", "scenario", "image", "exam_session" vb.
  final String type;

  final DateTime date;
  final double? score; // tek soru skoru (varsa)
  final String? feedback; // tek soru feedback (varsa)

  /// ✅ Sınav oturumu için
  final String? sessionId;
  final int? totalQuestions;
  final double? avgScore;

  /// ✅ Sınav oturumu detayları: JSON string
  /// İçerik: [{questionId, questionText, qType, score, feedback}, ...]
  final String? detailsJson;

  ExamAttempt({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.type,
    required this.date,
    this.score,
    this.feedback,
    this.sessionId,
    this.totalQuestions,
    this.avgScore,
    this.detailsJson,
  });

  /// Tek soru kaydı üretmek için (general/scenario/image gibi)
  factory ExamAttempt.fromQuestionResult({
    required ExamQuestion question,
    required String type,
    required Map<String, dynamic> result,
  }) {
    final now = DateTime.now();

    final rawScore = result['overall_score'] ?? result['score'];
    double? score;
    if (rawScore is num) {
      score = rawScore.toDouble();
    } else if (rawScore is String) {
      score = double.tryParse(rawScore);
    }

    final rawFb =
        result['overall_feedback'] ?? result['feedback'] ?? result['comment'];

    String? feedback;
    if (rawFb is String) {
      feedback = rawFb;
    } else if (rawFb != null) {
      feedback = rawFb.toString();
    }

    return ExamAttempt(
      id: now.millisecondsSinceEpoch.toString(),
      questionId: question.id,
      questionText: question.text,
      type: type,
      date: now,
      score: score,
      feedback: feedback,
    );
  }

  /// ✅ Exam session detaylarını liste olarak okumak için
  List<Map<String, dynamic>> get details {
    if (detailsJson == null || detailsJson!.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(detailsJson!);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionId': questionId,
        'questionText': questionText,
        'type': type,
        'date': date.toIso8601String(),
        'score': score,
        'feedback': feedback,

        // ✅ yeni alanlar (eski kayıtlarla uyumlu)
        'sessionId': sessionId,
        'totalQuestions': totalQuestions,
        'avgScore': avgScore,
        'detailsJson': detailsJson,
      };

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    // score
    double? parsedScore;
    final js = json['score'];
    if (js is num) parsedScore = js.toDouble();
    if (js is String) parsedScore = double.tryParse(js);

    // avgScore
    double? parsedAvg;
    final ja = json['avgScore'];
    if (ja is num) parsedAvg = ja.toDouble();
    if (ja is String) parsedAvg = double.tryParse(ja);

    // totalQuestions
    int? parsedTotal;
    final jt = json['totalQuestions'];
    if (jt is int) parsedTotal = jt;
    if (jt is num) parsedTotal = jt.toInt();
    if (jt is String) parsedTotal = int.tryParse(jt);

    return ExamAttempt(
      id: (json['id'] ?? '').toString(),
      questionId: (json['questionId'] ?? '').toString(),
      questionText: (json['questionText'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      score: parsedScore,
      feedback: json['feedback'] as String?,

      sessionId: json['sessionId'] as String?,
      totalQuestions: parsedTotal,
      avgScore: parsedAvg,
      detailsJson: json['detailsJson'] as String?,
    );
  }

  static String encodeList(List<ExamAttempt> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ExamAttempt> decodeList(String raw) {
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => ExamAttempt.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
