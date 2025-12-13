// lib/services/recommendation_engine.dart
import 'stats_service.dart';

class Recommendation {
  final String title;
  final String body;
  final String focusType; // general/scenario/image/exam/exam_session

  const Recommendation({
    required this.title,
    required this.body,
    required this.focusType,
  });
}

class RecommendationEngine {
  static Recommendation build(StatsSnapshot snap) {
    // Öncelik: son 30 gün (yoksa all time)
    final base = _pickBaseMap(snap);

    // En düşük ortalama skorlu kategoriyi bul
    final worst = _findWorstCategory(base);

    // Trend kötüleşiyorsa farklı uyarı ekle
    final trend = snap.trendDelta;

    if (worst == null) {
      return const Recommendation(
        title: "Başlayalım!",
        body: "Henüz skor yok. Bir deneme yap, sonra sana kişisel öneri çıkarayım.",
        focusType: "general",
      );
    }

    // ✅ exam_session -> exam gibi davran (plan mantığı aynı)
    final t = _normalizeType(worst);

    switch (t) {
      case 'exam':
        return Recommendation(
          title: "Öneri: Sınav Simülasyonu Rutini",
          body: _withTrend(
            "Bu hafta 2 kez Exam Simulation yap.\n"
            "Kural: Her simülasyon sonrası 1 zayıf kategoride (General/Scenario/Image) 2 ek deneme.",
            trend,
          ),
          focusType: worst, // kullanıcıda hangisi varsa onu tag’le
        );

      case 'scenario':
        return Recommendation(
          title: "Öneri: Scenario Güçlendirme",
          body: _withTrend(
            "Günde 1 scenario denemesi yap.\n"
            "Format: (1) Situation → (2) Action → (3) Result. Her cevapta bu 3 adımı zorunlu tut.",
            trend,
          ),
          focusType: "scenario",
        );

      case 'image':
        return Recommendation(
          title: "Öneri: Image Description Hızlandırma",
          body: _withTrend(
            "Günde 1 image denemesi.\n"
            "3 aşama: Overview (1 cümle) → Details (3 cümle) → Inference (1 cümle).",
            trend,
          ),
          focusType: "image",
        );

      case 'general':
      default:
        return Recommendation(
          title: "Öneri: General Akıcılık",
          body: _withTrend(
            "Günde 2 kısa general deneme (30–45 sn).\n"
            "Kural: duraksama olursa cümleyi baştan değil, kaldığın yerden toparla.",
            trend,
          ),
          focusType: "general",
        );
    }
  }

  static String _normalizeType(String t) {
    if (t == 'exam_session') return 'exam';
    return t;
  }

  static String _withTrend(String base, double? trendDelta) {
    if (trendDelta == null) return base;
    if (trendDelta >= 2) {
      return "$base\n\n📈 Trend iyi: Son denemeler önceki döneme göre +${trendDelta.toStringAsFixed(1)} puan.";
    } else if (trendDelta <= -2) {
      return "$base\n\n📉 Trend düştü: Son denemeler önceki döneme göre ${trendDelta.toStringAsFixed(1)} puan. Bugün kısa ama düzenli pratik öneriyorum.";
    }
    return "$base\n\n➖ Trend stabil: ${trendDelta.toStringAsFixed(1)} puan.";
  }

  static Map<String, CategoryStats> _pickBaseMap(StatsSnapshot snap) {
    // 30 gün boşsa all-time
    final any30 = snap.byTypeLast30.values.any((v) => v.count > 0);
    return any30 ? snap.byTypeLast30 : snap.byTypeAllTime;
  }

  static String? _findWorstCategory(Map<String, CategoryStats> map) {
    String? worstType;
    double worstScore = 999999;

    map.forEach((type, stat) {
      if (stat.count == 0) return;

      final avg = stat.avgScore;
      // skor yoksa ama deneme varsa: “zayıf” kabul et
      final effective = (avg == null) ? -1.0 : avg;

      if (effective < worstScore) {
        worstScore = effective;
        worstType = type;
      }
    });

    return worstType;
  }
}
