import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/models/auth_model.dart';

part 'auth_repository.g.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final google_sign.GoogleSignIn _googleSignIn = google_sign.GoogleSignIn.instance;

  AuthRepository(this._dio, [this._storage = const FlutterSecureStorage()]);

  Future<AuthModel> login(
    String username,
    String password, {
    String? captchaToken,
  }) async {
    // inicia sesión con credenciales de wordpress
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'password': password,
        if (captchaToken != null && captchaToken.isNotEmpty)
          'captcha_token': captchaToken,
      };

      final String loginUrl = '${EnvironmentConfig.wpApiUrl}/naviux/v1/login';

      final response = await _dio.post(
        loginUrl,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      if (response.statusCode == 200) {
        final resData = response.data;
        
        if (resData['status'] == 'success') {
          final userData = resData['user'];
          
          final fullAuth = AuthModel(
            id: userData['id'] != null ? int.tryParse(userData['id'].toString()) : null,
            token: resData['token'] ?? '', 
            userEmail: userData['email'] ?? '',
            userDisplayName: userData['display_name'] ?? '',
            userNiceName: userData['display_name'] ?? '',
            roles: userData['roles'] != null
                ? List<String>.from(userData['roles'].map((r) => r.toString().toLowerCase()))
                : [],
          );

          await _storage.write(key: 'jwt_token', value: fullAuth.token);
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(fullAuth.toJson()),
          );

          return fullAuth;
        } else {
          throw AuthException(resData['message'] ?? 'Usuario o contraseña incorrectos');
        }
      } else {
        throw AuthException('No se ha podido conectar con el servicio de autenticación (Error ${response.statusCode})');
      }
    } on DioException catch (e) {
      throw AuthException('Error de conexión con el servidor. Por favor, revisa tu conexión.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error inesperado al iniciar sesión');
    }
  }

  Future<AuthModel> register({
    required String username,
    required String email,
    required String password,
    required String captchaToken,
  }) async {
    // registra un nuevo usuario en la plataforma
    try {
      final response = await _dio.post(
        '/wp/v2/users/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'captcha_token': captchaToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return await login(username, password, captchaToken: captchaToken);
      } else {
        throw AuthException('No se pudo completar el registro.');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        throw AuthException(data['message']);
      }
      throw AuthException('Error al registrar usuario: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error inesperado durante el registro');
    }
  }

  Future<AuthModel?> getPersistedUser() async {
    // recupera el usuario guardado localmente
    final userData = await _storage.read(key: 'user_data');
    if (userData == null) return null;
    try {
      return AuthModel.fromJson(jsonDecode(userData));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getUserDetails(String token) async {
    try {
      final response = await _dio.get(
        '/wp/v2/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getWooCommerceCustomerData() async {
    // obtiene los datos de cliente desde woocommerce
    try {
      final token = await getToken();
      if (token == null) throw AuthException('No hay sesión activa');

      final responseMe = await _dio.get(
        '/wp/v2/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final userId = responseMe.data['id'];

      final responseCustomer = await _dio.get(
        '/wc/v3/customers/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return responseCustomer.data;
    } catch (e) {
      throw AuthException('No se pudieron recuperar los datos de facturación');
    }
  }

  Future<void> logout() async {
    // cierra la sesión y limpia los datos locales
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<AuthModel> signInWithGoogle() async {
    // gestiona el inicio de sesión mediante google
    try {
      await _googleSignIn.initialize(
        serverClientId: EnvironmentConfig.googleServerClientId,
      );

      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) throw AuthException('Inicio de sesión cancelado por el usuario.');

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw AuthException('No se pudo obtener el ID Token de Google.');
      }

      final fullUrl = '${EnvironmentConfig.wpApiUrl}${EnvironmentConfig.googleLoginEndpoint}';
      
      final response = await _dio.post(
        fullUrl,
        data: {
          'id_token': idToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'success') {
          final userData = data['user'];
          
          final fullAuth = AuthModel(
            token: data['token'] ?? idToken, 
            userEmail: userData['email'] ?? '',
            userDisplayName: userData['display_name'] ?? '',
            userNiceName: userData['display_name'] ?? '',
            roles: userData['roles'] != null
                ? List<String>.from(userData['roles'].map((r) => r.toString().toLowerCase()))
                : [],
          );

          await _storage.write(key: 'jwt_token', value: fullAuth.token);
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(fullAuth.toJson()),
          );

          return fullAuth;
        } else {
          throw AuthException(data['message'] ?? 'Error de autenticación en el servidor.');
        }
      } else {
        throw AuthException('El servidor respondió con código ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw AuthException('Error de red al conectar con el servidor');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al iniciar sesión con Google');
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRepository(dio);
}
