// lib/screens/exam_intro_screen.dart
import 'package:flutter/material.dart';
import 'question_screen.dart';

import '../constants/exam_config.dart';
import '../theme/delea_tokens.dart';

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
                            'Sorular yüksek sesle okunur. Her soruda önce ${ExamConfig.thinkingSeconds} saniye '
                            'düşünme süresi vardır; ardından kayıt otomatik başlar.',
                            style: t.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          _BulletRow(
                            icon: Icons.schedule,
                            text:
                                '${ExamConfig.totalCount} soru · her soruda ${ExamConfig.thinkingSeconds} sn düşünme + ${ExamConfig.recordingSeconds} sn konuşma.',
                          ),
                          _BulletRow(
                            icon: Icons.format_list_numbered,
                            text:
                                'Sıra: ${ExamConfig.introCount} ısınma → ${ExamConfig.personalCount} kişisel → '
                                '${ExamConfig.generalCount} genel → ${ExamConfig.imageCount} fotoğraf → '
                                '${ExamConfig.scenarioCount} senaryo (karıştırılmaz).',
                          ),
                          const _BulletRow(
                            icon: Icons.mic,
                            text:
                                'Kayıt otomatik başlar. Düşünme sırasında "Cevap Ver" ile erken geçebilir; '
                                'konuşma sırasında yalnızca "Sıradaki soru" kullanılır.',
                          ),
                          const _BulletRow(
                            icon: Icons.info_outline,
                            text:
                                'İlk ${ExamConfig.unscoredCount} soru puanlamaya dahil değildir. '
                                'Genel süre sınırı yoktur.',
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
              'Simülasyon çok aşamalıdır; ücretsiz planda sınırlı deneme hakkın vardır.',
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
