import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../shop/data/providers/products_provider.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/featured_products_grid.dart';
import '../widgets/promo_marquee.dart';
import 'package:naviux_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // pantalla principal de la aplicación con carrusel y productos destacados
    final productsAsync = ref.watch(productsProvider(null));
    final l10n = AppLocalizations.of(context)!;
    final isPharmacy = ref.watch(authStateProvider.notifier).isPharmacy;
    final authValue = ref.watch(authStateProvider).value;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: CustomAppBar(title: l10n.appTitle, isHome: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PromoMarquee(),
            const PromoCarousel().animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
            if (isPharmacy)
              _buildPharmacyWelcomeBanner(context, authValue?.userDisplayName)
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeProducts,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/shop'), 
                      child: const Text('Ver Todo'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              productsAsync.when(
                data: (products) => FeaturedProductsGrid(products: products)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Lo sentimos, ha ocurrido un error inesperado al cargar los productos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.refresh(productsProvider(null)),
                          icon: const Icon(Icons.refresh),
                          label: const Text('REINTENTAR'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyWelcomeBanner(BuildContext context, String? pharmacyName) {
    // banner específico para usuarios profesionales de farmacia
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pharmacyGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pharmacyGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_pharmacy, size: 48, color: AppColors.pharmacyGreen),
          const SizedBox(height: 16),
          Text(
            '¡Bienvenido, ${pharmacyName ?? "Farmacia"}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.pharmacyGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tienes acceso a nuestro Catálogo Profesional 2026. Gestiona tus pedidos directamente desde la App.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pharmacyGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ACCEDER AL CATÁLOGO', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}
