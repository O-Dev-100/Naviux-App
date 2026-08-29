import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shop/data/repositories/order_repository.dart';
import '../../../shop/data/services/pdf_invoice_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../payment/data/services/redsys_service.dart';
import '../../../payment/presentation/screens/redsys_webview_screen.dart';
import '../../../auth/application/auth_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'cancelled':
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 'Completado';
      case 'pending': return 'Pendiente';
      case 'processing': return 'En Proceso';
      case 'cancelled': return 'Cancelado';
      case 'failed': return 'Fallido';
      default: return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const CustomAppBar(
        title: 'Mis Pedidos',
        showBackButton: false,
        showHomeButton: true,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildUnauthenticatedView(context);
          }
          return ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('No has realizado ningún pedido aún.'));
              }
              return _buildOrderList(orders, ref);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error de autenticación')),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 100, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Consulta tus pedidos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Inicia sesión para ver el historial de tus compras y descargar tus facturas.',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Iniciar Sesión / Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final date = DateTime.tryParse(order.dateCreated);
        final formattedDate = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'N/A';
        final status = order.status;
        final total = order.total;
        final orderId = order.id.toString();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pedido #$orderId', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Text(_formatStatus(status), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Fecha: $formattedDate', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Total: $total €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pdfService = PdfInvoiceService();
                          await pdfService.generateAndPrintInvoice(order);
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Factura'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'failed') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _retryPayment(context, ref, order),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                          child: const Text('PAGAR AHORA'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _retryPayment(BuildContext context, WidgetRef ref, OrderModel order) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final redsysService = ref.read(redsysServiceProvider);
      final payload = await redsysService.getRedsysPayload(
        orderId: order.id.toString(),
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar loading

      final bool? success = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RedsysWebViewScreen(
            merchantParameters: payload['Ds_MerchantParameters']!,
            signature: payload['Ds_Signature']!,
            signatureVersion: payload['Ds_SignatureVersion']!,
            urlRedsys: payload['url']!,
          ),
        ),
      );

      if (success == true) {
        ref.invalidate(userOrdersProvider);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Pago completado! El estado del pedido se actualizará pronto.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reintentar el pago: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
