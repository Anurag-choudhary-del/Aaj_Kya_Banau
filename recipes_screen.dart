import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/recipe.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;
  String _voiceError = '';

  Future<void> _startRecipeVoice(KitchenStore store) async {
    _voiceError = '';
    final available = await _speech.initialize(
      onStatus: (status) {
        if (mounted) setState(() => _listening = status == 'listening');
      },
      onError: (error) {
        if (mounted) setState(() {
          _listening = false;
          _voiceError = store.language == 'Hindi'
              ? 'आवाज़ नहीं समझ आई। दोबारा कोशिश करें या टाइप करें।'
              : store.language == 'Hinglish'
                  ? 'Voice samajh nahi aayi. Dobara try karo ya type karo.'
                  : 'Could not hear that. Try again or type ingredients.';
        });
      },
    );
    if (!available) {
      if (mounted) setState(() => _voiceError = store.language == 'Hindi'
          ? 'इस डिवाइस पर voice input उपलब्ध नहीं है।'
          : store.language == 'Hinglish'
              ? 'Is device par voice input available nahi hai.'
              : 'Voice input is unavailable on this device.');
      return;
    }
    final localeId = store.language == 'Hindi' ? 'hi_IN' : 'en_IN';
    await _speech.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.recognizedWords.trim().isNotEmpty) {
          store.setVoiceRecipePrompt(result.recognizedWords);
        }
        if (result.finalResult && mounted) {
          setState(() => _listening = false);
          _speech.stop();
        }
      },
    );
    if (mounted) setState(() => _listening = true);
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final suggestions = store.suggestions;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            store.t('Recipe suggestions'),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            store.t('Ranked by what you already have. Missing ingredients show in red.'),
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cream),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.language == 'Hindi'
                      ? 'सामान बोलकर रेसिपी पूछें'
                      : store.language == 'Hinglish'
                          ? 'Ingredients bolkar recipe poochho'
                          : 'Ask for recipes by voice',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text(
                    store.voiceRecipePrompt.isEmpty
                        ? (store.language == 'Hindi'
                            ? 'जैसे: मेरे पास पनीर, आलू, गोभी, प्याज़ और टमाटर हैं'
                            : store.language == 'Hinglish'
                                ? 'Jaise: mere paas paneer, aloo, gobhi, pyaaz, tamatar hain'
                                : 'Example: I have paneer, potato, cauliflower, onion and tomato')
                        : store.voiceRecipePrompt,
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  )),
                  IconButton(
                    tooltip: _listening ? 'Listening' : 'Speak ingredients',
                    onPressed: _listening ? () => _speech.stop() : () => _startRecipeVoice(store),
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none,
                        color: _listening ? AppColors.missing : AppColors.saffron),
                  ),
                  if (store.voiceRecipePrompt.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear voice query',
                      onPressed: store.clearVoiceRecipePrompt,
                      icon: const Icon(Icons.close),
                    ),
                ]),
                if (_voiceError.isNotEmpty)
                  Text(_voiceError, style: const TextStyle(color: AppColors.missing, fontSize: 12)),
                if (store.voiceRecipePrompt.isNotEmpty)
                  Text(
                    store.language == 'Hindi'
                        ? 'ये सामग्री केवल इस खोज के लिए है; pantry में सेव नहीं होगी।'
                        : store.language == 'Hinglish'
                            ? 'Ye ingredients sirf is search ke liye hain; pantry mein save nahi honge.'
                            : 'These ingredients are only used for this search and are not saved to your pantry.',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
              child: Center(
                child: Text(
                  store.voiceRecipePrompt.isNotEmpty
                      ? (store.language == 'Hindi'
                          ? 'बताए गए सामान में कोई ingredient पहचान नहीं आया। नाम टाइप करके कोशिश करें।'
                          : store.language == 'Hinglish'
                              ? 'Bole gaye ingredients samajh nahi aaye. Naam type karke try karo.'
                              : 'No ingredients recognized. Try typing the ingredient names.')
                      : (store.language == 'Hindi'
                          ? 'अभी कोई रेसिपी नहीं — आपकी रसोई में सामान नहीं है। पहले pantry में सामान जोड़ें।'
                          : store.language == 'Hinglish'
                              ? 'Abhi recipes nahi hain, kyunki rasoi mein ingredients nahi hain. Pehle pantry mein samaan add karo.'
                              : 'No recipes because you don’t have ingredients in your kitchen. Add pantry items to see what you can cook.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 15),
                ),
              ),
            )
          else
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
                      store.displayName(recipe.name),
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
          Text(store.t('Ingredients'), style: const TextStyle(fontWeight: FontWeight.w700)),
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
                                store.language == 'Hindi' ? '${match.missing.length} बाकी सामान कार्ट में जोड़े' : store.language == 'Hinglish' ? '${match.missing.length} missing items cart mein add kiye' : 'Added ${match.missing.length} missing item(s) to cart',
                              ),
                            ),
                          );
                        },
                  child: Text(store.t('Add missing to cart')),
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
        '${ingredient.emoji}  ${context.watch<KitchenStore>().displayName(ingredient.name)}${ingredient.amount.isEmpty ? '' : ' · ${ingredient.amount}'}',
        style: TextStyle(
          color: missing ? AppColors.missing : AppColors.have,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
