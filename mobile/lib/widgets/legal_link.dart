import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_legal.dart';

Future<void> openLegalUrl(String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    throw Exception('Bağlantı açılamadı: $url');
  }
}

class LegalLink extends StatelessWidget {
  final String label;
  final String url;

  const LegalLink({super.key, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await openLegalUrl(url);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bağlantı açılamadı: $e')),
          );
        }
      },
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
          fontSize: 13,
        ),
      ),
    );
  }
}

class LegalLinkRow extends StatelessWidget {
  const LegalLinkRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const LegalLink(
          label: 'Gizlilik Politikası',
          url: AppLegal.privacyPolicyUrl,
        ),
        Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
        const LegalLink(
          label: 'Kullanım Koşulları (EULA)',
          url: AppLegal.termsOfUseUrl,
        ),
      ],
    );
  }
}

/// Abonelik yasal özeti (Guideline 3.1.2).
class SubscriptionLegalDisclosure extends StatelessWidget {
  final String? priceLine;

  const SubscriptionLegalDisclosure({super.key, this.priceLine});

  @override
  Widget build(BuildContext context) {
    final price = priceLine ?? 'Fiyat App Store’da gösterilir';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Abonelik bilgisi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _line('Ürün', 'DLA + Aylık (dlaaylik)'),
          _line('Süre', '1 ay, otomatik yenilenir'),
          _line('Fiyat', price),
          const SizedBox(height: 6),
          Text(
            'Ödeme Apple ID hesabınıza yansır. Dönem bitiminden en az 24 saat önce '
            'iptal etmezseniz abonelik yenilenir. Yönetim ve iptal: Ayarlar → Apple ID → Abonelikler.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const LegalLinkRow(),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
