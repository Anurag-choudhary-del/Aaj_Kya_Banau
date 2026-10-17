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
import '../meal_notification_service.dart';

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
    unawaited(_loadLanguage());
    unawaited(_loadReminderSetting());
    ensureMonthlyPlan(DateTime.now());
  }

  static const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _pantryStorageKey = 'aaj_kya_banau_pantry_v1';
  static const _plannerStorageKey = 'aaj_kya_banau_planner_v1';
  static const _languageStorageKey = 'aaj_kya_banau_language_v1';
  static const _reminderStorageKey = 'aaj_kya_banau_meal_reminders_v1';
  static const _noneSelection = '__none__';

  final _uuid = const Uuid();
  final List<PantryItem> _pantry = [];
  final List<GroceryItem> _cart = [];
  final Map<String, Map<String, Recipe>> _plansByMonth = {};
  final Map<String, Map<String, Recipe>> _plannerSelections = {};
  final Set<String> _noneSelections = <String>{};
  bool eveningReminder = false;
  bool _pantryLoaded = false;
  String language = 'English';

  static const Map<String, Map<String, String>> _translations = {
    'Hindi': {
      'Pantry': 'रसोई',
      'Recipes': 'रेसिपी',
      'Planner': 'मील प्लानर',
      'Cart': 'कार्ट',
      'Namaste 👋': 'नमस्ते 👋',
      'Aaj kya banau?': 'आज क्या बनाऊँ?',
      'Your pantry': 'आपकी रसोई',
      'Camera scan': 'कैमरा से स्कैन',
      'Photo upload': 'फोटो चुनें',
      'Scan or upload photo': 'फोटो स्कैन करें या चुनें',
      'Recipe suggestions': 'रेसिपी सुझाव',
      'Ranked by what you already have. Missing ingredients show in red.': 'आपके पास मौजूद सामान के हिसाब से सुझाव। कम सामग्री लाल रंग में दिखेगी।',
      'Ingredients': 'सामग्री',
      'Add missing to cart': 'बाकी सामान कार्ट में डालें',
      'Plan': 'प्लान करें',
      'Monthly meal planner': 'महीने का मील प्लानर',
      'Breakfast': 'नाश्ता',
      'Lunch': 'दोपहर का खाना',
      'Dinner': 'रात का खाना',
      'Snacks': 'स्नैक्स',
      'Choose this meal': 'यह खाना चुनें',
      'Need to buy': 'खरीदना है',
      'In pantry': 'रसोई में है',
      'Grocery cart': 'किराना कार्ट',
      'Estimated total': 'अनुमानित कुल',
      'Cart is empty.\nAdd missing items from the Recipes tab.': 'कार्ट खाली है।\nरेसिपी टैब से बाकी सामान जोड़ें।',
      'Evening reminder': 'शाम का रिमाइंडर',
      'Add an item…  e.g. Methi': 'सामान जोड़ें… जैसे मेथी',
      'Pantry is empty — scan or add items': 'रसोई खाली है — स्कैन करें या सामान जोड़ें',
      'Potato': 'आलू',
      'Onion': 'प्याज़',
      'Tomato': 'टमाटर',
      'Rice': 'चावल',
      'Atta': 'आटा',
      'Eggs': 'अंडे',
      'Paneer': 'पनीर',
      'Coriander': 'धनिया',
      'Cumin': 'जीरा',
      'Salt': 'नमक',
      'Oil': 'तेल',
      'Garlic': 'लहसुन',
      'Ginger': 'अदरक',
      'Green chilli': 'हरी मिर्च',
      'Cauliflower': 'फूलगोभी',
      'Cabbage': 'पत्ता गोभी',
      'Carrot': 'गाजर',
      'Peas': 'मटर',
      'Lemon': 'नींबू',
      'Curd': 'दही',
      'Butter': 'मक्खन',
      'Turmeric': 'हल्दी',
      'Moong dal': 'मूंग दाल',
      'Chana dal': 'चना दाल',
      'Black chickpeas': 'काला चना',
      'Soya chunks': 'सोया चंक्स',
      'Lauki': 'लौकी',
      'Capsicum': 'शिमला मिर्च',
      'Cucumber': 'खीरा',
      'Brinjal': 'बैंगन',
      'Palak': 'पालक',
      'Banana': 'केला',
      'Bread': 'ब्रेड',
      'Toor dal': 'अरहर दाल',
      'Cream': 'क्रीम',
      'Coconut': 'नारियल',
      'Besan': 'बेसन',
      'Masoor dal': 'मसूर दाल',
      'Roasted chana': 'भुना चना',
      'Chilli powder': 'लाल मिर्च पाउडर',
      'Pack: 1 kg': 'पैक: 1 किलो',
      'Pack: 5 kg': 'पैक: 5 किलो',
      'Pack: 10 kg': 'पैक: 10 किलो',
      'Vegetable Poha': 'सब्ज़ी पोहा',
      'Aloo Paratha': 'आलू पराठा',
      'Besan Chilla': 'बेसन चीला',
      'Vegetable Upma': 'सब्ज़ी उपमा',
      'Egg Bhurji Toast': 'अंडा भुर्जी टोस्ट',
      'Vegetable Dalia': 'सब्ज़ी दलिया',
      'Idli with Chutney': 'चटनी के साथ इडली',
      'Masala Bread Sandwich': 'मसाला ब्रेड सैंडविच',
      'Dal Chawal': 'दाल चावल',
      'Rajma Chawal': 'राजमा चावल',
      'Chole Rice': 'छोले चावल',
      'Aloo Gobi with Roti': 'रोटी के साथ आलू गोभी',
      'Bhindi Masala': 'भिंडी मसाला',
      'Kadhi Chawal': 'कढ़ी चावल',
      'Seasonal Mix Veg': 'मौसमी मिक्स सब्ज़ी',
      'Soya Chunk Curry': 'सोया चंक्स करी',
      'Moong Dal Khichdi': 'मूंग दाल खिचड़ी',
      'Aloo Jeera with Roti': 'रोटी के साथ आलू जीरा',
      'Lauki Chana Dal': 'लौकी चना दाल',
      'Egg Curry': 'अंडा करी',
      'Kala Chana Curry': 'काला चना करी',
      'Vegetable Pulao': 'वेज पुलाव',
      'Masoor Dal and Roti': 'मसूर दाल और रोटी',
      'Cabbage Peas Sabzi': 'पत्ता गोभी मटर की सब्ज़ी',
      'Roasted Chana Chaat': 'भुना चना चाट',
      'Bhel Puri': 'भेल पूरी',
      'Sprouts Chaat': 'स्प्राउट्स चाट',
      'Vegetable Sandwich': 'वेज सैंडविच',
      'Masala Makhana': 'मसाला मखाना',
      'Masala Corn': 'मसाला कॉर्न',
      'Dahi Chaat': 'दही चाट',
      'Masala Peanut Chaat': 'मसाला मूंगफली चाट',
      'Paneer Butter Masala': 'पनीर बटर मसाला',
      'Palak Paneer': 'पालक पनीर',
      'Aloo Tamatar Sabzi': 'आलू टमाटर की सब्ज़ी',
      'Dal Tadka': 'दाल तड़का',
      'Jeera Rice': 'जीरा चावल',
      'Kadhi Pakora': 'कढ़ी पकौड़ा',
      'Poha': 'पोहा',
      'Sooji': 'सूजी',
      'Dalia': 'दलिया',
      'Rajma': 'राजमा',
      'Chickpeas': 'छोले',
      'Bhindi': 'भिंडी',
      'Ghee': 'घी',
      'Idli batter': 'इडली बैटर',
      'Makhana': 'मखाना',
      'Puffed rice': 'मुरमुरे',
      'Sprouts': 'अंकुरित दालें',
      'Sweet corn': 'स्वीट कॉर्न',
      'Peanuts': 'मूंगफली',
    },
    'Hinglish': {
      'Pantry': 'Rasoi',
      'Recipes': 'Recipes',
      'Planner': 'Meal Planner',
      'Cart': 'Grocery Cart',
      'Namaste 👋': 'Namaste 👋',
      'Aaj kya banau?': 'Aaj kya banau?',
      'Your pantry': 'Tumhari rasoi',
      'Camera scan': 'Camera se scan',
      'Photo upload': 'Gallery se photo',
      'Scan or upload photo': 'Photo scan karo ya upload karo',
      'Recipe suggestions': 'Recipe suggestions',
      'Ranked by what you already have. Missing ingredients show in red.': 'Jo samaan ghar mein hai uske hisaab se recipes. Missing items red mein.',
      'Ingredients': 'Ingredients / Samagri',
      'Add missing to cart': 'Missing samaan cart mein daalo',
      'Plan': 'Plan karo',
      'Monthly meal planner': 'Monthly meal planner',
      'Breakfast': 'Nashta',
      'Lunch': 'Lunch',
      'Dinner': 'Dinner',
      'Snacks': 'Snacks',
      'Choose this meal': 'Ye meal choose karo',
      'Need to buy': 'Kharidna hai',
      'In pantry': 'Ghar mein hai',
      'Grocery cart': 'Grocery cart',
      'Estimated total': 'Approx total',
      'Cart is empty.\nAdd missing items from the Recipes tab.': 'Cart khaali hai.\nRecipes tab se missing items add karo.',
      'Evening reminder': 'Shaam ka reminder',
      'Add an item…  e.g. Methi': 'Samaan add karo… jaise Methi',
      'Pantry is empty — scan or add items': 'Rasoi khaali hai — scan karo ya items add karo',
      'Potato': 'Aloo',
      'Onion': 'Pyaaz',
      'Tomato': 'Tamatar',
      'Rice': 'Chawal',
      'Atta': 'Aata',
      'Eggs': 'Ande',
      'Paneer': 'Paneer',
      'Coriander': 'Dhaniya',
      'Cumin': 'Jeera',
      'Salt': 'Namak',
      'Oil': 'Tel',
      'Garlic': 'Lehsun',
      'Ginger': 'Adrak',
      'Green chilli': 'Hari mirch',
      'Cauliflower': 'Phool gobhi',
      'Cabbage': 'Patta gobhi',
      'Carrot': 'Gajar',
      'Peas': 'Matar',
      'Lemon': 'Nimbu',
      'Curd': 'Dahi',
      'Butter': 'Butter',
      'Turmeric': 'Haldi',
      'Moong dal': 'Moong dal',
      'Chana dal': 'Chana dal',
      'Black chickpeas': 'Kala chana',
      'Soya chunks': 'Soya chunks',
      'Lauki': 'Lauki',
      'Capsicum': 'Shimla mirch',
      'Cucumber': 'Kheera',
      'Brinjal': 'Baingan',
      'Palak': 'Palak',
      'Banana': 'Kela',
      'Bread': 'Bread',
      'Toor dal': 'Arhar dal',
      'Cream': 'Cream',
      'Coconut': 'Nariyal',
      'Besan': 'Besan',
      'Masoor dal': 'Masoor dal',
      'Roasted chana': 'Bhuna chana',
      'Chilli powder': 'Lal mirch powder',
      'Pack: 1 kg': 'Pack: 1 kg',
      'Pack: 5 kg': 'Pack: 5 kg',
      'Pack: 10 kg': 'Pack: 10 kg',
      'Vegetable Poha': 'Veg poha',
      'Aloo Paratha': 'Aloo paratha',
      'Besan Chilla': 'Besan chilla',
      'Vegetable Upma': 'Veg upma',
      'Egg Bhurji Toast': 'Egg bhurji toast',
      'Vegetable Dalia': 'Veg dalia',
      'Idli with Chutney': 'Idli with chutney',
      'Masala Bread Sandwich': 'Masala bread sandwich',
      'Dal Chawal': 'Dal chawal',
      'Rajma Chawal': 'Rajma chawal',
      'Chole Rice': 'Chole rice',
      'Aloo Gobi with Roti': 'Aloo gobi roti',
      'Bhindi Masala': 'Bhindi masala',
      'Kadhi Chawal': 'Kadhi chawal',
      'Seasonal Mix Veg': 'Seasonal mix sabzi',
      'Soya Chunk Curry': 'Soya chunk curry',
      'Moong Dal Khichdi': 'Moong dal khichdi',
      'Aloo Jeera with Roti': 'Aloo jeera roti',
      'Lauki Chana Dal': 'Lauki chana dal',
      'Egg Curry': 'Egg curry',
      'Kala Chana Curry': 'Kala chana curry',
      'Vegetable Pulao': 'Veg pulao',
      'Masoor Dal and Roti': 'Masoor dal aur roti',
      'Cabbage Peas Sabzi': 'Patta gobhi matar sabzi',
      'Roasted Chana Chaat': 'Roasted chana chaat',
      'Bhel Puri': 'Bhel puri',
      'Sprouts Chaat': 'Sprouts chaat',
      'Vegetable Sandwich': 'Veg sandwich',
      'Masala Makhana': 'Masala makhana',
      'Masala Corn': 'Masala corn',
      'Dahi Chaat': 'Dahi chaat',
      'Masala Peanut Chaat': 'Masala peanut chaat',
      'Paneer Butter Masala': 'Paneer butter masala',
      'Palak Paneer': 'Palak paneer',
      'Aloo Tamatar Sabzi': 'Aloo tamatar sabzi',
      'Dal Tadka': 'Dal tadka',
      'Jeera Rice': 'Jeera rice',
      'Kadhi Pakora': 'Kadhi pakora',
      'Poha': 'Poha',
      'Sooji': 'Sooji',
      'Dalia': 'Dalia',
      'Rajma': 'Rajma',
      'Chickpeas': 'Chole',
      'Bhindi': 'Bhindi',
      'Ghee': 'Ghee',
      'Idli batter': 'Idli batter',
      'Makhana': 'Makhana',
      'Puffed rice': 'Murmure',
      'Sprouts': 'Sprouts',
      'Sweet corn': 'Sweet corn',
      'Peanuts': 'Moongfali',
    },
  };

  String t(String value) => _translations[language]?[value] ?? value;

  String displayName(String value) => t(value);

  String _canonicalIngredientKey(String name) {
    final key = name.trim().toLowerCase();
    const aliases = <String, String>{
      'aloo': 'potato', 'aaloo': 'potato', 'आलू': 'potato',
      'pyaaz': 'onion', 'pyaz': 'onion', 'प्याज': 'onion', 'प्याज़': 'onion',
      'tamatar': 'tomato', 'टमाटर': 'tomato',
      'chawal': 'rice', 'चावल': 'rice',
      'aata': 'atta', 'आटा': 'atta',
      'anda': 'eggs', 'ande': 'eggs', 'अंडा': 'eggs', 'अंडे': 'eggs',
      'dahi': 'curd', 'दही': 'curd',
      'dhaniya': 'coriander', 'धनिया': 'coriander',
      'jeera': 'cumin', 'जीरा': 'cumin',
      'namak': 'salt', 'नमक': 'salt',
      'tel': 'oil', 'तेल': 'oil',
      'lehsun': 'garlic', 'lahsun': 'garlic', 'लहसुन': 'garlic',
      'adrak': 'ginger', 'अदरक': 'ginger',
      'hari mirch': 'green chilli', 'हरी मिर्च': 'green chilli',
      'matar': 'peas', 'मटर': 'peas',
      'nimbu': 'lemon', 'नींबू': 'lemon',
      'haldi': 'turmeric', 'हल्दी': 'turmeric',
      'phool gobhi': 'cauliflower', 'फूलगोभी': 'cauliflower',
      'patta gobhi': 'cabbage', 'पत्ता गोभी': 'cabbage',
      'gajar': 'carrot', 'गाजर': 'carrot',
      'kheera': 'cucumber', 'खीरा': 'cucumber',
      'baingan': 'brinjal', 'बैंगन': 'brinjal',
      'shimla mirch': 'capsicum', 'शिमला मिर्च': 'capsicum',
      'पालक': 'palak',
      'लौकी': 'lauki',
      'मूंग दाल': 'moong dal',
      'चना दाल': 'chana dal',
      'काला चना': 'black chickpeas',
      'सोया चंक्स': 'soya chunks',
      'केला': 'banana',
      'ब्रेड': 'bread',
    };
    return aliases[key] ?? key;
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_languageStorageKey);
      if (saved == 'English' || saved == 'Hindi' || saved == 'Hinglish') {
        language = saved!;
        if (eveningReminder) await _refreshMealReminders();
        notifyListeners();
      }
    } catch (_) {
      // English remains the safe default if preferences are unavailable.
    }
  }

  Future<void> setLanguage(String value) async {
    if (!['English', 'Hindi', 'Hinglish'].contains(value) || language == value) return;
    language = value;
    if (eveningReminder) unawaited(_refreshMealReminders());
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageStorageKey, value);
    } catch (_) {
      // The selected language remains active for this session.
    }
  }

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

  String _selectionKey(DateTime date, String category) => '${dateKey(date)}|$category';

  Recipe? selectedPlannerMeal(DateTime date, String category) {
    return _plannerSelections[dateKey(date)]?[category];
  }

  bool isPlannerMealNone(DateTime date, String category) =>
      _noneSelections.contains(_selectionKey(date, category));

  bool hasExplicitPlannerSelection(DateTime date, String category) =>
      selectedPlannerMeal(date, category) != null || isPlannerMealNone(date, category);

  void selectPlannerMeal(DateTime date, String category, Recipe recipe) {
    _noneSelections.remove(_selectionKey(date, category));
    _plannerSelections.putIfAbsent(dateKey(date), () => <String, Recipe>{})[category] = recipe;
    unawaited(_savePlannerSelections());
    unawaited(_refreshMealReminders());
    notifyListeners();
  }

  void setPlannerMealNone(DateTime date, String category) {
    _plannerSelections[dateKey(date)]?.remove(category);
    _noneSelections.add(_selectionKey(date, category));
    unawaited(_savePlannerSelections());
    unawaited(_refreshMealReminders());
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
          final category = mealEntry.key as String;
          if (!PlannerCatalog.categories.containsKey(category)) continue;
          if (mealEntry.value == _noneSelection) {
            _noneSelections.add('${dateEntry.key}|$category');
            continue;
          }
          final recipe = recipesById[mealEntry.value as String];
          if (recipe != null) selections[category] = recipe;
        }
        if (selections.isNotEmpty) _plannerSelections[dateEntry.key as String] = selections;
      }
    } catch (_) {
      // Ignore malformed saved planner data and use generated suggestions.
    }
    if (eveningReminder) await _refreshMealReminders();
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
      for (final key in _noneSelections) {
        final separator = key.lastIndexOf('|');
        if (separator <= 0) continue;
        final date = key.substring(0, separator);
        final category = key.substring(separator + 1);
        data.putIfAbsent(date, () => <String, String>{})[category] = _noneSelection;
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
              displayName: value['displayName'] is String ? value['displayName'] as String : null,
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
        'quantity': item.quantity, 'unit': item.unit, 'displayName': item.displayName,
      }).toList()));
    } catch (_) {
      // Pantry still works for this session if local storage is unavailable.
    }
  }

  bool hasIngredient(String name) {
    final wanted = _canonicalIngredientKey(name);
    return _pantry.any((item) => _canonicalIngredientKey(item.name) == wanted);
  }

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
    final itemKey = _canonicalIngredientKey(item.name);
    final existing = _pantry.indexWhere((p) => _canonicalIngredientKey(p.name) == itemKey);
    if (existing >= 0) {
      final current = _pantry[existing];
      _pantry[existing] = current.copyWith(
        quantity: current.quantity + item.quantity,
        displayName: item.displayName ?? current.displayName,
      );
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
    final key = _canonicalIngredientKey(name);
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
    final itemKey = _canonicalIngredientKey(name);
    final existing = _cart.indexWhere((item) => _canonicalIngredientKey(item.name) == itemKey);
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

  void changeCartPackSize(String id, int packSize) {
    final index = _cart.indexWhere((item) => item.id == id);
    if (index < 0 || _cart[index].unit != 'kg' || ![1, 5, 10].contains(packSize)) return;
    _cart[index] = _cart[index].copyWith(packSize: packSize);
    notifyListeners();
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

  Future<void> _loadReminderSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      eveningReminder = prefs.getBool(_reminderStorageKey) ?? false;
    } catch (_) {
      eveningReminder = false;
    }
    if (eveningReminder) await _refreshMealReminders();
    notifyListeners();
  }

  void setEveningReminder(bool value) {
    eveningReminder = value;
    unawaited(_saveReminderSetting(value));
    if (value) {
      unawaited(_enableAndRefreshMealReminders());
    } else {
      unawaited(MealNotificationService.instance.cancelMealReminders());
    }
    notifyListeners();
  }

  Future<void> _saveReminderSetting(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderStorageKey, value);
    } catch (_) {
      // Keep the toggle active for this session if storage is unavailable.
    }
  }

  Future<void> _enableAndRefreshMealReminders() async {
    final granted = await MealNotificationService.instance.requestPermission();
    if (!granted) {
      eveningReminder = false;
      await _saveReminderSetting(false);
      notifyListeners();
      return;
    }
    await _refreshMealReminders();
  }

  Future<void> _refreshMealReminders() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    String? chosen(String category) {
      if (isPlannerMealNone(tomorrow, category)) return null;
      final recipe = selectedPlannerMeal(tomorrow, category);
      return recipe == null ? null : displayName(recipe.name);
    }
    await MealNotificationService.instance.schedule(
      enabled: eveningReminder,
      now: now,
      language: language,
      breakfast: chosen('Breakfast'),
      lunch: chosen('Lunch'),
      dinner: chosen('Dinner'),
      snacks: chosen('Snacks'),
    );
  }
}
