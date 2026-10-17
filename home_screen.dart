import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pantry_item.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store.t('Namaste 👋'),
                  style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ),
              DropdownButton<String>(
                value: store.language,
                underline: const SizedBox.shrink(),
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'Hinglish', child: Text('Hinglish')),
                  DropdownMenuItem(value: 'Hindi', child: Text('हिन्दी')),
                ],
                onChanged: (value) {
                  if (value != null) store.setLanguage(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            store.t('Aaj kya banau?'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            store.language == 'Hindi'
                ? 'आपकी रसोई में ${store.pantry.length} सामान · फोटो स्कैन करके और जोड़ें'
                : store.language == 'Hinglish'
                    ? '${store.pantry.length} items tumhari rasoi mein · photo scan karke aur add karo'
                    : '${store.pantry.length} items in your pantry · scan or upload a photo to add more',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _ScanCta(
            onTap: () async {
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
              if (added == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(store.language == 'Hindi' ? 'स्कैन किया गया सामान रसोई में जोड़ दिया' : store.language == 'Hinglish' ? 'Scanned items pantry mein add ho gaye' : 'Scanned items added to pantry')),
                );
              }
            },
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                store.t('Your pantry'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${store.pantry.length}',
                style: const TextStyle(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              store.addManualItem(value);
              _controller.clear();
            },
            decoration: InputDecoration(
              hintText: store.t('Add an item…  e.g. Methi'),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.add_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.saffron),
                onPressed: () {
                  store.addManualItem(_controller.text);
                  _controller.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (store.pantry.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text(store.t('Pantry is empty — scan or add items'))),
            )
          else
            ...store.pantry.map((item) => _PantryTile(item: item)),
        ],
      ),
    );
  }
}

class _ScanCta extends StatelessWidget {
  const _ScanCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.saffron,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.t('Camera scan'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.language == 'Hindi' ? 'AI से सामान पहचानने के लिए फोटो लें या अपलोड करें' : store.language == 'Hinglish' ? 'AI se ingredients pehchanne ke liye photo lo ya upload karo' : 'Take a photo or upload one for AI ingredient recognition',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantryTile extends StatelessWidget {
  const _PantryTile({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<KitchenStore>().removePantryItem(item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.missing.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.missing),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.cream,
              child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.watch<KitchenStore>().displayName(item.name),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.read<KitchenStore>().removePantryItem(item.id),
              icon: const Icon(Icons.close_rounded, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
