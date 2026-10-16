import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final suggestions = store.suggestions;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const Text(
            'AI recipe suggestions',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ranked by what you already have. Missing ingredients show in red.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          ...suggestions.map((match) => _RecipeCard(match: match)),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final recipe = match.recipe;
    final store = context.read<KitchenStore>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.cream,
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipe.tagline,
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _MatchBadge(percent: match.percent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaChip(icon: Icons.schedule, label: '${recipe.minutes} min'),
              const SizedBox(width: 8),
              _MetaChip(icon: Icons.local_fire_department_outlined, label: recipe.spice),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ingredient in recipe.ingredients)
                _IngredientChip(
                  ingredient: ingredient,
                  missing: match.missing.any((m) => m.key == ingredient.key),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: match.missing.isEmpty
                      ? null
                      : () {
                          store.addMissingToCart(match);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added ${match.missing.length} missing item(s) to cart',
                              ),
                            ),
                          );
                        },
                  child: const Text('Add missing to cart'),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => _pickDay(context, recipe),
                child: const Text('Plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDay(BuildContext context, Recipe recipe) async {
    final store = context.read<KitchenStore>();
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final plan = store.monthlyPlanFor(month);
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text("Add to this month's planner",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            for (var day = 1; day <= totalDays; day++)
              Builder(builder: (context) {
                final date = DateTime(now.year, now.month, day);
                final existing = plan[store.dateKey(date)];
                return ListTile(
                  title: Text('${weekdays[date.weekday - 1]}, ${date.day}/${date.month}'),
                  subtitle: Text(existing?.name ?? 'No meal selected'),
                  trailing: existing?.id == recipe.id ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, date),
                );
              }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
    if (selected != null) {
      store.assignMeal(selected, recipe);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${recipe.name} planned for ${selected.day}/${selected.month}')),
        );
      }
    }
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 80
        ? AppColors.leaf
        : percent >= 50
            ? AppColors.saffron
            : AppColors.missing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percent% match',
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.ingredient, required this.missing});

  final RecipeIngredient ingredient;
  final bool missing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: missing ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: missing ? AppColors.missing.withValues(alpha: 0.35) : AppColors.have.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        '${ingredient.emoji}  ${ingredient.name}${ingredient.amount.isEmpty ? '' : ' · ${ingredient.amount}'}',
        style: TextStyle(
          color: missing ? AppColors.missing : AppColors.have,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
