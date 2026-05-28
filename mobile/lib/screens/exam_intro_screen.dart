// lib/screens/exam_intro_screen.dart
import 'package:flutter/material.dart';
import 'question_screen.dart';

import '../constants/exam_config.dart';
import '../services/plan_service.dart';
import '../theme/delea_tokens.dart';
import 'premium_screen.dart';

class ExamIntroScreen extends StatelessWidget {
  const ExamIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav talimatı'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hazırlık simülasyonu',
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(
                color: DeleaColors.brandLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: DeleaColors.backgroundCard,
                        borderRadius: BorderRadius.circular(DeleaRadii.xl),
                        border: Border.all(
                          color: DeleaColors.brandLight.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DeleaColors.brand.withValues(alpha: 0.15),
                            offset: const Offset(0, 6),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nasıl ilerler?',
                            style: t.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sorular yüksek sesle okunur. Kaydı başlatıp, düşünmek için kısa bir an '
                            'bırakabilir; cevabınızı cümlelere böl.',
                            style: t.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          _BulletRow(
                            icon: Icons.schedule,
                            text:
                                'Yaklaşık ${ExamConfig.totalCount} soru · 18–24 dakika; konuşma bölümlerinde 45–75 sn hedef.',
                          ),
                          _BulletRow(
                            icon: Icons.shuffle,
                            text:
                                'İçerik dağılımı: ${ExamConfig.introCount} ısınma, ${ExamConfig.generalCount} genel, ${ExamConfig.imageCount} resim, ${ExamConfig.scenarioCount} senaryo — rastgele sırada.',
                          ),
                          const _BulletRow(
                            icon: Icons.mic,
                            text:
                                'Her soru için ayrı kayıt. Bitince cevaplar toplu değerlendirilir; internet kesintisinde bölüme yeniden dönmeden hata alabilirsiniz.',
                          ),
                          const _BulletRow(
                            icon: Icons.warning_amber_rounded,
                            text:
                                'Arayı çok uzatırsanız cevabınız nitelik açısından sınıflanabilir. Simülasyonu tek oturumda bitirmeniz iyi pratiktir.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DeleaColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(DeleaRadii.lg),
                        border: Border.all(
                          color: DeleaColors.border,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            size: 22,
                            color: DeleaColors.brandLight.withValues(alpha: 0.95),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aşırı “kusursuz aksan”dan çok, anlaşılır ve tutarlı bir tını hedefleyin. '
                              'Soruyu dinleyip nefes alın; cevabınızı iki–üç cümlelik net bloklara bölün.',
                              style: t.bodyMedium?.copyWith(
                                color: DeleaColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                if (!await PlanService.isPremium()) {
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: DeleaColors.backgroundCard,
                      title: const Text('Premium gerekli'),
                      content: const Text(
                        'Sınav simülasyonu yalnızca Premium abonelikle açılır. '
                        'Ana ekrandaki sınava, Premium olduktan sonra ulaşırsın.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Kapat'),
                        ),
                        FilledButton.tonal(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final unlocked = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PremiumScreen(),
                              ),
                            );
                            if (!context.mounted) return;
                            final isPrem = unlocked == true ||
                                await PlanService.isPremium();
                            if (!isPrem) return;
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QuestionScreen(),
                              ),
                            );
                          },
                          child: const Text('Premium’u aç'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                if (!context.mounted) return;
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuestionScreen(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: DeleaColors.brand,
              ),
              child: const Text('Simülasyona devam et'),
            ),
            const SizedBox(height: 8),
            Text(
              'Simülasyon çok aşamalıdır; sınava yalnızca Premium aboneleri başlayabilir.',
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(
                color: DeleaColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BulletRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: DeleaColors.brandLight.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: DeleaColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
