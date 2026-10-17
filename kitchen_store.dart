import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/kitchen_catalog.dart';
import '../data/planner_catalog.dart';
import '../models/grocery_item.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';

class RecipeMatch {
  const RecipeMatch({required this.recipe, required this.have, required this.missing});
  final Recipe recipe;
  final List<RecipeIngredient> have;
  final List<RecipeIngredient> missing;
  double get coverage => recipe.ingredients.isEmpty ? 0 : have.length / recipe.ingredients.length;
  int get percent => (coverage * 100).round();
}

class KitchenStore extends ChangeNotifier {
  KitchenStore() {
    unawaited(_loadPantry());
    unawaited(_loadPlannerSelections());
    ensureMonthlyPlan(DateTime.now());
  }

  static const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _pantryStorageKey = 'aaj_kya_banau_pantry_v1';
  static const _plannerStorageKey = 'aaj_kya_banau_planner_v1';

  final _uuid = const Uuid();
  final List<PantryItem> _pantry = [];
  final List<GroceryItem> _cart = [];
  final Map<String, Map<String, Recipe>> _plansByMonth = {};
  final Map<String, Map<String, Recipe>> _plannerSelections = {};
  bool eveningReminder = false;
  bool _pantryLoaded = false;

  List<PantryItem> get pantry => List.unmodifiable(_pantry);
  List<GroceryItem> get cart => List.unmodifiable(_cart);
  bool get pantryLoaded => _pantryLoaded;
  Map<String, Recipe> monthlyPlanFor(DateTime month) {
    final key = _monthKey(month);
    return Map.unmodifiable(_plansByMonth.putIfAbsent(key, () => _generatePlan(month)));
  }
  int plannedCountFor(DateTime month) => monthlyPlanFor(month).length;
  int get cartTotal => _cart.fold(0, (sum, item) => sum + item.lineTotal);

  String _monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';
  String dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, Recipe> _generatePlan(DateTime month) {
    final recipes = List<Recipe>.of(KitchenCatalog.recipes);
    recipes.shuffle(Random(month.year * 100 + month.month));
    final totalDays = DateTime(month.year, month.month + 1, 0).day;
    final plan = <String, Recipe>{};
    for (var day = 1; day <= totalDays; day++) {
      var index = (day - 1) % recipes.length;
      if (day > 1 && recipes[index].id == plan[dateKey(DateTime(month.year, month.month, day - 1))]?.id) {
        index = (index + 1) % recipes.length;
      }
      plan[dateKey(DateTime(month.year, month.month, day))] = recipes[index];
    }
    return plan;
  }

  Recipe? selectedPlannerMeal(DateTime date, String category) {
    return _plannerSelections[dateKey(date)]?[category];
  }

  void selectPlannerMeal(DateTime date, String category, Recipe recipe) {
    _plannerSelections.putIfAbsent(dateKey(date), () => <String, Recipe>{})[category] = recipe;
    unawaited(_savePlannerSelections());
    notifyListeners();
  }

  void ensureMonthlyPlan(DateTime month) {
    _plansByMonth.putIfAbsent(_monthKey(month), () => _generatePlan(month));
    notifyListeners();
  }

  void assignMeal(DateTime date, Recipe? recipe) {
    final key = _monthKey(date);
    final plan = _plansByMonth.putIfAbsent(key, () => _generatePlan(date));
    if (recipe == null) {
      plan.remove(dateKey(date));
    } else {
      plan[dateKey(date)] = recipe;
    }
    notifyListeners();
  }

  Future<void> _loadPlannerSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_plannerStorageKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final recipesById = <String, Recipe>{
        for (final recipes in PlannerCatalog.categories.values)
          for (final recipe in recipes) recipe.id: recipe,
      };
      for (final dateEntry in decoded.entries) {
        if (dateEntry.key is! String || dateEntry.value is! Map) continue;
        final selections = <String, Recipe>{};
        for (final mealEntry in (dateEntry.value as Map).entries) {
          if (mealEntry.key is! String || mealEntry.value is! String) continue;
          final recipe = recipesById[mealEntry.value as String];
          if (recipe != null && PlannerCatalog.categories.containsKey(mealEntry.key as String)) {
            selections[mealEntry.key as String] = recipe;
          }
        }
        if (selections.isNotEmpty) _plannerSelections[dateEntry.key as String] = selections;
      }
    } catch (_) {
      // Ignore malformed saved planner data and use generated suggestions.
    }
    notifyListeners();
  }

  Future<void> _savePlannerSelections() async {
    try {
      final data = <String, Map<String, String>>{};
      for (final entry in _plannerSelections.entries) {
        data[entry.key] = {
          for (final meal in entry.value.entries) meal.key: meal.value.id,
        };
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_plannerStorageKey, jsonEncode(data));
    } catch (_) {
      // Selections remain available for the current session if storage fails.
    }
  }

  Future<void> _loadPantry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pantryStorageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final value in decoded) {
            if (value is! Map) continue;
            final name = value['name'];
            if (name is! String || name.trim().isEmpty) continue;
            _pantry.add(PantryItem(
              id: value['id'] is String ? value['id'] as String : _uuid.v4(),
              name: name,
              emoji: value['emoji'] is String ? value['emoji'] as String : '🧺',
              quantity: value['quantity'] is int ? value['quantity'] as int : 1,
              unit: value['unit'] is String ? value['unit'] as String : 'pcs',
            ));
          }
        }
      }
    } catch (_) {
      // Corrupt or unavailable local data must not seed fake pantry items.
    }
    _pantryLoaded = true;
    notifyListeners();
  }

  Future<void> _savePantry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pantryStorageKey, jsonEncode(_pantry.map((item) => {
        'id': item.id, 'name': item.name, 'emoji': item.emoji,
        'quantity': item.quantity, 'unit': item.unit,
      }).toList()));
    } catch (_) {
      // Pantry still works for this session if local storage is unavailable.
    }
  }

  bool hasIngredient(String name) => _pantry.any((item) => item.key == name.trim().toLowerCase());

  RecipeMatch matchFor(Recipe recipe) {
    final have = <RecipeIngredient>[];
    final missing = <RecipeIngredient>[];
    for (final ingredient in recipe.ingredients) {
      (hasIngredient(ingredient.name) ? have : missing).add(ingredient);
    }
    return RecipeMatch(recipe: recipe, have: have, missing: missing);
  }

  List<RecipeMatch> get suggestions {
    final matches = KitchenCatalog.recipes.map(matchFor).toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));
    return matches;
  }

  void addPantryItem(PantryItem item, {bool notify = true}) {
    final existing = _pantry.indexWhere((p) => p.key == item.key);
    if (existing >= 0) {
      final current = _pantry[existing];
      _pantry[existing] = current.copyWith(quantity: current.quantity + item.quantity);
    } else {
      _pantry.insert(0, item);
    }
    unawaited(_savePantry());
    if (notify) notifyListeners();
  }

  void addManualItem(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    addPantryItem(PantryItem(id: _uuid.v4(), name: trimmed, emoji: '🧺', quantity: 1));
  }

  void removePantryItem(String id) {
    _pantry.removeWhere((item) => item.id == id);
    unawaited(_savePantry());
    notifyListeners();
  }

  void addMissingToCart(RecipeMatch match) {
    for (final ingredient in match.missing) {
      addGrocery(ingredient.name, ingredient.emoji, notify: false);
    }
    notifyListeners();
  }

  ({String unit, int price}) _groceryEstimate(String name) {
    final key = name.trim().toLowerCase();
    // Indicative local-market estimates only; these are not live Blinkit prices.
    const kgPrices = <String, int>{
      'potato': 30, 'onion': 40, 'tomato': 40, 'capsicum': 60,
      'palak': 30, 'cauliflower': 40, 'cabbage': 35, 'carrot': 50,
      'peas': 80, 'brinjal': 40, 'lauki': 35, 'cucumber': 35,
      'lemon': 80,
      'rice': 60, 'toor dal': 150, 'moong dal': 130, 'chana dal': 100,
      'besan': 100, 'atta': 45, 'sugar': 45,
    };
    const piecePrices = <String, int>{'eggs': 8, 'banana': 8};
    const packPrices = <String, int>{
      'turmeric': 35, 'salt': 25, 'cumin': 45, 'mustard seeds': 35,
      'chilli powder': 45, 'garam masala': 60, 'cream': 35,
      'butter': 60, 'paneer': 90, 'curd': 35, 'ginger': 30, 'garlic': 30,
      'green chilli': 20, 'coconut': 40,
    };
    if (kgPrices.containsKey(key)) return (unit: 'kg', price: kgPrices[key]!);
    if (piecePrices.containsKey(key)) return (unit: 'pcs', price: piecePrices[key]!);
    if (key == 'oil') return (unit: 'L', price: 150);
    if (key == 'coriander') return (unit: 'bunch', price: 20);
    if (packPrices.containsKey(key)) return (unit: 'pack', price: packPrices[key]!);
    return (unit: 'pack', price: 30);
  }

  void addGrocery(String name, String emoji, {bool notify = true}) {
    final existing = _cart.indexWhere((item) => item.name.toLowerCase() == name.toLowerCase());
    if (existing >= 0) {
      final current = _cart[existing];
      _cart[existing] = current.copyWith(quantity: current.quantity + 1);
    } else {
      final estimate = _groceryEstimate(name);
      _cart.add(GroceryItem(
        id: _uuid.v4(),
        name: name,
        emoji: emoji,
        quantity: 1,
        unit: estimate.unit,
        price: estimate.price,
      ));
    }
    if (notify) notifyListeners();
  }

  void changeCartQty(String id, int delta) {
    final index = _cart.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final next = _cart[index].quantity + delta;
    if (next <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].copyWith(quantity: next);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void setEveningReminder(bool value) {
    eveningReminder = value;
    notifyListeners();
  }
}
