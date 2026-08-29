import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';

part 'pharmacy_repository.g.dart';

class PharmacyRepository {
  // gestión de peticiones específicas del portal de farmacia
  final Dio _dio;

  PharmacyRepository(this._dio);

  Future<void> submitPharmacyRequest({
    required String businessName,
    required String email,
    required String phone,
    String? message,
    required String captchaToken,
  }) async {
    // envía los datos de una farmacia interesada en darse de alta
    try {
      await _dio.post(
        '/naviux/v1/pharmacy-request',
        data: {
          'business_name': businessName,
          'email': email,
          'phone': phone,
          'message': message,
          'captcha_token': captchaToken,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }
      throw Exception('Error al enviar solicitud');
    }
  }
}

@riverpod
PharmacyRepository pharmacyRepository(PharmacyRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  return PharmacyRepository(dio);
}
