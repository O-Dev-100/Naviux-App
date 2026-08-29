import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shop/presentation/screens/product_detail_screen.dart';
import '../../features/shop/presentation/screens/shop_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/contact/presentation/screens/contact_screen.dart';
import '../../features/pharmacy/presentation/screens/pharmacy_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/shop/presentation/screens/cart_screen.dart';
import '../../features/shop/presentation/screens/checkout_screen.dart';
import '../../features/shop/presentation/screens/order_success_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../../features/legal/presentation/screens/terms_conditions_screen.dart';
import '../../features/legal/presentation/screens/legal_notice_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/order_history_screen.dart';
import '../../features/pharmacy/presentation/screens/pdf_viewer_screen.dart';
import '../../data/models/product_model.dart';
import '../../core/constants/app_constants.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorShopKey = GlobalKey<NavigatorState>(debugLabel: 'shellShop');
final _shellNavigatorPharmacyKey = GlobalKey<NavigatorState>(debugLabel: 'shellPharmacy');
final _shellNavigatorContactKey = GlobalKey<NavigatorState>(debugLabel: 'shellContact');

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // configuración central de la navegación del proyecto
  ref.keepAlive();
  
  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: _AuthStateListenable(ref),
    
    redirect: (context, state) {
      // lógica para redirigir según el estado de autenticación
      final authValue = ref.read(authStateProvider).value;
      final isLoggedIn = authValue != null;
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' || 
                          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn) {
        final protectedPaths = ['/checkout'];
        if (protectedPaths.any((path) => state.matchedLocation.startsWith(path))) {
          return '/login';
        }
      }

      if (isLoggedIn && isLoggingIn) {
        final isPharmacy = ref.read(authStateProvider.notifier).isPharmacy;
        return isPharmacy ? '/pharmacy' : '/home';
      }

      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Página no encontrada'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // definición de las rutas principales
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrderHistoryScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/order-success/:id',
        builder: (context, state) => OrderSuccessScreen(orderId: state.pathParameters['id'] ?? '0'),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/privacy-policy', builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms-conditions', builder: (context, state) => const TermsConditionsScreen()),
      GoRoute(path: '/legal-notice', builder: (context, state) => const LegalNoticeScreen()),
      GoRoute(
        path: '/pdf-viewer',
        builder: (context, state) {
          final assetPath = state.uri.queryParameters['path'] ?? 'assets/catalogo.pdf';
          final title = state.uri.queryParameters['title'] ?? 'Catálogo';
          return PdfViewerScreen(assetPath: assetPath, title: title);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');

          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            return ProductDetailScreen(
              product: extra['product'] as ProductModel,
              heroPrefix: extra['heroPrefix'] as String? ?? '',
            );
          }
          
          if (state.extra is ProductModel) {
            return ProductDetailScreen(product: state.extra as ProductModel);
          }

          if (id != null) {
            return ProductDetailScreen(productId: id);
          }

          return const Scaffold(body: Center(child: Text('Producto no válido')));
        },
      ),
      StatefulShellRoute.indexedStack(
        // barra de navegación inferior con navegación persistente
        builder: (context, state, navigationShell) {
          final isPharmacy = ref.watch(authStateProvider.notifier).isPharmacy;
          
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int index) => navigationShell.goBranch(index),
              destinations: [
                const NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
                NavigationDestination(
                  icon: const Icon(Icons.store), 
                  label: isPharmacy ? 'Catálogo' : 'Tienda'
                ),
                const NavigationDestination(
                  icon: Icon(Icons.local_pharmacy, color: AppColors.pharmacyGreen),
                  label: 'Farmacia',
                ),
                const NavigationDestination(icon: Icon(Icons.contact_mail), label: 'Contacto'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorShopKey,
            routes: [
              GoRoute(
                path: '/shop', 
                builder: (context, state) {
                  final isPharmacy = ref.watch(authStateProvider.notifier).isPharmacy;
                  if (isPharmacy) {
                    return const PharmacyScreen();
                  }
                  return const ShopScreen();
                },
              )
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPharmacyKey,
            routes: [
              GoRoute(
                path: '/pharmacy', 
                builder: (context, state) => const PharmacyScreen(),
              )
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorContactKey,
            routes: [GoRoute(path: '/contact', builder: (context, state) => const ContactScreen())],
          ),
        ],
      ),
    ],
  );
}

class _AuthStateListenable extends ChangeNotifier {
  // escucha cambios en la autenticación para refrescar el router
  _AuthStateListenable(AppRouterRef ref) {
    _subscription = ref.listen(authStateProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
