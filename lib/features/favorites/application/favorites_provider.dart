import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/product.dart';
import 'package:hive/hive.dart';

part 'favorites_provider.g.dart';

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  late Box<String> _favoritesBox;

  @override
  List<Product> build() {
    _favoritesBox = Hive.box<String>('favorites');
    // For now returning empty until we connect it fully with repo
    return []; 
  }

  void toggleFavorite(Product product) {
    final isFavorite = _favoritesBox.containsKey(product.id);
    if (isFavorite) {
      _favoritesBox.delete(product.id);
    } else {
      _favoritesBox.put(product.id, product.id);
    }
    // state = ... Update state here
  }

  bool isFavorite(String id) {
    return _favoritesBox.containsKey(id);
  }
}
