// lib/widgets/demo_limit_dialog.dart

import 'package:flutter/material.dart';

class DemoLimitDialog extends StatelessWidget {
  final String featureName;

  const DemoLimitDialog({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Demo hakkın doldu"),
      content: Text(
        "Demo sürümünde '$featureName' bölümünü günde yalnızca 1 kez kullanabilirsin.\n\n"
        "Sınırsız kullanım için Premium'a geçebilirsin.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Kapat"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, "/premium");
          },
          child: const Text("Premium'a Geç"),
        ),
      ],
    );
  }
}
