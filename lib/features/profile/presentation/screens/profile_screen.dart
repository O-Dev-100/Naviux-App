import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../favorites/application/favorites_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // pantalla principal del perfil de usuario
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const CustomAppBar(
        title: 'Mi Perfil',
        showBackButton: false,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildUnauthenticatedView(context);
          }
          return _buildAuthenticatedView(context, ref, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    // vista para usuarios no logueados
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Accede a tus ventajas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Inicia sesión para gestionar tus pedidos, favoritos y mucho más.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Iniciar Sesión / Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(BuildContext context, WidgetRef ref, user) {
    // vista para usuarios autenticados
    final bool isPharmacy = user.isPharmacy;
    final Color activeColor = isPharmacy ? AppColors.pharmacyGreen : AppColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: activeColor.withAlpha(50),
                child: Text(
                  user.userDisplayName.isNotEmpty ? user.userDisplayName.substring(0, 1).toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: activeColor),
                ),
              ),
              if (isPharmacy)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.verified, color: AppColors.pharmacyGreen, size: 24),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.userDisplayName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            user.userEmail,
            style: const TextStyle(color: Colors.grey),
          ),
          if (isPharmacy)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pharmacyGreen.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CUENTA DE FARMACIA',
                style: TextStyle(color: AppColors.pharmacyGreen, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 32),
          
          _buildOptionTile(
            context,
            icon: Icons.person_outline,
            title: 'Mis Datos',
            subtitle: 'Nombre, Email y Datos personales',
            color: activeColor,
            onTap: () => _showEditProfileDialog(context, user),
          ),

          if (isPharmacy)
             _buildOptionTile(
              context,
              icon: Icons.local_pharmacy_outlined,
              title: 'Panel de Farmacia',
              subtitle: 'Acceder al catálogo profesional',
              color: AppColors.pharmacyGreen,
              onTap: () => context.go('/pharmacy'),
            ),

          _buildOptionTile(
            context,
            icon: Icons.shopping_bag_outlined,
            title: 'Mis Pedidos',
            subtitle: 'Historial de compras y estado',
            color: activeColor,
            onTap: () => context.push('/orders'),
          ),

          if (!isPharmacy)
            _buildOptionTile(
              context,
              icon: Icons.favorite_border,
              title: 'Lista de Deseos',
              subtitle: '${ref.watch(favoritesProvider).length} productos guardados',
              color: activeColor,
              onTap: () => context.push('/favorites'),
            ),

          _buildOptionTile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Direcciones',
            subtitle: 'Gestionar envío y facturación',
            color: activeColor,
            onTap: () => _showPlaceholder(context, 'Direcciones', 'Aquí podrás gestionar tus direcciones.', Icons.map_outlined),
          ),

          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            subtitle: 'Preguntas frecuentes y contacto',
            color: activeColor,
            onTap: () => _showPlaceholder(context, 'Ayuda', 'Nuestro servicio de soporte estará disponible pronto.', Icons.support_agent),
          ),

          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('CERRAR SESIÓN'),
              onPressed: () => _showLogoutConfirmation(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    // confirma el cierre de sesión
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que quieres salir de tu cuenta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('SALIR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    // muestra el modal para editar datos del perfil
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(initialValue: user.userDisplayName, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Apellidos')),
            const SizedBox(height: 12),
            TextFormField(initialValue: user.userNiceName, decoration: const InputDecoration(labelText: 'Nombre Visible')),
            const SizedBox(height: 12),
            TextFormField(initialValue: user.userEmail, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado correctamente (Simulación)'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('GUARDAR CAMBIOS'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title, String message, IconData icon, {bool showShopButton = false}) {
    // muestra una vista temporal para secciones no implementadas
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            if (showShopButton) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/shop');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('IR A LA TIENDA'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
