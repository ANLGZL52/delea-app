// lib/screens/premium_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import '../services/plan_service.dart';
import '../services/purchase_service.dart';
import '../widgets/legal_link.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = true;
  bool _isPremium = false;
  bool _isProcessingPurchase = false;
  String? _subscriptionPrice;
  StreamSubscription<void>? _premiumActivatedSub;

  @override
  void initState() {
    super.initState();
    _premiumActivatedSub =
        PurchaseService.instance.onPremiumActivated.listen((_) {
      _handlePremiumActivated();
    });
    _bootstrap();
  }

  @override
  void dispose() {
    _premiumActivatedSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await PurchaseService.instance.init();
    final product = PurchaseService.instance.premiumProduct;
    await _loadPlan();
    if (!mounted) return;
    setState(() {
      _subscriptionPrice = product?.price;
    });
  }

  Future<void> _loadPlan() async {
    final isPrem = await PlanService.isPremium();
    if (!mounted) return;
    setState(() {
      _isPremium = isPrem;
      _isLoading = false;
    });
  }

  String get _priceLine {
    final p = _subscriptionPrice;
    if (p != null && p.isNotEmpty) return '$p / ay (App Store fiyatı)';
    return 'Fiyat satın alma ekranında App Store tarafından gösterilir';
  }

  Future<void> _handlePremiumActivated() async {
    await _loadPlan();
    if (!mounted || !_isPremium) return;

    setState(() => _isProcessingPurchase = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium hesabın aktif edildi.'),
      ),
    );

    Navigator.pop(context, true);
  }

  Future<void> _waitForPremiumActivation({int maxSeconds = 20}) async {
    for (var i = 0; i < maxSeconds; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      final isPrem = await PlanService.isPremium();
      if (isPrem) {
        await _handlePremiumActivated();
        return;
      }
    }
  }

  Future<void> _onBuyPremium() async {
    setState(() => _isProcessingPurchase = true);

    await PurchaseService.instance.buyPremium();
    await _waitForPremiumActivation();

    if (!mounted) return;
    if (!_isPremium) {
      setState(() => _isProcessingPurchase = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Satın alma tamamlanmadı veya iptal edildi. Tekrar deneyebilirsin.',
          ),
        ),
      );
    }
  }

  Future<void> _onRestore() async {
    setState(() => _isProcessingPurchase = true);

    await PurchaseService.instance.restorePurchases();
    await _waitForPremiumActivation();

    if (!mounted) return;
    if (!_isPremium) {
      setState(() => _isProcessingPurchase = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geri yüklenecek aktif abonelik bulunamadı.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Plan ve Üyelik'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isPremium
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPremium
                              ? 'Aktif Planın'
                              : 'Ücretsiz planın aktif',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                _isPremium ? 'PREMIUM' : 'ÜCRETSİZ',
                                style: TextStyle(
                                  color:
                                      _isPremium ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _isPremium
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isPremium
                                    ? 'Tüm bölümlere sınırsız erişimin var.'
                                    : 'Her bölümden (Genel, Resim, Senaryo, Sınav) sınırlı ücretsiz deneme hakkın var.',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SubscriptionLegalDisclosure(priceLine: _priceLine),
                  const SizedBox(height: 24),
                  Text(
                    'Premium ile neler açılıyor?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _BenefitRow(
                    icon: Icons.all_inclusive,
                    text: 'Genel sorular bölümünde sınırsız deneme',
                  ),
                  const _BenefitRow(
                    icon: Icons.psychology_alt,
                    text: 'Senaryo sorularında sınırsız deneme',
                  ),
                  const _BenefitRow(
                    icon: Icons.image_outlined,
                    text: 'Resim açıklama bölümünde sınırsız deneme',
                  ),
                  const _BenefitRow(
                    icon: Icons.workspace_premium,
                    text: 'Sınav simülasyonunda sınırsız giriş',
                  ),
                  const SizedBox(height: 28),
                  if (!_isPremium) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isProcessingPurchase ? null : _onBuyPremium,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isProcessingPurchase
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Premium'a Geç",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed:
                          _isProcessingPurchase ? null : _onRestore,
                      child: const Text(
                        'Satın alımları geri yükle',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF334155),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Premium aktif, geri dön',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
