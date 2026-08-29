import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/product_model.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

part 'favorites_provider.g.dart';

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  // gestión de la lista de productos favoritos del usuario
  late Box<String> _favoritesBox;

  @override
  List<ProductModel> build() {
    // carga los favoritos guardados localmente al iniciar el provider
    _favoritesBox = Hive.box<String>('favorites');
    try {
      return _favoritesBox.values
          .map((jsonStr) => ProductModel.fromJson(jsonDecode(jsonStr)))
          .toList();
    } catch (e) {
      _favoritesBox.clear();
      return [];
    }
  }

  void toggleFavorite(ProductModel product) {
    // añade o elimina un producto de la lista de favoritos
    final key = product.id.toString();
    final isFav = _favoritesBox.containsKey(key);
    
    if (isFav) {
      _favoritesBox.delete(key);
      state = state.where((p) => p.id != product.id).toList();
    } else {
      _favoritesBox.put(key, jsonEncode(product.toJson()));
      state = [...state, product];
    }
  }

  Future<void> clearAll() async {
    await _favoritesBox.clear();
    state = [];
  }

  bool isFavorite(int id) {
    return _favoritesBox.containsKey(id.toString());
  }
}
