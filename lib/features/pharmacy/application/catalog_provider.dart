import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/catalog_item.dart';
import '../../../../data/models/product_model.dart';

part 'catalog_provider.g.dart';

@riverpod
class CatalogState extends _$CatalogState {
  @override
  Map<String, CatalogItem> build() => {};

  void updateQuantity(ProductModel product, String variant, int delta) {
    // actualiza la cantidad de un producto en el pedido profesional
    final key = '${product.id}_$variant';
    final currentItem = state[key];
    
    if (currentItem == null && delta > 0) {
      state = {
        ...state,
        key: CatalogItem(product: product, selectedVariant: variant, quantity: delta)
      };
    } else if (currentItem != null) {
      final newQty = currentItem.quantity + delta;
      if (newQty <= 0) {
        final newState = Map<String, CatalogItem>.from(state);
        newState.remove(key);
        state = newState;
      } else {
        state = {
          ...state,
          key: currentItem.copyWith(quantity: newQty)
        };
      }
    }
  }

  void clear() => state = {};
  
  int get totalItems {
    return state.values.fold(0, (sum, item) => sum + item.quantity);
  }
}
