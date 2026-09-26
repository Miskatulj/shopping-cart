import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  UnmodifiableMapView<String, CartItem> get items =>
      UnmodifiableMapView(_items);
  List<CartItem> get cartItems => _items.values.toList(growable: false);
  bool get isEmpty => _items.isEmpty;
  int get totalItems =>
      _items.values.fold(0, (total, item) => total + item.quantity);
  double get subtotal =>
      _items.values.fold(0, (total, item) => total + item.lineTotal);
  double get discount => subtotal > 2000 ? subtotal * 0.10 : 0;
  double get finalTotal => subtotal - discount;

  void addProduct(Product product) {
    final existingItem = _items[product.id];
    if (existingItem == null) {
      _items[product.id] = CartItem(product: product, quantity: 1);
    } else {
      _items[product.id] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  void increaseQuantity(String productId) {
    final item = _items[productId];
    if (item == null) return;
    _items[productId] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity == 1) {
      _items.remove(productId);
    } else {
      _items[productId] = item.copyWith(quantity: item.quantity - 1);
    }
    notifyListeners();
  }

  void clearCart() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
