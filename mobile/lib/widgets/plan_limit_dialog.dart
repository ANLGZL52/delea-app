// lib/widgets/plan_limit_dialog.dart

import 'package:flutter/material.dart';

import '../theme/delea_tokens.dart';
import '../screens/premium_screen.dart';

class PlanLimitDialog extends StatelessWidget {
  final String featureName;

  const PlanLimitDialog({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DeleaColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: DeleaColors.border),
      ),
      title: Text(
        "Ücretsiz planda sınır",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        "Ücretsiz planda \"$featureName\" bölümünde bu cihazda sınırlı deneme hakkın vardı; kotan doldu.\n\n"
        "Tüm pratik alanları ve sınav simülasyonu için Premium’a geçebilirsin.",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: DeleaColors.textSecondary,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Kapat", style: TextStyle(color: DeleaColors.textMuted)),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PremiumScreen(),
              ),
            );
          },
          child: const Text("Planları gör"),
        ),
      ],
    );
  }
}

Future<void> showPlanLimitDialog(
  BuildContext context, {
  String featureName = "Bu bölüm",
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => PlanLimitDialog(featureName: featureName),
  );
}
