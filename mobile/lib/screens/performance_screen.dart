// lib/screens/performance_screen.dart
import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../services/stats_service.dart';
import '../services/recommendation_engine.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool _loading = true;
  StatsSnapshot? _snap;
  Recommendation? _rec;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final history = await HistoryService.getHistory();
    final snap = StatsService.buildSnapshot(history);
    final rec = RecommendationEngine.build(snap);

    if (!mounted) return;
    setState(() {
      _snap = snap;
      _rec = rec;
      _loading = false;
    });
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'general':
        return 'General';
      case 'scenario':
        return 'Scenario';
      case 'image':
        return 'Image';
      case 'exam':
        return 'Exam Simulation';
      case 'exam_session':
        return 'Exam Simulation';
      default:
        return t;
    }
  }

  Color _typeColor(String t) {
    switch (t) {
      case 'general':
        return Colors.greenAccent;
      case 'scenario':
        return Colors.redAccent;
      case 'image':
        return Colors.tealAccent;
      case 'exam':
        return Colors.purpleAccent;
      case 'exam_session':
        return Colors.amberAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _fmtScore(double? v) => v == null ? '-' : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final snap = _snap;
    final rec = _rec;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("Performans"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: (_loading || snap == null || rec == null)
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ÜST METRİK KARTLARI
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: "Ortalama (7g)",
                          value: _fmtScore(snap.overallAvgScoreLast7),
                          sub: "30g: ${_fmtScore(snap.overallAvgScoreLast30)}",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          title: "Streak",
                          value: "${snap.streakDays}",
                          sub: "Aktif gün: ${snap.totalDaysActive}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    title: "Trend (son 10)",
                    value: _fmtScore(snap.last10Avg),
                    sub: snap.trendDelta == null
                        ? "Yeterli veri yok"
                        : (snap.trendDelta! >= 0
                            ? "+${snap.trendDelta!.toStringAsFixed(1)} puan"
                            : "${snap.trendDelta!.toStringAsFixed(1)} puan"),
                  ),

                  const SizedBox(height: 16),

                  // ÖNERİ
                  const _SectionTitle("Bu haftanın önerisi"),
                  const SizedBox(height: 10),
                  _RecommendationCard(rec: rec),

                  const SizedBox(height: 16),

                  // KATEGORİ BAZLI ÖZET (30 gün)
                  const _SectionTitle("Kategori performansı (son 30 gün)"),
                  const SizedBox(height: 10),
                  ...snap.byTypeLast30.entries.map((e) {
                    final t = e.key;
                    final s = e.value;
                    if (s.count == 0) return const SizedBox.shrink();

                    final color = _typeColor(t);
                    return _CategoryRow(
                      label: _typeLabel(t),
                      count: s.count,
                      avg: s.avgScore,
                      color: color,
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // KATEGORİ BAZLI ÖZET (all time)
                  const _SectionTitle("Kategori performansı (tüm zamanlar)"),
                  const SizedBox(height: 10),
                  ...snap.byTypeAllTime.entries.map((e) {
                    final t = e.key;
                    final s = e.value;
                    if (s.count == 0) return const SizedBox.shrink();

                    final color = _typeColor(t);
                    return _CategoryRow(
                      label: _typeLabel(t),
                      count: s.count,
                      avg: s.avgScore,
                      color: color,
                    );
                  }).toList(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(sub,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  const _RecommendationCard({required this.rec});

  Color _tagColor(String t) {
    switch (t) {
      case 'general':
        return Colors.greenAccent;
      case 'scenario':
        return Colors.redAccent;
      case 'image':
        return Colors.tealAccent;
      case 'exam':
        return Colors.purpleAccent;
      case 'exam_session':
        return Colors.amberAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _tagColor(rec.focusType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: c.withOpacity(0.6)),
                ),
                child: Text(
                  rec.focusType.toUpperCase(),
                  style: TextStyle(
                    color: c,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rec.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rec.body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final int count;
  final double? avg;
  final Color color;

  const _CategoryRow({
    required this.label,
    required this.count,
    required this.avg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            "Deneme: $count",
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(width: 12),
          Text(
            avg == null ? "Skor: -" : "Skor: ${avg!.toStringAsFixed(1)}",
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
