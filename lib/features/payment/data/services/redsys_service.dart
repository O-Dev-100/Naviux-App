import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/config/environment_config.dart';

part 'redsys_service.g.dart';

class RedsysService {
  // servicio para gestionar pagos mediante la pasarela redsys
  final Dio _dio;

  RedsysService(this._dio);

  Future<Map<String, String>> getRedsysPayload({
    required String orderId,
    String? payMethods,
  }) async {
    // solicita los parámetros de cifrado necesarios al servidor
    try {
      final response = await _dio.post(
        '/naviux/v1/redsys-payload',
        data: {
          'order_id': orderId,
          if (payMethods != null) 'pay_methods': payMethods,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'Ds_SignatureVersion': data['Ds_SignatureVersion']?.toString() ?? 'HMAC_SHA256_V1',
          'Ds_MerchantParameters': data['Ds_MerchantParameters']?.toString() ?? '',
          'Ds_Signature': data['Ds_Signature']?.toString() ?? '',
          'url': data['url']?.toString() ?? EnvironmentConfig.redsysUrl,
        };
      } else {
        throw Exception('Error al obtener el payload de Redsys');
      }
    } catch (e) {
      throw Exception('Error en la comunicación con el servidor');
    }
  }

  String generateUniqueOrderId(String wooOrderId) {
    return wooOrderId.padLeft(12, '0');
  }
}

@riverpod
RedsysService redsysService(RedsysServiceRef ref) {
  final dio = ref.watch(dioClientProvider);
  return RedsysService(dio);
}

class RedsysResponse {
  final bool isValid;
  final String? errorCode;
  final String? orderId;

  RedsysResponse({required this.isValid, this.errorCode, this.orderId});
}
