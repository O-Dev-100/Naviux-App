import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/models/product_model.dart';
import 'dart:convert';

part 'product_repository.g.dart';

class ProductRepository {
  // repositorio para la gestión de productos de woocommerce
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 10,
    String? categorySlug,
    String? search,
  }) async {
    // obtiene la lista de productos con paginación y filtros
    try {
      final consumerKey = dotenv.env['WC_CONSUMER_KEY'] ?? '';
      final consumerSecret = dotenv.env['WC_CONSUMER_SECRET'] ?? '';
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}';

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (categorySlug != null && int.tryParse(categorySlug) != null) {
        queryParams['category'] = categorySlug;
      }
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/wc/v3/products',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': basicAuth},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        final fallbackResponse = await _dio.get(
          '/wc/v3/products',
          queryParameters: queryParams,
        );
        final List<dynamic> data = fallbackResponse.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }

      final List<dynamic> data = response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error al cargar productos');
    }
  }

  Future<List<ProductVariation>> getProductVariations(int productId) async {
    // obtiene todas las variaciones disponibles de un producto específico
    try {
      final consumerKey = dotenv.env['WC_CONSUMER_KEY'] ?? '';
      final consumerSecret = dotenv.env['WC_CONSUMER_SECRET'] ?? '';
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}';

      final response = await _dio.get(
        '/wc/v3/products/$productId/variations',
        options: Options(headers: {'Authorization': basicAuth}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => ProductVariation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar variaciones');
    }
  }

  Future<ProductModel> getProductById(int productId) async {
    // recupera la información detallada de un producto por su id
    try {
      final consumerKey = dotenv.env['WC_CONSUMER_KEY'] ?? '';
      final consumerSecret = dotenv.env['WC_CONSUMER_SECRET'] ?? '';
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}';

      final response = await _dio.get(
        '/wc/v3/products/$productId',
        options: Options(headers: {'Authorization': basicAuth}),
      );

      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al cargar el producto');
    }
  }

  Future<List<ProductModel>> getSiblingProducts(String baseName) async {
    // busca productos que pertenecen a la misma familia de diseño
    try {
      final consumerKey = dotenv.env['WC_CONSUMER_KEY'] ?? '';
      final consumerSecret = dotenv.env['WC_CONSUMER_SECRET'] ?? '';
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}';

      final response = await _dio.get(
        '/wc/v3/products',
        queryParameters: {
          'search': baseName,
          'per_page': 50,
        },
        options: Options(headers: {'Authorization': basicAuth}),
      );

      final List<dynamic> data = response.data;
      final products = data.map((json) => ProductModel.fromJson(json)).toList();
      
      final baseLow = baseName.toLowerCase().trim();
      return products.where((p) {
        final pNameLow = p.name.toLowerCase().trim();
        if (!pNameLow.startsWith(baseLow)) return false;
        
        final rest = pNameLow.substring(baseLow.length).trim();
        if (rest.isEmpty) return true;
        return RegExp(r'^c[0-9]+$', caseSensitive: false).hasMatch(rest);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  return ProductRepository(dio);
}
