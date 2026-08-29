import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/product_model.dart';
import '../repositories/product_repository.dart';

part 'products_provider.g.dart';

@riverpod
class Products extends _$Products {
  bool _hasReachedEnd = false;

  @override
  FutureOr<List<ProductModel>> build(String? categorySlug) async {
    _hasReachedEnd = false;
    return _fetchAndGroup(page: 1, categorySlug: categorySlug);
  }

  Future<List<ProductModel>> _fetchAndGroup({required int page, String? categorySlug}) async {
    final repository = ref.read(productRepositoryProvider);
    
    final rawProducts = await repository.getProducts(
      page: page, 
      perPage: 60,
      categorySlug: categorySlug,
      search: _getSearchTermForSlug(categorySlug),
    );

    if (rawProducts.isEmpty) {
      _hasReachedEnd = true;
      return [];
    }

    // Filtrado local adicional para asegurar que si buscamos "Lectura" no aparezcan otros
    // que simplemente contengan la palabra pero no sean de esa categoría principal.
    var filteredProducts = rawProducts;
    if (categorySlug != null) {
      final searchTerm = _getSearchTermForSlug(categorySlug)?.toLowerCase();
      if (searchTerm != null) {
        filteredProducts = rawProducts.where((p) {
          final name = p.name.toLowerCase();
          // Casos especiales para mayor precisión
          if (searchTerm == 'sol') {
            return name.contains('sol') && !name.contains('blue light');
          }
          return name.contains(searchTerm);
        }).toList();
      }
    }

    final Map<String, ProductModel> grouped = {};
    for (var p in filteredProducts) {
      final baseName = p.name.replaceAll(RegExp(r'\s+c[0-9]+$', caseSensitive: false), '').trim();
      if (!grouped.containsKey(baseName)) {
        grouped[baseName] = p;
      }
    }
    return grouped.values.toList();
  }

  String? _getSearchTermForSlug(String? slug) {
    if (slug == 'lectura') return 'Lectura';
    if (slug == 'sol') return 'Sol';
    if (slug == 'blue-light') return 'Blue Light';
    if (slug == 'edicion-limitada') return 'Edición Limitada';
    return null;
  }

  Future<void> loadMore(int page) async {
    if (state.isLoading || _hasReachedEnd) return;

    final currentProducts = state.value ?? [];
    try {
      final newProducts = await _fetchAndGroup(page: page);
      if (newProducts.isEmpty) {
        _hasReachedEnd = true;
        return;
      }
      state = AsyncValue.data([...currentProducts, ...newProducts]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    _hasReachedEnd = false;
    final slug = categorySlug; // El parámetro 'categorySlug' está disponible en la clase generada
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndGroup(page: 1, categorySlug: slug));
  }

  bool get hasReachedEnd => _hasReachedEnd;
}

@riverpod
Future<ProductModel> productDetail(Ref ref, int id) {
  return ref.watch(productRepositoryProvider).getProductById(id);
}
