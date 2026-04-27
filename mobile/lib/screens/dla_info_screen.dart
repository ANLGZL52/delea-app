// lib/screens/dla_info_screen.dart
import 'package:flutter/material.dart';

import '../theme/delea_tokens.dart';

/// DLA hakkında yapılandırılmış, profesyonel içerik + bağımsızlık açıklaması.
class DlaInfoScreen extends StatelessWidget {
  const DlaInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: DeleaColors.background,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 200,
            pinned: true,
            title: const Text('DLA rehberi'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [DeleaColors.brand, Color(0xFF1E3A8A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DeleaColors.brand.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Dijital dil değerlendirmesi',
                            style: t.titleLarge?.copyWith(
                              color: DeleaColors.textPrimary,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kabin mülakatı İngilizce akışı—özet rehber',
                            style: t.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const _Callout(
                    child: _Paragraph(
                      text:
                          'Türk Hava Yolları, DLA adı, sınav hükümleri ve puanlama ağırlıkları '
                          'için yalnızca resmî kaynaklara ve bilgilendirmenize dayanın. DLA +, bu '
                          'kaynakların yerine geçen bir sınava veya sertifika vermez: '
                          'bireysel, yapay zekâ destekli pratik uygulamasıdır.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoSection(
                    icon: Icons.school_outlined,
                    color: const Color(0xFF0EA5E9),
                    title: 'DLA neden var?',
                    body: const _Paragraph(
                      text:
                          'THY ve birçok havayolu, kabin ekibinin otorite dilinde, net ve yolcuya '
                          'güven veren konuşma beklentisi koyar. DLA, bu beklentiyi tespit amaçlı, '
                          'dijital ortamda, akıcılık, dil bilgisi, kapsam (kelime) ve sözlü anlatıma '
                          'bakan bölümlerle ilerletilebilen bir tür konuşma incelemesidir. '
                          'Amaç: sakin, çözüme açık ve kurala uyumlu duruşu gözlemek.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoSection(
                    icon: Icons.view_timeline_outlined,
                    color: const Color(0xFF7C3AED),
                    title: 'Bölümler genelde neleri ölçer?',
                    body: const Column(
                      children: [
                        _NumberLine(
                          n: '1',
                          text:
                              'Kendini, deneyimini, motivasyonunu ve günlük iletişimini açıkça ifade edebilme; '
                              'aşırı jargonsuz, oturaklı cümleler.',
                        ),
                        _NumberLine(
                          n: '2',
                          text:
                              'Sınırlı sürede senaryo: yolcunun duygu ve talebine sabır, empati, '
                              'güvenlik/ prosedüre dönük, çözümcü yanıt.',
                        ),
                        _NumberLine(
                          n: '3',
                          text:
                              'Görsele dönük anlatı: tespit edilen detay, sıra, hafif yorum, '
                              'düz bir İngilizce tümleme.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoSection(
                    icon: Icons.grade_outlined,
                    color: const Color(0xFF22C55E),
                    title: 'Dilsel kriterlere dair yorum',
                    body: const _Paragraph(
                      text: 'Aşağıdakiler, mülakat dilinde en sık işaret edilen alanlardır:\n\n'
                          'Fluency — anlam akışı; aşırı tekrar ve anlık tıkanma denetimi.\n\n'
                          'Accuracy / Grammar — büyük hataların, zamansal tutarlılığın etkisi.\n\n'
                          'Range — havacılık, yolcu ve operasyon söylemine uygun sözcük sınırı.\n\n'
                          'Discourse — giriş, açılım, kısa yönlendirme ve noktalama: tutarlılık.\n\n'
                          'Approach — kabin gölgesi: sakin, tartışmaya girmeyen, çözüme açık üslup.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoSection(
                    icon: Icons.tips_and_updates_outlined,
                    color: const Color(0xFFF59E0B),
                    title: 'Pratikte fark yaratacak 6 adım',
                    body: const Column(
                      children: [
                        _Bullet("Süre tut; hedef 50–60 sn üstü tutarlı konuşma, acele etmeyip susmayı sınırla."),
                        _Bullet("Aç → geliştir → mini kapanış: 3 parçalı mini makro (tek paragrafta) düşün."),
                        _Bullet("Belli çekirdek sözlük: safety, security, compliance, concern, option, I’ll check, let me..."),
                        _Bullet("Duygusal senaryolarda: önce tanı, sonra sınırla, sonra hareket planı; savunmaya dönme."),
                        _Bullet("Bir kez açıkça “Could you repeat, please?” demekten kaçınma: mesaj netliğidir."),
                        _Bullet("Aşırı ezberi ezber cümle bırak: doğal, az ama güvenli varyasyon ekle."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoSection(
                    icon: Icons.science_outlined,
                    color: const Color(0xFF38BDF8),
                    title: 'DLA + bu rehberi nerede hayata geçirir?',
                    body: const _Paragraph(
                      text: 'Sınav simülasyonu tüm tipleri (ısınma, genel, resim, senaryo) tek akışa bağlar. '
                          'Ayrı modüllerle parça parça çalışıp sözlükle sözlük tazeler, geri bildirim '
                          "metninde Türkçe açıklama ve örnek yanıt gösterilir. Skor, OpenAI altyapısına dayanır; "
                          'aynı cevabın farklı oturumda birkaç puan sapması olağandır.',
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: DeleaColors.border),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'DLA + ile yol, bilinçli, tekrar eden, ölçülebilen pratiktir.\n'
                      'Resmî sınav sonucu sadece ilgili kurum tarafından verilebilir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DeleaColors.textMuted,
                        fontSize: 12,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget body;

  const _InfoSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeleaColors.backgroundCard,
        borderRadius: BorderRadius.circular(DeleaRadii.lg),
        border: Border.all(color: DeleaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  final Widget child;
  const _Callout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        borderRadius: BorderRadius.circular(DeleaRadii.lg),
        border: Border.all(
          color: DeleaColors.brandLight.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: DeleaColors.textSecondary,
            height: 1.55,
          ),
    );
  }
}

class _NumberLine extends StatelessWidget {
  final String n;
  final String text;
  const _NumberLine({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DeleaColors.brand.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              n,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: DeleaColors.brandLight,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: DeleaColors.textSecondary,
                    height: 1.5,
                    fontSize: 14.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('· ', style: TextStyle(color: DeleaColors.textMuted, fontSize: 18, height: 1.2)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: DeleaColors.textSecondary,
                    height: 1.45,
                    fontSize: 14.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
