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

  String _monthName(DateTime date, String language) {
    const english = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    const hindi = ['जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
      'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];
    const hinglish = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    final months = language == 'Hindi' ? hindi : language == 'Hinglish' ? hinglish : english;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(store.t('Monthly meal planner'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              store.language == 'Hindi' ? '${totalDays} दिन · नाश्ता, दोपहर का खाना, रात का खाना और स्नैक्स · हर श्रेणी में 5 विकल्प' : store.language == 'Hinglish' ? '${totalDays} days · nashta, lunch, dinner aur snacks · har category mein 5 options' : '${totalDays} days · breakfast, lunch, dinner and snacks · 5 options per category each day',
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(child: Text(_monthName(_visibleMonth, store.language),
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
                  ? 'Reminder on hai. Scheduled notifications abhi configure nahi hain.'
                  : 'Evening reminder off'),
              ));
            },
          ),
          const SizedBox(height: 12),
          for (var day = 1; day <= totalDays; day++)
            _DayMealCard(
              date: DateTime(_visibleMonth.year, _visibleMonth.month, day),
              monthName: _monthName(_visibleMonth, store.language),
              onSelect: (category, recipe) => _showRecipeDetails(context, DateTime(_visibleMonth.year, _visibleMonth.month, day), category, recipe),
            ),
          const SizedBox(height: 8),
          Text(
            context.watch<KitchenStore>().language == 'Hindi' ? 'ये बजट के हिसाब से घर पर बनने वाले खाने के सुझाव हैं। दाम और मौसमी उपलब्धता बदल सकती है; चुने गए विकल्प ऐप खुला रहने तक सेव रहते हैं।' : context.watch<KitchenStore>().language == 'Hinglish' ? 'Ye budget-friendly home cooking ideas hain. Prices aur seasonal availability badal sakti hai; selections app open rehne tak save hain.' : 'Meal ideas are budget-conscious home-cooking suggestions. Prices and seasonal availability vary; chosen options stay selected while the app remains open.',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
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
                Text('${recipe.emoji}  ${store.displayName(recipe.name)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${recipe.minutes} min · ${store.t(category)} · ${recipe.tagline}', style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                Text(store.t('Ingredients'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final ingredient in recipe.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Text(ingredient.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${store.displayName(ingredient.name)}${ingredient.amount.isEmpty ? '' : ' · ${ingredient.amount}'}')),
                      Text(
                        match.missing.any((item) => item.key == ingredient.key) ? store.t('Need to buy') : store.t('In pantry'),
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
                    label: Text(store.t('Add missing to cart')),
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
                    child: Text(store.t('Choose this meal')),
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
    final store = context.watch<KitchenStore>();
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
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.t('Evening reminder'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              store.language == 'Hindi' ? 'चुने गए खाने के लिए शाम 7 बजे और दोपहर 12:30 बजे रिमाइंडर' : store.language == 'Hinglish' ? 'Selected meals ke reminders: shaam 7 baje aur dopahar 12:30' : 'Reminders only for selected meals: 7:00 PM and 12:30 PM',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
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
              final isNone = store.isPlannerMealNone(date, category);
              final chosen = store.selectedPlannerMeal(date, category);
              final displayed = chosen ?? (isNone ? null : PlannerCatalog.defaultForDay(category, date.day));
              final options = PlannerCatalog.optionsForDay(category, date.day);
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  leading: Text(_categoryEmoji(category), style: const TextStyle(fontSize: 22)),
                  title: Text(store.t(category), style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(displayed == null ? store.t('None — skip this meal') : '${displayed.emoji} ${store.displayName(displayed.name)}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  children: [
                    for (final recipe in options)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: Text(recipe.emoji, style: const TextStyle(fontSize: 23)),
                        title: Text(store.displayName(recipe.name), style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(store.language == 'Hindi' ? '${recipe.minutes} मिनट · सामग्री देखने के लिए टैप करें' : store.language == 'Hinglish' ? '${recipe.minutes} min · ingredients dekhne ke liye tap karo' : '${recipe.minutes} min · tap for ingredients'),
                        trailing: chosen?.id == recipe.id ? const Icon(Icons.check_circle, color: AppColors.have) : const Icon(Icons.chevron_right),
                        onTap: () => onSelect(category, recipe),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: isNone ? const Color(0xFFFFE0C2) : const Color(0xFFFFF8F1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isNone ? AppColors.deepSpice : const Color(0xFFE8CDB5), width: isNone ? 2 : 1),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.block, color: AppColors.deepSpice),
                        title: Text(store.t('None — skip this meal'), style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(store.language == 'Hindi' ? 'इस समय के लिए कोई खाना नहीं चुनना' : store.language == 'Hinglish' ? 'Is meal ke liye kuch select nahi karna' : 'Skip a suggested meal for this slot'),
                        trailing: isNone ? const Icon(Icons.check_circle, color: AppColors.deepSpice) : const Icon(Icons.chevron_right),
                        selected: isNone,
                        onTap: () => store.setPlannerMealNone(date, category),
                      ),
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
