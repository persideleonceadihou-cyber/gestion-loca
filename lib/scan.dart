import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';

class Scan extends StatelessWidget {
  const Scan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un dossier")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text("Lancer le scan"),
          onPressed: () async {
            final image = await DocumentScannerFlutter.launch(context);

            if (image != null && context.mounted) {
              Navigator.pop(context, image.path);
            }
          },
        ),
      ),
    );
  }
}
