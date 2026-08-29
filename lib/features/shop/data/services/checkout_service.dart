import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/order_repository.dart';
import '../../../payment/data/services/redsys_service.dart';

part 'checkout_service.g.dart';

/// Servicio para coordinar la lógica de checkout, 
/// separando la lógica de negocio de la UI de CheckoutScreen.
class CheckoutService {
  final OrderRepository _orderRepository;
  final RedsysService _redsysService;

  CheckoutService(this._orderRepository, this._redsysService);

  // TODO: Migrar lógica de polling y creación coordinada aquí si es necesario
}

@riverpod
CheckoutService checkoutService(CheckoutServiceRef ref) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final redsys = ref.watch(redsysServiceProvider);
  return CheckoutService(orderRepo, redsys);
}
