import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/providers/cart_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool isHome;
  final bool showHomeButton;
  final bool showCart;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.isHome = false,
    this.showHomeButton = false,
    this.showCart = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // construcción de la barra superior personalizada de la aplicación
    return AppBar(
      title: isHome
          ? Image.asset(
              'assets/images/naviux/logo_naviux_.png',
              height: 32,
              fit: BoxFit.contain,
            )
          : Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      leading: showBackButton && context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            )
          : null,
      actions: [
        if (actions != null) ...actions!,
        if (showHomeButton)
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        if (showCart)
          Consumer(
            builder: (context, ref, child) {
              final cartCount = ref.watch(cartNotifierProvider).length;
              return IconButton(
                icon: badges.Badge(
                  showBadge: cartCount > 0,
                  badgeContent: Text(
                    cartCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Color(0xFFE31B23),
                  ),
                  child: const Icon(Icons.shopping_cart),
                ),
                onPressed: () {
                  context.push('/cart');
                },
              );
            },
          ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.push('/profile');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
