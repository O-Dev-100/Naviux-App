import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String assetPath;
  final String title;

  const PdfViewerScreen({
    super.key, 
    required this.assetPath, 
    this.title = "Visualizador de PDF"
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2E7D32), // Color de farmacia
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.asset(
        assetPath,
      ),
    );
  }
}
