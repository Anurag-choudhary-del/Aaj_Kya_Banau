import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grocery_item.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Grocery cart',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Missing ingredients collected from recipes',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: store.cart.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Cart is empty.\nAdd missing items from the Recipes tab.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, height: 1.4),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    itemCount: store.cart.length,
                    itemBuilder: (context, index) {
                      return _CartTile(item: store.cart[index]);
                    },
                  ),
          ),
          _CheckoutBar(total: store.cartTotal, enabled: store.cart.isNotEmpty),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    final store = context.read<KitchenStore>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFEBEE),
            child: Text(item.emoji),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '₹${item.price} · missing from pantry',
                  style: const TextStyle(color: AppColors.missing, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _QtyButton(
            icon: Icons.remove,
            onTap: () => store.changeCartQty(item.id, -1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => store.changeCartQty(item.id, 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.enabled});

  final int total;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Estimated total', style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              Text(
                '₹$total',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: !enabled
                ? null
                : () => _placeBlinkitOrder(context),
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Blinkit Delivery'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D9B4D),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeBlinkitOrder(BuildContext context) async {
    final store = context.read<KitchenStore>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              const Text(
                'Blinkit Delivery',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Your missing groceries (₹${store.cartTotal}) will arrive in 10 minutes. This is a demo checkout.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D9B4D)),
                  onPressed: () {
                    store.clearCart();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed with Blinkit. Arriving in 10 min!')),
                    );
                  },
                  child: const Text('Confirm order'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
