// lib/screens/dla_info_screen.dart
import 'package:flutter/material.dart';

class DlaInfoScreen extends StatelessWidget {
  const DlaInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      appBar: AppBar(
        title: const Text('DLA Hakkında'),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: 'DLA Nedir?',
              child: const Text(
                'DLA (Digital Language Assessment), Türk Hava Yolları kabin memuru '
                'adaylarının İngilizce konuşma becerisini ölçen dijital bir sınavdır. '
                'Sınav; akıcılık, gramer, kelime bilgisi ve iletişim yeteneğinizi '
                'değerlendirir. Amaç, uçuş sırasında yolcularla etkili ve profesyonel '
                'şekilde iletişim kurup kuramayacağınızı ölçmektir.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: 'Sınavın Genel Yapısı',
              child: const Text(
                '• Genel Sorular: Kendinizi tanıtma, günlük hayat, iş/okul, hobiler gibi '
                'konularda konuşma.\n'
                '• Senaryolar: Kabin içinde yaşanabilecek problemli veya hassas durumlara '
                'verdiğiniz tepkiler ve iletişim tarzınız.\n'
                '• Resim Açıklama: Ekranda gördüğünüz bir fotoğrafı ayrıntılı şekilde '
                'anlatmanız ve yorumlamanız beklenir.\n\n'
                'Her bölümde net, anlaşılır ve profesyonel bir İngilizce kullanmanız '
                'beklenir.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: 'Değerlendirilen Kriterler',
              child: const Text(
                '• Fluency (Akıcılık): Duraksamadan, çok takılmadan konuşabilme.\n'
                '• Grammar (Dilbilgisi): Zamanları, cümle yapılarını ve temel dilbilgisi '
                'kurallarını doğru kullanma.\n'
                '• Vocabulary (Kelime Bilgisi): Uygun ve yeterli kelime kullanımı, '
                'özellikle havacılık ve müşteri ilişkileriyle ilgili kelimeler.\n'
                '• Coherence (Tutarlılık): Cevabınızın giriş–gelişme–sonuç açısından '
                'mantıklı ve düzenli olması.\n'
                '• Appropriateness (Uygunluk): Kabin görevlisine yakışır, nazik ve '
                'profesyonel bir üslup kullanmanız.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: 'Hazırlık İpuçları',
              child: const Text(
                '• Mükemmel gramer peşinde koşmak yerine, anlaşılır ve akıcı olmaya odaklan.\n'
                '• Cevaplarına kısa bir giriş yap, ardından detay ver ve küçük bir özetle bitir.\n'
                '• “Customer, safety, delay, turbulence, emergency, crew, passenger” gibi '
                'çekirdek kelimeleri sık kullanmaya çalış.\n'
                '• Özellikle senaryolarda empati, sakinlik ve çözüm odaklı bir tavır göstermeye dikkat et.\n'
                '• Evde pratik yaparken süre tut ve en az 45–60 saniye konuşmayı hedefle.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: 'Senaryolarda Nelere Dikkat Etmeliyim?',
              child: const Text(
                '• Önce yolcunun duygusunu anladığını göster: “I understand that you are upset…”\n'
                '• Özür ve empati cümleleri kullan: “I\'m really sorry for the inconvenience.”\n'
                '• Çözüm veya alternatif sun: “Let me check what I can do for you.”\n'
                '• Sakin, nazik ve profesyonel bir ton kullan; tartışmaya girme.\n'
                '• Güvenlik içeren durumlarda, prosedürlere bağlı kalmayı mutlaka vurgula.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: 'Sık Yapılan Hatalar',
              child: const Text(
                '• Çok kısa cevaplar vermek (1–2 cümle ile yetinmek).\n'
                '• Sadece “yes/no” tarzı cevaplar vermek, örnek ve detay eklememek.\n'
                '• Anlamadığında hiç soru sormamak; oysa “Could you please repeat the question?” demek doğal.\n'
                '• Çok uzun duraklamalar ve “ee, ıı” gibi sesleri aşırı kullanmak.\n'
                '• Senaryolarda savunmacı veya kaba bir üslup kullanmak.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: 'Bu Uygulama Bana Nasıl Yardımcı Olur?',
              child: const Text(
                '• Sınav Simülasyonu: Gerçeğe yakın bir DLA deneyimi yaşayıp, her sorudan sonra skorlarını görebilirsin.\n'
                '• Genel Sorular: Kendini ifade etme ve akıcılık konusunda pratik yaparsın.\n'
                '• Senaryolar: Kabin içi problem çözme ve iletişim becerilerini geliştirirsin.\n'
                '• Resim Açıklama: Detaylı anlatım ve yorumlama becerini güçlendirirsin.\n'
                '• Sözlük: DLA’da işine yarayacak kelimeleri hedefli şekilde öğrenebilirsin.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'Unutma: Amaç, mükemmel olmak değil; \n'
                'yolcuya güven veren, net ve profesyonel bir iletişim kurabilmek.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white24,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
