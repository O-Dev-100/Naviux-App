import '../../../../data/models/product_model.dart';

class CatalogItem {
  final ProductModel product;
  final String selectedVariant; // Ej: "Graduación: +1.50" or Variation ID/Name
  final int quantity;

  CatalogItem({
    required this.product,
    required this.selectedVariant,
    required this.quantity,
  });

  CatalogItem copyWith({int? quantity, String? selectedVariant}) {
    return CatalogItem(
      product: product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
    );
  }

  // Key for the map in state (Product ID + variant string to differentiate)
  String get uniqueKey => '${product.id}_$selectedVariant';
}
