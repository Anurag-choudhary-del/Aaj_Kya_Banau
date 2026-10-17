import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/planner_catalog.dart';
import '../models/recipe.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  String _monthName(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _changeMonth(int delta) {
    setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final existingPlan = store.monthlyPlanFor(_visibleMonth);
    final totalDays = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('Monthly meal planner', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$totalDays days · breakfast, lunch, dinner and snacks · 5 options per category each day',
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(child: Text(_monthName(_visibleMonth),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
              IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
            ]),
          ),
          const SizedBox(height: 16),
          _ReminderCard(
            enabled: store.eveningReminder,
            onChanged: (value) {
              store.setEveningReminder(value);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(value
                  ? 'Reminder toggle on. Actual scheduled notifications abhi configure nahi hain.'
                  : 'Evening reminder turned off'),
              ));
            },
          ),
          const SizedBox(height: 12),
          for (var day = 1; day <= totalDays; day++)
            _DayMealCard(
              date: DateTime(_visibleMonth.year, _visibleMonth.month, day),
              monthName: _monthName(_visibleMonth),
              onSelect: (category, recipe) => _showRecipeDetails(context, DateTime(_visibleMonth.year, _visibleMonth.month, day), category, recipe),
            ),
          const SizedBox(height: 8),
          const Text(
            'Meal ideas are budget-conscious home-cooking suggestions. Prices and seasonal availability vary; chosen options stay selected while the app remains open.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          if (existingPlan.isEmpty) const SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<void> _showRecipeDetails(BuildContext context, DateTime date, String category, Recipe recipe) async {
    final store = context.read<KitchenStore>();
    final match = store.matchFor(recipe);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${recipe.emoji}  ${recipe.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${recipe.minutes} min · $category · ${recipe.tagline}', style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final ingredient in recipe.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Text(ingredient.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${ingredient.name}${ingredient.amount.isEmpty ? '' : ' · ${ingredient.amount}'}')),
                      Text(
                        match.missing.any((item) => item.key == ingredient.key) ? 'Need to buy' : 'In pantry',
                        style: TextStyle(
                          color: match.missing.any((item) => item.key == ingredient.key) ? AppColors.missing : AppColors.have,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: match.missing.isEmpty ? null : () {
                      store.addMissingToCart(match);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${match.missing.length} missing ingredient(s) to cart')),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add missing to cart'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton(
                    onPressed: () {
                      store.selectPlannerMeal(date, category, recipe);
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipe.name} selected for $category on ${date.day}/${date.month}')),
                      );
                    },
                    child: const Text('Choose this meal'),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
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
        gradient: const LinearGradient(colors: [Color(0xFFFFE0C2), Color(0xFFFFF6EC)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.notifications_active_outlined, color: AppColors.deepSpice),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evening reminder', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 2),
            Text('Reminder toggle (scheduled notifications not yet enabled)',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        )),
        Switch.adaptive(value: enabled, onChanged: onChanged),
      ]),
    );
  }
}

class _DayMealCard extends StatelessWidget {
  const _DayMealCard({required this.date, required this.monthName, required this.onSelect});
  final DateTime date;
  final String monthName;
  final void Function(String category, Recipe recipe) onSelect;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(weekdays[date.weekday - 1], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.deepSpice)),
                  Text('${date.day}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('${weekdays[date.weekday - 1]}, ${date.day} ${monthName.split(' ').first}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              const Text('4 meals', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          for (final category in PlannerCatalog.categories.keys)
            Builder(builder: (context) {
              final selected = store.selectedPlannerMeal(date, category) ?? PlannerCatalog.defaultForDay(category, date.day);
              final options = PlannerCatalog.optionsForDay(category, date.day);
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  leading: Text(_categoryEmoji(category), style: const TextStyle(fontSize: 22)),
                  title: Text(category, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${selected.emoji} ${selected.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  children: [
                    for (final recipe in options)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: Text(recipe.emoji, style: const TextStyle(fontSize: 23)),
                        title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${recipe.minutes} min · tap for ingredients'),
                        trailing: selected.id == recipe.id ? const Icon(Icons.check_circle, color: AppColors.have) : const Icon(Icons.chevron_right),
                        onTap: () => onSelect(category, recipe),
                      ),
                  ],
                ),
              );
            }),
        ],
        ),
      ),
    );
  }

  String _categoryEmoji(String category) => switch (category) {
    'Breakfast' => '🌅',
    'Lunch' => '🍱',
    'Dinner' => '🌙',
    _ => '☕',
  };
}
