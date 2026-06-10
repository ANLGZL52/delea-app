// lib/screens/exam_result_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/exam_config.dart';
import '../constants/exam_question_labels.dart';
import '../models/exam_question.dart';
import '../models/exam_attempt.dart';
import '../services/history_service.dart';
import '../services/plan_service.dart';
import 'question_screen.dart' show ClipRrectImage;

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
  late final FlutterTts _tts;
  double? _previousAvgScore;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _configureTts();
    _saveExamSessionToHistory();
    _loadPreviousSession();
  }

  void _configureTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _tts.setVolume(1.0);
  }

  Future<void> _loadPreviousSession() async {
    final history = await HistoryService.getHistory();
    if (!mounted) return;
    final examSessions =
        history.where((e) => e.type == 'exam_session' && e.avgScore != null).toList();
    if (examSessions.length >= 2) {
      setState(() {
        _previousAvgScore = examSessions[1].avgScore;
        _historyLoaded = true;
      });
    } else {
      setState(() => _historyLoaded = true);
    }
  }

  Future<void> _speakText(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// Backend /evaluate cevabı: scores.overall | fallback: overall_score, score, grade
  double? _extractScore(Map<String, dynamic> r) {
    final scores = r['scores'];
    if (scores is Map) {
      final raw = scores['overall'];
      if (raw != null) {
        if (raw is num) return raw.toDouble();
        if (raw is String) return double.tryParse(raw);
      }
    }
    final raw = r['overall_score'] ?? r['score'] ?? r['grade'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  /// Backend feedback objesi: feedback.overall_comment vb.
  Map<String, dynamic>? _extractFeedbackMap(Map<String, dynamic> r) {
    final fb = r['feedback'];
    if (fb is Map<String, dynamic>) return fb;
    return null;
  }

  double? _numFrom(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Eski format için metin feedback (geriye uyumluluk)
  String? _extractFeedbackText(Map<String, dynamic> r) {
    final raw = r['overall_feedback'] ?? r['feedback'] ?? r['comment'];
    if (raw == null) return null;
    if (raw is String) return raw.trim().isEmpty ? null : raw;
    return raw.toString().trim();
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
      final fbMap = _extractFeedbackMap(map);
      final fbText = fbMap?['overall_comment']?.toString() ?? _extractFeedbackText(map);

      if (s != null && ExamConfig.countsTowardScore(i)) scoreList.add(s);

      details.add({
        'questionId': q.id,
        'questionText': q.text,
        'qType': q.type,
        'score': s,
        'feedback': fbText,
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
    if (!await PlanService.isPremium()) {
      await PlanService.registerUsage('exam');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double? avgScore;
    double? avgFluency;
    double? avgGrammar;
    double? avgVocabulary;
    final scores = <double>[];
    final fluencyList = <double>[];
    final grammarList = <double>[];
    final vocabList = <double>[];

    for (int i = 0; i < widget.results.length; i++) {
      if (!ExamConfig.countsTowardScore(i)) continue;
      final raw = widget.results[i];
      if (raw is! Map<String, dynamic>) continue;
      final s = _extractScore(raw);
      if (s != null) scores.add(s);
      final sm = raw['scores'];
      if (sm is Map) {
        final f = _numFrom(sm['fluency']);
        final g = _numFrom(sm['grammar']);
        final v = _numFrom(sm['vocabulary']);
        if (f != null) fluencyList.add(f);
        if (g != null) grammarList.add(g);
        if (v != null) vocabList.add(v);
      }
    }

    if (scores.isNotEmpty) {
      avgScore = scores.reduce((a, b) => a + b) / scores.length;
    }
    if (fluencyList.isNotEmpty) {
      avgFluency = fluencyList.reduce((a, b) => a + b) / fluencyList.length;
    }
    if (grammarList.isNotEmpty) {
      avgGrammar = grammarList.reduce((a, b) => a + b) / grammarList.length;
    }
    if (vocabList.isNotEmpty) {
      avgVocabulary = vocabList.reduce((a, b) => a + b) / vocabList.length;
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
            // Özet + Geçmiş karşılaştırma + Bar chart
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
                    'Toplam soru: ${widget.questions.length}  ·  '
                    'Puanlanan: ${widget.questions.length - ExamConfig.unscoredCount}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (avgScore != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Bu sınav: ${avgScore.toStringAsFixed(1)} / 100',
                          style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_historyLoaded && _previousAvgScore != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Önceki: ${_previousAvgScore!.toStringAsFixed(1)}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  avgScore > _previousAvgScore!
                                      ? Icons.trending_up
                                      : avgScore < _previousAvgScore!
                                          ? Icons.trending_down
                                          : Icons.trending_flat,
                                  size: 16,
                                  color: avgScore > _previousAvgScore!
                                      ? const Color(0xFF22C55E)
                                      : avgScore < _previousAvgScore!
                                          ? const Color(0xFFEF4444)
                                          : Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (avgFluency != null || avgGrammar != null || avgVocabulary != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Performans Özeti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 132,
                      child: _ScoresBarChart(
                        fluency: avgFluency ?? 0,
                        grammar: avgGrammar ?? 0,
                        vocabulary: avgVocabulary ?? 0,
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
                  final scoresMap = map['scores'] is Map
                      ? map['scores'] as Map<String, dynamic>
                      : null;
                  final fbMap = _extractFeedbackMap(map);
                  final fbText = _extractFeedbackText(map);

                  return _ResultQuestionCard(
                    index: index,
                    question: q,
                    score: score,
                    scoresMap: scoresMap,
                    feedbackMap: fbMap,
                    feedbackText: fbText,
                    countsTowardScore: ExamConfig.countsTowardScore(index),
                    onSpeakCorrectedAnswer: _speakText,
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
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

/// Her soru için detaylı sonuç kartı (genişletilebilir)
class _ResultQuestionCard extends StatelessWidget {
  final int index;
  final ExamQuestion question;
  final double? score;
  final Map<String, dynamic>? scoresMap;
  final Map<String, dynamic>? feedbackMap;
  final String? feedbackText;
  final bool countsTowardScore;
  final void Function(String text)? onSpeakCorrectedAnswer;

  const _ResultQuestionCard({
    required this.index,
    required this.question,
    this.score,
    this.scoresMap,
    this.feedbackMap,
    this.feedbackText,
    this.countsTowardScore = true,
    this.onSpeakCorrectedAnswer,
  });

  static const _green = Color(0xFF22C55E);
  static const _white70 = Color(0xFFB8B8B8);
  static const _white54 = Color(0xFF8A8A8A);

  num? _num(Map<String, dynamic>? m, String k) {
    if (m == null) return null;
    final v = m[k];
    if (v is num) return v;
    if (v is String) return double.tryParse(v);
    return null;
  }

  String? _str(Map<String, dynamic>? m, String k) {
    if (m == null) return null;
    final v = m[k];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  List<String> _list(Map<String, dynamic>? m, String k) {
    if (m == null) return [];
    final v = m[k];
    if (v is List) {
      return v.map((e) => e?.toString().trim()).whereType<String>().toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final fluency = _num(scoresMap, 'fluency');
    final grammar = _num(scoresMap, 'grammar');
    final vocabulary = _num(scoresMap, 'vocabulary');
    final overall = _num(scoresMap, 'overall') ?? score;

    final verilenYanit = _str(feedbackMap, 'verilen_yanit');
    final grammarErrors = _list(feedbackMap, 'grammar_errors');
    final correctedAnswer = _str(feedbackMap, 'corrected_answer');
    final overallComment = _str(feedbackMap, 'overall_comment') ?? feedbackText;

    final hasDetails =
        fluency != null ||
        grammar != null ||
        vocabulary != null ||
        verilenYanit != null ||
        grammarErrors.isNotEmpty ||
        correctedAnswer != null ||
        overallComment != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: ExpansionTile(
        initiallyExpanded: hasDetails,
        tilePadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Soru ${index + 1}  •  ${ExamQuestionLabels.typeLabel(question.type)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              question.text,
              style: const TextStyle(
                color: _white70,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!countsTowardScore) ...[
              const SizedBox(height: 8),
              Text(
                question.type == 'personal'
                    ? 'Kişisel sorular puanlamaya dahil edilmez.'
                    : 'Isınma soruları puanlamaya dahil edilmez.',
                style: const TextStyle(
                  color: _white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else if (overall != null) ...[
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (scoresMap != null &&
                      (fluency != null || grammar != null || vocabulary != null)) ...[
                    if (fluency != null)
                      _ScoreChip(label: 'Akıcılık', value: fluency),
                    if (grammar != null)
                      _ScoreChip(label: 'Gramer', value: grammar),
                    if (vocabulary != null)
                      _ScoreChip(label: 'Kelime', value: vocabulary),
                    Text(
                      'Genel: ${overall.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else
                    Text(
                      'Puan: ${overall.toStringAsFixed(0)} / 100',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        children: [
          // Image sorularında görsel göster
          if (question.type == 'image' &&
              question.imageUrl != null &&
              question.imageUrl!.isNotEmpty) ...[
            _SectionTitle(title: 'Sorudaki Görsel'),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: (MediaQuery.of(context).size.height * 0.25)
                    .clamp(120.0, 220.0),
              ),
              child: ClipRrectImage(url: question.imageUrl!),
            ),
            const SizedBox(height: 14),
          ],
          // Karşılaştırma modu: Verdiğiniz vs Önerilen yan yana
          if ((verilenYanit != null && verilenYanit.isNotEmpty) ||
              (correctedAnswer != null && correctedAnswer.isNotEmpty)) ...[
            _SectionTitle(title: 'Cevap Karşılaştırması'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Senin Cevabın',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF475569)),
                        ),
                        child: Text(
                          verilenYanit ?? '(Cevap yok)',
                          style: const TextStyle(
                            color: _white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Önerilen Cevap',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF22C55E),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (correctedAnswer != null &&
                              correctedAnswer.isNotEmpty &&
                              onSpeakCorrectedAnswer != null) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              iconSize: 20,
                              onPressed: () =>
                                  onSpeakCorrectedAnswer!(correctedAnswer),
                              icon: const Icon(
                                Icons.volume_up,
                                color: Color(0xFF22C55E),
                              ),
                              tooltip: 'Önerilen cevabı dinle',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF22C55E).withOpacity(0.5)),
                        ),
                        child: Text(
                          correctedAnswer ?? '(Öneri yok)',
                          style: const TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (grammarErrors.isNotEmpty) ...[
            _SectionTitle(title: 'Gramer Hataları'),
            ...grammarErrors.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: _white54)),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(color: _white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (overallComment != null && overallComment.isNotEmpty) ...[
            _SectionTitle(title: 'Genel Yorum'),
            Text(
              overallComment,
              style: const TextStyle(color: _white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final Object value;

  const _ScoreChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value is num ? (value as num).toInt() : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.4)),
      ),
      child: Text(
        '$label: $v',
        style: const TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Fluency / Grammar / Vocabulary bar chart
class _ScoresBarChart extends StatelessWidget {
  final double fluency;
  final double grammar;
  final double vocabulary;

  const _ScoresBarChart({
    required this.fluency,
    required this.grammar,
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFF22C55E);
    const labelColor = Color(0xFF94A3B8);

    final barData = [
      _BarItem('Akıcılık', fluency),
      _BarItem('Gramer', grammar),
      _BarItem('Kelime', vocabulary),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        // [showingTooltipIndicators] tüm sütunlara zorunlu tooltip basıp üst üste kargaşa yaratıyordu; kapalı
        barTouchData: BarTouchData(
          enabled: false,
          handleBuiltInTouches: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= barData.length) {
                  return const SizedBox();
                }
                final item = barData[idx];
                final shown = _round0to100(item.value);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        shown.toString(),
                        style: const TextStyle(
                          color: barColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: labelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
              reservedSize: 40,
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: labelColor,
                    fontSize: 10,
                  ),
                );
              },
              interval: 25,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF334155),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.clamp(0.0, 100.0),
                color: barColor,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
            // Otomatik tooltip yok: puan, alt etiketlerde
          );
        }).toList(),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}

int _round0to100(double v) {
  if (v.isNaN) return 0;
  return v.clamp(0, 100).round();
}

class _BarItem {
  final String label;
  final double value;

  _BarItem(this.label, this.value);
}
