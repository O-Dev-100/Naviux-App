// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedAttributes:
          Map<String, String>.from(json['selectedAttributes'] as Map),
      variationId: (json['variationId'] as num?)?.toInt(),
      price: json['price'] as String?,
      variationImage: json['variationImage'] as String?,
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'product': instance.product,
      'quantity': instance.quantity,
      'selectedAttributes': instance.selectedAttributes,
      'variationId': instance.variationId,
      'price': instance.price,
      'variationImage': instance.variationImage,
    };
