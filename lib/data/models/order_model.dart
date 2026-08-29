import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final int id;
  final String number;
  final String status;
  final String total;
  
  @JsonKey(name: 'date_created')
  final String dateCreated;
  
  @JsonKey(name: 'line_items')
  final List<OrderLineItem> lineItems;

  final Map<String, dynamic>? billing;
  final Map<String, dynamic>? shipping;

  OrderModel({
    required this.id,
    required this.number,
    required this.status,
    required this.total,
    required this.dateCreated,
    required this.lineItems,
    this.billing,
    this.shipping,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderLineItem {
  final int id;
  final String name;
  
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;
  final String total;
  final String? price;

  OrderLineItem({
    required this.id,
    required this.name,
    required this.productId,
    required this.quantity,
    required this.total,
    this.price,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => _$OrderLineItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderLineItemToJson(this);
}
