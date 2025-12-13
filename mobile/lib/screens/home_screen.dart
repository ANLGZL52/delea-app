// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

import 'question_screen.dart';
import 'general_questions_screen.dart';
import 'scenario_screen.dart';
import 'image_description_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goExam(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }

  void _goGeneral(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GeneralQuestionsScreen()),
    );
  }

  void _goScenario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScenarioScreen()),
    );
  }

  void _goImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImageDescriptionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("DeLeA"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Bottom nav zaten Profile'a götürüyor.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alttan Profile / Performance’a geçebilirsin ✅")),
              );
            },
            icon: const Icon(Icons.person_outline),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _GradientHeader(
              title: "Welcome aboard ✈️",
              subtitle:
                  "CRM Interview & Cabin Crew practice.\nShort, focused, and trackable.",
              rightBadge: "BETA",
              onPrimaryTap: () => _goExam(context),
            ),

            const SizedBox(height: 16),

            // Quick stats şimdilik placeholder kalsın (istersen sonra History+Stats bağlarız)
            Row(
              children: const [
                Expanded(
                  child: _MiniStatCard(
                    title: "Today",
                    value: "—",
                    sub: "attempts",
                    icon: Icons.today_outlined,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MiniStatCard(
                    title: "Streak",
                    value: "—",
                    sub: "days",
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const _SectionTitle(
              title: "Quick Actions",
              subtitle: "Start fast, improve steadily.",
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _ActionCard(
                  title: "Exam Simulation",
                  subtitle: "Full mixed set",
                  icon: Icons.assignment_turned_in_outlined,
                  accent: scheme.primary,
                  onTap: () => _goExam(context),
                ),
                _ActionCard(
                  title: "General",
                  subtitle: "Short Q&A",
                  icon: Icons.chat_bubble_outline,
                  accent: Colors.greenAccent,
                  onTap: () => _goGeneral(context),
                ),
                _ActionCard(
                  title: "Scenario",
                  subtitle: "S.T.A.R answers",
                  icon: Icons.psychology_alt_outlined,
                  accent: Colors.redAccent,
                  onTap: () => _goScenario(context),
                ),
                _ActionCard(
                  title: "Image",
                  subtitle: "Describe & infer",
                  icon: Icons.image_outlined,
                  accent: Colors.tealAccent,
                  onTap: () => _goImage(context),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.lightbulb_outline, color: Colors.amberAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tip: Keep answers 2–3 sentences. Structure them like:\n"
                      "Situation → Action → Result.\n\n"
                      "Consistency beats intensity.",
                      style: TextStyle(color: Colors.white70, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HEADER
class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rightBadge;
  final VoidCallback onPrimaryTap;

  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.rightBadge,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withOpacity(0.55),
            scheme.secondary.withOpacity(0.35),
            const Color(0xFF0F172A),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Text(
                  rightBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.35)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPrimaryTap,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Exam"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.tune,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Yakında: Ayarlar")),
                  );
                },
              ),
            ],
          ),
        ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/// SMALL STATS
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// SECTION TITLE
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

/// ACTION CARD
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0F172A),
          border: Border.all(color: accent.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.35)),
              ),
              child: Icon(icon, color: accent),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
