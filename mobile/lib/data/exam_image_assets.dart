// Tek kaynak: assets/pexels_images/img_1.jpg … img_{count}.jpg
// (WhatsApp zip’ten dönüştürüldü; sayıyı yeni dosya eklerseniz güncelleyin.)

class ExamImageAssets {
  ExamImageAssets._();

  static const int count = 91;
  static const String _root = 'assets/pexels_images';

  static String pathForIndex1Based(int n) {
    if (n < 1 || n > count) {
      throw RangeError('Görsel indeksi 1..$count arasında olmalı, verilen: $n');
    }
    return '$_root/img_$n.jpg';
  }

  static List<String> allPaths() {
    return List<String>.generate(count, (i) => pathForIndex1Based(i + 1));
  }
}
