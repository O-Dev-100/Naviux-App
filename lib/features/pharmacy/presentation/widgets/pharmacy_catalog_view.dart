import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class PharmacyCatalogView extends ConsumerStatefulWidget {
  const PharmacyCatalogView({super.key});

  @override
  ConsumerState<PharmacyCatalogView> createState() => _PharmacyCatalogViewState();
}

class _PharmacyCatalogViewState extends ConsumerState<PharmacyCatalogView> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    // inicialización del visor de catálogo pdf
    super.initState();
    _initPdfLoad();
  }

  void _initPdfLoad() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // interfaz para visualizar y enviar el catálogo profesional interactivo
    final auth = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _buildPdfViewer(),
            ),
            if (_loadError == null && !_isLoading) _buildFloatingSendButton(auth),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    // visor integrado de documentos pdf con soporte para formularios
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.pharmacyGreen),
            SizedBox(height: 16),
            Text("Iniciando catálogo Naviux...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                "Incompatibilidad en el documento",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "El PDF comprimido tiene una estructura no válida para el visor.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loadError = null;
                    _isLoading = true;
                  });
                  _initPdfLoad();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("REINTENTAR"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pharmacyGreen, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return SfPdfViewer.asset(
      'assets/catalogo.pdf',
      controller: _pdfViewerController,
      enableTextSelection: true,
      enableDocumentLinkAnnotation: true,
      canShowScrollHead: false,
      onDocumentLoadFailed: (details) {
        setState(() => _loadError = details.description);
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.pharmacyGreen.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.pharmacyGreen, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Catálogo Naviux 2026",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pharmacyGreen,
                  fontSize: 16
              ),
            ),
          ),
          if (_loadError == null && !_isLoading)
            IconButton(
              icon: const Icon(Icons.zoom_in, color: AppColors.pharmacyGreen),
              onPressed: () => _pdfViewerController.zoomLevel = 1.5,
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingSendButton(dynamic auth) {
    // botón inferior para enviar el catálogo relleno por email
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Rellena el PDF y pulsa enviar para tramitar tu pedido",
            style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _showConfirmDialog(auth),
            icon: const Icon(Icons.send_rounded),
            label: const Text("ENVIAR PEDIDO", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pharmacyGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog(dynamic auth) async {
    // solicita confirmación antes de abrir el cliente de correo
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enviar Pedido"),
        content: const Text("¿Has terminado de rellenar el catálogo? Se abrirá tu correo para enviar el pedido a Naviux."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("REVISAR", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pharmacyGreen,
                foregroundColor: Colors.white
            ),
            child: const Text("ENVIAR AHORA"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _handleSend(auth);
    }
  }

  Future<void> _handleSend(dynamic auth) async {
    // guarda el pdf temporalmente y lanza la acción de compartir por email
    try {
      final List<int> savedBytes = await _pdfViewerController.saveDocument();

      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/pedido_naviux_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(savedBytes, flush: true);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'Pedido Farmacia Naviux - ${auth?.userDisplayName ?? "Cliente"}',
        text: 'Se adjunta el catálogo interactivo con el pedido realizado.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Preparando envío... Selecciona tu aplicación de CORREO."),
              backgroundColor: AppColors.pharmacyGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error al procesar el envío"),
                backgroundColor: Colors.red
            )
        );
      }
    }
  }
}
