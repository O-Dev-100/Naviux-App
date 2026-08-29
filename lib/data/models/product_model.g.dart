// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      price: json['price'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String? ?? '',
      images: (json['images'] as List<dynamic>)
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: (json['attributes'] as List<dynamic>)
          .map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
      variations: (json['variations'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      type: json['type'] as String,
      stockStatus: json['stock_status'] as String,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'images': instance.images,
      'categories': instance.categories,
      'attributes': instance.attributes,
      'variations': instance.variations,
      'type': instance.type,
      'stock_status': instance.stockStatus,
    };

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
      src: json['src'] as String,
    );

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'src': instance.src,
    };

ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) =>
    ProductCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$ProductCategoryToJson(ProductCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

ProductAttribute _$ProductAttributeFromJson(Map<String, dynamic> json) =>
    ProductAttribute(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      variation: json['variation'] as bool,
    );

Map<String, dynamic> _$ProductAttributeToJson(ProductAttribute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'options': instance.options,
      'variation': instance.variation,
    };

ProductVariation _$ProductVariationFromJson(Map<String, dynamic> json) =>
    ProductVariation(
      id: (json['id'] as num).toInt(),
      price: json['price'] as String,
      regularPrice: json['regular_price'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: (json['attributes'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      stockStatus: json['stock_status'] as String,
      manageStock: json['manage_stock'],
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductVariationToJson(ProductVariation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'regular_price': instance.regularPrice,
      'images': instance.images,
      'attributes': instance.attributes,
      'stock_status': instance.stockStatus,
      'manage_stock': instance.manageStock,
      'stock_quantity': instance.stockQuantity,
    };
