// lib/screens/premium_screen.dart

import 'package:flutter/material.dart';
import '../services/plan_service.dart';
import '../services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = true;
  bool _isPremium = false;
  bool _isProcessingPurchase = false; // satın alma / restore işlemi için

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final isPrem = await PlanService.isPremium();
    if (!mounted) return;
    setState(() {
      _isPremium = isPrem;
      _isLoading = false;
    });
  }

  Future<void> _onBuyPremium() async {
    setState(() {
      _isProcessingPurchase = true;
    });

    // Gerçek satın alma isteği
    await PurchaseService.instance.buyPremium();

    // Satın alma sonucu purchaseStream'den gelecek.
    // Basit yaklaşım: kısa bir bekleme sonrası planı kontrol et.
    await Future.delayed(const Duration(seconds: 2));
    await _loadPlan();

    if (!mounted) return;
    setState(() {
      _isProcessingPurchase = false;
    });

    if (_isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Premium hesabın aktif edildi."),
        ),
      );
    }
  }

  Future<void> _onRestore() async {
    setState(() {
      _isProcessingPurchase = true;
    });

    await PurchaseService.instance.restorePurchases();
    await Future.delayed(const Duration(seconds: 2));
    await _loadPlan();

    if (!mounted) return;
    setState(() {
      _isProcessingPurchase = false;
    });

    if (_isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Satın alımların geri yüklendi."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Plan ve Üyelik"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst kart: mevcut planı göster
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
                          _isPremium ? "Aktif Planın" : "Şu Anda Demo Sürümdesin",
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
                                _isPremium ? "PREMIUM" : "DEMO",
                                style: TextStyle(
                                  color: _isPremium ? Colors.black : Colors.white,
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
                                    ? "Tüm bölümlere sınırsız erişimin var."
                                    : "Her bölümden (Genel, Resim, Senaryo, Sınav) günde 1 hak kullanabilirsin.",
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

                  const SizedBox(height: 24),

                  Text(
                    "Premium ile neler açılıyor?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _BenefitRow(
                    icon: Icons.all_inclusive,
                    text: "Genel sorular bölümünde sınırsız deneme",
                  ),
                  const _BenefitRow(
                    icon: Icons.psychology_alt,
                    text: "Senaryo sorularında sınırsız deneme",
                  ),
                  const _BenefitRow(
                    icon: Icons.image_outlined,
                    text: "Resim açıklama bölümünde sınırsız deneme",
                  ),
                  const _BenefitRow(
                    icon: Icons.workspace_premium,
                    text: "Sınav simülasyonunda sınırsız giriş",
                  ),

                  const Spacer(),

                  if (!_isPremium)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isProcessingPurchase ? null : _onBuyPremium,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
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
                            "Satın alımları geri yükle",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF334155),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "Premium aktif, geri dön",
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
