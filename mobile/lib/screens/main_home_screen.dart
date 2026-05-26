// lib/screens/main_home_screen.dart

import 'package:flutter/material.dart';

import '../services/plan_service.dart';
import '../theme/delea_tokens.dart';
import '../widgets/demo_limit_dialog.dart';
import 'dictionary_screen.dart';
import 'dla_info_screen.dart';
import 'exam_intro_screen.dart';
import 'general_questions_screen.dart';
import 'image_description_screen.dart';
import 'profile_screen.dart';
import 'scenario_screen.dart';
import 'submit_question_screen.dart';
import 'premium_screen.dart';

Color _homeShade(Color a, [double t = 0.3]) {
  return Color.lerp(a, const Color(0xFF020617), t) ?? a;
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _refreshPremium();
  }

  Future<void> _refreshPremium() async {
    final p = await PlanService.isPremium();
    if (mounted) setState(() => _isPremium = p);
  }

  Future<void> _openPremium() async {
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
    await _refreshPremium();
  }

  Future<void> _onExamCardTap() async {
    if (!mounted) return;
    final isPrem = await PlanService.isPremium();
    if (!mounted) return;
    if (isPrem) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const ExamIntroScreen()),
      );
      if (mounted) await _refreshPremium();
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DeleaColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DeleaColors.border),
        ),
        title: const Text('Sınav simülasyonu — Premium'),
        content: const Text(
          'Bu bölüm Premium üyelere özel. Sınava devam etmek ve tüm pratiklere sınırsız erişmek için Premium’a geçebilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(ctx);
              _openPremium();
            },
            child: const Text('Premium’a geç'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, -1.0),
            end: Alignment(1.0, 1.2),
            colors: DeleaHome.pageGradient,
            stops: [0.0, 0.32, 0.68, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: -120,
                right: -60,
                child: _MeshGlow(
                  size: 300,
                  color1: Color(0x333B82F6),
                  color2: Color(0x22818CF8),
                ),
              ),
              const Positioned(
                top: 80,
                left: -100,
                child: _MeshGlow(
                  size: 220,
                  color1: Color(0x287C3AED),
                  color2: Color(0x1A2DD4BF),
                ),
              ),
              const Positioned(
                bottom: -100,
                left: -20,
                child: _MeshGlow(
                  size: 240,
                  color1: Color(0x260EA5E9),
                  color2: Color(0x1894A3B8),
                ),
              ),
              const Positioned(
                bottom: 40,
                right: -30,
                child: _MeshGlow(
                  size: 180,
                  color1: Color(0x20F59E0B),
                  color2: Color(0x15EA580C),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPatternPainter(
                    color: DeleaColors.border.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _DotPatternPainter(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                    spacing: 20,
                    dot: 0.6,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _PremiumPill(
                          onTap: _openPremium,
                        ),
                        const Spacer(),
                        _CircleIconButton(
                          icon: Icons.person_rounded,
                          onTap: () async {
                            if (!mounted) return;
                            await Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                            await _refreshPremium();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment(-0.6, -1),
                          end: Alignment(0.8, 1.2),
                          colors: DeleaHome.titleShader,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        );
                      },
                      child: Text(
                        'DLA +',
                        style: t.displayLarge?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Kabin mülakatına yönelik konuşma & DLA hazırlığı',
                      style: t.bodySmall?.copyWith(
                        color: DeleaColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bugün neye odaklanmak istersin?',
                      style: t.bodyMedium?.copyWith(
                        color: DeleaColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PrimaryExamCard(
                      locked: !_isPremium,
                      onTap: _onExamCardTap,
                    ),

                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Pratik alanları',
                      accent: const [Color(0xFF22C55E), Color(0xFF0EA5E9)],
                      subtitle:
                          'Genel, senaryo, görsel: ücretsizde bölüm başı birer deneme; Premium’da sınırsız',
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _HomeFeatureTile(
                            icon: Icons.forum_outlined,
                            title: 'Genel sorular',
                            subtitle: 'Kısa cevaplar, akıcılık, özgüven',
                            gradient: const [
                              Color(0xFF15803D),
                              Color(0xFF16A34A),
                            ],
                            onTap: () => _openPractice(
                              planKey: "general",
                              featureLabel: "Genel sorular",
                              child: const GeneralQuestionsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeFeatureTile(
                            icon: Icons.psychology_outlined,
                            title: 'Senaryolar',
                            subtitle: 'Kabin içi iletişim, empati, çözüm',
                            gradient: const [
                              Color(0xFFDC2626),
                              Color(0xFFB91C1C),
                            ],
                            onTap: () => _openPractice(
                              planKey: "scenario",
                              featureLabel: "Senaryolar",
                              child: const ScenarioScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _HomeFeatureTile(
                      icon: Icons.landscape_outlined,
                      title: 'Resim açıklama',
                      subtitle: 'Görseli yapılandır, detay ekle, akıcı anlat',
                      gradient: const [
                        Color(0xFFD97706),
                        Color(0xFFEA580C),
                      ],
                      horizontal: true,
                      onTap: () => _openPractice(
                        planKey: "image",
                        featureLabel: "Resim açıklama",
                        child: const ImageDescriptionScreen(),
                      ),
                    ),

                    const SizedBox(height: 26),
                    _SectionHeader(
                      title: 'Araçlar & rehber',
                      accent: const [Color(0xFFC084FC), Color(0xFF0EA5E9)],
                      subtitle: 'Kelimeler, bilgi ve uygulamaya dönüt',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _HomeToolTile(
                            color: const Color(0xFFA855F7),
                            icon: Icons.menu_book_rounded,
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
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HomeToolTile(
                            color: const Color(0xFF0EA5E9),
                            icon: Icons.info_rounded,
                            label: 'DLA rehberi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DlaInfoScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HomeToolTile(
                            color: const Color(0xFFEF4444),
                            icon: Icons.outgoing_mail,
                            label: 'Görüş & öneri',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SubmitQuestionScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1018).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DeleaColors.border.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Resmi sınav değil; bireysel pratik aracıdır. Skorlar yapay zekâ '
                        'değerlendirmesine dayanır, gerçek puan teyididir.',
                        textAlign: TextAlign.center,
                        style: t.bodySmall?.copyWith(
                          color: DeleaColors.textMuted,
                          fontSize: 11,
                          height: 1.45,
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
    );
  }

  Future<void> _openPractice({
    required String planKey,
    required String featureLabel,
    required Widget child,
  }) async {
    if (!mounted) return;
    final isPrem = await PlanService.isPremium();
    if (!mounted) return;
    if (!isPrem) {
      final can = await PlanService.canUseFeature(planKey);
      if (!mounted) return;
      if (!can) {
        await showPlanLimitDialog(context, featureName: featureLabel);
        return;
      }
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => child),
    );
  }
}

class _MeshGlow extends StatelessWidget {
  final double size;
  final Color color1;
  final Color color2;

  const _MeshGlow({
    required this.size,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  _GridPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 28.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({
    required this.color,
    this.spacing = 20,
    this.dot = 1.0,
  });
  final Color color;
  final double spacing;
  final double dot;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dot, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter old) =>
      old.color != color || old.spacing != spacing || old.dot != dot;
}

class _PremiumPill extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DeleaRadii.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DeleaRadii.full),
            border: Border.all(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.45),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4C1D95),
                Color(0xFF5B21B6),
                Color(0xFF6D28D9),
                Color(0xFF7C3AED),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: Color(0xFFFFFBEB)),
              SizedBox(width: 7),
              Text(
                'Plan & Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F1419).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(DeleaRadii.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DeleaRadii.full),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: DeleaColors.brandLight.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: DeleaColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _PrimaryExamCard extends StatelessWidget {
  final bool locked;
  final VoidCallback onTap;
  const _PrimaryExamCard({
    this.locked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rOuter = BorderRadius.circular(DeleaRadii.xl + 4);
    final rInner = BorderRadius.circular(DeleaRadii.xl + 2);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: rOuter,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: rOuter,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF93C5FD),
                Color(0xFF3B82F6),
                Color(0xFF1D4ED8),
                Color(0xFF1E3A8A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: rInner,
              gradient: const LinearGradient(
                begin: Alignment(-1, -0.5),
                end: Alignment(1, 1.1),
                colors: [
                  Color(0xFF0EA5E9),
                  Color(0xFF1D4ED8),
                  Color(0xFF1E3A8A),
                  Color(0xFF172554),
                ],
                stops: [0.0, 0.35, 0.72, 1.0],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : Icons.verified_rounded,
                    size: 30,
                    color: const Color(0xFFEFF6FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Sınav simülasyonu',
                            style: t.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          if (locked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade200.withValues(alpha: 0.3),
                                    Colors.amber.shade100.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.amber.shade200.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.amber.shade100,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        locked
                            ? 'Premium ile çok aşamalı alıştırma ve anında geri bildirim'
                            : 'Çok aşamalı alıştırma, sesle yanıt, anında geri bildirim',
                        style: t.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  locked ? Icons.chevron_right_rounded : Icons.arrow_forward_ios_rounded,
                  size: locked ? 24 : 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> accent;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 44,
          margin: const EdgeInsets.only(top: 2, right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: accent,
            ),
            boxShadow: [
              BoxShadow(
                color: accent[0].withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: t.bodySmall?.copyWith(
                  color: DeleaColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool horizontal;

  const _HomeFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = gradient[0];
    final mid = gradient.length > 1 ? gradient[1] : gradient[0];
    final low = _homeShade(mid, 0.38);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(DeleaRadii.lg + 3),
        onTap: onTap,
        child: Ink(
          height: horizontal ? 102 : 152,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DeleaRadii.lg + 3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
            gradient: LinearGradient(
              begin: const Alignment(-0.8, -1),
              end: const Alignment(1, 1.1),
              colors: [
                base,
                mid,
                low,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: 0.35),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 10),
                blurRadius: 16,
              ),
            ],
          ),
          child: horizontal
              ? Row(
                  children: [
                    _IconInCircle(icon: icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TileTexts(title: title, subtitle: subtitle),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconInCircle(icon: icon),
                    const Spacer(),
                    _TileTexts(title: title, subtitle: subtitle),
                  ],
                ),
        ),
      ),
    );
  }
}

class _IconInCircle extends StatelessWidget {
  final IconData icon;
  const _IconInCircle({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 25, color: Colors.white),
    );
  }
}

class _TileTexts extends StatelessWidget {
  final String title;
  final String subtitle;
  const _TileTexts({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _HomeToolTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeToolTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.22),
                const Color(0xFF0C1018).withValues(alpha: 0.5),
                color.withValues(alpha: 0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: DeleaColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
