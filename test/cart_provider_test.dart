import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/product.dart';
import 'package:task_manager/providers/cart_provider.dart';

void main() {
  const product = Product(
    id: 'test-product',
    name: 'Test Product',
    category: 'Test',
    price: 1250,
  );

  test('updates quantities and applies a discount above BDT 2000', () {
    final cart = CartProvider();
    cart.addProduct(product);
    cart.addProduct(product);
    expect(cart.totalItems, 2);
    expect(cart.subtotal, 2500);
    expect(cart.discount, 250);
    expect(cart.finalTotal, 2250);
    cart.decreaseQuantity(product.id);
    expect(cart.totalItems, 1);
    expect(cart.discount, 0);
    cart.decreaseQuantity(product.id);
    expect(cart.isEmpty, isTrue);
  });

  test('clears every cart item', () {
    final cart = CartProvider();
    cart.addProduct(product);
    cart.clearCart();
    expect(cart.isEmpty, isTrue);
    expect(cart.totalItems, 0);
  });
}
