import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/environment_config.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  // cliente http configurado para la comunicación con la api
  final baseUrl = EnvironmentConfig.wpApiUrl;
  
  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // interceptor para añadir el token de autenticación a las peticiones
        if (options.headers.containsKey('Authorization')) {
          return handler.next(options);
        }

        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'jwt_token');
        
        if (token != null && token.isNotEmpty) {
          bool isValid = true;
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final payload = jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              );
              if (payload['exp'] != null) {
                final exp = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
                if (exp.isBefore(DateTime.now())) {
                  isValid = false;
                }
              }
            }
          } catch (e) {
            isValid = false;
          }

          if (isValid) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            await storage.delete(key: 'jwt_token');
          }
        }
        
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ),
  );

  return dio;
}
