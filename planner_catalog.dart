import '../models/recipe.dart';

/// Budget-friendly, mostly everyday Indian meals. Each day displays five
/// rotating choices from a larger category pool; these are suggestions, not
/// a nutrition or price guarantee.
class PlannerCatalog {
  static const categories = <String, List<Recipe>>{
    'Breakfast': [
      Recipe(id: 'b-poha', name: 'Vegetable Poha', tagline: 'Light poha with seasonal vegetables', emoji: '🍋', minutes: 20, ingredients: [
        RecipeIngredient(name: 'Poha', emoji: '🍚', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '1'), RecipeIngredient(name: 'Lemon', emoji: '🍋', amount: '1/2'),
      ]),
      Recipe(id: 'b-paratha', name: 'Aloo Paratha', tagline: 'Homemade potato-stuffed paratha', emoji: '🫓', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '2'), RecipeIngredient(name: 'Atta', emoji: '🌾', amount: '1 cup'), RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '1'), RecipeIngredient(name: 'Curd', emoji: '🥛', amount: 'to serve'),
      ]),
      Recipe(id: 'b-chilla', name: 'Besan Chilla', tagline: 'Quick savoury gram-flour pancakes', emoji: '🥞', minutes: 20, ingredients: [
        RecipeIngredient(name: 'Besan', emoji: '🌾', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'), RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '1'),
      ]),
      Recipe(id: 'b-upma', name: 'Vegetable Upma', tagline: 'Semolina with vegetables and spices', emoji: '🥣', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Sooji', emoji: '🌾', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Carrot', emoji: '🥕', amount: '1'), RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '1 tbsp'),
      ]),
      Recipe(id: 'b-egg', name: 'Egg Bhurji Toast', tagline: 'Protein-rich quick breakfast', emoji: '🍳', minutes: 15, ingredients: [
        RecipeIngredient(name: 'Eggs', emoji: '🥚', amount: '2'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'), RecipeIngredient(name: 'Bread', emoji: '🍞', amount: '2 slices'),
      ]),
      Recipe(id: 'b-dalia', name: 'Vegetable Dalia', tagline: 'Filling broken-wheat porridge', emoji: '🥣', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Dalia', emoji: '🌾', amount: '1/2 cup'), RecipeIngredient(name: 'Peas', emoji: '🫛', amount: '1/4 cup'), RecipeIngredient(name: 'Carrot', emoji: '🥕', amount: '1'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'),
      ]),
      Recipe(id: 'b-idli', name: 'Idli with Chutney', tagline: 'Steamed breakfast; batter may be store-bought', emoji: '⚪', minutes: 20, ingredients: [
        RecipeIngredient(name: 'Idli batter', emoji: '🥣', amount: '2 cups'), RecipeIngredient(name: 'Coconut', emoji: '🥥', amount: '1/4'), RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '1'), RecipeIngredient(name: 'Salt', emoji: '🧂', amount: 'to taste'),
      ]),
      Recipe(id: 'b-sandwich', name: 'Masala Bread Sandwich', tagline: 'Potato and vegetable filling', emoji: '🥪', minutes: 15, ingredients: [
        RecipeIngredient(name: 'Bread', emoji: '🍞', amount: '4 slices'), RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '1'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'),
      ]),
    ],
    'Lunch': [
      Recipe(id: 'l-dal-rice', name: 'Dal Chawal', tagline: 'Everyday dal and rice', emoji: '🍛', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Toor dal', emoji: '🫘', amount: '1/2 cup'), RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'), RecipeIngredient(name: 'Garlic', emoji: '🧄', amount: '2 cloves'),
      ]),
      Recipe(id: 'l-rajma', name: 'Rajma Chawal', tagline: 'Kidney beans with rice', emoji: '🫘', minutes: 45, ingredients: [
        RecipeIngredient(name: 'Rajma', emoji: '🫘', amount: '1 cup'), RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '2'),
      ]),
      Recipe(id: 'l-chole', name: 'Chole Rice', tagline: 'Chickpeas in homestyle masala', emoji: '🍲', minutes: 40, ingredients: [
        RecipeIngredient(name: 'Chickpeas', emoji: '🫘', amount: '1 cup'), RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '2'),
      ]),
      Recipe(id: 'l-aloo-gobi', name: 'Aloo Gobi with Roti', tagline: 'Seasonal cauliflower and potato', emoji: '🥦', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '2'), RecipeIngredient(name: 'Cauliflower', emoji: '🥦', amount: '1/2'), RecipeIngredient(name: 'Atta', emoji: '🌾', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
      ]),
      Recipe(id: 'l-bhindi', name: 'Bhindi Masala', tagline: 'Simple okra sabzi with roti', emoji: '🥬', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Bhindi', emoji: '🥬', amount: '250 g'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Atta', emoji: '🌾', amount: '1 cup'), RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '1 tbsp'),
      ]),
      Recipe(id: 'l-kadhi', name: 'Kadhi Chawal', tagline: 'Tangy curd-and-besan kadhi', emoji: '🫕', minutes: 40, ingredients: [
        RecipeIngredient(name: 'Curd', emoji: '🥛', amount: '1 cup'), RecipeIngredient(name: 'Besan', emoji: '🌾', amount: '3 tbsp'), RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'), RecipeIngredient(name: 'Turmeric', emoji: '🌼', amount: '1/2 tsp'),
      ]),
      Recipe(id: 'l-mixveg', name: 'Seasonal Mix Veg', tagline: 'Use whichever vegetables are affordable', emoji: '🥕', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '1'), RecipeIngredient(name: 'Carrot', emoji: '🥕', amount: '1'), RecipeIngredient(name: 'Peas', emoji: '🫛', amount: '1/4 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
      ]),
      Recipe(id: 'l-soya', name: 'Soya Chunk Curry', tagline: 'Budget-friendly protein with rice or roti', emoji: '🍲', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Soya chunks', emoji: '🫘', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '2'), RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'),
      ]),
    ],
    'Dinner': [
      Recipe(id: 'd-khichdi', name: 'Moong Dal Khichdi', tagline: 'One-pot light and comforting meal', emoji: '🍲', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1/2 cup'), RecipeIngredient(name: 'Moong dal', emoji: '🫘', amount: '1/2 cup'), RecipeIngredient(name: 'Turmeric', emoji: '🌼', amount: '1/2 tsp'), RecipeIngredient(name: 'Ghee', emoji: '🧈', amount: '1 tsp'),
      ]),
      Recipe(id: 'd-aloojeera', name: 'Aloo Jeera with Roti', tagline: 'Quick potato sabzi for busy evenings', emoji: '🥔', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '3'), RecipeIngredient(name: 'Cumin', emoji: '🌿', amount: '1 tsp'), RecipeIngredient(name: 'Atta', emoji: '🌾', amount: '1 cup'), RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '1 tbsp'),
      ]),
      Recipe(id: 'd-lauki', name: 'Lauki Chana Dal', tagline: 'Simple seasonal bottle-gourd curry', emoji: '🥒', minutes: 35, ingredients: [
        RecipeIngredient(name: 'Lauki', emoji: '🥒', amount: '1'), RecipeIngredient(name: 'Chana dal', emoji: '🫘', amount: '1/2 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'),
      ]),
      Recipe(id: 'd-egg', name: 'Egg Curry', tagline: 'Affordable curry with boiled eggs', emoji: '🥚', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Eggs', emoji: '🥚', amount: '4'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '2'), RecipeIngredient(name: 'Garlic', emoji: '🧄', amount: '3 cloves'),
      ]),
      Recipe(id: 'd-kala-chana', name: 'Kala Chana Curry', tagline: 'Filling black chickpea curry', emoji: '🫘', minutes: 40, ingredients: [
        RecipeIngredient(name: 'Black chickpeas', emoji: '🫘', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'), RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'),
      ]),
      Recipe(id: 'd-veg-pulao', name: 'Vegetable Pulao', tagline: 'One-pot rice with seasonal vegetables', emoji: '🥘', minutes: 30, ingredients: [
        RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'), RecipeIngredient(name: 'Carrot', emoji: '🥕', amount: '1'), RecipeIngredient(name: 'Peas', emoji: '🫛', amount: '1/4 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
      ]),
      Recipe(id: 'd-masoor', name: 'Masoor Dal and Roti', tagline: 'Fast red lentil dal', emoji: '🍲', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Masoor dal', emoji: '🫘', amount: '1/2 cup'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'), RecipeIngredient(name: 'Garlic', emoji: '🧄', amount: '2 cloves'), RecipeIngredient(name: 'Atta', emoji: '🌾', amount: '1 cup'),
      ]),
      Recipe(id: 'd-cabbage', name: 'Cabbage Peas Sabzi', tagline: 'Low-cost seasonal sabzi', emoji: '🥬', minutes: 25, ingredients: [
        RecipeIngredient(name: 'Cabbage', emoji: '🥬', amount: '1/2'), RecipeIngredient(name: 'Peas', emoji: '🫛', amount: '1/4 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'), RecipeIngredient(name: 'Atta', emoji: '🌾', amount: '1 cup'),
      ]),
    ],
    'Snacks': [
      Recipe(id: 's-chana', name: 'Roasted Chana Chaat', tagline: 'Low-cost crunchy snack', emoji: '🥜', minutes: 10, ingredients: [
        RecipeIngredient(name: 'Roasted chana', emoji: '🥜', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'), RecipeIngredient(name: 'Lemon', emoji: '🍋', amount: '1/2'),
      ]),
      Recipe(id: 's-bhel', name: 'Bhel Puri', tagline: 'Puffed rice with chutney and vegetables', emoji: '🥣', minutes: 10, ingredients: [
        RecipeIngredient(name: 'Puffed rice', emoji: '🍚', amount: '2 cups'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'), RecipeIngredient(name: 'Lemon', emoji: '🍋', amount: '1/2'),
      ]),
      Recipe(id: 's-sprouts', name: 'Sprouts Chaat', tagline: 'Fresh sprouts with lemon and onion', emoji: '🌱', minutes: 10, ingredients: [
        RecipeIngredient(name: 'Sprouts', emoji: '🌱', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'), RecipeIngredient(name: 'Lemon', emoji: '🍋', amount: '1/2'),
      ]),
      Recipe(id: 's-sandwich', name: 'Vegetable Sandwich', tagline: 'Bread with simple seasonal filling', emoji: '🥪', minutes: 15, ingredients: [
        RecipeIngredient(name: 'Bread', emoji: '🍞', amount: '4 slices'), RecipeIngredient(name: 'Cucumber', emoji: '🥒', amount: '1'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'), RecipeIngredient(name: 'Butter', emoji: '🧈', amount: '1 tbsp'),
      ]),
      Recipe(id: 's-makhana', name: 'Masala Makhana', tagline: 'Roasted fox nuts, lightly spiced', emoji: '🍿', minutes: 10, ingredients: [
        RecipeIngredient(name: 'Makhana', emoji: '🍿', amount: '2 cups'), RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '1 tsp'), RecipeIngredient(name: 'Turmeric', emoji: '🌼', amount: '1 pinch'), RecipeIngredient(name: 'Salt', emoji: '🧂', amount: 'to taste'),
      ]),
      Recipe(id: 's-corn', name: 'Masala Corn', tagline: 'Sweet corn with lemon and spices', emoji: '🌽', minutes: 12, ingredients: [
        RecipeIngredient(name: 'Sweet corn', emoji: '🌽', amount: '1 cup'), RecipeIngredient(name: 'Butter', emoji: '🧈', amount: '1 tsp'), RecipeIngredient(name: 'Lemon', emoji: '🍋', amount: '1/2'), RecipeIngredient(name: 'Salt', emoji: '🧂', amount: 'to taste'),
      ]),
      Recipe(id: 's-dahi', name: 'Dahi Chaat', tagline: 'Curd with potato and simple spices', emoji: '🥣', minutes: 10, ingredients: [
        RecipeIngredient(name: 'Curd', emoji: '🥛', amount: '1 cup'), RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '1'), RecipeIngredient(name: 'Cumin', emoji: '🌿', amount: '1/2 tsp'), RecipeIngredient(name: 'Chilli powder', emoji: '🌶️', amount: 'to taste'),
      ]),
      Recipe(id: 's-peanut', name: 'Masala Peanut Chaat', tagline: 'Peanuts tossed with onion and lemon', emoji: '🥜', minutes: 10, ingredients: [
        RecipeIngredient(name: 'Peanuts', emoji: '🥜', amount: '1 cup'), RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1/2'), RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1/2'), RecipeIngredient(name: 'Lemon', emoji: '🍋', amount: '1/2'),
      ]),
    ],
  };

  static List<Recipe> optionsForDay(String category, int day) {
    final all = categories[category] ?? const <Recipe>[];
    if (all.length <= 5) return all;
    final start = (day - 1) % all.length;
    return List<Recipe>.generate(5, (i) => all[(start + i) % all.length]);
  }

  static Recipe defaultForDay(String category, int day) {
    final options = categories[category]!;
    return options[(day - 1) % options.length];
  }
}
