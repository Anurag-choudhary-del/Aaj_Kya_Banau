class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.emoji,
    this.amount = '',
  });

  final String name;
  final String emoji;
  final String amount;

  String get key => name.trim().toLowerCase();
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.tagline,
    required this.emoji,
    required this.minutes,
    required this.ingredients,
    this.spice = 'Medium',
  });

  final String id;
  final String name;
  final String tagline;
  final String emoji;
  final int minutes;
  final String spice;
  final List<RecipeIngredient> ingredients;
}
