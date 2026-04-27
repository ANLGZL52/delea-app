import 'package:flutter/material.dart';

import '../widgets/demo_limit_dialog.dart';
import 'plan_service.dart';

/// Demo: bölüm başına toplam 1 değerlendirme hakkı bittiyse dialog, `false`. Premium: `true`.
/// Başarılı değerlendirme sonrası: `markPracticeUseIfDemo` ile sayaç artar.
Future<bool> canSubmitPractice(
  String planFeature, {
  String featureLabel = 'Bu bölüm',
  required BuildContext context,
}) async {
  if (await PlanService.isPremium()) return true;
  if (await PlanService.canUseFeature(planFeature)) return true;
  if (!context.mounted) return false;
  await showPlanLimitDialog(context, featureName: featureLabel);
  return false;
}

/// İlk başarılı değerlendirmede (ücretsiz) ilgili bölüm hakkı düşer (bölüm başına toplam 1).
Future<void> markPracticeUseIfDemo(String planFeature) async {
  if (await PlanService.isPremium()) return;
  await PlanService.registerUsage(planFeature);
}
