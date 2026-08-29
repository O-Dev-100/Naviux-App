import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';


part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final ProductModel product;
  final int quantity;
  final Map<String, String> selectedAttributes;
  final int? variationId;
  final String? price; // Precio específico de la variación si existe
  final String? variationImage; // Imagen específica de la variación

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedAttributes,
    this.variationId,
    this.price,
    this.variationImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
    Map<String, String>? selectedAttributes,
    int? variationId,
    String? price,
    String? variationImage,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      variationId: variationId ?? this.variationId,
      price: price ?? this.price,
      variationImage: variationImage ?? this.variationImage,
    );
  }

  double get subtotal {
    final rawPrice = price ?? product.price;
    // Manejo de posibles comas decimales
    final normalizedPrice = rawPrice.replaceAll(',', '.');
    final effectivePrice = double.tryParse(normalizedPrice) ?? 0.0;
    return effectivePrice * quantity;
  }
}
