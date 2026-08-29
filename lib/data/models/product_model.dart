import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  // modelo que representa un producto de la tienda
  final int id;
  final String name;
  final String price;
  final String description;

  @JsonKey(name: 'short_description')
  final String shortDescription;
  final List<ProductImage> images;
  final List<ProductCategory> categories;
  final List<ProductAttribute> attributes;
  final List<int> variations;
  final String type;
  
  @JsonKey(name: 'stock_status')
  final String stockStatus;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.shortDescription = '',
    required this.images,
    required this.categories,
    required this.attributes,
    required this.variations,
    required this.type,
    required this.stockStatus,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

@JsonSerializable()
class ProductImage {
  // imagen asociada a un producto
  final String src;

  ProductImage({required this.src});

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
  Map<String, dynamic> toJson() => _$ProductImageToJson(this);
}

@JsonSerializable()
class ProductCategory {
  // categoría a la que pertenece un producto
  final int id;
  final String name;
  final String slug;

  ProductCategory({required this.id, required this.name, required this.slug});

  factory ProductCategory.fromJson(Map<String, dynamic> json) => _$ProductCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);
}

@JsonSerializable()
class ProductAttribute {
  // atributo de producto como color o tamaño
  final int id;
  final String name;
  final List<String> options;
  final bool variation;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.options,
    required this.variation,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) => _$ProductAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$ProductAttributeToJson(this);
}

@JsonSerializable()
class ProductVariation {
  // variante específica de un producto variable
  final int id;
  final String price;
  @JsonKey(name: 'regular_price')
  final String regularPrice;
  final List<ProductImage> images;
  final List<Map<String, dynamic>> attributes;
  @JsonKey(name: 'stock_status')
  final String stockStatus;
  
  @JsonKey(name: 'manage_stock')
  final dynamic manageStock;

  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;

  ProductVariation({
    required this.id,
    required this.price,
    required this.regularPrice,
    required this.images,
    required this.attributes,
    required this.stockStatus,
    this.manageStock,
    this.stockQuantity,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) => _$ProductVariationFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariationToJson(this);

  Map<String, String> get attributeMap {
    // convierte la lista de atributos en un mapa para búsqueda rápida
    final Map<String, String> map = {};
    for (var attr in attributes) {
      if (attr.containsKey('name') && attr.containsKey('option')) {
        map[attr['name'].toString()] = attr['option'].toString();
      }
    }
    return map;
  }
}
