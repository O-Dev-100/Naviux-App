import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/config/environment_config.dart';
import 'try_on_models.dart';

class VirtualTryOnView extends StatefulWidget {
  // vista para el probador virtual de gafas
  final String glassesAsset;
  final FaceType initialFaceType;

  const VirtualTryOnView({
    super.key,
    required this.glassesAsset,
    required this.initialFaceType
  });

  @override
  State<VirtualTryOnView> createState() => _VirtualTryOnViewState();
}

class _VirtualTryOnViewState extends State<VirtualTryOnView> {
  late FaceType selectedFace;
  SkinTone selectedTone = SkinTone.white;
  UserGender selectedGender = UserGender.female;
  bool _isConfigured = false;

  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _offset = Offset.zero;

  Uint8List? _processedGlassesBytes;
  bool _isLoadingGlasses = false;
  bool _apiError = false;

  @override
  void initState() {
    // inicializa la configuración del probador y procesa la imagen
    super.initState();
    selectedFace = widget.initialFaceType;

    if (widget.glassesAsset.startsWith('http')) {
      _removeBackground();
    }
  }

  Future<void> _removeBackground() async {
    // elimina el fondo de la imagen de las gafas usando una api externa
    setState(() => _isLoadingGlasses = true);
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.remove.bg/v1.0/removebg')
      );
      request.headers['X-Api-Key'] = EnvironmentConfig.removeBgApiKey;
      request.fields['image_url'] = widget.glassesAsset;
      request.fields['size'] = 'preview';

      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        if (mounted) {
          setState(() {
            _processedGlassesBytes = bytes;
            _isLoadingGlasses = false;
          });
        }
      } else {
        if (mounted) setState(() { _apiError = true; _isLoadingGlasses = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _apiError = true; _isLoadingGlasses = false; });
    }
  }

  void _resetPosition() {
    // restablece la posición y escala de las gafas
    setState(() {
      _offset = Offset.zero;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // construye la interfaz principal del probador virtual
    if (!_isConfigured) {
      return _buildConfigurationView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: _buildMainViewer(),
              ),
              _buildBottomControls(),
            ],
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.2,
            child: _buildSkinToneSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationView() {
    // formulario de configuración inicial de rasgos faciales
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Personaliza tu experiencia",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Selecciona tu perfil para ajustar el probador a tus facciones.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            const Text("GÉNERO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSelectableCard(
                  label: "Mujer",
                  icon: Icons.woman,
                  isSelected: selectedGender == UserGender.female,
                  onTap: () => setState(() => selectedGender = UserGender.female),
                ),
                const SizedBox(width: 16),
                _buildSelectableCard(
                  label: "Hombre",
                  icon: Icons.man,
                  isSelected: selectedGender == UserGender.male,
                  onTap: () => setState(() => selectedGender = UserGender.male),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text("TONO DE PIEL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildToneCard(
                  label: "Blanco",
                  color: const Color(0xFFFADCC8),
                  isSelected: selectedTone == SkinTone.white,
                  onTap: () => setState(() => selectedTone = SkinTone.white),
                ),
                const SizedBox(width: 16),
                _buildToneCard(
                  label: "Moreno",
                  color: const Color(0xFFD4A373),
                  isSelected: selectedTone == SkinTone.tan,
                  onTap: () => setState(() => selectedTone = SkinTone.tan),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => setState(() => _isConfigured = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoadingGlasses
                    ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : const Text("CONTINUAR AL PROBADOR", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildSelectableCard({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToneCard({required String label, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              ),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: AppColors.primary),
              style: IconButton.styleFrom(backgroundColor: Colors.white, elevation: 4),
            ),
            const Expanded(
              child: Text(
                "PROBADOR VIRTUAL",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16, color: AppColors.primary),
              ),
            ),
            IconButton(
              onPressed: _resetPosition,
              icon: const Icon(Icons.restart_alt_rounded, color: AppColors.primary),
              style: IconButton.styleFrom(backgroundColor: Colors.white, elevation: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainViewer() {
    // visor principal donde se superponen las gafas sobre el rostro
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size.infinite, painter: GridPainter()),

            AnimatedSwitcher(
              duration: 500.ms,
              child: Image.asset(
                TryOnService.getFaceAsset(selectedFace, selectedTone, selectedGender),
                key: ValueKey('${selectedFace}_${selectedTone}_${selectedGender}'),
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.face_retouching_natural, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text("Error al cargar rostro",
                            style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) => _baseScale = _scale,
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = (_baseScale * details.scale).clamp(0.4, 2.5);
                    _offset += details.focalPointDelta;
                  });
                },
                child: Center(
                  child: Transform.translate(
                    offset: _offset,
                    child: Transform.scale(
                      scale: _scale,
                      child: _buildGlassesLayer(),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
                child: const Text("Pellizca para escalar y arrastra para mover",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassesLayer() {
    // capa que renderiza las gafas procesadas sin fondo
    if (_isLoadingGlasses) {
      return const SizedBox(
        width: 40, height: 40,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }

    if (_processedGlassesBytes != null) {
      return Image.memory(
        _processedGlassesBytes!,
        width: 220,
        fit: BoxFit.contain,
      );
    }

    if (widget.glassesAsset.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.glassesAsset,
        width: 220,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, color: Colors.red, size: 40),
      );
    } else {
      return Image.asset(
        widget.glassesAsset,
        width: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image_outlined, color: Colors.red, size: 40),
      );
    }
  }

  Widget _buildSkinToneSelector() {
    // selector vertical flotante para cambiar el tono de piel
    return Column(
      children: [
        _toneOption(SkinTone.white, const Color(0xFFFADCC8)),
        _toneOption(SkinTone.tan, const Color(0xFFD4A373)),
      ],
    ).animate().fadeIn().slideX(begin: 0.5);
  }

  Widget _toneOption(SkinTone tone, Color color) {
    bool isSel = selectedTone == tone;
    return GestureDetector(
      onTap: () => setState(() => selectedTone = tone),
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSel ? AppColors.primary : Colors.white, width: 3),
          boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10)] : [],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    // controles inferiores para cambiar el tipo de rostro y ver recomendaciones
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRecommendationCard(),
          const SizedBox(height: 24),
          const Text("FORMA DE TU ROSTRO",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildFaceTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    // tarjeta informativa con consejos estéticos según el rostro
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TryOnService.getRecommendation(selectedFace),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  TryOnService.getColorAdvice(selectedTone),
                  style: TextStyle(fontSize: 11, color: AppColors.primary.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceTypeSelector() {
    // selector horizontal de formas de rostro
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: FaceType.values.map((type) {
          bool isSel = selectedFace == type;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(type.name.toUpperCase()),
              selected: isSel,
              onSelected: (_) => setState(() => selectedFace = type),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: isSel ? Colors.white : Colors.black87,
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  // dibuja una cuadrícula de referencia en el visor
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withValues(alpha: 0.05)..strokeWidth = 1;
    for (var i = 0.0; i <= size.width; i += 40) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (var i = 0.0; i <= size.height; i += 40) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
