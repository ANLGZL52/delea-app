/// Sınav simülasyonu tek kaynak: `QuestionScreen` ve talimat ekranı aynı değerleri kullanmalı.
class ExamConfig {
  ExamConfig._();

  static const int introCount = 2;
  static const int personalCount = 1;
  static const int generalCount = 6;
  static const int imageCount = 2;
  static const int scenarioCount = 2;

  /// İlk 3 soru (2 intro + 1 kişisel) puana dahil değil.
  static const int unscoredCount = introCount + personalCount;

  static const int thinkingSeconds = 15;
  static const int recordingSeconds = 75;

  static int get totalCount =>
      introCount + personalCount + generalCount + imageCount + scenarioCount;

  /// Ortalama puana dahil mi (soru 4–13).
  static bool countsTowardScore(int index) => index >= unscoredCount;

  /// API değerlendirmesine gönderilsin mi (kişisel soru transkript için dahil; intro hariç).
  static bool shouldEvaluate(int index) => index >= introCount;
}
