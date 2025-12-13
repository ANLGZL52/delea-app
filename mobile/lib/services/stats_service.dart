// lib/services/stats_service.dart
import '../models/exam_attempt.dart';

class StatsSnapshot {
  final DateTime generatedAt;

  // totals
  final int totalAttempts;
  final int totalDaysActive;
  final int streakDays;

  // overall
  final double? overallAvgScoreAllTime;
  final double? overallAvgScoreLast7;
  final double? overallAvgScoreLast30;

  // by category: avg + count
  final Map<String, CategoryStats> byTypeAllTime;
  final Map<String, CategoryStats> byTypeLast7;
  final Map<String, CategoryStats> byTypeLast30;

  // trend (last N attempts overall)
  final double? last10Avg;
  final double? prev10Avg; // previous window before last10
  final double? trendDelta; // last10 - prev10

  const StatsSnapshot({
    required this.generatedAt,
    required this.totalAttempts,
    required this.totalDaysActive,
    required this.streakDays,
    required this.overallAvgScoreAllTime,
    required this.overallAvgScoreLast7,
    required this.overallAvgScoreLast30,
    required this.byTypeAllTime,
    required this.byTypeLast7,
    required this.byTypeLast30,
    required this.last10Avg,
    required this.prev10Avg,
    required this.trendDelta,
  });
}

class CategoryStats {
  final int count;
  final double? avgScore;

  const CategoryStats({
    required this.count,
    required this.avgScore,
  });
}

class StatsService {
  /// Uygulamada göstereceğimiz kategori seti
  /// ✅ exam_session eklendi
  static const List<String> knownTypes = [
    'general',
    'scenario',
    'image',
    'exam',
    'exam_session',
  ];

  static StatsSnapshot buildSnapshot(List<ExamAttempt> history) {
    final now = DateTime.now();

    // history newest-first geliyorsa bile garanti altına alalım:
    final items = [...history]..sort((a, b) => b.date.compareTo(a.date));

    final last7Cutoff = now.subtract(const Duration(days: 7));
    final last30Cutoff = now.subtract(const Duration(days: 30));

    final all = items;
    final last7 = items.where((e) => e.date.isAfter(last7Cutoff)).toList();
    final last30 = items.where((e) => e.date.isAfter(last30Cutoff)).toList();

    final byAll = _groupByType(all);
    final by7 = _groupByType(last7);
    final by30 = _groupByType(last30);

    final overallAll = _avgScore(all);
    final overall7 = _avgScore(last7);
    final overall30 = _avgScore(last30);

    final activeDays = _distinctActiveDays(items);
    final streak = _calcStreakDays(items, now);

    final last10 = _avgScore(items.take(10).toList());
    final prev10 = items.length > 10
        ? _avgScore(items.skip(10).take(10).toList())
        : null;
    final trendDelta =
        (last10 != null && prev10 != null) ? (last10 - prev10) : null;

    return StatsSnapshot(
      generatedAt: now,
      totalAttempts: items.length,
      totalDaysActive: activeDays,
      streakDays: streak,
      overallAvgScoreAllTime: overallAll,
      overallAvgScoreLast7: overall7,
      overallAvgScoreLast30: overall30,
      byTypeAllTime: byAll,
      byTypeLast7: by7,
      byTypeLast30: by30,
      last10Avg: last10,
      prev10Avg: prev10,
      trendDelta: trendDelta,
    );
  }

  static Map<String, CategoryStats> _groupByType(List<ExamAttempt> list) {
    final map = <String, List<ExamAttempt>>{};

    // knownTypes’ı baştan ekleyelim ki UI stabil kalsın
    for (final t in knownTypes) {
      map[t] = [];
    }

    for (final e in list) {
      // ✅ Bilinmeyen type’ları “general”e zorlamıyoruz.
      // İleride yeni tür eklersen istatistikte kaybolmaz.
      final t = e.type;
      map.putIfAbsent(t, () => []);
      map[t]!.add(e);
    }

    final out = <String, CategoryStats>{};
    for (final t in map.keys) {
      final items = map[t]!;
      out[t] = CategoryStats(
        count: items.length,
        avgScore: _avgScore(items),
      );
    }
    return out;
  }

  static double? _avgScore(List<ExamAttempt> list) {
    final scores = list
        .map((e) => e.score)
        .where((s) => s != null)
        .map((s) => s!)
        .toList();
    if (scores.isEmpty) return null;
    final sum = scores.reduce((a, b) => a + b);
    return sum / scores.length;
  }

  static int _distinctActiveDays(List<ExamAttempt> list) {
    final set = <String>{};
    for (final e in list) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      set.add('${d.year}-${d.month}-${d.day}');
    }
    return set.length;
  }

  /// Bugün dahil geriye doğru “üst üste aktif gün” sayısı.
  static int _calcStreakDays(List<ExamAttempt> list, DateTime now) {
    if (list.isEmpty) return 0;

    final activeDaySet = <String>{};
    for (final e in list) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      activeDaySet.add('${d.year}-${d.month}-${d.day}');
    }

    int streak = 0;
    DateTime cursor = DateTime(now.year, now.month, now.day);
    while (true) {
      final key = '${cursor.year}-${cursor.month}-${cursor.day}';
      if (!activeDaySet.contains(key)) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
