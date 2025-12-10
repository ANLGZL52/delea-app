// lib/screens/exam_result_screen.dart

import 'package:flutter/material.dart';

import '../models/exam_question.dart';

class ExamResultScreen extends StatelessWidget {
  final List<ExamQuestion> questions;
  final List<Map<String, dynamic>?> results;

  const ExamResultScreen({
    super.key,
    required this.questions,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final q = questions[index];
          final result = results[index];

          final scores =
              (result?['scores'] as Map<String, dynamic>?) ?? {};
          final feedback =
              (result?['feedback'] as Map<String, dynamic>?) ?? {};
          final transcript = result?['transcript'] as String? ?? '';

          return Card(
            color: const Color(0xFF111827),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.blue.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}  •  ${q.type.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    q.text,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  if (scores.isNotEmpty) ...[
                    Text(
                      'Overall: ${scores['overall'] ?? 0} / 100',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fluency: ${scores['fluency'] ?? 0}   '
                      'Grammar: ${scores['grammar'] ?? 0}   '
                      'Vocab: ${scores['vocabulary'] ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    const Text(
                      'Bu soru için herhangi bir cevap kaydı yok.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (feedback['overall_comment'] != null) ...[
                    const Text(
                      'Genel Yorum:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feedback['overall_comment'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (feedback['corrected_answer'] != null) ...[
                    const Text(
                      'Önerilen Cevap (ENG):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feedback['corrected_answer'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (transcript.isNotEmpty) ...[
                    const Text(
                      'Senin Yanıtın (transcript):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transcript,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
