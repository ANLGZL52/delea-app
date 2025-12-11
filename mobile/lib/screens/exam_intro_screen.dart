// lib/screens/exam_intro_screen.dart
import 'package:flutter/material.dart';
import 'question_screen.dart';

// DEMO/PREMIUM için eklenen importlar
import '../services/plan_service.dart';
import '../widgets/demo_limit_dialog.dart';

class ExamIntroScreen extends StatelessWidget {
  const ExamIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sınav Talimatları'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3B82F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Sınav Hakkında',
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  _BulletRow(
                    emoji: '🕒',
                    text: 'Toplam 10 soru (yaklaşık 15 dakika)',
                  ),
                  _BulletRow(
                    emoji: '🎯',
                    text: '6 Genel + 2 Resim + 2 Senaryo',
                  ),
                  _BulletRow(
                    emoji: '🎙️',
                    text: 'Her soru için 45–75 saniye konuşma',
                  ),
                  _BulletRow(
                    emoji: '⚡',
                    text: 'İlk 3 soru ısınma sorusu (daha kısa)',
                  ),
                  _BulletRow(
                    emoji: '⚠️',
                    text: 'Sınav sırasında uygulamadan çıkmayın',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '💡 İpucu: Soru okunduktan sonra konuşmaya başlayın. '
                'Cevap verirken doğal olun, günlük konuşma tonunda konuşmaya çalışın.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // 🔐 DEMO/PREMIUM KONTROLÜ
                  final canUse = await PlanService.canUseFeature("exam");

                  if (!canUse) {
                    // Demo hakkı dolmuş kullanıcı
                    // Kullanıcıya uyarı dialogu göster
                    // (Bu widget'ı lib/widgets/demo_limit_dialog.dart içinde tanımladık)
                    // featureName, dialogdaki açıklama metninde kullanılacak
                    // (Örn: Exam Simulation)
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (_) => const DemoLimitDialog(
                        featureName: "Exam Simulation",
                      ),
                    );
                    return;
                  }

                  // Kullanabiliyorsa: önce kullanımını kaydet
                  await PlanService.registerUsage("exam");

                  // Sonra eski davranış: sınav ekranına geç
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QuestionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Sınava Başla ➜',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _BulletRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
