// lib/screens/main_home_screen.dart

import 'package:flutter/material.dart';

// Hizmetler
import '../services/plan_service.dart';
import '../services/demo_limiter.dart';

// Var olan ekranlar
import 'exam_intro_screen.dart';
import 'general_questions_screen.dart';
import 'scenario_screen.dart';
import 'image_description_screen.dart';
import 'dictionary_screen.dart';
import 'dla_info_screen.dart';
import 'submit_question_screen.dart';
import 'profile_screen.dart';

/// DEMO sınırı dolduğunda gösterilecek uyarı dialog'u
Future<void> showDemoLimitDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0B1120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Demo Sınırına Ulaştın',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Demo sürümde bu bölümde bugün en fazla 1 soru cevaplayabilirsin.\n\n'
          'Tüm sorulara ve sınırsız denemeye erişmek için premium sürüme geçebilirsin.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // İleride "Plan / Satın Al" ekranına yönlendirme ekleyebilirsin
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanScreen()));
            },
            child: const Text(
              'Premium’a Geç',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF050509);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ÜST BAR: Premium badge + profil ikonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32), // solda boşluk, simetri için

                  // PREMIUM ROZETİ
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PROFİL İKONU
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // UYGULAMA BAŞLIK ALANI
              const Center(
                child: Column(
                  children: [
                    Text(
                      'DeLeA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Welcome Aboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BÜYÜK "SINAV SİMÜLASYONU" BUTONU
              GestureDetector(
                onTap: () async {
                  final isPremium = await PlanService.isPremium();
                  final allowed =
                      await DemoLimiter.canUseSection(SectionType.exam);

                  if (!isPremium && !allowed) {
                    return showDemoLimitDialog(context);
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExamIntroScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Sınav Simülasyonu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ALTTAKİ 2x3 GRID MENÜ
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _HomeMenuTile(
                      color: const Color(0xFF22C55E), // yeşil
                      icon: Icons.chat_bubble_outline,
                      label: 'Genel Sorular',
                      onTap: () async {
                        final isPremium = await PlanService.isPremium();
                        final allowed = await DemoLimiter.canUseSection(
                            SectionType.general);

                        if (!isPremium && !allowed) {
                          return showDemoLimitDialog(context);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GeneralQuestionsScreen(),
                          ),
                        );
                      },
                    ),
                    _HomeMenuTile(
                      color: const Color(0xFFEF4444), // kırmızı
                      icon: Icons.psychology_alt_outlined,
                      label: 'Senaryolar',
                      onTap: () async {
                        final isPremium = await PlanService.isPremium();
                        final allowed = await DemoLimiter.canUseSection(
                            SectionType.scenario);

                        if (!isPremium && !allowed) {
                          return showDemoLimitDialog(context);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScenarioScreen(),
                          ),
                        );
                      },
                    ),
                    _HomeMenuTile(
                      color: const Color(0xFFF59E0B), // turuncu
                      icon: Icons.image_outlined,
                      label: 'Resim\nAçıklama',
                      onTap: () async {
                        final isPremium = await PlanService.isPremium();
                        final allowed = await DemoLimiter.canUseSection(
                            SectionType.image);

                        if (!isPremium && !allowed) {
                          return showDemoLimitDialog(context);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ImageDescriptionScreen(),
                          ),
                        );
                      },
                    ),
                    _HomeMenuTile(
                      color: const Color(0xFFA855F7), // mor
                      icon: Icons.menu_book_outlined,
                      label: 'Sözlük',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DictionaryScreen(),
                          ),
                        );
                      },
                    ),
                    _HomeMenuTile(
                      color: const Color(0xFF0EA5E9), // mavi
                      icon: Icons.info_outline,
                      label: 'DLA Hakkında',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DlaInfoScreen(),
                          ),
                        );
                      },
                    ),
                    _HomeMenuTile(
                      color: const Color(0xFFDC2626), // kırmızı ton
                      icon: Icons.send_outlined,
                      label: 'Soru Gönder',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubmitQuestionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tek tek Container yazmamak için küçük bir widget
class _HomeMenuTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeMenuTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: Colors.white.withOpacity(0.95)),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
