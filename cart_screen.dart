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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              store.t('Grocery cart'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              store.language == 'Hindi' ? 'मात्रा और स्थानीय बाज़ार के अनुमानित दाम' : store.language == 'Hinglish' ? 'Quantity aur local market ke estimated rates' : 'Quantities and indicative local-market estimates',
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: store.cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        store.t('Cart is empty.\nAdd missing items from the Recipes tab.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted, height: 1.4),
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
                Text(store.displayName(item.name), style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '₹${item.price}/${item.unitLabel} estimated · line total ₹${item.lineTotal}',
                  style: const TextStyle(color: AppColors.missing, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                if (item.unit == 'kg')
                  DropdownButton<int>(
                    value: item.packSize,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 1, child: Text(store.t('Pack: 1 kg'))),
                      DropdownMenuItem(value: 5, child: Text(store.t('Pack: 5 kg'))),
                      DropdownMenuItem(value: 10, child: Text(store.t('Pack: 10 kg'))),
                    ],
                    onChanged: (value) {
                      if (value != null) store.changeCartPackSize(item.id, value);
                    },
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
              item.unit == 'kg'
                  ? '${item.quantity} × ${item.packSize} kg'
                  : '${item.quantity} ${item.unitLabel}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
    final store = context.watch<KitchenStore>();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              Text(store.t('Estimated total'), style: const TextStyle(color: AppColors.muted)),
              const Spacer(),
              Text(
                '₹$total',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(store.language == 'Hindi' ? 'ये अनुमान हैं, Blinkit के लाइव दाम नहीं। असली दाम, पैक, उपलब्धता और डिलीवरी फीस अलग हो सकती है।' : store.language == 'Hinglish' ? 'Ye estimates hain, live Blinkit prices nahi. Actual price, pack aur delivery fee alag ho sakti hai.' : 'Estimates only — not live Blinkit prices. Actual prices, pack sizes, availability and delivery fees may differ.', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: !enabled
                ? null
                : () => _placeBlinkitOrder(context),
            icon: const Icon(Icons.bolt_rounded),
            label: Text(store.language == 'Hindi' ? 'Blinkit (कनेक्ट नहीं है)' : store.language == 'Hinglish' ? 'Blinkit (connected nahi)' : 'Blinkit (not connected)'),
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
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              store.language == 'Hindi' ? 'Blinkit ऑर्डरिंग कनेक्ट नहीं है' : store.language == 'Hinglish' ? 'Blinkit ordering connected nahi hai' : 'Blinkit ordering is not connected',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              store.language == 'Hindi' ? 'इस कार्ट में स्थानीय बाज़ार के अनुमानित दाम हैं। यह Blinkit को सामान नहीं भेज सकता और ऑर्डर या पेमेंट नहीं करेगा। लाइव दाम देखने और सामान जोड़ने के लिए Blinkit अलग से खोलें।' : store.language == 'Hinglish' ? 'Is cart mein local market ke estimated rates hain. Ye Blinkit par items bhej ya order place nahi kar sakta. Live prices check karne ke liye Blinkit alag se kholo.' : 'This cart uses estimated local-market prices. It cannot send items to Blinkit or place an order. Open Blinkit separately to check live prices and add items.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(store.language == 'Hindi' ? 'समझ गया' : store.language == 'Hinglish' ? 'Theek hai' : 'Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
