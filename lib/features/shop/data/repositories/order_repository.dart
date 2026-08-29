import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/cart_item.dart';

part 'order_repository.g.dart';

class OrderRepository {
  final Dio _dio;
  final AuthRepository _authRepo;

  OrderRepository(this._dio, this._authRepo);

  /// Create an order in WooCommerce using CartItems
  Future<String> createOrder({
    required List<CartItem> lineItems,
    required Map<String, dynamic> shipping,
    required Map<String, dynamic> billing,
    List<Map<String, String>>? couponLines,
    String? customerNote,
    String paymentMethod = 'redsys',
    String paymentMethodTitle = 'Tarjeta de Crédito',
  }) async {
    try {
      final token = await _authRepo.getToken();
      
      final items = lineItems.map((item) {
        final Map<String, dynamic> data = {
          'product_id': item.product.id,
          'quantity': item.quantity,
        };
        
        // Si hay una variación seleccionada, la incluimos
        if (item.variationId != null) {
          data['variation_id'] = item.variationId!;
        }

        // Metadatos para los atributos seleccionados (ej: Color, Dioptrías)
        if (item.selectedAttributes.isNotEmpty) {
          data['meta_data'] = item.selectedAttributes.entries.map((e) => {
            'key': e.key,
            'value': e.value,
          }).toList();
        }

        return data;
      }).toList();

      final Map<String, dynamic> orderData = {
        'payment_method': paymentMethod,
        'payment_method_title': paymentMethodTitle,
        'set_paid': false,
        'status': 'pending',
        'billing': billing,
        'shipping': shipping,
        'line_items': items,
        if (couponLines != null) 'coupon_lines': couponLines,
        if (customerNote != null) 'customer_note': customerNote,
      };

      final options = token != null 
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : Options(); 
      
      final response = await _dio.post(
        '/wc/v3/orders',
        data: orderData,
        options: options,
      );

      final orderId = response.data['id'].toString();
      return orderId;
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
    }
  }

  /// Get user orders from WooCommerce
  Future<List<OrderModel>> getOrders() async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('unauthorized');

      // Intentamos obtener el ID persistido para ahorrar una llamada a /me
      final persistedUser = await _authRepo.getPersistedUser();
      int? userId = persistedUser?.id;

      if (userId == null) {
        final userResponse = await _dio.get('/wp/v2/users/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
        userId = userResponse.data['id'];
      }

      final ordersResponse = await _dio.get(
        '/wc/v3/orders?customer=$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List data = ordersResponse.data;
      return data.map((o) => OrderModel.fromJson(o)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('unauthorized');
      }
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  /// Verifica el estado de un pedido específico
  Future<String> getOrderStatus(String orderId) async {
    try {
      final token = await _authRepo.getToken();
      final options = token != null 
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : Options();

      final response = await _dio.get(
        '/wc/v3/orders/$orderId',
        options: options,
      );

      return response.data['status'] ?? 'unknown';
    } catch (e) {
      throw Exception('Error al verificar estado del pedido: $e');
    }
  }

  /// Valida un cupón en WooCommerce
  Future<Map<String, dynamic>?> validateCoupon(String code) async {
    try {
      final token = await _authRepo.getToken();
      final options = token != null 
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : Options();

      final response = await _dio.get(
        '/wc/v3/coupons?code=$code',
        options: options,
      );

      final List coupons = response.data;
      if (coupons.isNotEmpty) {
        return coupons.first;
      }
      return null;
    } catch (e) {
      throw Exception('Error al validar cupón: $e');
    }
  }
}

@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return OrderRepository(dio, authRepo);
}

@riverpod
Future<List<OrderModel>> userOrders(UserOrdersRef ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders();
}
