// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';

import '../core/app_legal.dart';
import '../models/exam_attempt.dart';
import '../services/history_service.dart';
import '../services/plan_service.dart';
import '../services/session_service.dart';
import '../widgets/legal_link.dart';
import 'exam_history_detail_screen.dart';
import 'performance_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPremium = false;
  bool _loadingPlan = true;
  bool _signedIn = true;
  String _userName = SessionService.guestDisplayName;
  String _memberSince = '—';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await SessionService.ensureDefaultProfile(defaultName: 'Kullanıcı');
    await SessionService.removeStoredEmailIfEquals(AppLegal.supportEmail);
    final isPrem = await PlanService.isPremium();
    final signedIn = await SessionService.isSignedIn();
    final name = await SessionService.displayName();
    final since = await SessionService.memberSince();
    if (!mounted) return;
    setState(() {
      _isPremium = isPrem;
      _signedIn = signedIn;
      _userName = name;
      _memberSince = _formatDate(since);
      _loadingPlan = false;
    });
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _emailSupport() async {
    try {
      await openLegalUrl('mailto:${AppLegal.supportEmail}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-posta uygulaması açılamadı: ${AppLegal.supportEmail}'),
        ),
      );
    }
  }

  void _onTapExamHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ExamHistoryScreen()),
    );
  }

  void _onTapPerformance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerformanceScreen()),
    );
  }

  void _onTapSubscription() {
    Navigator.pushNamed(context, '/premium').then((_) => _loadAll());
  }

  Future<void> _onTapSignIn() async {
    await SessionService.signIn();
    await _loadAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oturum açıldı.')),
    );
  }

  Future<void> _onTapLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Oturumun kapatılacak. Premium aboneliğin Apple hesabında kalır; '
          'uygulamada yalnızca yerel oturum bilgileri sıfırlanır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await SessionService.signOut();
    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Çıkış yapıldı. Profilden tekrar oturum açabilirsiniz.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPlan) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ÜST PROFİL KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blueGrey.shade900,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isPremium
                                ? const Color(0xFF22C55E)
                                : Colors.yellow.shade500,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPremium
                                    ? Icons.workspace_premium
                                    : Icons.star,
                                size: 16,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isPremium ? "Premium Üye" : "Ücretsiz Üye",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ 4 BUTON (2 SATIR) — sıkışmasın diye
            Row(
              children: [
                Expanded(
                  child: _ProfileBigButton(
                    icon: Icons.history,
                    label: "Sınav Geçmişi",
                    color: const Color(0xFF4C1D95),
                    onTap: _onTapExamHistory,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileBigButton(
                    icon: Icons.insights,
                    label: "Performans",
                    color: const Color(0xFF0EA5E9),
                    onTap: _onTapPerformance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ProfileBigButton(
                    icon: Icons.subscriptions,
                    label: "Abonelik",
                    color: const Color(0xFF064E3B),
                    onTap: _onTapSubscription,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileBigButton(
                    icon: _signedIn ? Icons.logout : Icons.login,
                    label: _signedIn ? 'Çıkış Yap' : 'Oturum Aç',
                    color: _signedIn
                        ? const Color(0xFF450A0A)
                        : const Color(0xFF1E3A8A),
                    onTap: _signedIn ? _onTapLogout : _onTapSignIn,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // HESAP BİLGİLERİ
            _SectionCard(
              title: "Hesap Bilgileri",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: "Üyelik Tarihi",
                    value: _memberSince,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.workspace_premium_outlined,
                    label: "Plan",
                    value: _isPremium ? "Premium" : "Ücretsiz",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // İLETİŞİM
            _SectionCard(
              title: 'İletişim ve yasal',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soru ve geri bildirimlerin için DLA+ destek ekibine '
                    'yazabilirsin. (Bu, uygulamanın resmi destek adresidir; '
                    'senin hesap adresin değildir.)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _emailSupport,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.support_agent,
                            color: Colors.blueAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DLA+ destek e-postası',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLegal.supportEmail,
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.mail_outline,
                            color: Colors.white38,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LegalLink(
                    label: 'Destek sayfası',
                    url: AppLegal.supportUrl,
                  ),
                  const SizedBox(height: 8),
                  const LegalLinkRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// YARDIMCI WIDGETLAR
// ───────────────────────────────────────────────

class _ProfileBigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ProfileBigButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF111827)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────
// SINAV GEÇMİŞİ EKRANI (HistoryService üzerinden okur)
// ───────────────────────────────────────────────

class _ExamHistoryScreen extends StatefulWidget {
  const _ExamHistoryScreen({super.key});

  @override
  State<_ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<_ExamHistoryScreen> {
  bool _loading = true;
  List<ExamAttempt> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await HistoryService.getHistory();

    // ✅ Eski sistemden kalan "exam" tipli tek tek kayıtlar varsa gizle
    // ✅ exam_session / general / scenario / image gibi kayıtlar kalsın
    final cleaned = list.where((e) => e.type != 'exam').toList();

    if (!mounted) return;
    setState(() {
      _items = cleaned;
      _loading = false;
    });
  }

  String _formatDate(DateTime d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}";
  }

  IconData _iconForType(String t) {
    switch (t) {
      case 'general':
        return Icons.chat;
      case 'scenario':
        return Icons.psychology_alt;
      case 'image':
        return Icons.image_outlined;
      case 'exam_session':
        return Icons.assignment_turned_in_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _colorForType(String t) {
    switch (t) {
      case 'general':
        return Colors.greenAccent;
      case 'scenario':
        return Colors.redAccent;
      case 'image':
        return Colors.tealAccent;
      case 'exam_session':
        return Colors.amberAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _titleForItem(ExamAttempt item) {
    // ✅ exam_session kaydı zaten tek satır özet olmalı
    if (item.type == 'exam_session') {
      // Özet metnini ExamAttempt.questionText içine yazdırmanı öneririm.
      // (Örn: "Exam Simulation • 13 soru • Ort: 76.4")
      return item.questionText;
    }
    return item.questionText;
  }

  String _subtitleForItem(ExamAttempt item) {
    if (item.type == 'exam_session') {
      return _formatDate(item.date);
    }

    if (item.score != null) {
      return "${_formatDate(item.date)} • Skor: ${item.score!.toStringAsFixed(1)}";
    }

    return _formatDate(item.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sınav Geçmişi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Geçmişi Temizle"),
                    content: const Text(
                        "Tüm sınav geçmişini silmek istediğine emin misin?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Vazgeç"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Sil"),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await HistoryService.clearHistory();
                  if (!mounted) return;
                  setState(() => _items = []);
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : (_items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      "Henüz kayıtlı bir sınav geçmişin yok.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final color = _colorForType(item.type);

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (item.type == 'exam_session') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExamHistoryDetailScreen(session: item),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withOpacity(0.6)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_iconForType(item.type), color: color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _titleForItem(item),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _subtitleForItem(item),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (item.type != 'exam_session' &&
                                        item.feedback != null &&
                                        item.feedback!.trim().isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          item.feedback!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (item.type == 'exam_session')
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.chevron_right,
                                      color: Colors.white54),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
    );
  }
}
