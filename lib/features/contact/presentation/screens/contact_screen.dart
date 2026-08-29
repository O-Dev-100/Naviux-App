import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:naviux_app/l10n/app_localizations.dart';
import '../../../../shared/widgets/main_drawer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: CustomAppBar(title: l10n.contactTitle, showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿En qué podemos ayudarte?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta con nuestro equipo para asesoramiento personalizado o dudas sobre tu pedido.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            _ContactCard(
              title: 'WhatsApp (Soporte)',
              subtitle: AppContactInfo.whatsapp1,
              iconPath: 'assets/images/iconos/ic_contacto_whatsapp_.webp',
              color: Colors.green,
              onTap: () =>
                  _launchUrl('https://wa.me/34${AppContactInfo.whatsapp1}'),
              applyFilter: false,
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'Teléfono',
              subtitle: AppContactInfo.phone,
              icon: Icons.phone,
              color: Colors.brown,
              onTap: () => _launchUrl('tel:+34${AppContactInfo.phone}'),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'Email (Información)',
              subtitle: AppContactInfo.emailInfo,
              icon: Icons.email,
              color: Colors.red.shade300,
              onTap: () => _launchUrl('mailto:${AppContactInfo.emailInfo}'),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'Email (Pedidos)',
              subtitle: AppContactInfo.emailPedidos,
              icon: Icons.email_outlined,
              color: Colors.red.shade300,
              onTap: () => _launchUrl('mailto:${AppContactInfo.emailPedidos}'),
            ),
            const SizedBox(height: 24),
            // Ubicación de la oficina
            _ContactCard(
              title: 'Ubicación Oficina',
              subtitle: 'C/Felipe Moya 48 03202 Elche',
              icon: Icons.location_on,
              color: Colors.white,
              backgroundColor: AppColors.primary,
              onTap: () => _launchUrl(
                'https://www.google.com/maps/search/?api=1&query=Calle+Felipe+Moya+48+Elche',
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Envíanos un mensaje',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Mensaje',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(onPressed: () {}, text: 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconPath;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final bool applyFilter;

  const _ContactCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconPath,
    required this.color,
    this.backgroundColor,
    required this.onTap,
    this.applyFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor != null
                    ? Colors.white.withAlpha(40)
                    : color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: iconPath != null
                  ? Image.asset(
                      iconPath!,
                      width: 24,
                      height: 24,
                      color: applyFilter ? color : null,
                    )
                  : Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: backgroundColor != null ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: backgroundColor != null
                          ? Colors.white70
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: backgroundColor != null ? Colors.white70 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
