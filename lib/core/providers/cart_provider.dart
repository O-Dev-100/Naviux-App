import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/cart_item.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() {
    // carga los productos guardados en el carrito al iniciar
    final box = Hive.box<String>('cart_box');
    final cartJson = box.get('items');
    if (cartJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartJson);
        return decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error al decodificar el carrito: $e');
        return [];
      }
    }
    return [];
  }

  void _saveCart() {
    // persiste el estado actual del carrito localmente
    final box = Hive.box<String>('cart_box');
    box.put('items', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  void addCartItem(CartItem item) {
    // añade un producto o incrementa su cantidad si ya existe
    final existingIndex = state.indexWhere((i) => 
      i.product.id == item.product.id && 
      i.variationId == item.variationId &&
      _mapEquals(i.selectedAttributes, item.selectedAttributes)
    );

    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + item.quantity);
      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      state = [...state, item];
    }
    _saveCart();
  }

  void removeCartItem(int productId, {int? variationId, Map<String, String>? attributes}) {
    // elimina productos específicos del carrito
    state = state.where((i) {
      if (i.product.id != productId) return true;
      if (variationId != null && i.variationId != variationId) return true;
      if (attributes != null && !_mapEquals(i.selectedAttributes, attributes)) return true;
      return false;
    }).toList();
    _saveCart();
  }

  void removeCartItemAtIndex(int index) {
    if (index >= 0 && index < state.length) {
      final newState = [...state];
      newState.removeAt(index);
      state = newState;
      _saveCart();
    }
  }

  void updateQuantity(int index, int newQuantity) {
    // actualiza la cantidad de un producto por su posición
    if (newQuantity <= 0) {
      removeCartItemAtIndex(index);
    } else {
      final newState = [...state];
      newState[index] = newState[index].copyWith(quantity: newQuantity);
      state = newState;
      _saveCart();
    }
  }

  void clearCart() {
    state = [];
    _saveCart();
  }

  int get cartCount {
    return state.fold<int>(0, (total, item) => total + item.quantity);
  }
  
  double get cartTotal {
    return state.fold<double>(0.0, (total, item) => total + item.subtotal);
  }

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }
}
