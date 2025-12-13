// lib/screens/exam_result_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/exam_question.dart';
import '../models/exam_attempt.dart';
import '../services/history_service.dart';

class ExamResultScreen extends StatefulWidget {
  final List<ExamQuestion> questions;
  final List<Map<String, dynamic>?> results;

  const ExamResultScreen({
    super.key,
    required this.questions,
    required this.results,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveExamSessionToHistory();
  }

  double? _extractScore(Map<String, dynamic> r) {
    final raw = r['overall_score'] ?? r['score'] ?? r['grade'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String? _extractFeedback(Map<String, dynamic> r) {
    final raw = r['overall_feedback'] ?? r['feedback'] ?? r['comment'];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  Future<void> _saveExamSessionToHistory() async {
    if (_saved) return;
    if (widget.questions.length <= 1) return; // tek soru değilse session yaz

    _saved = true;
    final now = DateTime.now();
    final sessionId = now.millisecondsSinceEpoch.toString();

    // detay listesi hazırla
    final List<Map<String, dynamic>> details = [];
    final List<double> scoreList = [];

    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final raw = (i < widget.results.length ? widget.results[i] : null);
      final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};

      final s = _extractScore(map);
      final fb = _extractFeedback(map);

      if (s != null) scoreList.add(s);

      details.add({
        'questionId': q.id,
        'questionText': q.text,
        'qType': q.type,
        'score': s,
        'feedback': fb,
      });
    }

    double? avgScore;
    if (scoreList.isNotEmpty) {
      avgScore = scoreList.reduce((a, b) => a + b) / scoreList.length;
    }

    final sessionAttempt = ExamAttempt(
      id: sessionId,
      sessionId: sessionId,
      questionId: 'session',
      questionText: 'Exam Simulation',
      type: 'exam_session',
      date: now,
      totalQuestions: widget.questions.length,
      avgScore: avgScore,
      detailsJson: jsonEncode(details),
    );

    await HistoryService.addAttempt(sessionAttempt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ortalama skor UI için
    double? avgScore;
    final scores = widget.results
        .whereType<Map<String, dynamic>>()
        .map((r) => _extractScore(r))
        .whereType<double>()
        .toList();

    if (scores.isNotEmpty) {
      avgScore = scores.reduce((a, b) => a + b) / scores.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sınav Sonuçları'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Özet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3B82F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genel Özet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toplam soru: ${widget.questions.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (avgScore != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ortalama puan: ${avgScore.toStringAsFixed(1)} / 100',
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final q = widget.questions[index];
                  final raw =
                      index < widget.results.length ? widget.results[index] : null;

                  final map =
                      (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};

                  final score = _extractScore(map);
                  final fb = _extractFeedback(map);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soru ${index + 1}  •  ${q.type.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.text,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        if (score != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Puan: ${score.toStringAsFixed(1)} / 100',
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (fb != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            fb,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Geri dön'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
