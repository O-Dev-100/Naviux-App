import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:naviux_app/l10n/app_localizations.dart';

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
              title: 'WhatsApp (Soporte 1)',
              subtitle: AppContactInfo.whatsapp1,
              icon: Icons.chat,
              onTap: () =>
                  _launchUrl('https://wa.me/34${AppContactInfo.whatsapp1}'),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'WhatsApp (Soporte 2)',
              subtitle: AppContactInfo.whatsapp2,
              icon: Icons.chat,
              onTap: () =>
                  _launchUrl('https://wa.me/34${AppContactInfo.whatsapp2}'),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'Teléfono',
              subtitle: AppContactInfo.phone,
              icon: Icons.phone,
              onTap: () => _launchUrl('tel:+34${AppContactInfo.phone}'),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'Email (Información)',
              subtitle: AppContactInfo.emailInfo,
              icon: Icons.email,
              onTap: () => _launchUrl('mailto:${AppContactInfo.emailInfo}'),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              title: 'Email (Pedidos)',
              subtitle: AppContactInfo.emailPedidos,
              icon: Icons.email_outlined,
              onTap: () => _launchUrl('mailto:${AppContactInfo.emailPedidos}'),
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
  final IconData icon;
  final VoidCallback onTap;

  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
