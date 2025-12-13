// lib/screens/exam_history_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/exam_attempt.dart';

class ExamHistoryDetailScreen extends StatelessWidget {
  final ExamAttempt session;

  const ExamHistoryDetailScreen({super.key, required this.session});

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}";
  }

  IconData _iconForQType(String t) {
    switch (t) {
      case 'general':
        return Icons.chat;
      case 'scenario':
        return Icons.psychology_alt;
      case 'image':
        return Icons.image_outlined;
      case 'intro':
        return Icons.play_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = session.details;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("Sınav Detayı"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // üst özet kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.questionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(session.date),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Toplam soru: ${session.totalQuestions ?? details.length}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (session.avgScore != null)
                    Text(
                      "Ortalama: ${session.avgScore!.toStringAsFixed(1)} / 100",
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: details.isEmpty
                  ? const Center(
                      child: Text(
                        "Bu sınav için detay bulunamadı.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.separated(
                      itemCount: details.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final d = details[index];
                        final qText = (d['questionText'] ?? '').toString();
                        final qType = (d['qType'] ?? '').toString();

                        double? score;
                        final s = d['score'];
                        if (s is num) score = s.toDouble();
                        if (s is String) score = double.tryParse(s);

                        final fb = d['feedback']?.toString();

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_iconForQType(qType),
                                  color: Colors.blueAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Soru ${index + 1} • ${qType.toUpperCase()}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      qText,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (score != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        "Puan: ${score.toStringAsFixed(1)} / 100",
                                        style: const TextStyle(
                                          color: Color(0xFF22C55E),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    if (fb != null && fb.trim().isNotEmpty) ...[
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
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
