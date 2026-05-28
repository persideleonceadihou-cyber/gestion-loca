import 'dart:io';

import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  File? _scannedImage;
  bool _isScanning = false;

  Future<void> _scanDocument() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final file = await DocumentScannerFlutter.launch(
        context,
        source: ScannerFileSource.CAMERA,
        labelsConfig: {
          ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: 'Suivant',
          ScannerLabelsConfig.ANDROID_SAVE_BUTTON_LABEL: 'Enregistrer',
          ScannerLabelsConfig.ANDROID_ROTATE_LEFT_LABEL: 'Tourner a gauche',
          ScannerLabelsConfig.ANDROID_ROTATE_RIGHT_LABEL: 'Tourner a droite',
          ScannerLabelsConfig.ANDROID_ORIGINAL_LABEL: 'Original',
          ScannerLabelsConfig.ANDROID_BMW_LABEL: 'Noir et blanc',
          ScannerLabelsConfig.ANDROID_SCANNING_MESSAGE: 'Scan en cours...',
          ScannerLabelsConfig.ANDROID_LOADING_MESSAGE: 'Chargement...',
          ScannerLabelsConfig.ANDROID_APPLYING_FILTER_MESSAGE:
              'Application du filtre...',
          ScannerLabelsConfig.ANDROID_OK_LABEL: 'OK',
        },
      );

      if (file == null || !mounted) {
        return;
      }

      setState(() {
        _scannedImage = file;
      });
      Navigator.pop(context, 'Document scanne: ${file.path}');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer le scanner: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un dossier")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_isScanning ? "Ouverture..." : "Lancer le scan"),
              onPressed: _isScanning ? null : _scanDocument,
            ),
            const SizedBox(height: 20),
            if (_scannedImage != null)
              Image.file(
                // Affiche l'image scannee.
                _scannedImage!,
                height: 300,
              ),
          ],
        ),
      ),
    );
  }
}
