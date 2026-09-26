import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  final VoidCallback onPressed;

  const CartBadge({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => IconButton(
        tooltip: 'Open cart',
        onPressed: onPressed,
        icon: Badge(
          isLabelVisible: cart.totalItems > 0,
          label: Text('${cart.totalItems}'),
          child: const Icon(Icons.shopping_bag_outlined),
        ),
      ),
    );
  }
}
