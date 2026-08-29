import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:naviux_app/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/locale_provider.dart';
import '../../features/auth/application/auth_provider.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  Future<void> _launchUrl(String url) async {
    // abre una url externa en el navegador del dispositivo
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // menú lateral principal de la aplicación
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeNotifierProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/inicio/slide_imagenn.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(color: Colors.black.withAlpha(100)),
                if (user != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(user.userDisplayName[0].toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userDisplayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.userEmail,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.local_pharmacy,
                    color: AppColors.pharmacyGreen,
                  ),
                  title: Text(
                    l10n.drawerPharmacy,
                    style: const TextStyle(
                      color: AppColors.pharmacyGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    context.pop();
                    context.go('/pharmacy');
                  },
                ),
                if (user == null)
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: Text(
                      l10n.drawerLogin,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      context.pop();
                      context.push('/login');
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    onTap: () {
                      context.pop();
                      ref.read(authStateProvider.notifier).logout();
                      context.go('/home');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text(
                    'Mi Perfil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text(
                    'Mis Pedidos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    context.push('/orders');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(
                    l10n.favoritesTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    context.push('/favorites');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(
                    l10n.drawerAbout,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    context.push('/about');
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LanguageButton(
                        text: 'ES',
                        flag: '🇪🇸',
                        isSelected: currentLocale.languageCode == 'es',
                        onTap: () => ref
                            .read(localeNotifierProvider.notifier)
                            .setLocale(const Locale('es')),
                      ),
                      const SizedBox(width: 16),
                      _LanguageButton(
                        text: 'EN',
                        flag: '🇬🇧',
                        isSelected: currentLocale.languageCode == 'en',
                        onTap: () => ref
                            .read(localeNotifierProvider.notifier)
                            .setLocale(const Locale('en')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIconButton(
                      iconPath: 'assets/images/iconos/ic_facebook.webp',
                      onTap: () => _launchUrl(
                        'https://www.facebook.com/p/nxnaviux-61573826500065/',
                      ),
                    ),
                    const SizedBox(width: 20),
                    _SocialIconButton(
                      iconPath: 'assets/images/iconos/ic_instagram_menu.png',
                      onTap: () =>
                          _launchUrl('https://www.instagram.com/n.xnaviux/'),
                    ),
                    const SizedBox(width: 20),
                    _SocialIconButton(
                      iconPath: 'assets/images/iconos/ic_linkedin_menu.png',
                      onTap: () => _launchUrl(
                        'https://www.linkedin.com/in/raulmorenoaranda/?originalSubdomain=es',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    _FooterLinkSmall(
                      text: 'Privacidad',
                      onTap: () {
                        context.pop();
                        context.push('/privacy-policy');
                      },
                    ),
                    _FooterLinkSmall(
                      text: 'Términos y Condiciones',
                      onTap: () {
                        context.pop();
                        context.push('/terms-conditions');
                      },
                    ),
                    _FooterLinkSmall(
                      text: 'Legal',
                      onTap: () {
                        context.pop();
                        context.push('/legal-notice');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '© 2026 Nx Naviux®\nTodos Los Derechos Reservados',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLinkSmall extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLinkSmall({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String text;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.text,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _SocialIconButton({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.link, size: 24),
      ),
    );
  }
}
