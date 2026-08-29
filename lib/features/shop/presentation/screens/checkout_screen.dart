import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../payment/data/services/redsys_service.dart';
import '../../../payment/presentation/screens/redsys_webview_screen.dart';
import '../../data/repositories/order_repository.dart';
import 'package:naviux_app/features/auth/application/auth_provider.dart';
import 'package:naviux_app/features/auth/data/repositories/auth_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _couponController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedShippingMethod = 'farmacia';
  String _selectedAddressType = 'fiscal';
  String _selectedPaymentMethod = 'T';

  bool _isLoading = false;
  bool _isApplyingCoupon = false;
  Map<String, dynamic>? _appliedCoupon;
  double _discountAmount = 0.0;
  Map<String, dynamic>? _wooCustomerData;

  @override
  void initState() {
    // carga los datos del cliente al iniciar el proceso de pago
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    // recupera información de facturación y envío del usuario
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(authRepositoryProvider).getWooCommerceCustomerData();
      if (mounted) {
        setState(() {
          _wooCustomerData = data;
          final shipping = data['shipping'] ?? {};
          final billing = data['billing'] ?? {};
          
          _addressController.text = shipping['address_1']?.isNotEmpty == true ? shipping['address_1'] : (billing['address_1'] ?? '');
          _cityController.text = shipping['city']?.isNotEmpty == true ? shipping['city'] : (billing['city'] ?? '');
          _zipController.text = shipping['postcode']?.isNotEmpty == true ? shipping['postcode'] : (billing['postcode'] ?? '');
          _phoneController.text = shipping['phone']?.isNotEmpty == true ? shipping['phone'] : (billing['phone'] ?? '');
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    // valida y aplica un código de descuento al pedido
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingCoupon = true);

    try {
      final coupon = await ref.read(orderRepositoryProvider).validateCoupon(code);
      
      if (coupon != null) {
        final double amount = double.tryParse(coupon['amount'].toString()) ?? 0.0;
        final String type = coupon['discount_type'] ?? 'fixed_cart';
        
        double discount = 0.0;
        final total = ref.read(cartNotifierProvider.notifier).cartTotal;

        if (type == 'percent') {
          discount = total * (amount / 100);
        } else {
          discount = amount;
        }

        setState(() {
          _appliedCoupon = coupon;
          _discountAmount = discount;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cupón "$code" aplicado: -${discount.toStringAsFixed(2)} €'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) _showErrorSnackBar('El cupón no es válido o ha expirado.');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error al validar el cupón.');
    } finally {
      if (mounted) setState(() => _isApplyingCoupon = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(String orderId) {
    // finaliza el proceso de compra con éxito
    ref.read(cartNotifierProvider.notifier).clearCart();
    ref.invalidate(userOrdersProvider);
    context.go('/order-success/$orderId');
  }

  Future<void> _proceedToPayment() async {
    // gestiona la creación del pedido y el inicio del pago seguro
    if (_selectedAddressType == 'other' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cartItems = ref.read(cartNotifierProvider);
      if (cartItems.isEmpty) {
        _showErrorSnackBar('El carrito está vacío');
        setState(() => _isLoading = false);
        return;
      }

      final cartTotal = ref.read(cartNotifierProvider.notifier).cartTotal;
      final finalTotal = cartTotal - _discountAmount;

      Map<String, String> shipping;
      final user = ref.read(authStateProvider).value;
      final displayName = user?.userDisplayName ?? 'Cliente';
      final names = displayName.split(' ');
      final firstName = names.isNotEmpty ? names.first : 'Cliente';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Naviux';

      if (_selectedAddressType == 'fiscal') {
        final billingData = _wooCustomerData?['billing'] ?? {};
        shipping = {
          'first_name': billingData['first_name']?.isNotEmpty == true ? billingData['first_name'] : firstName,
          'last_name': billingData['last_name']?.isNotEmpty == true ? billingData['last_name'] : lastName,
          'address_1': billingData['address_1']?.isNotEmpty == true ? billingData['address_1'] : 'Dirección Fiscal',
          'city': billingData['city']?.isNotEmpty == true ? billingData['city'] : 'Madrid',
          'postcode': billingData['postcode']?.isNotEmpty == true ? billingData['postcode'] : '28001',
          'country': billingData['country']?.isNotEmpty == true ? billingData['country'] : 'ES',
          'phone': billingData['phone']?.isNotEmpty == true ? billingData['phone'] : '910000000',
          'email': user?.userEmail ?? (billingData['email'] ?? 'cliente@naviux.com'),
        };
      } else {
        shipping = {
          'first_name': 'Envío',
          'last_name': 'Particular',
          'address_1': _addressController.text,
          'city': _cityController.text,
          'postcode': _zipController.text,
          'phone': _phoneController.text,
          'country': 'ES',
        };
      }

      final orderRepo = ref.read(orderRepositoryProvider);
      final userEmail = ref.read(authStateProvider).value?.userEmail;
      if (userEmail != null) {
        shipping['email'] = userEmail;
      }

      final orderIdStr = await orderRepo.createOrder(
        lineItems: cartItems,
        shipping: shipping,
        billing: shipping,
        couponLines: _appliedCoupon != null ? [{'code': _appliedCoupon!['code'].toString()}] : null,
        customerNote: _notesController.text.isNotEmpty ? _notesController.text : null,
        paymentMethod: 'redsys',
        paymentMethodTitle: _selectedPaymentMethod == 'z' ? 'Bizum' : 'Tarjeta de Crédito',
      );

      final redsysService = ref.read(redsysServiceProvider);
      final payload = await redsysService.getRedsysPayload(
        orderId: orderIdStr,
        payMethods: _selectedPaymentMethod,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      final bool? isWebViewClosed = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RedsysWebViewScreen(
            merchantParameters: payload['Ds_MerchantParameters']!,
            signature: payload['Ds_Signature']!,
            signatureVersion: payload['Ds_SignatureVersion']!,
            urlRedsys: payload['url']!,
          ),
        ),
      );

      if (isWebViewClosed == true) {
        // verifica el estado del pedido tras el cierre de la pasarela
        setState(() => _isLoading = true);
        
        bool isConfirmed = false;
        int attempts = 0;
        const maxAttempts = 5;

        while (attempts < maxAttempts && !isConfirmed) {
          attempts++;
          await Future.delayed(const Duration(seconds: 3));
          
          final status = await orderRepo.getOrderStatus(orderIdStr);
          if (status == 'processing' || status == 'completed') {
            isConfirmed = true;
          }
        }
        
        setState(() => _isLoading = false);
        
        if (isConfirmed) {
          _showSuccessDialog(orderIdStr);
        } else {
          _showStatusPendingDialog();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showStatusPendingDialog() {
    // informa al usuario si el pago queda pendiente de verificación bancaria
    ref.read(cartNotifierProvider.notifier).clearCart();
    ref.invalidate(userOrdersProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pago en Verificación'),
        content: const Text(
          'El pago se está procesando en el banco. No te preocupes, te notificaremos por correo cuando se confirme el pedido.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // construcción de la interfaz de resumen y selección de métodos de envío y pago
    final cartItems = ref.watch(cartNotifierProvider);
    final cartTotal = ref.watch(cartNotifierProvider.notifier).cartTotal;
    final total = cartTotal - _discountAmount;
    final authState = ref.watch(authStateProvider);

    final subtotalBase = total / 1.21;
    final ivaAmount = total - subtotalBase;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Finalizar Compra',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepCard(
                        title: 'Resumen del Pedido',
                        icon: Icons.shopping_bag_outlined,
                        child: Column(
                          children: [
                            ...cartItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity}x ${item.product.name}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      '${item.subtotal.toStringAsFixed(2)} €',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              'Subtotal (sin IVA)',
                              '${subtotalBase.toStringAsFixed(2)} €',
                            ),
                            _buildSummaryRow(
                              'IVA (21%)',
                              '${ivaAmount.toStringAsFixed(2)} €',
                            ),
                            if (_discountAmount > 0)
                              _buildSummaryRow(
                                'Descuento (Cupón)',
                                '-${_discountAmount.toStringAsFixed(2)} €',
                                color: Colors.green,
                              ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'TOTAL',
                              '${total.toStringAsFixed(2)} €',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildStepCard(
                        title: 'Cupón de Descuento',
                        icon: Icons.local_offer_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                        children: [
                                          TextSpan(text: 'Usa el código '),
                                          TextSpan(
                                            text: 'NAVIUX10',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: ' y obtén un 10% dto en tu primera compra.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponController,
                                    decoration: InputDecoration(
                                      hintText: 'Introduce tu código',
                                      hintStyle: const TextStyle(fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isApplyingCoupon
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('APLICAR'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildStepCard(
                        title: 'Dirección de Entrega',
                        icon: Icons.location_on_outlined,
                        child: Column(
                          children: [
                            authState.maybeWhen(
                              data: (user) {
                                final isPharmacy = user?.isPharmacy ?? false;
                                return Column(
                                  children: [
                                    if (isPharmacy)
                                      _buildSelectionTile(
                                        title: 'Dirección Fiscal de Farmacia',
                                        subtitle:
                                            'Envío directo a la farmacia registrada',
                                        value: 'fiscal',
                                        groupValue: _selectedAddressType,
                                        onChanged: (v) => setState(
                                          () => _selectedAddressType = v!,
                                        ),
                                      ),
                                    _buildSelectionTile(
                                      title: 'Otra Dirección',
                                      subtitle:
                                          'Enviar a una dirección diferente',
                                      value: 'other',
                                      groupValue: _selectedAddressType,
                                      onChanged: (v) => setState(
                                        () => _selectedAddressType = v!,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              orElse: () => _buildSelectionTile(
                                title: 'Dirección de Envío',
                                subtitle: 'Introduce tus datos de entrega',
                                value: 'other',
                                groupValue: 'other',
                                onChanged: (_) {},
                              ),
                            ),
                            if (_selectedAddressType == 'other') ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                _addressController,
                                'Dirección completa',
                                Icons.home_outlined,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      _cityController,
                                      'Ciudad',
                                      Icons.location_city,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      _zipController,
                                      'C. Postal',
                                      Icons.location_city,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                _phoneController,
                                'Teléfono móvil',
                                Icons.phone_android,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildStepCard(
                        title: 'Método de Envío',
                        icon: Icons.local_shipping_outlined,
                        child: Column(
                          children: [
                            _buildSelectionTile(
                              title: 'Entrega en Farmacia',
                              subtitle: 'Gratis - Recogida en 24h',
                              value: 'farmacia',
                              groupValue: _selectedShippingMethod,
                              onChanged: (v) =>
                                  setState(() => _selectedShippingMethod = v!),
                            ),
                            _buildSelectionTile(
                              title: 'Punto de Recogida',
                              subtitle: 'Red de puntos de conveniencia',
                              value: 'punto',
                              groupValue: _selectedShippingMethod,
                              onChanged: (v) =>
                                  setState(() => _selectedShippingMethod = v!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildStepCard(
                        title: 'Notas del Pedido (Opcional)',
                        icon: Icons.note_alt_outlined,
                        child: TextField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Ej: Horario de entrega, indicaciones...',
                            hintStyle: const TextStyle(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildStepCard(
                        title: 'Método de Pago',
                        icon: Icons.payment_outlined,
                        child: Column(
                          children: [
                            _buildSelectionTile(
                              title: 'Tarjeta de Crédito / Débito',
                              subtitle: 'Pago seguro con tarjeta bancaria',
                              value: 'T',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                            ),
                            _buildSelectionTile(
                              title: 'Bizum',
                              subtitle: 'Pago rápido con tu móvil',
                              value: 'z',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'assets/images/iconos/nx_naviux_pago_seguro_online.webp',
                            height: 45,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _proceedToPayment,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/iconos/nx_naviux_pago_seguro_web.webp',
                              height: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'PAGAR ${total.toStringAsFixed(2)} €',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          '🔒 Pago seguro mediante pasarela Redsys',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    // contenedor estilizado para cada paso del checkout
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    // opción de selección mediante radio button estilizado
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 13,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 13,
              color: color ?? (isTotal ? AppColors.primary : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
    );
  }
}
