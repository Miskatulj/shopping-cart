import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import 'price_text.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('${formatBdt(item.product.price)} each'),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Decrease quantity',
              onPressed: () => cart.decreaseQuantity(item.product.id),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 24,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Increase quantity',
              onPressed: () => cart.increaseQuantity(item.product.id),
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: 'Remove ${item.product.name}',
              color: Theme.of(context).colorScheme.error,
              onPressed: () => cart.removeProduct(item.product.id),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
