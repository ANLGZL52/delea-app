/// Sınav soru tipleri için Türkçe etiketler.
class ExamQuestionLabels {
  ExamQuestionLabels._();

  static String typeLabel(String type) {
    switch (type) {
      case 'intro':
        return 'Isınma Sorusu';
      case 'personal':
        return 'Kişisel Soru';
      case 'general':
        return 'Genel Soru';
      case 'image':
        return 'Fotoğraf Sorusu';
      case 'scenario':
        return 'Senaryo Sorusu';
      default:
        return type;
    }
  }
}
