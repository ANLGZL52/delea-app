/// Sınav simülasyonu tek kaynak: `QuestionScreen` ve talimat ekranı aynı değerleri kullanmalı.
class ExamConfig {
  ExamConfig._();

  static const int introCount = 2;
  static const int generalCount = 6;
  static const int imageCount = 3;
  static const int scenarioCount = 2;

  static int get totalCount =>
      introCount + generalCount + imageCount + scenarioCount;
}
