import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kitchen_catalog.dart';
import '../models/recipe.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const Text(
            'Weekly meal planner',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${store.plannedCount}/7 dinners planned',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _ReminderCard(
            enabled: store.eveningReminder,
            onChanged: (value) {
              store.setEveningReminder(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Evening reminder on — we will nudge you at 7:00 PM'
                        : 'Evening reminder turned off',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          for (final day in KitchenStore.days)
            _DayCard(
              day: day,
              recipe: store.plan[day],
              onPick: () => _chooseRecipe(context, day),
              onClear: () => store.assignMeal(day, null),
            ),
        ],
      ),
    );
  }

  Future<void> _chooseRecipe(BuildContext context, String day) async {
    final store = context.read<KitchenStore>();
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                'Dinner for $day',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            for (final recipe in KitchenCatalog.recipes)
              ListTile(
                leading: Text(recipe.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(recipe.name),
                subtitle: Text('${recipe.minutes} min · ${recipe.spice}'),
                onTap: () => Navigator.pop(context, recipe),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
    if (recipe != null) {
      store.assignMeal(day, recipe);
    }
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE0C2), Color(0xFFFFF6EC)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_active_outlined, color: AppColors.deepSpice),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evening reminder',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  'Daily ping at 7:00 PM — “Aaj kya banau?”',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.recipe,
    required this.onPick,
    required this.onClear,
  });

  final String day;
  final Recipe? recipe;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              day.substring(0, 3),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.deepSpice,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: recipe == null
                ? Text(
                    'Nothing planned',
                    style: TextStyle(color: AppColors.muted.withValues(alpha: 0.9)),
                  )
                : Row(
                    children: [
                      Text(recipe!.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recipe!.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
          ),
          IconButton(
            tooltip: 'Choose dish',
            onPressed: onPick,
            icon: const Icon(Icons.edit_outlined, color: AppColors.saffron),
          ),
          if (recipe != null)
            IconButton(
              tooltip: 'Clear',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}
