import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // pantalla informativa sobre la historia y valores de la empresa
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const CustomAppBar(
        title: 'Sobre Nosotros',
        showBackButton: false,
        showHomeButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuestra Historia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Naviux nace con la misión de democratizar el acceso a salud visual de calidad para profesionales farmacéuticos.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              '¿Por qué Naviux?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Somos especialistas en soluciones ópticas diseñadas específicamente para el canal farmacia. Entendemos las necesidades del profesional y ofrecemos productos de alta rotación con la mejor relación calidad-precio del mercado.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildFeatureRow(Icons.check_circle_outline, 'Calidad Garantizada', 'Todos nuestros productos cumplen con las normativas europeas más estrictas.'),
            _buildFeatureRow(Icons.local_shipping_outlined, 'Logística Eficiente', 'Entregas rápidas y seguras directamente en tu establecimiento.'),
            _buildFeatureRow(Icons.support_agent_outlined, 'Soporte Profesional', 'Equipo dedicado para resolver cualquier duda técnica o comercial.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
