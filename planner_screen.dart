import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kitchen_catalog.dart';
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
    final plan = store.monthlyPlanFor(_visibleMonth);
    final totalDays = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final planned = plan.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const Text('Monthly meal planner', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('$planned/$totalDays days planned · generated automatically each month',
            style: const TextStyle(color: AppColors.muted)),
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
          const SizedBox(height: 16),
          for (var day = 1; day <= totalDays; day++)
            _DayCard(
              date: DateTime(_visibleMonth.year, _visibleMonth.month, day),
              recipe: plan[store.dateKey(DateTime(_visibleMonth.year, _visibleMonth.month, day))],
              onPick: () => _chooseRecipe(context, DateTime(_visibleMonth.year, _visibleMonth.month, day)),
              onClear: () => store.assignMeal(DateTime(_visibleMonth.year, _visibleMonth.month, day), null),
            ),
          const SizedBox(height: 8),
          const Text('Plan local recipe catalogue se banta hai. Har month recipe order badalta hai; internet ya API key ki zarurat nahi.',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _chooseRecipe(BuildContext context, DateTime date) async {
    final store = context.read<KitchenStore>();
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text('Meal for ${date.day} ${_monthName(date)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
      ),
    );
    if (recipe != null) store.assignMeal(date, recipe);
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

class _DayCard extends StatelessWidget {
  const _DayCard({required this.date, required this.recipe, required this.onPick, required this.onClear});
  final DateTime date;
  final Recipe? recipe;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        SizedBox(width: 58, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(weekday, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepSpice)),
            Text('${date.day}', style: const TextStyle(color: AppColors.muted)),
          ],
        )),
        Expanded(child: recipe == null
          ? const Text('No meal selected', style: TextStyle(color: AppColors.muted))
          : Row(children: [
              Text(recipe!.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${recipe!.minutes} min · ${recipe!.tagline}',
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ])),
            ])),
        IconButton(tooltip: 'Change dish', onPressed: onPick,
          icon: const Icon(Icons.edit_outlined, color: AppColors.saffron)),
        if (recipe != null) IconButton(tooltip: 'Clear', onPressed: onClear,
          icon: const Icon(Icons.close_rounded, color: AppColors.muted)),
      ]),
    );
  }
}
