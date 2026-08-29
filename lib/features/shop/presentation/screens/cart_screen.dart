import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/application/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // pantalla del carrito de compras
    final isPharmacy = ref.watch(authStateProvider.notifier).isPharmacy;
    
    if (isPharmacy) {
      return _buildPharmacyCartPlaceholder(context, ref);
    }

    final cartItems = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.watch(cartNotifierProvider.notifier);
    final total = cartNotifier.cartTotal;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const CustomAppBar(
        title: 'Carrito',
        showBackButton: true,
        showCart: false,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: (item.variationImage != null && item.variationImage!.isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: item.variationImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : product.images.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: product.images.first.src,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.image),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.selectedAttributes.isNotEmpty)
                                      Text(
                                        item.selectedAttributes.entries
                                            .map((e) => '${e.key}: ${e.value}')
                                            .join(', '),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.price ?? product.price} €',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => cartNotifier.updateQuantity(index, item.quantity - 1),
                                      ),
                                      Text('${item.quantity}'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => cartNotifier.updateQuantity(index, item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => cartNotifier.removeCartItemAtIndex(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),

                _buildSummary(context, ref, total),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // vista cuando no hay productos en el carrito
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOut),
          const SizedBox(height: 24),
          const Text('Su carrito está vacío', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/shop'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Volver a la Tienda', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildPharmacyCartPlaceholder(BuildContext context, WidgetRef ref) {
    // vista alternativa para usuarios profesionales
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const CustomAppBar(
        title: 'Carrito Profesional',
        showBackButton: true,
        showCart: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 80, color: AppColors.primary)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text(
                'Acceso Profesional',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Como usuario de Farmacia, los pedidos se realizan exclusivamente a través del Catálogo PDF interactivo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                'Para realizar una compra como cliente particular, debe cerrar su sesión profesional.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('CERRAR SESIÓN PROFESIONAL', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    // dialogo de confirmación para cerrar sesión
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Deberá volver a identificarse para acceder al catálogo de farmacia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, WidgetRef ref, double total) {
    // resumen del pedido y botón de checkout
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 18)),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final isLoggedIn = ref.read(authStateProvider).value != null;
                  if (isLoggedIn) {
                    context.push('/checkout');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Debes iniciar sesión para finalizar la compra'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.push('/login');
                  }
                },
                child: const Text(
                  'PROCEDER AL CHECKOUT',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
