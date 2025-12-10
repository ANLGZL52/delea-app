// lib/models/exam_question.dart

class ExamQuestion {
  /// Benzersiz soru ID'si (ör: gen_1, img_5, sc_10 vs.)
  final String id;

  /// Soru tipi: 'intro', 'general', 'image', 'scenario'
  final String type;

  /// Soru metni
  final String text;

  /// Sadece image soruları için doldurulacak görsel URL'si
  final String? imageUrl;

  const ExamQuestion({
    required this.id,
    required this.type,
    required this.text,
    this.imageUrl,
  });
}
