import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shop/presentation/screens/shop_screen.dart';
import '../../features/shop/presentation/screens/product_detail_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/contact/presentation/screens/contact_screen.dart';
import '../../data/models/product.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorShopKey = GlobalKey<NavigatorState>(debugLabel: 'shellShop');
final _shellNavigatorFavoritesKey = GlobalKey<NavigatorState>(debugLabel: 'shellFavorites');
final _shellNavigatorContactKey = GlobalKey<NavigatorState>(debugLabel: 'shellContact');

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int index) => navigationShell.goBranch(index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.shop), label: 'Shop'),
                NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
                NavigationDestination(icon: Icon(Icons.contact_mail), label: 'Contact'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorShopKey,
            routes: [
              GoRoute(
                path: '/shop',
                builder: (context, state) => const ShopScreen(),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    builder: (context, state) {
                      final product = state.extra as Product;
                      return ProductDetailScreen(product: product);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFavoritesKey,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorContactKey,
            routes: [
              GoRoute(
                path: '/contact',
                builder: (context, state) => const ContactScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
